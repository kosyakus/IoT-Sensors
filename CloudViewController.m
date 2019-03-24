/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CloudViewController.h"
#import "Cloud/CloudManager.h"
#import "BluetoothDefines.h"
#import "MBProgressHUD.h"
#import "SettingsVault.h"
#import "APLSlideMenuViewController.h"

@implementation CloudViewController{}

- (void) viewDidLoad {
    [super viewDidLoad];

    for (UITableViewCell* cell in self.cloudAppsCells) {
        cell.imageView.tintColor = UIColorWithRGB(0x808080);
    }

    if (BluetoothManager.instance.device.state != CBPeripheralStateConnected) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.cloudSettingsCell.hidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sensorToggleButton.title = BluetoothManager.instance.device.isStarted ? @"Stop" : @"Start";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(nullable id)sender {
    if (![identifier isEqualToString:@"ShowCloudSettings"] && ![[SettingsVault sharedSettingsVault] getConfigHasEnabledCloudAtLeastOnce]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Please enable cloud";
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
        return false;
    }
    return true;
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    BOOL sensorState = [notification.object boolValue];
    self.sensorToggleButton.title = sensorState ? @"Stop" : @"Start";
}

- (IBAction) onSensorToggleButton:(id)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [BluetoothManager.instance.device.manager sendStopCommand];
    } else {
        [BluetoothManager.instance.device.manager sendStartCommand];
    }
}

- (IBAction) onShowMenu:(id)sender {
    [self.slideMenuController showLeftMenu:YES];
}

@end
