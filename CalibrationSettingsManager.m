/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CalibrationSettingsManager.h"
#import "IotSensorsDevice.h"
#import "BluetoothDefines.h"
#import "iniparser.h"


@interface CalibrationCoefficients : NSObject

- (uint8_t) sensor;
- (uint8_t) format;
- (const int16_t*) offset;
- (int16_t (*)[3]) matrix;

- (id) initWithData:(NSData*)data;
- (void) unpack:(NSData*)data;
- (NSData*) pack;
- (id) initWithFile:(NSString*)file;
- (BOOL) writeToFile:(NSString*)file;

@end


static NSArray* magnetometerCalibrationModeLabels;
static NSArray* magnetometerCalibrationModeValues;

@implementation CalibrationSettingsManager

+ (void)initialize {
    magnetometerCalibrationModeLabels = @[
            @"None",
            @"Static",
            @"Continuous Auto",
            @"Continuous Auto (SmartFusion)",
            @"One-Shot Auto",
            @"One-Shot Auto (SmartFusion)"
    ];
    magnetometerCalibrationModeValues = @[ @0, @2, @4, @5, @6, @7 ];
}

- (NSArray*) specV1 {
    return @[
            [IotSettingsItem listWithKey:@"CurrentCalibrationMode" labels:magnetometerCalibrationModeLabels values:magnetometerCalibrationModeValues],
            [IotSettingsItem switchWithKey:@"Apply"],
            [IotSettingsItem switchWithKey:@"MatrixApply"],
            [IotSettingsItem switchWithKey:@"Update"],
            [IotSettingsItem switchWithKey:@"MatrixUpdate"],
            [IotSettingsItem switchWithKey:@"InitializeFromStaticCoeffs"],
            [IotSettingsItem numericWithKey:@"ReferenceMagnitude" min:0 max:32767 title:@"Reference Magnitude" message:@"Enter the reference magnitude, [0..32767]"],
            [IotSettingsItem numericWithKey:@"MagnitudeRange" min:0 max:32768 title:@"Magnitude Range" message:@"Enter the magnitude range, [0..32768]"],
            [IotSettingsItem numericWithKey:@"Mu" min:-32768 max:0 title:@"Mu" message:@"Enter mu, [-32768..0]"],
    ];
}

- (NSArray*) specV2 {
    return @[
            [IotSettingsItem listWithKey:@"CurrentCalibrationMode" labels:magnetometerCalibrationModeLabels values:magnetometerCalibrationModeValues],
            [IotSettingsItem switchWithKey:@"Apply"],
            [IotSettingsItem switchWithKey:@"MatrixApply"],
            [IotSettingsItem switchWithKey:@"Update"],
            [IotSettingsItem switchWithKey:@"MatrixUpdate"],
            [IotSettingsItem switchWithKey:@"InitializeFromStaticCoeffs"],
            [IotSettingsItem numericWithKey:@"ReferenceMagnitude" min:0 max:32767 title:@"Reference Magnitude" message:@"Enter the reference magnitude, [0..32767]"],
            [IotSettingsItem numericWithKey:@"MagnitudeRange" min:0 max:32768 title:@"Magnitude Range" message:@"Enter the magnitude range, [0..32768]"],
            [IotSettingsItem numericWithKey:@"MagnitudeAlpha" min:0 max:32768 title:@"Magnitude Alpha" message:@"Enter Magnitude Alpha, [0..32768]"],
            [IotSettingsItem numericWithKey:@"MagnitudeGradientThreshold" min:0 max:32768 title:@"Magnitude Gradient Threshold" message:@"Enter Magnitude Gradient Threshold, [0..32768]"],
            [IotSettingsItem numericWithKey:@"OffsetMu" min:0 max:32768 title:@"Offset Mu" message:@"Enter Offset Mu, [0..32768]"],
            [IotSettingsItem numericWithKey:@"MatrixMu" min:0 max:32768 title:@"Matrix Mu" message:@"Enter Matrix Mu, [0..32768]"],
            [IotSettingsItem numericWithKey:@"ErrorAlpha" min:0 max:32768 title:@"Error Alpha" message:@"Enter Error Alpha, [0..32768]"],
            [IotSettingsItem numericWithKey:@"ErrorThreshold" min:0 max:32768 title:@"Error Threshold" message:@"Enter Error Threshold, [0..32768]"],
    ];
}

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    NSArray* items = self.device.isNewVersion ? self.specV2 : self.specV1;
    [self initSpec:items];
    [(IotSettingsItem*) self.spec[@"CurrentCalibrationMode"] setReadOnly:true];

    [self initCalibrationMode];
    self.settings = device.calibrationSettings;
    if (self.settings.valid) {
        [self.settings save:self.spec];
        [self updateUI];
    }

    return self;
}

