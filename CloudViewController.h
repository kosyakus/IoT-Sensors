/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>

@interface CloudViewController : UITableViewController

@property IBOutletCollection(UITableViewCell) NSArray* cloudAppsCells;
@property (weak, nonatomic) IBOutlet UITableViewCell* cloudSettingsCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* sensorToggleButton;

- (IBAction) onSensorToggleButton:(id)sender;
- (IBAction) onShowMenu:(id)sender;

@end
