/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class IotSensorsDevice;

extern NSString *const IotSensorsManagerServiceNotFound;
extern NSString *const IotSensorsManagerSensorReport;
extern NSString *const IotSensorsManagerSensorStateReport;
extern NSString *const IotSensorsManagerConfigurationReport;
extern NSString *const IotSensorsManagerCharacteristicValueUpdated;
extern NSString *const IotSensorsManagerMagnetometerState;
extern NSString *const IotSensorsManagerOneShotCalibrationComplete;
extern NSString *const IotSensorsManagerFeaturesRead;


@interface IotSensorsManager : NSObject <CBPeripheralDelegate>

@property (weak) IotSensorsDevice* device;
@property CBPeripheral* peripheral;

- (id) initWithDevice:(IotSensorsDevice*)device;

- (void) discoverServices;
- (void) writeValueWithResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID data:(NSData *)data;
- (void) writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID data:(NSData *)data;
- (void) readValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID;

- (void) readFeatures;
- (void) sendCommand:(uint8_t)command;
- (void) sendCommand:(uint8_t)command data:(NSData*)data;
- (void) sendReadFeaturesCommand;
- (void) sendReadVersionCommand;
- (void) sendStartCommand;
- (void) sendStopCommand;
- (void) sendReadConfigCommand;
- (void) sendWriteConfigCommand:(NSData*)data;
- (void) sendReadCalibrationModesCommand;
- (void) sendWriteCalibrationModesCommand:(NSData*)data;
- (void) sendResetToDefaultsCommand;
- (void) sendReadNvCommand;
- (void) sendWriteConfigToNvCommand;
- (void) sendAccCalibrateCommand;
- (void) sendCalReadCommand;
- (void) sendCalWriteCommand:(NSData*)data;
- (void) sendCalCoeffReadCommand;
- (void) sendCalCoeffWriteCommand:(NSData*)data;
- (void) sendCalResetCommand;
- (void) sendCalStoreNvCommand;
- (void) sendSflReadCommand;
- (void) sendSflWriteCommand:(NSData*)data;
- (void) sendStartLedBlinkCommand;
- (void) sendStopLedBlinkCommand;
- (void) sendReadProximityHysteresisCommand;
- (void) sendWriteProximityHysteresisCommand:(NSData*)data;
- (void) sendProximityCalibrationCommand;

- (CBService*)findServiceWithUUID:(CBUUID *)UUID;

@end
