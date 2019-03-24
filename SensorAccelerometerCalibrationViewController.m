/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorAccelerometerCalibrationViewController.h"
#import "MBProgressHUD.h"

@implementation SensorAccelerometerCalibrationViewController {
    BOOL itemsEnabled;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    if (self.device.type != DEVICE_TYPE_IOT_585) {
        self.imageView.image = [UIImage imageNamed:@"accel-calibration.jpg"];
        self.textLabel.text = @"Place the device on a horizontal flat surface with the LED upwards and press start.";
    } else {
        self.imageView.image = [UIImage imageNamed:@"accel-calibration-iot-plus.jpg"];
        self.textLabel.text = @"Place the device on a horizontal flat surface with the logo upwards and press start.";
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    itemsEnabled = !self.device.isStarted;
    self.sensorToggleButton.title = self.device.isStarted ? @"Stop" : @"Start";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfigurationReport:) name:IotSensorsManagerConfigurationReport object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerConfigurationReport object:nil];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void) updateUI {
    [self setItemEnabled:self.imageView enabled:itemsEnabled];
    [self setItemEnabled:self.textLabel enabled:itemsEnabled];
    [self setItemEnabled:self.startCalibrationButton enabled:itemsEnabled];
}

- (void) setItemEnabled:(UIView*)view enabled:(BOOL)enabled {
    view.alpha = enabled ? 1.f : 0.45f;
    view.userInteractionEnabled = enabled;
}

#pragma mark - Configuration commands

- (IBAction) onSensorToggle:(id)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [self.device.manager sendStopCommand];
        [self.sensorToggleButton setTitle:@"Start"];
    } else {
        [self.device.manager sendStartCommand];
        [self.sensorToggleButton setTitle:@"Stop"];
    }
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    BOOL sensorState = [notification.object boolValue];
    self.sensorToggleButton.title = sensorState ? @"Stop" : @"Start";
    itemsEnabled = !sensorState;
    [self updateUI];
}

- (IBAction) onStartCalibration:(id)sender {
    [self.device.manager sendAccCalibrateCommand];
}

- (void) onConfigurationReport:(NSNotification*)notification {
    NSDictionary* report = notification.object;
    int command = [report[@"command"] intValue];
    if (command != DIALOG_WEARABLES_COMMAND_CALIBRATION_ACCELEROMETER_START)
        return;

    NSData* data = report[@"data"];
    uint8_t state = ((const uint8_t*)data.bytes)[0];
    switch (state) {
        case 1: // Calibration started
            [self showMessage:@"Calibrating, please wait..." duration:2];
            [self setItemEnabled:self.startCalibrationButton enabled:NO];
            break;

        case 0: // Calibration ended
            [self showMessage:@"Calibrated!" duration:1];
            [self setItemEnabled:self.startCalibrationButton enabled:YES];
            break;
    }
}

- (void) showMessage:(NSString*)message duration:(float)seconds{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[MBProgressHUD HUDForView:self.navigationController.view] isEqual:hud])
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    });
}

@end
