/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "MenuViewController.h"
#import "IotSensorsManager.h"
#import "BluetoothDefines.h"
#import "MBProgressHUD.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    self.magnetometerStatusIntroLabel.hidden = YES;
    self.magnetometerStatusIndicatorView.hidden = YES;
    self.magnetometerStatusLabel.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectPeripheral:) name:BluetoothManagerDisconnectedPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateValueForCharacteristic:) name:IotSensorsManagerCharacteristicValueUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateMagnetometerState:) name:IotSensorsManagerMagnetometerState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOneShotCalibrationCompletion:) name:IotSensorsManagerOneShotCalibrationComplete object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onServiceNotFound:) name:IotSensorsManagerServiceNotFound object:self.device.peripheral];
    if (self.device.peripheral.services && ![self.device.manager findServiceWithUUID:[CBUUID UUIDWithString:DIALOG_WEARABLES_SERVICE]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerServiceNotFound object:self.device.peripheral];
        [self showServiceNotFoundMessage];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BluetoothManagerDisconnectedPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerMagnetometerState object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerCharacteristicValueUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerOneShotCalibrationComplete object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerServiceNotFound object:self.device.peripheral];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)disconnect:(id)sender {
    [self.device disconnect];
}


- (void) onServiceNotFound:(NSNotification*)notification {
    [self showServiceNotFoundMessage];
}

- (void) showServiceNotFoundMessage {
    NSString* title = @"Missing IoT Sensors Service";
    NSString* message = @"This device does not support the Dialog IoT Sensors service. If the device was "
                        "previously used with different functionality (e.g. SmartTag), you may need to "
                        "unpair it and/or restart Bluetooth in system settings.";

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action) {
                                                         [self.device disconnect];
                                                     }];
    [alert addAction:okButton];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void) didDisconnectPeripheral:(NSNotification*)notification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didUpdateValueForCharacteristic:(NSNotification*)notification {
    CBCharacteristic *characteristic = (CBCharacteristic*) notification.object;
    
    if ([characteristic.UUID.UUIDString.lowercaseString isEqualToString:DIALOG_WEARABLES_CHARACTERISTIC_FEATURES]) {
        // Display these features if the device supports it.
        if (self.device.isNewVersion) {
            self.magnetometerStatusIntroLabel.hidden = NO;
            self.magnetometerStatusIndicatorView.hidden = NO;
            self.magnetometerStatusLabel.hidden = NO;
            magnetometerCalibrationStatusPrevious = -1; // Make sure it updates the next notification
        }
    }
}


- (void)didUpdateMagnetometerState:(NSNotification*)notification {
    if (!self.device.isNewVersion)
        return;

    int magnetometerCalibrationStatus = [notification.object[@"calibrationState"] intValue];
    if (magnetometerCalibrationStatus == magnetometerCalibrationStatusPrevious)
        return;
    magnetometerCalibrationStatusPrevious = magnetometerCalibrationStatus;
    
    NSLog(@"Magnetometer status: %d", magnetometerCalibrationStatus);
    switch (magnetometerCalibrationStatus) {
        case 0: // DISABLED
            [self.magnetometerStatusLabel setText:@"Disabled"];
            [self.magnetometerStatusIndicatorView setBackgroundColor:[UIColor colorWithWhite:0.710 alpha:1.000]];
            break;
            
        case 1: // INIT
            [self.magnetometerStatusLabel setText:@"Init"];
            [self.magnetometerStatusIndicatorView setBackgroundColor:[UIColor colorWithRed:0.255 green:0.608 blue:0.925 alpha:1.000]];
            break;
            
        case 2: // BAD
            [self.magnetometerStatusLabel setText:@"Bad"];
            [self.magnetometerStatusIndicatorView setBackgroundColor:[UIColor colorWithRed:0.941 green:0.153 blue:0.153 alpha:1.000]];
            break;
            
        case 3: // OK
            [self.magnetometerStatusLabel setText:@"OK"];
            [self.magnetometerStatusIndicatorView setBackgroundColor:[UIColor colorWithRed:0.984 green:0.859 blue:0.141 alpha:1.000]];
            break;
            
        case 4: // GOOD
            [self.magnetometerStatusLabel setText:@"Good"];
            [self.magnetometerStatusIndicatorView setBackgroundColor:[UIColor colorWithRed:0.420 green:0.647 blue:0.000 alpha:1.000]];
            break;
            
        case 5: // ERROR
            [self.magnetometerStatusLabel setText:@"Error"];
            [self.magnetometerStatusIndicatorView setBackgroundColor:[UIColor colorWithRed:0.863 green:0.161 blue:0.161 alpha:1.000]];
            break;
    }
}

- (void) onOneShotCalibrationCompletion:(NSNotification*)notification {
    NSString* msg = @"One-shot calibration complete";
    if (notification.object) {
        NSString* sensor = nil;
        switch ([notification.object[@"sensor"] intValue]) {
            case SENSOR_TYPE_ACCELEROMETER:
                sensor = @"Accelerometer";
                break;
            case SENSOR_TYPE_GYROSCOPE:
                sensor = @"Gyroscope";
                break;
            case SENSOR_TYPE_MAGNETOMETER:
                sensor = @"Magnetometer";
                break;
        }
        if (sensor) {
            BOOL ok = [notification.object[@"ok"] boolValue];
            msg = [NSString stringWithFormat:@"%@ one-shot calibration %@", sensor, ok ? @"complete" : @"error"];
        }
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.parentViewController.view animated:YES];
    });
}

@end