- (void) initCalibrationMode {
    int calMode = [self.device getCalibrationMode:SENSOR_TYPE_MAGNETOMETER];
    int calAutoMode = [self.device getAutoCalibrationMode:SENSOR_TYPE_MAGNETOMETER];
    self.settings.calMode = calMode;
    self.settings.calAutoMode = calAutoMode;
    [(IotSettingsItem*) self.spec[@"CurrentCalibrationMode"] setValue:@(calMode * 2 + (calMode > CALIBRATION_MODE_STATIC ? calAutoMode : 0))];
}

- (void) readConfiguration {
    if (self.device.type != DEVICE_TYPE_IOT_585)
        [self.device.manager sendReadConfigCommand];
    else
        [self.device.manager sendReadCalibrationModesCommand];
    [self.device.manager sendCalReadCommand];
}

- (void) saveCoefficients {
    [self.device.manager sendCalCoeffReadCommand];
}

- (BOOL) loadCoefficients:(NSString*)filePath {
    CalibrationCoefficients* coefficients = [[CalibrationCoefficients alloc] initWithFile:filePath];
    if (!coefficients)
        return false;
    [self.device.manager sendCalCoeffWriteCommand:[coefficients pack]];
    return true;
}

- (BOOL) processConfigurationReport:(int)command data:(NSData*)data {
    switch (command) {
        case DIALOG_WEARABLES_COMMAND_CALIBRATION_CONTROL_READ:
            [self.settings save:self.spec];
            [self updateUI];
            return true;
        case DIALOG_WEARABLES_COMMAND_CONFIGURATION_READ:
        case DIALOG_WEARABLES_COMMAND_CALIBRATION_READ_MODES:
            [self initCalibrationMode];
            [self updateUI];
            return true;
        case DIALOG_WEARABLES_COMMAND_CALIBRATION_COEFFICIENTS_READ: {
            CalibrationCoefficients* coefficients = [[CalibrationCoefficients alloc] initWithData:data];
            return [coefficients writeToFile:[self newCoefficientsFile]];
        }
        default:
            return false;
    }
}

- (BOOL) updateValues {
    [super updateValues];

    [self.settings load:self.spec];
    NSData* data = [self.settings pack];
    if (self.settings.modified) {
        [self.device.manager sendCalWriteCommand:data];
        [self.device.manager sendCalReadCommand];
        return true;
    }

    return false;
}

- (void) updateUI {
    if (!self.device.isStarted)
        [self.settings enableSettingsForCalibrationMode:self.spec];
    [(IotSettingsItem*) self.spec[@"CurrentCalibrationMode"] setEnabled:true];
    [super updateUI];
}

