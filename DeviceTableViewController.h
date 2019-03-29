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

#import <YandexMapKit/YMKMapKitFactory.h>

@interface DeviceTableViewController : UITableViewController <BluetoothManagerDelegate, CLLocationManagerDelegate, YMKMapObjectTapListener>

@property IBOutlet UIBarButtonItem *cloudButton;
@property NSMutableArray *devices;
@property NSMutableArray *devicesInfo;

//Natali added
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property YMKMapView *mapView;
@property YMKPoint *target;
@property YMKPoint *target2;
@property YMKPoint *target3;
@property NSMutableArray *placemarks;
//- (void) onMapObjectTap:(nonnull YMKMapObject *)mapObject style:(nonnull YMKPoint *)point;

@end
