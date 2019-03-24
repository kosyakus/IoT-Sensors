
/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSettingsManager.h"
#import "IotSensorsDevice.h"
#import "BasicSensorConfigurationTableViewController.h"


static NSArray* sensorFusionCombinationLabels;
static NSArray* sensorFusionCombinationValues;
static NSArray* imuSensorCombinationLabels;
static NSArray* imuSensorCombinationValues;
static NSArray* accelerometerRangeLabels;
static NSArray* accelerometerRangeValues;
static NSArray* accelerometerRateLabels;
static NSArray* accelerometerRateValues;
static NSArray* gyroscopeRangeLabels;
static NSArray* gyroscopeRangeValues;
static NSArray* gyroscopeRateLabels;
static NSArray* gyroscopeRateValues;
static NSArray* gyroscopeRateLabelsRaw;
static NSArray* gyroscopeRateValuesRaw;
static NSArray* magnetometerRateLabels;
static NSArray* magnetometerRateValues;
static NSArray* magnetometerRateLabels680;
static NSArray* magnetometerRateValues680;
static NSArray* environmentalRateLabels;
static NSArray* environmentalRateValues;
static NSArray* sensorFusionRateLabels;
static NSArray* sensorFusionRateValues;
static NSArray* sensorFusionRateLabels680;
static NSArray* sensorFusionRateValues680;
static NSArray* calibrationModeLabels;
static NSArray* calibrationModeValues;
static NSArray* autoCalibrationModeLabels;
static NSArray* autoCalibrationModeValues;


@implementation BasicSettingsManager

+ (void) initialize {
    if (self != [BasicSettingsManager class])
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
            @"Magnetometer",
            @"Accelerometer + Magnetometer",
            @"Gyroscope + Magnetometer",
            @"All"
    ];
    imuSensorCombinationValues = @[ @0, @1, @2, @3, @4, @5, @6, @7 ];

    accelerometerRangeLabels = @[
            @"2G",
            @"4G",
            @"8G",
            @"16G"
    ];
    accelerometerRangeValues = @[ @3, @5, @8, @12 ];

    accelerometerRateLabels = @[
            @"0.78Hz",
            @"1.56Hz",
            @"3.12Hz",
            @"6.25Hz",
            @"12.5Hz",
            @"25Hz",
            @"50Hz",
            @"100Hz"
    ];
    accelerometerRateValues = @[ @1, @2, @3, @4, @5, @6, @7, @8 ];

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
            @"100Hz"
    ];
    gyroscopeRateValues = @[ @6, @7, @8 ];

    gyroscopeRateLabelsRaw = @[
            @"0.78Hz",
            @"1.56Hz",
            @"3.12Hz",
            @"6.25Hz",
            @"12.5Hz",
            @"25Hz",
            @"50Hz",
            @"100Hz"
    ];
    gyroscopeRateValuesRaw = @[ @1, @2, @3, @4, @5, @6, @7, @8 ];

    magnetometerRateLabels = @[
            @"Accelerometer Rate",
            @"Accelerometer Rate / 2",
            @"Accelerometer Rate / 4",
            @"Accelerometer Rate / 8"
    ];
    magnetometerRateValues = @ [ @0, @1, @3, @7 ];

    magnetometerRateLabels680 = @[
            @"0.78Hz",
            @"1.56Hz",
            @"3.12Hz",
            @"6.25Hz",
            @"12.5Hz",
            @"25Hz",
            @"50Hz",
            @"100Hz"
    ];
    magnetometerRateValues680 = @[ @1, @2, @3, @4, @5, @6, @7, @8 ];

    environmentalRateLabels = @[
            @"0.5Hz",
            @"1Hz",
            @"2Hz"
    ];
    environmentalRateValues = @[ @1, @2, @4 ];

    sensorFusionRateLabels = @[
            @"10Hz",
            @"15Hz",
            @"20Hz",
            @"25Hz"
    ];
    sensorFusionRateValues = @[ @10, @15, @20, @25 ];

    sensorFusionRateLabels680 = @[
            @"0.78Hz",
            @"1.56Hz",
            @"3.12Hz",
            @"6.25Hz",
            @"12.5Hz",
            @"25Hz",
            @"50Hz"
    ];
    sensorFusionRateValues680 = @[ @1, @2, @3, @4, @5, @6, @7 ];

    calibrationModeLabels = @[
            @"None",
            @"Static",
            @"Continuous Auto",
            @"One-Shot Auto"
    ];
    calibrationModeValues = @[ @0, @1, @2, @3 ];

    autoCalibrationModeLabels = @[
            @"Basic",
            @"SmartFusion"
    ];
    autoCalibrationModeValues = @[ @0, @1 ];
}

