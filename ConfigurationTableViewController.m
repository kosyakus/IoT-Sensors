/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ConfigurationTableViewController.h"
#import "APLSlideMenuViewController.h"

@implementation ConfigurationTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sensorToggleButton.title = self.device.isStarted ? @"Stop" : @"Start";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide cloud settings for non IoT+
    if (!self.device.cloudSupport && indexPath.section == 0 && indexPath.row >= 4)
        return 0;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    self.sensorToggleButton.title = [notification.object boolValue] ? @"Stop" : @"Start";
    return;
}

- (IBAction) onSensorToggle:(id)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [self.device.manager sendStopCommand];
        [self.sensorToggleButton setTitle:@"Start"];
    } else {
        [self.device.manager sendStartCommand];
        [self.sensorToggleButton setTitle:@"Stop"];
    }
}

- (IBAction) onShowMenu:(id)sender {
    [self.slideMenuController showLeftMenu:YES];
}

@end
