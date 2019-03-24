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

@interface InfoViewController : UITableViewController

@property IotSensorsDevice* device;

@property (weak, nonatomic) IBOutlet UILabel *supportMailLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;

- (IBAction)showMenu:(id)sender;

@end
