/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotPlus585.h"
#import "IotSensorsDevice.h"
#import "SensorFusion.h"
#import "ButtonSensor.h"
#import "BasicSettingsIotPlus.h"
#import "CalibrationModesSettings.h"
#import "ProximityHysteresisSettings.h"
#import "CalibrationSettingsV2.h"
#import "SensorFusionSettings.h"
#import "BasicSettingsManagerIotPlus.h"
#import "BasicSettings.h"
#import "BluetoothDefines.h"

@interface SensorFusion_IotPlus585 : SensorFusion {
    int16_t raw[4];
}
@end

@implementation SensorFusion_IotPlus585

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

@interface ButtonSensor_IotPlus585 : ButtonSensor
@end

@implementation ButtonSensor_IotPlus585

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    uint32_t ID = 0;
    [data getBytes:&ID range:NSMakeRange(offset + 2, 4)];
    self.ID = CFSwapInt32LittleToHost(ID);
    uint8_t state = 0;
    [data getBytes:&state range:NSMakeRange(offset, 1)];
    self.state = state != 0;
    self.value = [[IotSensorValue alloc] initWithValue:self.state ? 1 : 0];
    return self.value;
}

@end


static NSArray* SENSOR_MENU_LAYOUT;

@implementation IotPlus585

+ (void) initialize {
    if (self != [IotPlus585 class])
        return;

    SENSOR_MENU_LAYOUT = @[
                           @{ @"title" : @"Датчики", @"view" : @"EnvironmentalSensorViewController" },
                           @{ @"title" : @"IMU Датчики", @"view" : @"ImuSensorViewController" },
                           ]; /*@[
            @{ @"title" : @"Environmental Sensors", @"view" : @"EnvironmentalSensorViewController" },
            @{ @"title" : @"IMU Sensors", @"view" : @"ImuSensorViewController" },
    ];*/
}

- (id)initWithDevice:(IotSensorsDevice *)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    self.deviceType = DEVICE_TYPE_IOT_585;
    self.isNewVersion = TRUE;
    self.cloudSupport = TRUE;
    self.sensorMenuLayout = SENSOR_MENU_LAYOUT;
    //Natali changed
    
    self.model = @"Turn_left.obj"; //@"iot585.obj";
    self.texture = @"CylinderSurface_Color.png"; //@"iot585_texture_mirror.png";
    
    //self.model = @"iot585.obj";
    //self.texture = @"iot585_texture_mirror.png";

    self.environmental = [[BME680 alloc] init];
    self.imu = [[ICM40605 alloc] init];
    self.magneto = [[AK09915C alloc] init];
    self.light = [[VCNL4010 alloc] init];

    self.basicSettings = [[BasicSettingsIotPlus alloc] initWithDevice:device];
    self.calibrationModesSettings = [[CalibrationModesSettings alloc] initWithDevice:device];
    self.proximityHysteresisSettings = [[ProximityHysteresisSettings alloc] initWithDevice:device];
    self.calibrationSettings = [[CalibrationSettingsV2 alloc] initWithDevice:device];
    self.sensorFusionSettings = [[SensorFusionSettings alloc] initWithDevice:device];

    __weak typeof(self) weakSelf = self;
    self.basicSettings.processCallback = ^{
        BasicSettingsIotPlus* basicSettings = (BasicSettingsIotPlus*) weakSelf.basicSettings;

        [weakSelf.imu processAccelerometerRawConfigRange:basicSettings.accRange];

        BOOL sfl = weakSelf.device.sflEnabled && basicSettings.sflEnabled;
        [weakSelf.imu processGyroscopeRawConfigRange:basicSettings.gyroRange rate:!sfl ? basicSettings.gyroRate : 0];
        if (sfl) {
            weakSelf.gyroscope.rate = basicSettings.sflRate;
        }

        weakSelf.device.integrationEngine = weakSelf.device.features.hasIntegrationEngine && basicSettings.rawDataType == 2;
        if (weakSelf.device.integrationEngine) {
            [weakSelf.accelerometerIntegration setIntegrationRate:basicSettings.sflRate sensorRate:[weakSelf.imu getAccelerometerRateFromRawConfig:basicSettings.accRate]];
            [weakSelf.gyroscopeAngleIntegration setIntegrationRate:basicSettings.sflRate sensorRate:[weakSelf.imu getGyroscopeRateFromRawConfig:basicSettings.gyroRate]];
            [weakSelf.gyroscopeQuaternionIntegration setIntegrationRate:basicSettings.sflRate sensorRate:[weakSelf.imu getGyroscopeRateFromRawConfig:basicSettings.gyroRate]];
        }
    };

    self.temperatureSensor = self.environmental.temperatureSensor;
    self.humiditySensor = self.environmental.humiditySensor;
    self.pressureSensor = self.environmental.pressureSensor;
    self.accelerometer = self.imu.accelerometer;
    self.accelerometerIntegration = [[AccelerometerIntegration alloc] init];
    self.gyroscope = self.imu.gyroscope;
    self.gyroscopeAngleIntegration = [[GyroscopeAngleIntegration alloc] init];
    self.gyroscopeQuaternionIntegration = [[GyroscopeQuaternionIntegration alloc] init];
    self.magnetometer = self.magneto.magnetometer;
    self.ambientLightSensor = self.light.ambientLightSensor;
    self.proximitySensor = self.light.proximitySensor;
    self.gasSensor = self.environmental.gasSensor;
    self.airQualitySensor = self.environmental.airQualitySensor;
    self.sensorFusion = [[SensorFusion_IotPlus585 alloc] init];
    self.buttonSensor = [[ButtonSensor_IotPlus585 alloc] init];
    return self;
}

