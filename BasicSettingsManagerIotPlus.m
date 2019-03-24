/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSettingsManagerIotPlus.h"
#import "IotSensorsDevice.h"
#import "BluetoothDefines.h"


static NSArray* sensorFusionCombinationLabels;
static NSArray* sensorFusionCombinationValues;
static NSArray* imuSensorCombinationLabels;
static NSArray* imuSensorCombinationValues;
static NSArray* operationModeLabels;
static NSArray* operationModeValues;
static NSArray* accelerometerRangeLabels;
static NSArray* accelerometerRangeValues;
static NSArray* accelerometerRateLabels;
static NSArray* accelerometerRateValues;
static NSArray* accelerometerRateLabelsSflDisabled;
static NSArray* accelerometerRateValuesSflDisabled;
static NSArray* gyroscopeRangeLabels;
static NSArray* gyroscopeRangeValues;
static NSArray* gyroscopeRateLabels;
static NSArray* gyroscopeRateValues;
static NSArray* gyroscopeRateLabelsSflDisabled;
static NSArray* gyroscopeRateValuesSflDisabled;
static NSArray* magnetometerRateLabels;
static NSArray* magnetometerRateValues;
static NSArray* environmentalRateLabels;
static NSArray* environmentalRateValues;
static NSArray* gasRateLabels;
static NSArray* gasRateValues;
static NSArray* proximityAmbientLightRateLabels;
static NSArray* proximityAmbientLightRateValues;
static NSArray* proximityAmbientLightModeLabels;
static NSArray* proximityAmbientLightModeValues;
static NSArray* sensorFusionRateLabels;
static NSArray* sensorFusionRateValues;
static NSArray* accelerometerCalibrationModeLabels;
static NSArray* accelerometerCalibrationModeValues;
static NSArray* gyroscopeCalibrationModeLabels;
static NSArray* gyroscopeCalibrationModeValues;
static NSArray* magnetometerCalibrationModeLabels;
static NSArray* magnetometerCalibrationModeValues;


@implementation BasicSettingsManagerIotPlus

