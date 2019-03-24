/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotDeviceFeatures.h"
#import "IotSensorsDevice.h"
#import "BluetoothDefines.h"
#import "CalibrationSettingsV1.h"
#import "CalibrationSettingsV2.h"

@implementation IotDeviceFeatures

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super init];
    if (!self)
        return nil;

    self.device = device;
    self.hasTemperature = TRUE;
    self.hasHumidity = TRUE;
    self.hasPressure = TRUE;
    self.hasAccelerometer = TRUE;
    self.hasGyroscope = TRUE;
    self.hasMagnetometer = TRUE;
    self.hasAmbientLight = FALSE;
    self.hasProximity = FALSE;
    self.hasProximityCalibration = FALSE;
    self.hasAirQuality = FALSE;
    self.hasRawGas = FALSE;
    self.hasGasSensor = FALSE;
    self.hasButton = FALSE;
    self.hasSensorFusion = FALSE;
    self.hasIntegrationEngine = FALSE;
    self.valid = FALSE;
    return self;
}

- (void) processFeaturesReport:(NSData*)data offset:(int)offset {
    self.rawFeatures = [data subdataWithRange:NSMakeRange(offset, data.length - offset)];
    const uint8_t* rawFeatures = self.rawFeatures.bytes;
    NSMutableSet* features = [NSMutableSet setWithCapacity:self.rawFeatures.length];
    for (int i = 0; i < self.rawFeatures.length; ++i)
        [features addObject:@(rawFeatures[i])];
    self.features = [NSSet setWithSet:features];

    self.hasTemperature = [self hasFeature:IOT_SENSORS_FEATURE_TEMPERATURE];
    self.hasHumidity = [self hasFeature:IOT_SENSORS_FEATURE_HUMIDITY];
    self.hasPressure = [self hasFeature:IOT_SENSORS_FEATURE_PRESSURE];
    self.hasAccelerometer = [self hasFeature:IOT_SENSORS_FEATURE_ACCELEROMETER];
    self.hasGyroscope = [self hasFeature:IOT_SENSORS_FEATURE_GYROSCOPE];
    self.hasMagnetometer = [self hasFeature:IOT_SENSORS_FEATURE_MAGNETOMETER];
    self.hasAmbientLight = [self hasFeature:IOT_SENSORS_FEATURE_AMBIENT_LIGHT];
    self.hasProximity = [self hasFeature:IOT_SENSORS_FEATURE_PROXIMITY];
    self.hasProximityCalibration = [self hasFeature:IOT_SENSORS_FEATURE_PROXIMITY_CALIBRATION];
    self.hasRawGas = [self hasFeature:IOT_SENSORS_FEATURE_RAW_GAS];
    self.hasAirQuality = [self hasFeature:IOT_SENSORS_FEATURE_AIR_QUALITY];
    self.hasGasSensor = self.hasRawGas || self.hasAirQuality;
    self.hasButton = [self hasFeature:IOT_SENSORS_FEATURE_BUTTON];
    self.hasSensorFusion = [self hasFeature:IOT_SENSORS_FEATURE_SENSOR_FUSION];
    self.hasIntegrationEngine = [self hasFeature:IOT_SENSORS_FEATURE_INTEGRATION_ENGINE];
    NSLog(@"Sensor fusion: %@", self.hasSensorFusion ? @"true" : @"false");
    self.device.sflEnabled = self.hasSensorFusion;
    self.valid = true;
}

- (void) processFeaturesCharacteristic:(NSData*)data {
    IotSensorsDevice* device = self.device;
    const uint8_t* features = data.bytes;

    self.hasAccelerometer = features[0] == 1;
    self.hasGyroscope = features[1] == 1;
    self.hasMagnetometer = features[2] == 1;
    self.hasPressure = features[3] == 1;
    self.hasHumidity = features[4] == 1;
    self.hasTemperature = features[5] == 1;
    self.hasSensorFusion = features[6] == 1;
    NSLog(@"Sensor fusion: %@", self.hasSensorFusion ? @"true" : @"false");
    device.sflEnabled = self.hasSensorFusion;

    // Get device type
    if (data.length > 23) {
        device.type = features[23];
    } else {
        NSLog(@"Features truncated, no device type available");
    }
    if (device.type == DEVICE_TYPE_UNKNOWN || device.type > DEVICE_TYPE_MAX) {
        NSLog(@"Unsupported device type (%d), assuming IoT dongle", device.type);
        device.type = DEVICE_TYPE_IOT_580;
    }

    // Get firmware version
    char version[17] = { 0 };
    memcpy(version, features + 7, 16);
    device.version = [NSString stringWithUTF8String:version];
    NSLog(@"Device version: %@", device.version);

    [device initSpec];
    // Init version dependent stuff
    if (device.type == DEVICE_TYPE_IOT_580) {
        device.isNewVersion = device.spec.isNewVersion = [@"5.160.1.20" compare:device.version options:NSNumericSearch] != NSOrderedDescending;
        NSLog(@"IoT dongle firmware: %@", device.isNewVersion ? @"new" : @"old");
        if (!device.calibrationSettings)
            device.calibrationSettings = device.spec.calibrationSettings = device.isNewVersion
                                                                            ? [[CalibrationSettingsV2 alloc] initWithDevice:device]
                                                                            : [[CalibrationSettingsV1 alloc] initWithDevice:device];
    }

    if (device.type == DEVICE_TYPE_IOT_580 || device.type == DEVICE_TYPE_WEARABLE) {
        self.valid = true;
    }
}

- (BOOL) hasFeature:(int)feature {
    return [self.features containsObject:@(feature)];
}

@end
