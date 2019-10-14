/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotDongle580.h"
#import "IotSensorsDevice.h"
#import "SensorFusion.h"
#import "BasicSettings.h"
#import "CalibrationSettingsV1.h"
#import "CalibrationSettingsV2.h"
#import "SensorFusionSettings.h"
#import "BasicSettingsManager.h"

@interface SensorFusion_IotDongle580 : SensorFusion {
    int16_t raw[4];
}
@end

@implementation SensorFusion_IotDongle580

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [self get4DValuesLE:raw data:data offset:offset];
    qx = raw[0] / 32768.f;
    qy = raw[1] / 32768.f;
    qz = raw[2] / 32768.f;
    qw = raw[3] / 32768.f;
    self.quaternion = [[IotSensorValue4D alloc] initWithX:qx Y:qy Z:qz W:qw];
    [self sensorFusionCalculation];
    return self.value;
}

@end


@implementation IotDongle580

- (id)initWithDevice:(IotSensorsDevice *)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.deviceType = DEVICE_TYPE_IOT_580;
    self.cloudSupport = FALSE;
    self.model = @"Audi_R8_2017.obj"; //@"DIAGR_DW_Final_Dcase.obj";
    self.texture = @"Audi_R8_2017.1.png"; //@"pattern.png";
    //self.model = @"Turn_left.obj"; //@"iot585.obj";
    //self.texture = @"CylinderSurface_Color.png";
    
    self.environmental = [[BME280 alloc] init];
    self.imu = [[BMI160 alloc] init];
    self.magneto = [[BMM150 alloc] init];

    self.basicSettings = [[BasicSettings alloc] initWithDevice:device];
    self.sensorFusionSettings = [[SensorFusionSettings alloc] initWithDevice:device];

    __weak typeof(self) weakSelf = self;
    self.basicSettings.processCallback = ^{
        BasicSettings* basicSettings = (BasicSettings*) weakSelf.basicSettings;

        // Workaround for old IoT firmware bug. The range setting isn't effective.
        // We keep the default sensitivity, which corresponds to 2G range.
        if (weakSelf.isNewVersion)
            [weakSelf.imu processAccelerometerRawConfigRange:basicSettings.accRange];

        [weakSelf.imu processGyroscopeRawConfigRange:basicSettings.gyroRange rate:!weakSelf.device.sflEnabled ? basicSettings.gyroRate : 0];
        if (weakSelf.device.sflEnabled) {
            weakSelf.gyroscope.rate = basicSettings.sflRate;
        }
    };

    self.temperatureSensor = self.environmental.temperatureSensor;
    self.humiditySensor = self.environmental.humiditySensor;
    self.pressureSensor = self.environmental.pressureSensor;
    self.accelerometer = self.imu.accelerometer;
    self.gyroscope = self.imu.gyroscope;
    self.magnetometer = self.magneto.magnetometer;
    self.sensorFusion = [[SensorFusion_IotDongle580 alloc] init];
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
