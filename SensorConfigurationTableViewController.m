/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorConfigurationTableViewController.h"
#import "ActionSheetStringPicker.h"

@implementation SensorConfigurationTableViewController {
    int temperatureUnit;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.manager = self.device.basicSettingsManager;
    self.firmwareVersionCell.detailTextLabel.text = self.device.version;

    self.proximityHysteresisRange.tintColor = UIColorWithRGB(0xB0BEC5);
    self.proximityHysteresisRange.handleColor = UIColorWithRGB(0x2663AC);
    self.proximityHysteresisRange.tintColorBetweenHandles = UIColorWithRGB(0x2663AC);
    self.proximityHysteresisRange.minLabelFont = [UIFont systemFontOfSize:15];
    self.proximityHysteresisRange.maxLabelFont = [UIFont systemFontOfSize:15];
    self.proximityHysteresisRange.labelPadding = 4;
    self.proximityHysteresisRange.handleDiameter = 18;
    self.proximityHysteresisRange.delegate = self;

    IotSettingsItem* i;
    i = self.manager.spec[@"EnvironmentalSensorsEnabled"];
    i.element = self.environmentalSensorsSwitch;
    i = self.manager.spec[@"GasSensorEnabled"];
    i.element = self.gasSensorSwitch;
    i = self.manager.spec[@"AmbientLightSensorEnabled"];
    i.element = self.ambientLightSensorSwitch;
    i = self.manager.spec[@"ProximitySensorEnabled"];
    i.element = self.proximitySensorSwitch;
    i = self.manager.spec[@"SensorFusionEnabled"];
    i.element = self.sensorFusionEnabledSwitch;
    i = self.manager.spec[@"SensorFusionRawEnabled"];
    i.element = self.sensorFusionRawEnabledSwitch;
    i = self.manager.spec[@"ProximityHysteresis"];
    i.element = self.proximityHysteresisRange;
    i = self.manager.spec[@"ProximityCalibration"];
    i.element = self;
    i.action = @selector(showProximityCalibrationDialog);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.loggingEnabledSwitch.on = [defaults boolForKey:@"LoggingEnabled"];
    temperatureUnit = [defaults integerForKey:@"TemperatureUnit"];
    self.temperatureUnitCell.detailTextLabel.text = temperatureUnit == TEMPERATURE_UNIT_CELSIUS ? @"Celsius" : @"Fahrenheit";
}

- (void) updateUI {
    [super updateUI];
    [self setItemEnabled:self.storeConfigurationNVButton enabled:itemsEnabled];
    [self setItemEnabled:self.readFromNVButton enabled:itemsEnabled];
    [self setItemEnabled:self.resetToDefaultsButton enabled:itemsEnabled];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:[self.tableView indexPathForCell:self.temperatureUnitCell]]) {
        [self temperatureUnitSelection];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void) didEndTouchesInRangeSlider:(TTRangeSlider*)sender {
    if ([self.manager updateValues])
        [self showMessage:@"Settings saved"];
}

- (IBAction)onLogEnableSwitch:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[self.loggingEnabledSwitch isOn] forKey:@"LoggingEnabled"];
}

- (IBAction)onStoreConfigToNV:(id)sender {
    [self.device.manager sendWriteConfigToNvCommand];
    [self showMessage:@"Settings stored"];
}

- (IBAction)onReadFromNV:(id)sender {
    [self.device.manager sendReadNvCommand];
    [self.manager readConfiguration];
    [self showMessage:@"Settings read"];
}

- (IBAction) onResetToDefaults:(id)sender {
    [self.device.manager sendResetToDefaultsCommand];
    [self.manager readConfiguration];
    [self showMessage:@"Settings reset"];
}

- (void) temperatureUnitSelection {
    [ActionSheetStringPicker showPickerWithTitle:@"Temperature Unit"
                                            rows:@[ @"Celsius", @"Fahrenheit" ]
                                initialSelection:temperatureUnit == TEMPERATURE_UNIT_CELSIUS ? 0 : 1
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           temperatureUnit = selectedIndex == 0 ? TEMPERATURE_UNIT_CELSIUS : TEMPERATURE_UNIT_FAHRENHEIT;
                                           self.temperatureUnitCell.detailTextLabel.text = temperatureUnit == TEMPERATURE_UNIT_CELSIUS ? @"Celsius" : @"Fahrenheit";
                                           self.device.temperatureSensor.displayUnit = temperatureUnit;
                                           self.device.temperatureSensor.logUnit = temperatureUnit;
                                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                           [defaults setInteger:temperatureUnit forKey:@"TemperatureUnit"];
                                       }
                                     cancelBlock:nil
                                          origin:self.temperatureUnitCell];
}

- (void) showProximityCalibrationDialog {
    UIAlertController* dialog = [UIAlertController alertControllerWithTitle:@"Proximity Calibration"
                                                                    message:@"Please remove any obstructions from the proximity sensor and press start."
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* startButton = [UIAlertAction actionWithTitle:@"Start"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self.device.manager sendProximityCalibrationCommand];
                                                           [self showMessage:@"Calibrating, please wait..." duration:10];
                                                       }];
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [dialog dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [dialog addAction:startButton];
    [dialog addAction:cancelButton];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:dialog animated:YES completion:nil];
    });
}

- (void) onConfigurationReport:(NSNotification*)notification {
    [super onConfigurationReport:notification];

    NSDictionary* report = notification.object;
    int command = [report[@"command"] intValue];
    if (command != DIALOG_WEARABLES_COMMAND_PROXIMITY_CALIBRATION)
        return;

    NSData* data = report[@"data"];
    uint8_t state = ((const uint8_t*)data.bytes)[0];
    switch (state) {
        case 1: // Calibration started
            break;
        case 0: // Calibration ended
            [self.device.manager sendReadProximityHysteresisCommand];
            [self showMessage:@"Proximity sensor calibrated." duration:1];
            break;
    }
}

@end