- (NSArray*) specIotDongle {
    return @[
            [IotSettingsItem listWithKey:@"SensorCombination" labels:sensorFusionCombinationLabels values:sensorFusionCombinationValues value:@7],
            [IotSettingsItem switchWithKey:@"EnvironmentalSensorsEnabled"],
            [IotSettingsItem listWithKey:@"AccelerometerRange" labels:accelerometerRangeLabels values:accelerometerRangeValues],
            [IotSettingsItem listWithKey:@"AccelerometerRate" labels:accelerometerRateLabels values:accelerometerRateValues],
            [IotSettingsItem listWithKey:@"GyroscopeRange" labels:gyroscopeRangeLabels values:gyroscopeRangeValues],
            [IotSettingsItem listWithKey:@"GyroscopeRate" labels:gyroscopeRateLabels values:gyroscopeRateValues],
            [IotSettingsItem listWithKey:@"MagnetometerRate" labels:magnetometerRateLabels values:magnetometerRateValues],
            [IotSettingsItem listWithKey:@"EnvironmentalRate" labels:environmentalRateLabels values:environmentalRateValues],
            [IotSettingsItem listWithKey:@"SensorFusionRate" labels:sensorFusionRateLabels values:sensorFusionRateValues],
            [IotSettingsItem switchWithKey:@"SensorFusionRawEnabled"],
            [IotSettingsItem listWithKey:@"CalibrationMode" labels:calibrationModeLabels values:calibrationModeValues],
            [IotSettingsItem listWithKey:@"AutoCalibrationMode" labels:autoCalibrationModeLabels values:autoCalibrationModeValues],
    ];
}

- (NSArray*) specWearable {
    return @[
            [IotSettingsItem listWithKey:@"SensorCombination" labels:sensorFusionCombinationLabels values:sensorFusionCombinationValues value:@7],
            [IotSettingsItem switchWithKey:@"EnvironmentalSensorsEnabled"],
            [IotSettingsItem listWithKey:@"AccelerometerRange" labels:accelerometerRangeLabels values:accelerometerRangeValues],
            [IotSettingsItem listWithKey:@"AccelerometerRate" labels:accelerometerRateLabels values:accelerometerRateValues],
            [IotSettingsItem listWithKey:@"GyroscopeRange" labels:gyroscopeRangeLabels values:gyroscopeRangeValues],
            [IotSettingsItem listWithKey:@"GyroscopeRate" labels:gyroscopeRateLabels values:gyroscopeRateValues],
            [IotSettingsItem listWithKey:@"MagnetometerRate" labels:magnetometerRateLabels680 values:magnetometerRateValues680],
            [IotSettingsItem listWithKey:@"EnvironmentalRate" labels:environmentalRateLabels values:environmentalRateValues],
            [IotSettingsItem switchWithKey:@"SensorFusionEnabled"],
            [IotSettingsItem listWithKey:@"SensorFusionRate" labels:sensorFusionRateLabels680 values:sensorFusionRateValues680],
            [IotSettingsItem switchWithKey:@"SensorFusionRawEnabled"],
            [IotSettingsItem listWithKey:@"CalibrationMode" labels:calibrationModeLabels values:calibrationModeValues],
            [IotSettingsItem listWithKey:@"AutoCalibrationMode" labels:autoCalibrationModeLabels values:autoCalibrationModeValues],
    ];
}

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    NSArray* items = nil;
    switch (device.type) {
        case DEVICE_TYPE_IOT_580:
            items = [self specIotDongle];
            break;
        case DEVICE_TYPE_WEARABLE:
            items = [self specWearable];
            break;
        default:
            return nil;
    }
    [self initSpec:items];

    IotSettingsItem* i;
    // Update spec for RAW project
    if (!self.device.sflEnabled) {
        i = self.spec[@"GyroscopeRate"];
        i.labels = gyroscopeRateLabelsRaw;
        i.values = gyroscopeRateValuesRaw;
        i = self.spec[@"SensorFusionRate"];
        i.text = @"Not supported";
        i = self.spec[@"SensorFusionRawEnabled"];
        i.text = @"Not supported";
    }

    self.settings = device.basicSettings;
    if (self.settings.valid) {
        [self.settings save:self.spec];
        [self updateUI];
    }

    return self;
}

- (void) readConfiguration {
    [self.device.manager sendReadConfigCommand];
}

- (BOOL) processConfigurationReport:(int)command data:(NSData*)data {
    if (command != DIALOG_WEARABLES_COMMAND_CONFIGURATION_READ)
        return false;
    [self.settings save:self.spec];
    [self updateUI];
    return true;
}

- (BOOL) updateValues {
    [super updateValues];

    [self.settings load:self.spec];
    NSData* data = [self.settings pack];
    if (self.settings.modified) {
        [self.device.manager sendWriteConfigCommand:data];
        [self.device.manager sendReadConfigCommand];
        return true;
    }

    return false;
}

- (void) updateUI {
    IotSettingsItem* i;
    if (self.device.sflEnabled) {
        i = self.spec[@"SensorFusionEnabled"];
        BOOL sflEnabled = self.device.type == DEVICE_TYPE_IOT_580 || i.value.boolValue;

        i = self.spec[@"SensorCombination"];
        i.cell.textLabel.text = sflEnabled ? @"Sensor Fusion Combination" : @"IMU Sensor Combination";
        i.labels = sflEnabled ? sensorFusionCombinationLabels : imuSensorCombinationLabels;
        i.values = sflEnabled ? sensorFusionCombinationValues : imuSensorCombinationValues;

        i = self.spec[@"SensorFusionRate"];
        i.enabled = !self.device.isStarted && sflEnabled;
        i = self.spec[@"SensorFusionRawEnabled"];
        i.enabled = !self.device.isStarted && sflEnabled;

        i = self.spec[@"MagnetometerRate"];
        i.enabled = !self.device.isStarted && !sflEnabled;
        i.text = sflEnabled ? @"Not supported" : nil;
    } else {
        i = self.spec[@"SensorFusionRate"];
        i.enabled = false;
        i = self.spec[@"SensorFusionRawEnabled"];
        i.enabled = false;
    }
    [super updateUI];
}

@end
