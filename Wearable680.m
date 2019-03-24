/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "Wearable680.h"
#import "IotSensorsDevice.h"
#import "SensorFusion.h"
#import "BasicSettings.h"
#import "CalibrationSettingsV2.h"
#import "SensorFusionSettings.h"
#import "BasicSettingsManager.h"

@interface SensorFusion_Wearable680 : SensorFusion {
    int16_t raw[4];
}
@end

@implementation SensorFusion_Wearable680

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [self get4DValuesLE:raw data:data offset:offset];
    qx = -raw[0] / 32768.f;
    qy = -raw[1] / 32768.f;
    qz = raw[2] / 32768.f;
    qw = raw[3] / 32768.f;
    self.quaternion = [[IotSensorValue4D alloc] initWithX:qx Y:qy Z:qz W:qw];
    [self sensorFusionCalculation];
    return self.value;
}

@end


static const float SENSOR_FUSION_RATES[] = { 0.78f, 1.56f, 3.12f, 6.25f, 12.5f, 25.f, 50.f };


@implementation Wearable680

- (id)initWithDevice:(IotSensorsDevice *)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.deviceType = DEVICE_TYPE_WEARABLE;
    self.isNewVersion = TRUE;
    self.cloudSupport = FALSE;
    self.model = @"Dialog_Watch2.obj";
    self.texture = @"Dialog_Watch_new_TXT_mirror.jpg";

    self.environmental = [[BME280 alloc] init];
    self.imu = [[BMI160 alloc] init];
    self.magneto = [[BMM150 alloc] init];

    self.basicSettings = [[BasicSettings alloc] initWithDevice:device];
    self.calibrationSettings = [[CalibrationSettingsV2 alloc] initWithDevice:device];
    self.sensorFusionSettings = [[SensorFusionSettings alloc] initWithDevice:device];

    __weak typeof(self) weakSelf = self;
    self.basicSettings.processCallback = ^{
        BasicSettings* basicSettings = (BasicSettings*) weakSelf.basicSettings;

        [weakSelf.imu processAccelerometerRawConfigRange:basicSettings.accRange];

        BOOL sfl = weakSelf.device.sflEnabled && basicSettings.sflEnabled;
        [weakSelf.imu processGyroscopeRawConfigRange:basicSettings.gyroRange rate:!sfl ? basicSettings.gyroRate : 0];
        if (sfl) {
            weakSelf.gyroscope.rate = SENSOR_FUSION_RATES[basicSettings.sflRate - 1];
        }
    };

    self.temperatureSensor = self.environmental.temperatureSensor;
    self.humiditySensor = self.environmental.humiditySensor;
    self.pressureSensor = self.environmental.pressureSensor;
    self.accelerometer = self.imu.accelerometer;
    self.gyroscope = self.imu.gyroscope;
    self.magnetometer = self.magneto.magnetometer;
    self.sensorFusion = [[SensorFusion_Wearable680 alloc] init];
    return self;
}

- (IotSettingsManager*) basicSettingsManager {
    return [[BasicSettingsManager alloc] initWithDevice:self.device];
}

- (int) getCalibrationMode:(int)sensor {
    return [(BasicSettings*) self.basicSettings calMode];
}

- (int) getAutoCalibrationMode:(int)sensor {
    return [(BasicSettings*) self.basicSettings autoCalMode];
}

@end
