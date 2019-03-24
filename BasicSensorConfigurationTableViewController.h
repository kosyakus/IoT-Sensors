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
#import "BluetoothDefines.h"
#import "IotSensorsManager.h"
#import "BluetoothManager.h"
#import "IotSensorsDevice.h"
#import "IotSettingsManager.h"

@interface BasicSensorConfigurationTableViewController : UITableViewController <UITextFieldDelegate> {
    BOOL itemsEnabled;
}

@property IotSensorsDevice* device;
@property IotSettingsManager* manager;

- (void) didUpdateSensorState:(NSNotification*)notification;
- (void) onConfigurationReport:(NSNotification*)notification;
- (void) updateUI;
- (void) setItemEnabled:(UIView*)view enabled:(BOOL)enabled;
- (void) showMessage:(NSString*)message duration:(float)seconds;
- (void) showMessage:(NSString*)message;
- (void) showErrorMessage:(NSString*)message;

- (IBAction) onSwitchToggle:(id)sender;
- (IBAction) onSensorToggle:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* sensorToggleButton;

@property IBOutletCollection(NSLayoutConstraint) NSArray* customCellLeadingConstraints;

@end
