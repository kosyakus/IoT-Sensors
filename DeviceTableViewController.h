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
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "BluetoothManager.h"

@interface DeviceTableViewController : UITableViewController <BluetoothManagerDelegate, CLLocationManagerDelegate>

@property IBOutlet UIBarButtonItem *cloudButton;
@property NSMutableArray *devices;
@property NSMutableArray *devicesInfo;

@end
