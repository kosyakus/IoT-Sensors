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
#import <CoreBluetooth/CoreBluetooth.h>
#import "IotDeviceSpec.h"
#import "BluetoothManager.h"
#import "IotSensorsManager.h"
#import "ChartDataEntryBuffer.h"


enum {
    DEVICE_TYPE_UNKNOWN = -1,
    DEVICE_TYPE_IOT_580 = 0,
    DEVICE_TYPE_WEARABLE = 1,
    DEVICE_TYPE_IOT_585 = 2,
    DEVICE_TYPE_MAX = 2,
};

#define IOT_SENSORS_GRAPH_DATA_SIZE 100


@interface IotSensorsDevice : NSObject

@property BluetoothManager* bluetoothManager;
@property IotSensorsManager* manager;
@property CBPeripheral* peripheral;
@property NSString* name;
@property NSUUID* uuid;
@property NSString* version;
@property NSString* ekid;
@property (readonly) CBPeripheralState state;

@property int type;
@property IotDeviceSpec* spec;
@property NSArray* sensorMenuLayout;
@property NSString* model;
@property NSString* texture;
@property IotDeviceFeatures* features;
@property IotDeviceSettings* basicSettings;
@property IotDeviceSettings* calibrationModesSettings;
@property IotDeviceSettings* proximityHysteresisSettings;
@property CalibrationSettings* calibrationSettings;
@property IotDeviceSettings* sensorFusionSettings;
@property BOOL isNewVersion;
@property BOOL cloudSupport;
@property BOOL sflEnabled;
@property BOOL isStarted;
@property int calibrationState;
@property BOOL oneShotModeSelected;
@property BOOL oneShotMode;
@property BOOL integrationEngine;

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

@property ChartDataEntryBuffer* temperatureGraphData;
@property ChartDataEntryBuffer* pressureGraphData;
@property ChartDataEntryBuffer* humidityGraphData;
@property ChartDataEntryBuffer* ambientLightGraphData;
@property ChartDataEntryBuffer* airQualityGraphData;
@property ChartDataEntryBuffer3D* accelerometerGraphData;
@property ChartDataEntryBuffer3D* gyroscopeGraphData;
@property ChartDataEntryBuffer3D* magnetometerGraphData;

- (id)initWithPeripheral:(CBPeripheral*)peripheral type:(int)type ekid:(NSString*)ekid;
- (void) initSpec;
- (void) initSensorGraphs;

- (void) connect;
- (void) disconnect;
- (void) startActivationSequence;

- (IotSettingsManager*) basicSettingsManager;
- (IotSettingsManager*) calibrationSettingsManager;
- (IotSettingsManager*) sensorFusionSettingsManager;

- (int) getCalibrationMode:(int)sensor;
- (int) getAutoCalibrationMode:(int)sensor;

- (void) processActuationMessage:(DataMsg*)msg;

@end