+ (void) initialize {
    if (self != [BasicSettingsManagerIotPlus class])
        return;

    sensorFusionCombinationLabels = @[
            @"Gyroscope",
            @"Gyroscope + Accelerometer",
            @"Accelerometer + Magnetometer",
            @"All"
    ];
    sensorFusionCombinationValues = @[ @2, @3, @5, @7 ];

    imuSensorCombinationLabels = @[
            @"None",
            @"Accelerometer",
            @"Gyroscope",
            @"Gyroscope + Accelerometer",
            //@"Magnetometer",
            @"Accelerometer + Magnetometer",
            @"Gyroscope + Magnetometer",
            @"All"
    ];
    imuSensorCombinationValues = @[ @0, @1, @2, @3, /*@4,*/ @5, @6, @7 ];

    operationModeLabels = @[
            @"Sensor Fusion",
            @"Sensor Fusion + Integration Engine",
            @"Sensor Fusion + Raw",
            @"Integration Engine",
            @"Raw"
    ];
    operationModeValues = @[ @10, @12, @11, @2, @1 ];

    accelerometerRangeLabels = @[
            @"2G",
            @"4G",
            @"8G",
            @"16G"
    ];
    accelerometerRangeValues = @[ @3, @2, @1, @0 ];

    accelerometerRateLabels = @[
            @"25Hz",
            @"50Hz",
            @"100Hz",
            @"200Hz",
            @"1kHz"
    ];
    accelerometerRateValues = @[ @10, @9, @8, @7, @6 ];

    accelerometerRateLabelsSflDisabled = @[
            @"25Hz",
            @"50Hz",
            @"100Hz"
    ];
    accelerometerRateValuesSflDisabled = @[ @10, @9, @8 ];

    gyroscopeRangeLabels = @[
            @"2000 deg/sec",
            @"1000 deg/sec",
            @"500 deg/sec",
            @"250 deg/sec",
            @"125 deg/sec"
    ];
    gyroscopeRangeValues = @[ @0, @1, @2, @3, @4 ];

    gyroscopeRateLabels = @[
            @"25Hz",
            @"50Hz",
            @"100Hz",
            @"200Hz",
            @"1kHz"
    ];
    gyroscopeRateValues = @[ @10, @9, @8, @7, @6 ];

    gyroscopeRateLabelsSflDisabled = @[
            @"25Hz",
            @"50Hz",
            @"100Hz"
    ];
    gyroscopeRateValuesSflDisabled = @[ @10, @9, @8 ];

    magnetometerRateLabels = @[
            @"Accelerometer Rate",
            @"Accelerometer Rate / 2",
            @"Accelerometer Rate / 4",
            @"Accelerometer Rate / 8"
    ];
    magnetometerRateValues = @ [ @0, @1, @3, @7 ];

    environmentalRateLabels = @[
            @"0.33Hz",
            @"0.5Hz",
            @"1Hz",
            @"2Hz"
    ];
    environmentalRateValues = @[ @6, @4, @2, @1 ];

    gasRateLabels = @[
            @"Low power",
            @"Ultra low power"
    ];
    gasRateValues = @[ @0, @1 ];

    proximityAmbientLightRateLabels = @[
            @"0.2Hz",
            @"0.5Hz",
            @"1Hz",
            @"2Hz",
            @"5Hz",
            @"10Hz"
    ];
    proximityAmbientLightRateValues = @[ @6, @5, @4, @3, @2, @1 ];

    proximityAmbientLightModeLabels = @[
            @"OFF",
            @"Interrupt",
            @"Polling"
    ];
    proximityAmbientLightModeValues = @[ @0, @1, @2 ];

    sensorFusionRateLabels = @[
            @"10Hz",
            @"25Hz",
            @"50Hz",
            @"100Hz"
    ];
    sensorFusionRateValues = @[ @10, @25, @50, @100 ];

    accelerometerCalibrationModeLabels = @[
            @"None",
            @"Static",
            @"One-Shot Auto",
            @"One-Shot Auto (SmartFusion)"
    ];
    accelerometerCalibrationModeValues = @[ @0, @2, @6, @7 ];

    gyroscopeCalibrationModeLabels = @[
            @"None",
            @"Static",
            @"Continuous Auto (SmartFusion)",
            @"One-Shot Auto",
            @"One-Shot Auto (SmartFusion)"
    ];
    gyroscopeCalibrationModeValues = @[ @0, @2, @5, @6, @7 ];

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

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    NSArray* items = @[
            [IotSettingsItem listWithKey:@"SensorCombination" labels:sensorFusionCombinationLabels values:sensorFusionCombinationValues value:@7],
            [IotSettingsItem switchWithKey:@"EnvironmentalSensorsEnabled"],
            [IotSettingsItem switchWithKey:@"GasSensorEnabled"],
            [IotSettingsItem switchWithKey:@"AmbientLightSensorEnabled"],
            [IotSettingsItem switchWithKey:@"ProximitySensorEnabled"],
            [IotSettingsItem listWithKey:@"AccelerometerRange" labels:accelerometerRangeLabels values:accelerometerRangeValues],
            [IotSettingsItem listWithKey:@"AccelerometerRate" labels:accelerometerRateLabels values:accelerometerRateValues],
            [IotSettingsItem listWithKey:@"GyroscopeRange" labels:gyroscopeRangeLabels values:gyroscopeRangeValues],
            [IotSettingsItem listWithKey:@"GyroscopeRate" labels:gyroscopeRateLabels values:gyroscopeRateValues],
            [IotSettingsItem listWithKey:@"MagnetometerRate" labels:magnetometerRateLabels values:magnetometerRateValues],
            [IotSettingsItem listWithKey:@"EnvironmentalRate" labels:environmentalRateLabels values:environmentalRateValues],
            [IotSettingsItem listWithKey:@"GasRate" labels:gasRateLabels values:gasRateValues],
            [IotSettingsItem listWithKey:@"ProximityAmbientLightRate" labels:proximityAmbientLightRateLabels values:proximityAmbientLightRateValues],
            [IotSettingsItem listWithKey:@"ProximityMode" labels:proximityAmbientLightModeLabels values:proximityAmbientLightModeValues],
            [IotSettingsItem listWithKey:@"AmbientLightMode" labels:proximityAmbientLightModeLabels values:proximityAmbientLightModeValues],
            [IotSettingsItem listWithKey:@"OperationMode" labels:operationModeLabels values:operationModeValues],
            [IotSettingsItem switchWithKey:@"SensorFusionEnabled"],
            [IotSettingsItem listWithKey:@"SensorFusionRate" labels:sensorFusionRateLabels values:sensorFusionRateValues],
            [IotSettingsItem switchWithKey:@"SensorFusionRawEnabled"],
            [IotSettingsItem listWithKey:@"AccelerometerCalibrationMode" labels:accelerometerCalibrationModeLabels values:accelerometerCalibrationModeValues],
            [IotSettingsItem listWithKey:@"GyroscopeCalibrationMode" labels:gyroscopeCalibrationModeLabels values:gyroscopeCalibrationModeValues],
            [IotSettingsItem listWithKey:@"MagnetometerCalibrationMode" labels:magnetometerCalibrationModeLabels values:magnetometerCalibrationModeValues],
            [IotSettingsItem rangeWithKey:@"ProximityHysteresis" min:2000 max:17000 minValue:2200 maxValue:2300],
            [IotSettingsItem actionWithKey:@"ProximityCalibration"],
    ];
    [self initSpec:items];

    self.spec[@"GasRate"].hidden = true;
    self.spec[@"ProximityMode"].hidden = true;
    self.spec[@"AmbientLightMode"].hidden = true;
    self.spec[@"AccelerometerCalibrationMode"].hidden = true;
    self.spec[@"GyroscopeCalibrationMode"].hidden = true;
    self.spec[@"GasSensorEnabled"].hidden = !device.features.hasGasSensor;

    if (device.features.hasIntegrationEngine) {
        self.spec[@"SensorFusionEnabled"].hidden = true;
        self.spec[@"SensorFusionRawEnabled"].hidden = true;
    } else {
        self.spec[@"OperationMode"].hidden = true;
    }

    if (!device.features.hasProximityCalibration)
        self.spec[@"ProximityCalibration"].hidden = true;

    self.basicSettings = device.basicSettings;
    self.calibrationSettings = device.calibrationModesSettings;
    self.proximitySettings = device.proximityHysteresisSettings;
    if (self.basicSettings.valid)
        [self.basicSettings save:self.spec];
    if (self.calibrationSettings.valid)
        [self.calibrationSettings save:self.spec];
    if (self.proximitySettings.valid)
        [self.proximitySettings save:self.spec];
    if (self.basicSettings.valid || self.calibrationSettings.valid || self.basicSettings.valid)
        [self updateUI];

    return self;
}

