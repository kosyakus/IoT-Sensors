/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSettings.h"
#import "IotSensorsDevice.h"

@implementation BasicSettings

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.length = 11;
    self.sflCombination = -1;
    self.imuCombination = -1;
    return self;
}

- (void) unpackSensorCombination {
    if (self.sflEnabled)
        self.sflCombination = self.sensorCombination & 0x07;
    else
        self.imuCombination = self.sensorCombination & 0x07;
    if (self.sflCombination == -1)
        self.sflCombination = 7; // all
    if (self.imuCombination == -1)
        self.imuCombination = self.sflCombination;
    self.envEnabled = (self.sensorCombination & 0x08) != 0;
}

- (void) packSensorCombination {
    uint8_t sensorCombination = (self.sflEnabled ? self.sflCombination : self.imuCombination) | (self.envEnabled ? 0x08 : 0);
    self.sensorCombination = sensorCombination;
}

- (void) process:(NSData*)data offset:(int)offset {
    self.raw = [data subdataWithRange:NSMakeRange(offset, self.length)];
    const uint8_t* raw = self.raw.bytes;

    self.sensorCombination = raw[0];
    self.accRange = raw[1];
    self.accRate = raw[2];
    self.gyroRange = raw[3];
    self.gyroRate = raw[4];
    self.magnetoRate = raw[5];
    self.envRate = raw[6];
    uint8_t sflRateSetting = raw[7];
    if (self.device.type != DEVICE_TYPE_WEARABLE) {
        self.sflEnabled = self.device.sflEnabled;
        self.sflRate = sflRateSetting;
    } else {
        self.sflEnabled = sflRateSetting != 0;
        if (self.sflEnabled)
            self.sflRate = sflRateSetting;
        if (self.sflRate == 0)
            self.sflRate = 5; // 12.5Hz
    }
    self.sflRawEnabled = raw[8] != 0;
    self.calMode = raw[9];
    self.autoCalMode = raw[10];
    [self unpackSensorCombination];
    self.valid = true;

    if (self.processCallback)
        self.processCallback();
}

- (NSData*) pack {
    [self packSensorCombination];
    uint8_t raw[] = {
        self.sensorCombination,
        self.accRange,
        self.accRate,
        self.gyroRange,
        self.gyroRate,
        self.magnetoRate,
        self.envRate,
        self.sflEnabled ? self.sflRate : 0,
        self.sflRawEnabled ? 1 : 0,
        self.calMode,
        self.autoCalMode
    };

    self.modified = memcmp(self.raw.bytes, raw, self.length) != 0;
    return [NSData dataWithBytes:raw length:self.length];
}

- (void) save:(NSDictionary*)spec {
    IotSettingsItem* i;
    i = spec[@"SensorCombination"];
    i.value = @(self.sflEnabled ? self.sflCombination : self.imuCombination);
    i = spec[@"EnvironmentalSensorsEnabled"];
    i.value = @(self.envEnabled);
    i = spec[@"AccelerometerRange"];
    i.value = @(self.accRange);
    i = spec[@"AccelerometerRate"];
    i.value = @(self.accRate);
    i = spec[@"GyroscopeRange"];
    i.value = @(self.gyroRange);
    i = spec[@"GyroscopeRate"];
    i.value = @(self.gyroRate);
    i = spec[@"MagnetometerRate"];
    i.value = @(self.magnetoRate);
    i = spec[@"EnvironmentalRate"];
    i.value = @(self.envRate);
    i = spec[@"SensorFusionEnabled"];
    i.value = @(self.sflEnabled);
    i = spec[@"SensorFusionRate"];
    i.value = @(self.sflRate);
    i = spec[@"SensorFusionRawEnabled"];
    i.value = @(self.sflRawEnabled);
    i = spec[@"CalibrationMode"];
    i.value = @(self.calMode);
    i = spec[@"AutoCalibrationMode"];
    i.value = @(self.autoCalMode);
}

- (void) load:(NSDictionary*)spec {
    IotSettingsItem* i;
    // In case sensor fusion state is changed, use previous state to select the correct variable.
    i = spec[@"SensorCombination"];
    if (self.sflEnabled)
        self.sflCombination = i.value.intValue;
    else
        self.imuCombination =  i.value.intValue;
    i = spec[@"EnvironmentalSensorsEnabled"];
    self.envEnabled = i.value.boolValue;
    i = spec[@"AccelerometerRange"];
    self.accRange = i.value.unsignedCharValue;
    i = spec[@"AccelerometerRate"];
    self.accRate = i.value.unsignedCharValue;
    i = spec[@"GyroscopeRange"];
    self.gyroRange = i.value.unsignedCharValue;
    i = spec[@"GyroscopeRate"];
    self.gyroRate = i.value.unsignedCharValue;
    i = spec[@"MagnetometerRate"];
    self.magnetoRate = i.value.unsignedCharValue;
    i = spec[@"EnvironmentalRate"];
    self.envRate = i.value.unsignedCharValue;
    i = spec[@"SensorFusionEnabled"];
    if (self.device.type == DEVICE_TYPE_WEARABLE)
        self.sflEnabled = i.value.boolValue;
    i = spec[@"SensorFusionRate"];
    self.sflRate = i.value.unsignedCharValue;
    i = spec[@"SensorFusionRawEnabled"];
    self.sflRawEnabled = i.value.boolValue;
    i = spec[@"CalibrationMode"];
    self.calMode = i.value.unsignedCharValue;
    i = spec[@"AutoCalibrationMode"];
    self.autoCalMode = i.value.unsignedCharValue;
    [self packSensorCombination];
}

@end
