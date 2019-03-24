/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotDeviceSpec.h"
#import "IotSensorsDevice.h"
#import "IotDongle580.h"
#import "Wearable680.h"
#import "IotPlus585.h"
#import "SensorFusionSettingsManager.h"
#import "CalibrationSettingsManager.h"
#import "BluetoothDefines.h"

static NSString* const PATTERN_IOT_580 = @".*IoT-DK.*";
static NSString* const PATTERN_WEARABLE = @".*(?:WRBL|Wearable).*";
static NSString* const PATTERN_IOT_585 = @".*(?:585|IoT-Plus|Multi|IoT\\+).*";
static NSString* const PATTERN_RAW_PROJECT = @".*-RAW.*";
static NSRegularExpression* MATCHER_IOT_580;
static NSRegularExpression* MATCHER_WEARABLE;
static NSRegularExpression* MATCHER_IOT_585;
static NSRegularExpression* MATCHER_RAW_PROJECT;

@implementation IotDeviceSpec

+ (void) initialize {
    if (self != [IotDeviceSpec class])
        return;

    MATCHER_IOT_580 = [NSRegularExpression regularExpressionWithPattern:PATTERN_IOT_580 options:NSRegularExpressionCaseInsensitive error:nil];
    MATCHER_WEARABLE = [NSRegularExpression regularExpressionWithPattern:PATTERN_WEARABLE options:NSRegularExpressionCaseInsensitive error:nil];
    MATCHER_IOT_585 = [NSRegularExpression regularExpressionWithPattern:PATTERN_IOT_585 options:NSRegularExpressionCaseInsensitive error:nil];
    MATCHER_RAW_PROJECT = [NSRegularExpression regularExpressionWithPattern:PATTERN_RAW_PROJECT options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (IotDeviceSpec*) getDeviceSpec:(IotSensorsDevice*)device {
    switch (device.type) {
        case DEVICE_TYPE_IOT_580:
            return [[IotDongle580 alloc] initWithDevice:device];
        case DEVICE_TYPE_WEARABLE:
            return [[Wearable680 alloc] initWithDevice:device];
        case DEVICE_TYPE_IOT_585:
            return [[IotPlus585 alloc] initWithDevice:device];
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported device type" userInfo:nil];
    }
}

+ (int) getDeviceTypeFromAdvName:(NSString*)name {
    if ([MATCHER_IOT_580 numberOfMatchesInString:name options:0 range:NSMakeRange(0, name.length)])
        return DEVICE_TYPE_IOT_580;
    if ([MATCHER_WEARABLE numberOfMatchesInString:name options:0 range:NSMakeRange(0, name.length)])
        return DEVICE_TYPE_WEARABLE;
    if ([MATCHER_IOT_585 numberOfMatchesInString:name options:0 range:NSMakeRange(0, name.length)])
        return DEVICE_TYPE_IOT_585;
    return DEVICE_TYPE_IOT_580;
}


+ (BOOL) isRawProjectFromAdvName:(NSString*)name {
    return [MATCHER_RAW_PROJECT numberOfMatchesInString:name options:0 range:NSMakeRange(0, name.length)] != 0;
}

+ (NSString*) getProperNameFromAdvName:(NSString*)name {
    if ([name compare:@"IoT-DK-SFL" options:NSCaseInsensitiveSearch] == NSOrderedSame || [name compare:@"IoT-DK-RAW" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return @"IoT Sensor DK";
    if ([name compare:@"Dialog WRBL" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return @"Wearable DK";
    if ([name compare:@"IoT-585" options:NSCaseInsensitiveSearch] == NSOrderedSame
            || [name compare:@"IoT-Plus" options:NSCaseInsensitiveSearch] == NSOrderedSame
            || [name compare:@"IoT-Multi" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return @"IoT Multi Sensor DK";
    return name;
}

+ (NSString*) getDeviceIcon:(int)type {
    switch (type) {
        case DEVICE_TYPE_IOT_580:
            return @"icon-580.png";
        case DEVICE_TYPE_WEARABLE:
            return @"icon-680.png";
        case DEVICE_TYPE_IOT_585:
            return @"icon-585.png";
        default:
            return nil;
    }
}


- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super init];
    if (!self)
        return nil;
    self.device = device;
    self.features = [[IotDeviceFeatures alloc] initWithDevice:device];
    return self;
}

- (void) startActivationSequence {
    [self.device.manager readFeatures];
    [self.device.manager sendReadConfigCommand]; // before start
    [self.device.manager sendStartCommand];
    [self.device.manager sendCalReadCommand];
    [self.device.manager sendSflReadCommand];
}

- (IotSettingsManager*) basicSettingsManager {
    return nil;
}

- (IotSettingsManager*) calibrationSettingsManager {
    return [[CalibrationSettingsManager alloc] initWithDevice:self.device];
}

- (IotSettingsManager*) sensorFusionSettingsManager {
    return [[SensorFusionSettingsManager alloc] initWithDevice:self.device];
}

- (int) getCalibrationMode:(int)sensor {
    return CALIBRATION_MODE_NONE;
}

- (int) getAutoCalibrationMode:(int)sensor {
    return CALIBRATION_AUTO_MODE_BASIC;
}

- (void) processActuationEvent:(DataEvent*)event {
}

@end
