/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSensorsDevice.h"
#import "AccelerometerSensorViewController.h"
#import "GyroscopeSensorViewController.h"
#import "MagnetoSensorViewController.h"
#import "FileLogger.h"

@implementation IotSensorsDevice

- (id)initWithPeripheral:(CBPeripheral*)peripheral type:(int)type ekid:(NSString*)ekid {
    self = [super init];
    if (!self)
        return nil;

    self.bluetoothManager = BluetoothManager.instance;
    self.peripheral = peripheral;
    self.name = peripheral.name;
    self.uuid = peripheral.identifier;
    self.type = type;
    self.ekid = ekid;
    [self initSpec];
    self.version = @"Unknown";
    self.calibrationState = -1;
    self.manager = [[IotSensorsManager alloc] initWithDevice:self];
    [self initSensorGraphs];
    return self;
}

- (void) initSpec {
    if (self.spec && self.type == self.spec.deviceType)
        return;

    self.spec = [IotDeviceSpec getDeviceSpec:self];

    self.sensorMenuLayout = self.spec.sensorMenuLayout;
    self.model = self.spec.model;
    self.texture = self.spec.texture;

    self.isNewVersion = self.spec.isNewVersion;
    self.cloudSupport = self.spec.cloudSupport;
    self.features = self.spec.features;
    self.basicSettings = self.spec.basicSettings;
    self.calibrationModesSettings = self.spec.calibrationModesSettings;
    self.proximityHysteresisSettings = self.spec.proximityHysteresisSettings;
    self.calibrationSettings = self.spec.calibrationSettings;
    self.sensorFusionSettings = self.spec.sensorFusionSettings;

    self.temperatureSensor = self.spec.temperatureSensor;
    self.humiditySensor = self.spec.humiditySensor;
    self.pressureSensor = self.spec.pressureSensor;
    self.accelerometer = self.spec.accelerometer;
    self.accelerometerIntegration = self.spec.accelerometerIntegration;
    self.gyroscope = self.spec.gyroscope;
    self.gyroscopeAngleIntegration = self.spec.gyroscopeAngleIntegration;
    self.gyroscopeQuaternionIntegration = self.spec.gyroscopeQuaternionIntegration;
    self.magnetometer = self.spec.magnetometer;
    self.ambientLightSensor = self.spec.ambientLightSensor;
    self.proximitySensor = self.spec.proximitySensor;
    self.gasSensor = self.spec.gasSensor;
    self.airQualitySensor = self.spec.airQualitySensor;
    self.sensorFusion = self.spec.sensorFusion;
    self.buttonSensor = self.spec.buttonSensor;

    int unit = (int) [[NSUserDefaults standardUserDefaults] integerForKey:@"TemperatureUnit"];
    self.temperatureSensor.displayUnit = unit;
    self.temperatureSensor.logUnit = unit;
}

- (void) initSensorGraphs {
    self.temperatureGraphData = [[ChartDataEntryBuffer alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
    self.humidityGraphData = [[ChartDataEntryBuffer alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
    self.pressureGraphData = [[ChartDataEntryBuffer alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
    if (self.type != DEVICE_TYPE_IOT_585) {
        self.accelerometerGraphData = [[ChartDataEntryBuffer3D alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
        self.gyroscopeGraphData = [[ChartDataEntryBuffer3D alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
        self.magnetometerGraphData = [[ChartDataEntryBuffer3D alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
    } else {
        self.accelerometerGraphData = [[ChartDataEntryBuffer3D alloc] initWithCapacity:2 * IOT_SENSORS_GRAPH_DATA_SIZE];
        self.gyroscopeGraphData = [[ChartDataEntryBuffer3D alloc] initWithCapacity:2 * IOT_SENSORS_GRAPH_DATA_SIZE];
        self.magnetometerGraphData = [[ChartDataEntryBuffer3D alloc] initWithCapacity:2 * IOT_SENSORS_GRAPH_DATA_SIZE];
        self.ambientLightGraphData = [[ChartDataEntryBuffer alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
        self.airQualityGraphData = [[ChartDataEntryBuffer alloc] initWithCapacity:IOT_SENSORS_GRAPH_DATA_SIZE];
    }
    self.accelerometer.graphValueProcessor = [[AccelerometerGraphValueProcessor alloc] init];
    self.accelerometerIntegration.graphValueProcessor = [[AccelerometerGraphValueProcessor alloc] init];
    self.gyroscope.graphValueProcessor = [[GyroscopeGraphValueProcessor alloc] init];
    self.gyroscopeAngleIntegration.graphValueProcessor = [[GyroscopeGraphValueProcessor alloc] init];
    self.magnetometer.graphValueProcessor = [[MagnetometerGraphValueProcessor alloc] init];
}

- (CBPeripheralState) state {
    return self.peripheral.state;
}

- (void) connect {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheral:) name:BluetoothManagerConnectedPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral:) name:BluetoothManagerDisconnectedPeripheral object:nil];
    [self.bluetoothManager connectToPeripheral:self.peripheral];
}

- (void) disconnect {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BluetoothManagerConnectedPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationBLELayerActuation object:nil];
    if (self.state != CBPeripheralStateConnected)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BluetoothManagerDisconnectedPeripheral object:nil];
    [self.bluetoothManager disconnectPeripheral:self.peripheral];
}

- (void) didConnectPeripheral:(NSNotification*)notification {
    if (![notification.object isEqual:self.peripheral])
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BluetoothManagerConnectedPeripheral object:nil];
    FLog(@"%@ [%@] connected", self.name, self.ekid);
    [self.manager discoverServices];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onActuationMessage:) name:NotificationBLELayerActuation object:nil];
}

- (void) didDisconnectPeripheral:(NSNotification*)notification {
    if (![notification.object isEqual:self.peripheral])
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BluetoothManagerDisconnectedPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationBLELayerActuation object:nil];
    FLog(@"%@ [%@] disconnected", self.name, self.ekid);
}

- (void) startActivationSequence {
    [self.spec startActivationSequence];
}

- (IotSettingsManager*) basicSettingsManager {
    return self.spec.basicSettingsManager;
}

- (IotSettingsManager*) calibrationSettingsManager {
    return self.spec.calibrationSettingsManager;
}

- (IotSettingsManager*) sensorFusionSettingsManager {
    return self.spec.sensorFusionSettingsManager;
}

- (int) getCalibrationMode:(int)sensor {
    return [self.spec getCalibrationMode:sensor];
}

- (int) getAutoCalibrationMode:(int)sensor {
    return [self.spec getAutoCalibrationMode:sensor];
}

- (void) processActuationMessage:(DataMsg*)msg {
    if (![msg.EKID isEqualToString:self.ekid])
        return;
    for (DataEvent* event in msg.Events) {
        [self.spec processActuationEvent:event];
    }
}

- (void) onActuationMessage:(NSNotification*)notification {
    DataMsg* msg = notification.object;
    NSLog(@"Actuation message: [%@] %@", msg.EKID, msg.Events);
    [self processActuationMessage:msg];
}

@end
