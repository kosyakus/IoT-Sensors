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
#import "IotSensorsDevice.h"

@interface MenuTableViewController : UITableViewController

@property IotSensorsDevice* device;

@property UIViewController *sensor;
@property UIViewController *imuSensor;
@property UIViewController *fusion;
@property UIViewController *cloud;
@property UIViewController *configuration;
@property UIViewController *info;
@property UIViewController *disclaimer;

@end
