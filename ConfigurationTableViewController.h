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

@interface ConfigurationTableViewController : UITableViewController

@property IotSensorsDevice* device;

- (IBAction) onShowMenu:(id)sender;
- (IBAction) onSensorToggle:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* sensorToggleButton;

@end
