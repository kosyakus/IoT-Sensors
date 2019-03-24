/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CalibrationModesSettings.h"
#import "IotSensorsDevice.h"
#import "IotSettingsManager.h"
#import "BluetoothDefines.h"

@implementation CalibrationModesSettings

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.length = 6;
    return self;
}

- (void) packModes {
    self.accCalMode = self.accMode / 2;
    if (self.accCalMode > CALIBRATION_MODE_STATIC)
        self.accAutoCalMode = self.accMode % 2;
    self.gyroCalMode = self.gyroMode / 2;
    if (self.gyroCalMode > CALIBRATION_MODE_STATIC)
        self.gyroAutoCalMode = self.gyroMode % 2;
    self.magnetoCalMode = self.magnetoMode / 2;
    if (self.magnetoCalMode > CALIBRATION_MODE_STATIC)
        self.magnetoAutoCalMode = self.magnetoMode % 2;
}

- (void) unpackModes {
    self.accMode = 2 * self.accCalMode;
    if (self.accCalMode > CALIBRATION_MODE_STATIC)
        self.accMode += self.accAutoCalMode;
    self.gyroMode = 2 * self.gyroCalMode;
    if (self.gyroCalMode > CALIBRATION_MODE_STATIC)
        self.gyroMode += self.gyroAutoCalMode;
    self.magnetoMode = 2 * self.magnetoCalMode;
    if (self.magnetoCalMode > CALIBRATION_MODE_STATIC)
        self.magnetoMode += self.magnetoAutoCalMode;
}

- (void) process:(NSData*)data offset:(int)offset {
    self.raw = [data subdataWithRange:NSMakeRange(offset, self.length)];
    const uint8_t* raw = self.raw.bytes;

    self.accCalMode = raw[0];
    self.gyroCalMode = raw[1];
    self.magnetoCalMode = raw[2];
    self.accAutoCalMode = raw[3];
    self.gyroAutoCalMode = raw[4];
    self.magnetoAutoCalMode = raw[5];
    [self unpackModes];
    self.valid = true;

    if (self.processCallback)
        self.processCallback();
}

- (NSData*) pack {
    uint8_t raw[] = {
        self.accCalMode,
        self.gyroCalMode,
        self.magnetoCalMode,
        self.accAutoCalMode,
        self.gyroAutoCalMode,
        self.magnetoAutoCalMode
    };

    self.modified = memcmp(self.raw.bytes, raw, self.length) != 0;
    return [NSData dataWithBytes:raw length:self.length];
}

- (void) save:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"AccelerometerCalibrationMode"];
    i.value = @(self.accMode);
    i = spec[@"GyroscopeCalibrationMode"];
    i.value = @(self.gyroMode);
    i = spec[@"MagnetometerCalibrationMode"];
    i.value = @(self.magnetoMode);
}

- (void) load:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"AccelerometerCalibrationMode"];
    self.accMode = i.value.intValue;
    i = spec[@"GyroscopeCalibrationMode"];
    self.gyroMode = i.value.intValue;
    i = spec[@"MagnetometerCalibrationMode"];
    self.magnetoMode = i.value.intValue;
    [self packModes];
}

@end
