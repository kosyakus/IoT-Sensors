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
#import "BasicSensorConfigurationTableViewController.h"

@interface SensorCoefficientsTableViewController : BasicSensorConfigurationTableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellBetaA;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellBetaM;

@property (weak, nonatomic) IBOutlet UIButton *buttonStoreToNV;
@property (weak, nonatomic) IBOutlet UIButton *buttonResetCurrentSet;

- (IBAction) onStoreToNV:(id)sender;
- (IBAction) onResetCurrentSet:(id)sender;

@end
