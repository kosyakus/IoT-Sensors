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
#import "SensorCalibrationTableViewController.h"

@interface FileTableViewController : UITableViewController

@property (strong) SensorCalibrationTableViewController *sensorCalibrationTableViewController;
@property (strong) NSMutableArray *fileArray;

@end
