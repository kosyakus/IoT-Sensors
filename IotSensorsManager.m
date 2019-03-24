/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSensorsManager.h"
#import "BluetoothDefines.h"
#import "FileLogger.h"
#import "IotSensorsDevice.h"
#import "InternalAPI.h"

NSString *const IotSensorsManagerServiceNotFound = @"IotSensorsManagerServiceNotFound";
NSString *const IotSensorsManagerSensorReport = @"IotSensorsManagerSensorReport";
NSString *const IotSensorsManagerSensorStateReport = @"IotSensorsManagerSensorStateReport";
NSString *const IotSensorsManagerConfigurationReport = @"IotSensorsManagerConfigurationReport";
NSString *const IotSensorsManagerCharacteristicValueUpdated = @"IotSensorsManagerCharacteristicValueUpdated";
NSString *const IotSensorsManagerMagnetometerState = @"IotSensorsManagerMagnetometerState";
NSString *const IotSensorsManagerOneShotCalibrationComplete = @"IotSensorsManagerOneShotCalibrationComplete";
NSString *const IotSensorsManagerFeaturesRead = @"IotSensorsManagerFeaturesRead";

static CBUUID* DWP_SERVICE;
static CBUUID* DWP_ACCELEROMETER;
static CBUUID* DWP_GYROSCOPE;
static CBUUID* DWP_MAGNETOMETER;
static CBUUID* DWP_PRESSURE;
static CBUUID* DWP_HUMIDITY;
static CBUUID* DWP_TEMPERATURE;
static CBUUID* DWP_SENSOR_FUSION;
static CBUUID* DWP_MULTI_SENSOR;
static CBUUID* DWP_FEATURES;
static CBUUID* DWP_CONTROL;
static CBUUID* DWP_CONTROL_NOTIFY;
static NSSet* ENABLE_NOTIFICATIONS;
static NSSet* SENSOR_REPORTS;
static NSDictionary* SENSOR_REPORT_TO_EVENT_TYPE;


@implementation IotSensorsManager

+ (void) initialize {
    if (self != [IotSensorsManager class])
        return;

    DWP_SERVICE = [CBUUID UUIDWithString:DIALOG_WEARABLES_SERVICE];
    DWP_ACCELEROMETER = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_ACCELEROMETER];
    DWP_GYROSCOPE = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_GYROSCOPE];
    DWP_MAGNETOMETER = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_MAGNETOMETER];
    DWP_PRESSURE = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_BAROMETER];
    DWP_HUMIDITY = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_HUMIDITY];
    DWP_TEMPERATURE = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_TEMPERATURE];
    DWP_SENSOR_FUSION = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_SENSOR_FUSION];
    DWP_MULTI_SENSOR = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_MULTI_SENSOR];
    DWP_FEATURES = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_FEATURES];
    DWP_CONTROL = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_CONTROL];
    DWP_CONTROL_NOTIFY = [CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_CONTROL_NOTIFY];

    ENABLE_NOTIFICATIONS = [NSSet setWithObjects:
            DWP_ACCELEROMETER, DWP_GYROSCOPE, DWP_MAGNETOMETER,
            DWP_PRESSURE, DWP_HUMIDITY, DWP_TEMPERATURE,
            DWP_SENSOR_FUSION, DWP_MULTI_SENSOR, DWP_CONTROL_NOTIFY, nil];
    SENSOR_REPORTS = [NSSet setWithObjects:
            DWP_ACCELEROMETER, DWP_GYROSCOPE, DWP_MAGNETOMETER,
            DWP_PRESSURE, DWP_HUMIDITY, DWP_TEMPERATURE,
            DWP_SENSOR_FUSION, DWP_MULTI_SENSOR, nil];

    SENSOR_REPORT_TO_EVENT_TYPE = @{
            @(SENSOR_REPORT_TEMPERATURE) : @(eEventTypes_Temperature),
            @(SENSOR_REPORT_HUMIDITY) : @(eEventTypes_Humidity),
            @(SENSOR_REPORT_PRESSURE) : @(eEventTypes_Pressure),
            @(SENSOR_REPORT_ACCELEROMETER) : @(eEventTypes_Accelerometer),
            @(SENSOR_REPORT_GYROSCOPE) : @(eEventTypes_Gyroscope),
            @(SENSOR_REPORT_MAGNETOMETER) : @(eEventTypes_Magnetometer),
            @(SENSOR_REPORT_SENSOR_FUSION) : @(eEventTypes_Fusion),
            @(SENSOR_REPORT_AMBIENT_LIGHT) : @(eEventTypes_Brightness),
            @(SENSOR_REPORT_PROXIMITY) : @(eEventTypes_Proximity),
            @(SENSOR_REPORT_GAS) : @(eEventTypes_Gas),
            @(SENSOR_REPORT_AIR_QUALITY) : @(eEventTypes_AirQuality),
            @(SENSOR_REPORT_BUTTON) : @(eEventTypes_Button),
    };
}

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super init];
    if (!self)
        return nil;

    self.device = device;
    self.peripheral = device.peripheral;
    self.peripheral.delegate = self;
    return self;
}

