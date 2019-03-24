/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <Foundation/Foundation.h>
#import "TemperatureSensor.h"
#import "HumiditySensor.h"
#import "PressureSensor.h"
#import "Accelerometer.h"
#import "AccelerometerIntegration.h"
#import "Gyroscope.h"
#import "GyroscopeAngleIntegration.h"
#import "GyroscopeQuaternionIntegration.h"
#import "Magnetometer.h"
#import "AmbientLightSensor.h"
#import "ProximitySensor.h"
#import "GasSensor.h"
#import "AirQualitySensor.h"
#import "SensorFusion.h"
#import "ButtonSensor.h"
#import "IotDeviceFeatures.h"
#import "IotDeviceSettings.h"
#import "CalibrationSettings.h"
#import "IotSettingsManager.h"
#import "InternalAPI.h"
@class IotSensorsDevice;

@interface IotDeviceSpec : NSObject

+ (IotDeviceSpec*) getDeviceSpec:(IotSensorsDevice*)device;
+ (int) getDeviceTypeFromAdvName:(NSString*)name;
+ (BOOL) isRawProjectFromAdvName:(NSString*)name;
+ (NSString*) getProperNameFromAdvName:(NSString*)name;
+ (NSString*) getDeviceIcon:(int)type;

@property (weak) IotSensorsDevice* device;
@property int deviceType;
@property BOOL isNewVersion;
@property BOOL cloudSupport;
@property NSArray* sensorMenuLayout;
@property NSString* model;
@property NSString* texture;

@property TemperatureSensor* temperatureSensor;
@property HumiditySensor* humiditySensor;
@property PressureSensor* pressureSensor;
@property Accelerometer* accelerometer;
@property AccelerometerIntegration* accelerometerIntegration;
@property Gyroscope* gyroscope;
@property GyroscopeAngleIntegration* gyroscopeAngleIntegration;
@property GyroscopeQuaternionIntegration* gyroscopeQuaternionIntegration;
@property Magnetometer* magnetometer;
@property AmbientLightSensor* ambientLightSensor;
@property ProximitySensor* proximitySensor;
@property GasSensor* gasSensor;
@property AirQualitySensor* airQualitySensor;
@property SensorFusion* sensorFusion;
@property ButtonSensor* buttonSensor;

@property IotDeviceFeatures* features;
@property IotDeviceSettings* basicSettings;
@property IotDeviceSettings* calibrationModesSettings;
@property IotDeviceSettings* proximityHysteresisSettings;
@property CalibrationSettings* calibrationSettings;
@property IotDeviceSettings* sensorFusionSettings;

- (id) initWithDevice:(IotSensorsDevice*)device;
- (void) startActivationSequence;

- (IotSettingsManager*) basicSettingsManager;
- (IotSettingsManager*) calibrationSettingsManager;
- (IotSettingsManager*) sensorFusionSettingsManager;

- (int) getCalibrationMode:(int)sensor;
- (int) getAutoCalibrationMode:(int)sensor;

- (void) processActuationEvent:(DataEvent*)event;

@end