- (void) readConfiguration {
    [self.device.manager sendReadConfigCommand];
    [self.device.manager sendReadCalibrationModesCommand];
    [self.device.manager sendReadProximityHysteresisCommand];
}

- (BOOL) processConfigurationReport:(int)command data:(NSData*)data {
    switch (command) {
        case DIALOG_WEARABLES_COMMAND_CONFIGURATION_READ:
            [self.basicSettings save:self.spec];
            [self updateUI];
            return true;
        case DIALOG_WEARABLES_COMMAND_CALIBRATION_READ_MODES:
            [self.calibrationSettings save:self.spec];
            [self updateUI];
            return true;
        case DIALOG_WEARABLES_COMMAND_PROXIMITY_HYSTERESIS_READ:
            [self.proximitySettings save:self.spec];
            [self updateUI];
            return true;
        default:
            return false;
    }
}

- (BOOL) updateValues {
    [super updateValues];
    NSData* data;
    BOOL updated = false;

    [self.basicSettings load:self.spec];
    data = [self.basicSettings pack];
    if (self.basicSettings.modified) {
        [self.device.manager sendWriteConfigCommand:data];
        [self.device.manager sendReadConfigCommand];
        updated = true;
    }

    [self.calibrationSettings load:self.spec];
    data = [self.calibrationSettings pack];
    if (self.calibrationSettings.modified) {
        [self.device.manager sendWriteCalibrationModesCommand:data];
        [self.device.manager sendReadCalibrationModesCommand];
        updated = true;
    }

    [self.proximitySettings load:self.spec];
    data = [self.proximitySettings pack];
    if (self.proximitySettings.modified) {
        [self.device.manager sendWriteProximityHysteresisCommand:data];
        [self.device.manager sendReadProximityHysteresisCommand];
        updated = true;
    }

    return updated;
}

- (void) updateUI {
    IotSettingsItem* i;
    i = self.spec[@"SensorFusionEnabled"];
    BOOL sflEnabled = i.value.boolValue;
    BOOL integrationEngine = self.device.integrationEngine;

    i = self.spec[@"SensorCombination"];
    i.cell.textLabel.text = sflEnabled ? @"Sensor Fusion Combination" : @"IMU Sensor Combination";
    i.labels = sflEnabled ? sensorFusionCombinationLabels : imuSensorCombinationLabels;
    i.values = sflEnabled ? sensorFusionCombinationValues : imuSensorCombinationValues;
    i = self.spec[@"AccelerometerRate"];
    i.labels = sflEnabled || integrationEngine ? accelerometerRateLabels : accelerometerRateLabelsSflDisabled;
    i.values = sflEnabled || integrationEngine ? accelerometerRateValues : accelerometerRateValuesSflDisabled;
    i = self.spec[@"GyroscopeRate"];
    i.labels = sflEnabled || integrationEngine ? gyroscopeRateLabels : gyroscopeRateLabelsSflDisabled;
    i.values = sflEnabled || integrationEngine ? gyroscopeRateValues : gyroscopeRateValuesSflDisabled;

    i = self.spec[@"SensorFusionRate"];
    i.enabled = !self.device.isStarted && (sflEnabled || integrationEngine);
    if (self.device.features.hasIntegrationEngine) {
        i.cell.textLabel.text = sflEnabled || !integrationEngine ? @"Sensor Fusion Rate" : @"Integration Engine Rate";
    }
    i = self.spec[@"SensorFusionRawEnabled"];
    i.enabled = !self.device.isStarted && sflEnabled;

    i = self.spec[@"MagnetometerRate"];
    i.enabled = !self.device.isStarted && !sflEnabled && !integrationEngine;
    i.text = sflEnabled || integrationEngine ? @"Not supported" : nil;

    i = self.spec[@"GasSensorEnabled"];
    BOOL gasEnabled = self.device.features.hasGasSensor && i.value.boolValue;
    i = self.spec[@"EnvironmentalRate"];
    i.enabled =  !self.device.isStarted && !gasEnabled;

    [super updateUI];
}

@end