- (void) discoverServices {
    [self.peripheral discoverServices:nil];
}

- (void) writeValueWithResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID data:(NSData *)data {
    [self writeValue:serviceUUID characteristicUUID:characteristicUUID data:data type:CBCharacteristicWriteWithResponse];
}

- (void) writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID data:(NSData *)data {
    [self writeValue:serviceUUID characteristicUUID:characteristicUUID data:data type:CBCharacteristicWriteWithoutResponse];
}

- (void)writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID data:(NSData*)data type:(CBCharacteristicWriteType)responseType {
    CBService *service = [self findServiceWithUUID:serviceUUID];
    if (!service) {
        NSLog(@"Could not find service with UUID %@", serviceUUID.UUIDString);
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicWithUUID:characteristicUUID forService:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@", characteristicUUID.UUIDString);
        return;
    }
    
    FLog(@"SEND\t%@\t%@", characteristic.UUID, data);
    [self.peripheral writeValue:data forCharacteristic:characteristic type:responseType];
}

- (void) readValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID {
    CBService *service = [self findServiceWithUUID:serviceUUID];
    if (!service) {
        NSLog(@"Could not find service with UUID %@", serviceUUID.UUIDString);
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicWithUUID:characteristicUUID forService:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@", characteristicUUID.UUIDString);
        return;
    }
    
    [self.peripheral readValueForCharacteristic:characteristic];
}

- (CBService*)findServiceWithUUID:(CBUUID *)UUID {
    for (CBService *service in self.peripheral.services) {
        if ([service.UUID isEqual:UUID])
            return service;
    }
    
    return nil;
}

- (CBCharacteristic*)findCharacteristicWithUUID:(CBUUID*)UUID forService:(CBService*)service {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:UUID])
            return characteristic;
    }
    
    return nil;
}

