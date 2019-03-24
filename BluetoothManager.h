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

extern NSString *const BluetoothManagerConnectedPeripheral;
extern NSString *const BluetoothManagerDisconnectedPeripheral;

@protocol BluetoothManagerDelegate <NSObject>

- (void) didUpdateState:(CBManagerState)state;
- (void) didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void) didConnectPeripheral:(CBPeripheral*)peripheral;
- (void) didDisconnectPeripheral:(CBPeripheral*)peripheral;
- (void) didFailToConnectPeripheral:(CBPeripheral*)peripheral;

@end


@interface BluetoothManager : NSObject <CBCentralManagerDelegate>

+ (BluetoothManager*) instance;

- (void) startScanning;
- (void) stopScanning;
- (void) connectToPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

@property CBCentralManager* centralManager;
@property id<BluetoothManagerDelegate> delegate;
@property IotSensorsDevice* device;
@property BOOL scanning;
@property BOOL assetTracking;
@property BOOL background;

@end
