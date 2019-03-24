/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSettingsIotPlus.h"
#import "IotSensorsDevice.h"
#import "IotSettingsManager.h"

@implementation BasicSettingsIotPlus

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.length = 14;
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
    self.gasEnabled = (self.sensorCombination & 0x10) != 0;
    self.proxEnabled = (self.sensorCombination & 0x20) != 0;
    self.amblEnabled = (self.sensorCombination & 0x40) != 0;
}

- (void) packSensorCombination {
    uint8_t sensorCombination = (self.sflEnabled ? self.sflCombination : self.imuCombination)
                                | (self.envEnabled ? 0x08 : 0)
                                | (self.gasEnabled ? 0x10 : 0)
                                | (self.proxEnabled ? 0x20 : 0)
                                | (self.amblEnabled ? 0x40 : 0);
    self.sensorCombination = sensorCombination;
}

- (void) unpackProxAmblMode {
    self.proxMode = (self.proxAmblMode >> 2) & 0x03;
    self.amblMode = self.proxAmblMode & 0x03;
}

- (void) packProxAmblMode {
    uint8_t proxAmblMode = (self.proxMode << 2) | self.amblMode;
    self.proxAmblMode = proxAmblMode;
}

- (void) unpackOperationMode {
    self.operationMode = self.sflMode * 10 + self.rawDataType;
}

- (void) packOperationMode {
    self.sflMode = self.operationMode / 10;
    self.sflEnabled = self.sflMode != 0;
    self.rawDataType = self.operationMode % 10;
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
    if (!self.device.features.hasIntegrationEngine) {
        uint8_t sflRateSetting = raw[7];
        self.sflEnabled = sflRateSetting != 0;
        if (self.sflEnabled)
            self.sflRate = sflRateSetting;
        if (self.sflRate == 0)
            self.sflRate = 10;
        self.sflMode = raw[8];
        self.sflRawEnabled = raw[9] != 0;
    } else {
        self.sflRate = raw[7];
        self.sflMode = raw[8];
        self.sflEnabled = self.sflMode != 0;
        self.rawDataType = raw[9];
    }
    // byte 10 reserved
    self.gasRate = raw[11];
    self.proxAmblMode = raw[12];
    self.proxAmblRate = raw[13];
    [self unpackSensorCombination];
    [self unpackProxAmblMode];
    if (self.device.features.hasIntegrationEngine)
        [self unpackOperationMode];
    self.valid = true;

    if (self.processCallback)
        self.processCallback();
}

- (NSData*) pack {
    [self packSensorCombination];
    [self packProxAmblMode];
    BOOL integrationEngine = self.device.features.hasIntegrationEngine;
    if (integrationEngine)
        [self packOperationMode];
    uint8_t raw[] = {
        self.sensorCombination,
        self.accRange,
        self.sflEnabled || integrationEngine && self.rawDataType == 2 ? self.accRate : MAX(self.accRate, 8), // max 100Hz if sfl disabled
        self.gyroRange,
        self.sflEnabled || integrationEngine && self.rawDataType == 2 ? self.gyroRate : MAX(self.gyroRate, 8), // max 100Hz if sfl disabled
        self.magnetoRate,
        !self.device.features.hasGasSensor || !self.gasEnabled ? self.envRate : 6, // force 0.33Hz if gas enabled
        self.sflEnabled || integrationEngine ? self.sflRate : 0,
        self.sflMode,
        integrationEngine ? self.rawDataType : self.sflRawEnabled ? 1 : 0,
        0, // reserved
        self.gasRate,
        self.proxAmblMode,
        self.proxAmblRate,
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
    i = spec[@"GasSensorEnabled"];
    i.value = @(self.gasEnabled);
    i = spec[@"AmbientLightSensorEnabled"];
    i.value = @(self.amblEnabled);
    i = spec[@"ProximitySensorEnabled"];
    i.value = @(self.proxEnabled);
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
    i = spec[@"OperationMode"];
    i.value = @(self.operationMode);
    i = spec[@"SensorFusionEnabled"];
    i.value = @(self.sflEnabled);
    i = spec[@"SensorFusionRate"];
    i.value = @(self.sflRate);
    i = spec[@"SensorFusionRawEnabled"];
    i.value = @(self.sflRawEnabled);
    i = spec[@"GasRate"];
    i.value = @(self.gasRate);
    i = spec[@"ProximityMode"];
    i.value = @(self.proxMode);
    i = spec[@"AmbientLightMode"];
    i.value = @(self.amblMode);
    i = spec[@"ProximityAmbientLightRate"];
    i.value = @(self.proxAmblRate);
}

- (void) load:(NSDictionary*)spec {
    IotSettingsItem* i;

    // In case sensor fusion state is changed, use previous state to select the correct variable.
    i = spec[@"SensorCombination"];
    if (self.sflEnabled)
        self.sflCombination = i.value.intValue;
    else
        self.imuCombination =  i.value.intValue;
    BOOL prev = self.envEnabled;
    i = spec[@"EnvironmentalSensorsEnabled"];
    self.envEnabled = i.value.boolValue;
    if (prev != self.envEnabled && !self.envEnabled) {
        self.gasEnabled = false; // Disable gas if environmental changed to disabled.
    } else {
        prev = self.gasEnabled;
        i = spec[@"GasSensorEnabled"];
        self.gasEnabled = i.value.boolValue;
        if (prev != self.gasEnabled && self.gasEnabled)
            self.envEnabled = true; // Enable environmental if gas changed to enabled.
    }

    i = spec[@"AmbientLightSensorEnabled"];
    self.amblEnabled = i.value.boolValue;
    i = spec[@"ProximitySensorEnabled"];
    self.proxEnabled = i.value.boolValue;
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
    i = spec[@"OperationMode"];
    self.operationMode = i.value.intValue;
    i = spec[@"SensorFusionEnabled"];
    self.sflEnabled = i.value.boolValue;
    i = spec[@"SensorFusionRate"];
    self.sflRate = i.value.unsignedCharValue;
    i = spec[@"SensorFusionRawEnabled"];
    self.sflRawEnabled = i.value.boolValue;
    i = spec[@"GasRate"];
    self.gasRate = i.value.unsignedCharValue;
    i = spec[@"ProximityMode"];
    self.proxMode = i.value.intValue;
    i = spec[@"AmbientLightMode"];
    self.amblMode = i.value.intValue;
    i = spec[@"ProximityAmbientLightRate"];
    self.proxAmblRate = i.value.unsignedCharValue;

    [self packSensorCombination];
    [self packProxAmblMode];
    if (self.device.features.hasIntegrationEngine)
        [self packOperationMode];
}

@end
