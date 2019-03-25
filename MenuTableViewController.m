/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "MenuTableViewController.h"
#import "AppDelegate.h"
#import "IotSensorsManager.h"
#import "SensorViewController.h"
#import "APLSlideMenuViewController.h"
#import "SettingsVault.h"
#import "MBProgressHUD.h"

@implementation MenuTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFeaturesRead:) name:IotSensorsManagerFeaturesRead object:nil];
}

- (void) setItemEnabled:(UIView*)view enabled:(BOOL)enabled {
    view.alpha = enabled ? 1.f : 0.4f;
    view.userInteractionEnabled = enabled;
}

- (void) onFeaturesRead:(NSNotification*)notification {
    UITableViewCell* settingsMenuItem = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [self setItemEnabled:settingsMenuItem enabled:self.device.features.valid];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UITableViewCell* cloudMenuItem = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [self setItemEnabled:cloudMenuItem enabled:self.device.cloudSupport];
    UITableViewCell* settingsMenuItem = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [self setItemEnabled:settingsMenuItem enabled:self.device.features.valid];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide unused sensor menu items
    if (indexPath.section == 0 && indexPath.row < 2 && indexPath.row >= (self.device.sensorMenuLayout ? self.device.sensorMenuLayout.count : 1))
        return 0;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    // Set custom sensor menu title
    if (indexPath.section == 0 && self.device.sensorMenuLayout && indexPath.row < self.device.sensorMenuLayout.count)
        cell.textLabel.text = self.device.sensorMenuLayout[indexPath.row][@"title"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController* navigationController = (UINavigationController*)self.slideMenuController.contentViewController;
        UIViewController *vc;
        
        // Save DeviceViewController if it is the current view
        if (!self.sensor && [navigationController.topViewController isKindOfClass:[SensorViewController class]])
            self.sensor = navigationController.topViewController;

        switch (indexPath.section) {
            case 0: {
                switch (indexPath.row) {
                    case 0:
                        if (!self.sensor)
                            self.sensor = [self.storyboard instantiateViewControllerWithIdentifier:!self.device.sensorMenuLayout ? @"SensorViewController" : self.device.sensorMenuLayout[0][@"view"]];
                        vc = self.sensor;
                        break;

                    case 1:
                        if (!self.imuSensor)
                            self.imuSensor = [self.storyboard instantiateViewControllerWithIdentifier:self.device.sensorMenuLayout[1][@"view"]];
                        vc = self.imuSensor;
                        break;

                    case 2:
                        if (!self.fusion)
                            self.fusion = [self.storyboard instantiateViewControllerWithIdentifier: @"SensorFusionViewController"]; //@"MapViewController"];
                        vc = self.fusion;
                        break;
                }
                break;
            }
                
            case 1: {
                switch (indexPath.row) {
                    case 0:
                        if ([[SettingsVault sharedSettingsVault] getConfigHasEnabledCloudAtLeastOnce]) {
                            if (!self.cloud)
                                self.cloud = [self.storyboard instantiateViewControllerWithIdentifier:@"CloudViewController"];
                            vc = self.cloud;
                        } else {
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud.mode = MBProgressHUDModeText;
                            hud.labelText = @"Please enable Cloud";
                            hud.removeFromSuperViewOnHide = YES;
                            hud.margin = 10.f;
                            hud.yOffset = 150.f;
                            [hud hide:YES afterDelay:2];
                            return;
                        }
                        break;

                    case 1:
                        if (!self.configuration)
                            self.configuration = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfigurationViewController"];
                        vc = self.configuration;
                        break;
                        
                    case 2:
                        if (!self.info)
                            self.info = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
                        vc = self.info;
                        break;
                        
                    case 3:
                        if (!self.disclaimer)
                            self.disclaimer = [self.storyboard instantiateViewControllerWithIdentifier:@"DisclaimerViewController"];
                        vc = self.disclaimer;
                        break;
                }
                break;
            }
        }

        [navigationController setViewControllers:@[vc] animated:NO];
        [self.slideMenuController hideMenu:YES];
    });
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