- (void) startActivationSequence {
    [self.device.manager readFeatures]; // old
    [self.device.manager sendReadFeaturesCommand]; // new
    [self.device.manager sendReadVersionCommand];
    [self.device.manager sendReadConfigCommand]; // before start
    [self.device.manager sendStartCommand];
    [self.device.manager sendCalReadCommand];
    [self.device.manager sendSflReadCommand];
    [self.device.manager sendReadCalibrationModesCommand];
    [self.device.manager sendReadProximityHysteresisCommand];
}

- (IotSettingsManager*) basicSettingsManager {
    return [[BasicSettingsManagerIotPlus alloc] initWithDevice:self.device];
}

- (int) getCalibrationMode:(int)sensor {
    CalibrationModesSettings* settings = (CalibrationModesSettings*) self.calibrationModesSettings;
    switch (sensor) {
        case SENSOR_TYPE_ACCELEROMETER:
            return settings.accCalMode;
        case SENSOR_TYPE_GYROSCOPE:
            return settings.gyroCalMode;
        case SENSOR_TYPE_MAGNETOMETER:
            return settings.magnetoCalMode;
        default:
            return CALIBRATION_MODE_NONE;
    }
}

- (int) getAutoCalibrationMode:(int)sensor {
    CalibrationModesSettings* settings = (CalibrationModesSettings*) self.calibrationModesSettings;
    switch (sensor) {
        case SENSOR_TYPE_ACCELEROMETER:
            return settings.accAutoCalMode;
        case SENSOR_TYPE_GYROSCOPE:
            return settings.gyroAutoCalMode;
        case SENSOR_TYPE_MAGNETOMETER:
            return settings.magnetoAutoCalMode;
        default:
            return CALIBRATION_AUTO_MODE_BASIC;
    }
}

- (void)processActuationEvent:(DataEvent*)event {
    if (event.EventType != eActuationTypes_Leds)
        return;
    if ([event.Data isEqualToString:@"true"])
        [self.device.manager sendStartLedBlinkCommand];
    else if ([event.Data isEqualToString:@"false"])
        [self.device.manager sendStopLedBlinkCommand];
}

@end