- (NSString*) newCoefficientsFile {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH.mm.ss";
    NSString* iso8601String = [dateFormatter stringFromDate:[NSDate date]];
    NSString* docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filePath = [docsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-calibration.ini", iso8601String]];
    return filePath;
}

@end


@implementation CalibrationCoefficients {
    uint8_t sensor;
    uint8_t format;
    int16_t offset[3];
    int16_t matrix[3][3];
}


- (uint8_t) sensor {
    return sensor;
}

- (uint8_t) format {
    return format;
}

- (const int16_t*) offset {
    return offset;
}

- (int16_t (*)[3]) matrix {
    return matrix;
}

- (id) initWithData:(NSData*)data {
    self = [super init];
    if (!self)
        return nil;

    [self unpack:data];
    return self;
}

- (void) unpack:(NSData*)data {
    [data getBytes:&sensor range:NSMakeRange(0, 1)];
    [data getBytes:&format range:NSMakeRange(1, 1)];
    [data getBytes:offset range:NSMakeRange(2, 6)];
    [data getBytes:matrix range:NSMakeRange(8, 18)];
    for (int i = 0; i < 3; ++i)
        offset[i] = CFSwapInt16LittleToHost(offset[i]);
    for (int i = 0; i < 3; ++i)
        for (int j = 0; j < 3; ++j)
            matrix[i][j] = CFSwapInt16LittleToHost(matrix[i][j]);
}

- (NSData*) pack {
    uint8_t raw[26];
    raw[0] = sensor;
    raw[1] = format;
    int16_t* raw16 = (int16_t*) (raw + 2);
    for (int i = 0; i < 3; ++i)
        *raw16++ = CFSwapInt16HostToLittle(offset[i]);
    for (int i = 0; i < 3; ++i)
        for (int j = 0; j < 3; ++j)
            *raw16++ = CFSwapInt16HostToLittle(matrix[i][j]);
    return [NSData dataWithBytes:raw length:26];
}

- (id) initWithFile:(NSString*)filePath {
    self = [super init];
    if (!self)
        return nil;

    dictionary* ini = iniparser_load(filePath.UTF8String);
    iniparser_dump(ini, stdout);

    int iniSensor = iniparser_getint(ini, "magnetometer calibration:sensor_type", -1);
    int iniFormat = iniparser_getint(ini, "magnetometer calibration:q_format", -1);
    const char *iniOffset = iniparser_getstring(ini, "magnetometer calibration:offset_vector", NULL);
    const char *iniMatrix = iniparser_getstring(ini, "magnetometer calibration:matrix", NULL);

    NSArray* offsetValues = nil;
    NSArray* matrixValues = nil;
    if (iniOffset)
        offsetValues = [[NSString stringWithUTF8String:iniOffset] componentsSeparatedByString:@","];
    if (iniMatrix)
        matrixValues = [[NSString stringWithUTF8String:iniMatrix] componentsSeparatedByString:@","];

    if (iniSensor == -1 || iniFormat == -1 || offsetValues.count != 3 || matrixValues.count != 9) {
        NSLog(@"Error loading calibration coefficients.");
        iniparser_freedict(ini);
        return nil;
    }

    sensor = iniSensor;
    format = iniFormat;
    for (int i = 0; i < 3; ++i)
        offset[i] = [offsetValues[i] intValue];
    for (int i = 0; i < 9; ++i)
        matrix[i / 3][i % 3] = [matrixValues[i] intValue];

    iniparser_freedict(ini);
    return self;
}

- (BOOL) writeToFile:(NSString*)filePath {
    dictionary* ini = dictionary_new(0);
    dictionary_set(ini, "magnetometer calibration", NULL);
    dictionary_set(ini, "magnetometer calibration:sensor_type",
            [NSString stringWithFormat:@"%d", sensor].UTF8String);
    dictionary_set(ini, "magnetometer calibration:q_format",
            [NSString stringWithFormat:@"%d", format].UTF8String);
    dictionary_set(ini, "magnetometer calibration:offset_vector",
            [NSString stringWithFormat:@"%d,%d,%d", offset[0], offset[1], offset[2]].UTF8String);
    dictionary_set(ini, "magnetometer calibration:matrix",
            [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d",
                                        matrix[0][0], matrix[0][1], matrix[0][2],
                                        matrix[1][0], matrix[1][1], matrix[1][2],
                                        matrix[2][0], matrix[2][1], matrix[2][2]].UTF8String);

    NSFileManager* fileManager = [[NSFileManager alloc] init];
    const char* path = [fileManager fileSystemRepresentationWithPath:filePath];
    FILE* file = fopen(path, "w");
    if (!file) {
        NSLog(@"Error saving calibration coefficients.");
        iniparser_freedict(ini);
        return false;
    }
    iniparser_dump_ini(ini, file);
    iniparser_freedict(ini);
    fclose(file);
    return true;
}

@end
