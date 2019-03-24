/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>
#import "BluetoothManager.h"
#import "BluetoothDefines.h"
#import "IotSensorsDevice.h"

@implementation BluetoothManager

NSString *const BluetoothManagerConnectedPeripheral = @"BluetoothManagerConnectedPeripheral";
NSString *const BluetoothManagerDisconnectedPeripheral = @"BluetoothManagerDisconnectedPeripheral";

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnteringBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnteringForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

+ (id) instance {
    static BluetoothManager* instance = nil;
    @synchronized(self) {
        if (!instance)
            instance = [[self alloc] init];
    }
    return instance;
}

- (void) startScanning {
    NSLog(@"Start scanning");
    self.scanning = true;
    // Background scan works only with specific UUIDs, so scan settings must change when app goes to background/foreground.
    // Scan for all devices is required only for asset tracking in order to detect beacons with Dialog manufacturer ID.
    NSArray* services = !self.assetTracking || self.background ? @[[CBUUID UUIDWithString:DIALOG_WEARABLES_SERVICE_SCAN_UUID]] : nil;
    [self.centralManager scanForPeripheralsWithServices:services options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void) stopScanning {
    NSLog(@"Stop scanning");
    self.scanning = false;
    [self.centralManager stopScan];
}

- (void) onAppEnteringBackground:(NSNotification*)notification {
    self.background = true;
    if (self.assetTracking && self.scanning)
        [self startScanning];
}

- (void) onAppEnteringForeground:(NSNotification*)notification {
    self.background = false;
    if (self.assetTracking && self.scanning)
        [self startScanning];
}

- (void) connectToPeripheral:(CBPeripheral*)peripheral {
    NSLog(@"Connect peripheral: %@", peripheral);
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral {
    NSLog(@"Disconnect peripheral: %@", peripheral);
    [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Bluetooth state changed to %d", (int) central.state);
    [self.delegate didUpdateState:central.state];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered %@ [%@]: %@", peripheral.name, peripheral.identifier, advertisementData);
    [self.delegate didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to device: %@", peripheral);
    [self.delegate didConnectPeripheral:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerConnectedPeripheral object:peripheral userInfo:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected from device: %@", peripheral);
    [self.delegate didDisconnectPeripheral:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerDisconnectedPeripheral object:peripheral userInfo:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to device: %@", peripheral);
    [self.delegate didFailToConnectPeripheral:peripheral];
}

@end