- (NSArray*) processSensorReport:(NSData*)data multi:(BOOL)multi {
    IotSensor* sensor;
    DataMsg* dataMsg = [[DataMsg alloc] initWithEKID:self.device.ekid];
    const uint8_t* raw = data.bytes;

    int curr = 0;
    if (multi) {
        if (raw[0] != MULTI_SENSOR_REPORT_PREAMBLE)
            return nil;
        //NSLog(@"Multi sensor report: timestamp=%d", raw[1]);
        curr = 2;
    }

    NSMutableArray* reports = [NSMutableArray arrayWithCapacity:10];
    while (curr < data.length) {

        int reportID = raw[curr];
        [reports addObject:@(reportID)];
        sensor = nil;

        switch (reportID) {

            // IMU sensors

            case SENSOR_REPORT_ACCELEROMETER:
                sensor = self.device.accelerometer;
                [sensor processRawData:data offset:curr + 3];
                [self.device.accelerometerGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_ACCELEROMETER_LENGTH;
                break;

            case SENSOR_REPORT_GYROSCOPE:
                sensor = self.device.gyroscope;
                [sensor processRawData:data offset:curr + 3];
                [self.device.gyroscopeGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_GYROSCOPE_LENGTH;
                break;

            case SENSOR_REPORT_MAGNETOMETER:
                self.device.calibrationState = raw[curr + 2];

                // Check for one-shot calibration completion
                if (self.device.oneShotMode && self.device.calibrationState == 4) {
                    NSLog(@"One-shot calibration complete");
                    self.device.oneShotMode = false;
                    self.device.oneShotModeSelected = false;
                    [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerOneShotCalibrationComplete object:nil];
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerMagnetometerState
                                                                    object:@{ @"sensorState" : @(raw[curr + 1]),
                                                                              @"calibrationState" : @(self.device.calibrationState) }];

                sensor = self.device.magnetometer;
                [sensor processRawData:data offset:curr + 3];
                [self.device.magnetometerGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_MAGNETOMETER_LENGTH;
                break;

            case SENSOR_REPORT_SENSOR_FUSION:
                sensor = self.device.sensorFusion;
                [sensor processRawData:data offset:curr + 3];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_SENSOR_FUSION_LENGTH;
                break;

            case SENSOR_REPORT_VELOCITY_DELTA:
                sensor = self.device.accelerometerIntegration;
                [sensor processRawData:data offset:curr + 2];
                [self.device.accelerometerGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_VELOCITY_DELTA_LENGTH;
                break;

            case SENSOR_REPORT_EULER_ANGLE_DELTA:
                sensor = self.device.gyroscopeAngleIntegration;
                [sensor processRawData:data offset:curr + 2];
                [self.device.gyroscopeGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_EULER_ANGLE_DELTA_LENGTH;
                break;

            case SENSOR_REPORT_QUATERNION_DELTA:
                sensor = self.device.gyroscopeQuaternionIntegration;
                [sensor processRawData:data offset:curr + 3];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_QUATERNION_DELTA_LENGTH;
                break;

            // Environmental Sensors

            case SENSOR_REPORT_PRESSURE:
                sensor = self.device.pressureSensor;
                [sensor processRawData:data offset:curr + 3];
                [self.device.pressureGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_PRESSURE_LENGTH;
                break;

            case SENSOR_REPORT_HUMIDITY:
                sensor = self.device.humiditySensor;
                [sensor processRawData:data offset:curr + 3];
                [self.device.humidityGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_HUMIDITY_LENGTH;
                break;

            case SENSOR_REPORT_TEMPERATURE:
                sensor = self.device.temperatureSensor;
                [sensor processRawData:data offset:curr + 3];
                [self.device.temperatureGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_TEMPERATURE_LENGTH;
                break;

            case SENSOR_REPORT_GAS:
                sensor = self.device.gasSensor;
                [sensor processRawData:data offset:curr + 3];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_GAS_LENGTH;
                break;

            case SENSOR_REPORT_AIR_QUALITY:
                sensor = self.device.airQualitySensor;
                [sensor processRawData:data offset:curr + 2];
                [self.device.airQualityGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_AIR_QUALITY_LENGTH;
                break;

            case SENSOR_REPORT_AMBIENT_LIGHT:
                sensor = self.device.ambientLightSensor;
                [sensor processRawData:data offset:curr + 1];
                [self.device.ambientLightGraphData add:sensor.graphValue];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_AMBIENT_LIGHT_LENGTH;
                break;

            case SENSOR_REPORT_PROXIMITY:
                sensor = self.device.proximitySensor;
                [sensor processRawData:data offset:curr + 1];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_PROXIMITY_LENGTH;
                break;

            // Other

            case SENSOR_REPORT_BUTTON:
                sensor = self.device.buttonSensor;
                [sensor processRawData:data offset:curr + 1];
                FLog(@"%@\t%@", sensor.logTag, sensor.logEntry);
                curr += SENSOR_REPORT_BUTTON_LENGTH;
                break;

            default:
                NSLog(@"Unknown sensor report: %d", reportID);
                [reports removeLastObject];
                multi = false;
                break;
        }

        // Add cloud data event
        if (self.device.cloudSupport && sensor && SENSOR_REPORT_TO_EVENT_TYPE[@(reportID)]) {
            [dataMsg.Events addObject:[[DataEvent alloc] initWithType:[SENSOR_REPORT_TO_EVENT_TYPE[@(reportID)] intValue] data:sensor.cloudData]];
        }

        if (!multi)
            break;
    }

    // Send to cloud
    if (dataMsg.Events.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBLELayerEvent object:dataMsg userInfo:nil];
    }

    return reports;
}

- (BOOL) processConfigurationReport:(NSData*)data {
    NSLog(@"processConfigurationReport: %@", data);
    const uint8_t* raw = data.bytes;
    BOOL stateReport = false;

    int command = raw[1];
    switch (command) {
        case DIALOG_WEARABLES_COMMAND_CONFIGURATION_START:
        case DIALOG_WEARABLES_COMMAND_CONFIGURATION_STOP:
        case DIALOG_WEARABLES_COMMAND_CONFIGURATION_RUNNING_STATE:
            stateReport = true;
            self.device.isStarted = raw[2] == 1;
            NSLog(@"Sensors %@", self.device.isStarted ? @"started" : @"stopped");

            if (self.device.oneShotModeSelected && self.device.isStarted) {
                NSLog(@"One-shot calibration mode detected");
                self.device.oneShotMode = true;
            }

            // Check for one-shot calibration completion. Case of IoT dongle in one-shot basic: the dongle stops after sending the OK state.
            if (self.device.type == DEVICE_TYPE_IOT_580 && self.device.oneShotMode && command == DIALOG_WEARABLES_COMMAND_CONFIGURATION_RUNNING_STATE && !self.device.isStarted && self.device.calibrationState == 3) {
                NSLog(@"One-shot calibration complete");
                self.device.oneShotMode = false;
                self.device.oneShotModeSelected = false;
                [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerOneShotCalibrationComplete object:nil];
            }
            break;

        case DIALOG_WEARABLES_COMMAND_CONFIGURATION_READ:
            // Check calibration mode for one-shot
            if (self.device.type != DEVICE_TYPE_IOT_585 && self.device.isNewVersion) {
                self.device.oneShotModeSelected = raw[11] == 3;
                if (self.device.oneShotModeSelected) {
                    NSLog(@"One-shot calibration mode selected");
                    if (self.device.isStarted) {
                        NSLog(@"One-shot calibration mode detected");
                        self.device.oneShotMode = true;
                    }
                } else {
                    self.device.oneShotMode = false;
                }
            }

            [self.device.basicSettings process:data offset:2];
            break;

        case DIALOG_WEARABLES_COMMAND_CALIBRATION_CONTROL_READ:
            [self.device.calibrationSettings process:data offset:2];
            break;

        case DIALOG_WEARABLES_COMMAND_CALIBRATION_SFL_COEFFICIENTS_READ:
            [self.device.sensorFusionSettings process:data offset:2];
            break;

        case DIALOG_WEARABLES_COMMAND_CALIBRATION_READ_MODES:
            [self.device.calibrationModesSettings process:data offset:2];
            break;

        case DIALOG_WEARABLES_COMMAND_PROXIMITY_HYSTERESIS_READ:
            [self.device.proximityHysteresisSettings process:data offset:2];
            break;

        case DIALOG_WEARABLES_COMMAND_CALIBRATION_COMPLETE: {
            int sensor = raw[2] & 0xff;
            BOOL ok = raw[3] == 0;
            NSLog(@"One-shot calibration complete: Sensor %d%@", sensor, ok ? @"" : @", error");
            [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerOneShotCalibrationComplete object:@{ @"sensor" : @(sensor), @"ok" : @(ok) }];
            break;
        }

        case DIALOG_WEARABLES_COMMAND_READ_VERSION: {
            NSMutableData* version = [NSMutableData dataWithCapacity:data.length - 1];
            char terminating = 0;
            [version appendData:[data subdataWithRange:NSMakeRange(2, data.length - 2)]];
            [version appendBytes:&terminating length:1];
            self.device.version = [NSString stringWithCString:version.bytes encoding:NSUTF8StringEncoding];
            NSLog(@"Device version: %@", self.device.version);
            break;
        }

        case DIALOG_WEARABLES_COMMAND_READ_FEATURES:
            NSLog(@"Device features: %@", [data subdataWithRange:NSMakeRange(2, data.length - 2)]);
            [self.device.features processFeaturesReport:data offset:2];
            [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerFeaturesRead object:nil];
            break;
    }

    return stateReport;
}

- (void) processFeaturesCharacteristic:(NSData*)data {
    NSLog(@"processFeaturesCharacteristic: %@", data);
    [self.device.features processFeaturesCharacteristic:data];
    [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerFeaturesRead object:nil];
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSLog(@"Discovered services: %@", peripheral.services);

    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:DWP_SERVICE]) {
            NSLog(@"IoT Sensors service found: %@", service);
            [peripheral discoverCharacteristics:nil forService:service];
            return;
        }
    }

    NSLog(@"IoT Sensors service not found!");
    [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerServiceNotFound object:self.device.peripheral userInfo:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if ([service.UUID isEqual:DWP_SERVICE]) {
        NSLog(@"IoT Sensors service characteristics found: %@", service.characteristics);
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([ENABLE_NOTIFICATIONS containsObject:characteristic.UUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }

        [self.device startActivationSequence];
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic error:(nullable NSError*)error {
    if (error)
        NSLog(@"Failed to enable notifications for characteristic %@: %@", characteristic.UUID, error);
    else
        NSLog(@"Enabled notifications for characteristic %@", characteristic.UUID);
}

- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(nullable NSError*)error {
    if (error)
        NSLog(@"Write characteristic %@ failed: %@", characteristic.UUID, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"Read characteristic %@ failed: %@", characteristic.UUID, error);
        return;
    }

    NSData* data = characteristic.value;
    FLog(@"RECEIVE\t%@\t%@", characteristic.UUID, data);

    // Sensor report
    if ([SENSOR_REPORTS containsObject:characteristic.UUID]) {
        NSArray* reports = [self processSensorReport:data multi:[characteristic.UUID isEqual:DWP_MULTI_SENSOR]];
        if (reports.count)
            [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerSensorReport object:reports userInfo:nil];
    }
    // Configuration report
    else if ([characteristic.UUID isEqual:DWP_CONTROL_NOTIFY]) {
        BOOL stateReport = [self processConfigurationReport:data];
        if (stateReport)
            [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerSensorStateReport object:@(self.device.isStarted) userInfo:nil];
        NSDictionary* report = @{
                @"command" : @(((const uint8_t*)data.bytes)[1]),
                @"data" : [data subdataWithRange:NSMakeRange(2, data.length - 2)]
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerConfigurationReport object:report userInfo:nil];
    }
    // Features characteristic
    else if ([characteristic.UUID isEqual:DWP_FEATURES]) {
        [self processFeaturesCharacteristic:data];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:IotSensorsManagerCharacteristicValueUpdated object:characteristic userInfo:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"Peripheral %@ RSSI: %@", peripheral.name, RSSI);
}


#pragma mark - Sensor commands

- (void) readFeatures {
    NSLog(@"readFeatures");
    [self readValue:DWP_SERVICE characteristicUUID:DWP_FEATURES];
}

- (void) sendCommand:(uint8_t)command {
    NSData *data = [NSData dataWithBytes:&command length:1];
    [self writeValueWithResponse:DWP_SERVICE characteristicUUID:DWP_CONTROL data:data];
}

- (void) sendCommand:(uint8_t)command data:(NSData*)commandData {
    NSMutableData* data = [NSMutableData dataWithCapacity:commandData.length + 1];
    [data appendBytes:&command length:1];
    [data appendData:commandData];
    [self writeValueWithResponse:DWP_SERVICE characteristicUUID:DWP_CONTROL data:data];
}

- (void) sendReadFeaturesCommand {
    NSLog(@"sendReadFeaturesCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_READ_FEATURES];
}

- (void) sendReadVersionCommand {
    NSLog(@"sendReadVersionCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_READ_VERSION];
}

- (void) sendStartCommand {
    NSLog(@"sendStartCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_START];
}

- (void) sendStopCommand {
    NSLog(@"sendStopCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_STOP];
}

- (void) sendReadConfigCommand {
    NSLog(@"sendReadConfigCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_READ];
}

- (void) sendWriteConfigCommand:(NSData*)data {
    NSLog(@"sendWriteConfigCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_WRITE data:data];
}

- (void) sendReadCalibrationModesCommand {
    NSLog(@"sendReadCalibrationModesCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_READ_MODES];
}

- (void) sendWriteCalibrationModesCommand:(NSData*)data {
    NSLog(@"sendWriteCalibrationModesCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_SET_MODES data:data];
}

- (void) sendResetToDefaultsCommand {
    NSLog(@"sendResetToDefaultsCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_RESET_TO_DEFAULTS];
}

- (void) sendReadNvCommand {
    NSLog(@"sendReadNvCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_READ_NV];
}

- (void) sendWriteConfigToNvCommand {
    NSLog(@"sendWriteConfigToNvCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CONFIGURATION_STORE_NV];
}

- (void) sendAccCalibrateCommand {
    NSLog(@"sendAccCalibrateCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_ACCELEROMETER_START];
}

- (void) sendCalReadCommand {
    NSLog(@"sendCalReadCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_CONTROL_READ];
}

- (void) sendCalWriteCommand:(NSData*)data{
    NSLog(@"sendCalWriteCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_CONTROL_WRITE data:data];
}

- (void) sendCalCoeffReadCommand {
    NSLog(@"sendCalCoeffReadCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_COEFFICIENTS_READ];
}

- (void) sendCalCoeffWriteCommand:(NSData*)data {
    NSLog(@"sendCalCoeffWriteCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_COEFFICIENTS_WRITE data:data];
}

- (void) sendCalResetCommand {
    NSLog(@"sendCalResetCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_RESET_TO_DEFAULTS];
}

- (void) sendCalStoreNvCommand {
    NSLog(@"sendCalStoreNvCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_STORE_NV];
}

- (void) sendSflReadCommand {
    NSLog(@"sendSflReadCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_SFL_COEFFICIENTS_READ];
}

- (void) sendSflWriteCommand:(NSData*)data {
    NSLog(@"sendSflWriteCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_CALIBRATION_SFL_COEFFICIENTS_WRITE data:data];
}

- (void) sendStartLedBlinkCommand {
    NSLog(@"sendStartLedBlinkCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_START_LED_BLINK];
}

- (void) sendStopLedBlinkCommand {
    NSLog(@"sendStopLedBlinkCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_STOP_LED_BLINK];
}

- (void) sendReadProximityHysteresisCommand {
    NSLog(@"sendReadProximityHysteresisCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_PROXIMITY_HYSTERESIS_READ];
}

- (void) sendWriteProximityHysteresisCommand:(NSData*)data {
    NSLog(@"sendWriteProximityHysteresisCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_PROXIMITY_HYSTERESIS_WRITE data:data];
}

- (void) sendProximityCalibrationCommand {
    NSLog(@"sendProximityCalibrationCommand");
    [self sendCommand:DIALOG_WEARABLES_COMMAND_PROXIMITY_CALIBRATION];

}

@end
