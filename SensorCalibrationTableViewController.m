/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorCalibrationTableViewController.h"
#import "FileTableViewController.h"
#import "CalibrationSettingsManager.h"

@implementation SensorCalibrationTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.manager = self.device.calibrationSettingsManager;

    IotSettingsItem* i;
    i = self.manager.spec[@"Apply"];
    i.element = self.switchApply;
    i = self.manager.spec[@"MatrixApply"];
    i.element = self.switchMatrixApply;
    i = self.manager.spec[@"Update"];
    i.element = self.switchUpdate;
    i = self.manager.spec[@"MatrixUpdate"];
    i.element = self.switchMatrixUpdate;
    i = self.manager.spec[@"InitializeFromStaticCoeffs"];
    i.element = self.switchInitFromStatic;

    self.switchShowCalibrationOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowCalibrationOverlay"];
}

- (void) updateUI {
    [super updateUI];
    BOOL buttonsEnabled = itemsEnabled && [self.device getCalibrationMode:SENSOR_TYPE_MAGNETOMETER] != CALIBRATION_MODE_NONE;
    [self setItemEnabled:self.buttonLoadFromFile enabled:buttonsEnabled];
    [self setItemEnabled:self.buttonSaveToFile enabled:buttonsEnabled];
    [self setItemEnabled:self.buttonStoreToNV enabled:buttonsEnabled];
    [self setItemEnabled:self.buttonReset enabled:buttonsEnabled];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFileSelector"]) {
        FileTableViewController *vc = segue.destinationViewController;
        vc.sensorCalibrationTableViewController = self;
    }
}

- (void) loadCoefficients:(NSString*)fileName {
    if ([(CalibrationSettingsManager*)self.manager loadCoefficients:fileName])
        [self showMessage:@"Coefficients sent"];
    else
        [self showErrorMessage:@"Error loading coefficients"];
}

- (IBAction) onSaveCoefficients:(id)sender {
    [(CalibrationSettingsManager*) self.manager saveCoefficients];
}

- (void) onConfigurationReport:(NSNotification*)notification {
    NSDictionary* report = notification.object;
    int command = [report[@"command"] intValue];
    if (command == DIALOG_WEARABLES_COMMAND_CALIBRATION_COEFFICIENTS_READ) {
        if ([self.manager processConfigurationReport:command data:report[@"data"]])
            [self showMessage:@"Coefficients saved"];
        else
            [self showErrorMessage:@"Error saving coefficients"];
    } else {
        [super onConfigurationReport:notification];
    }
}

- (IBAction) onStoreToNV:(id)sender {
    [self.device.manager sendCalStoreNvCommand];
    [self showMessage:@"Settings stored"];
}

- (IBAction) onResetCurrentValues:(id)sender {
    [self.device.manager sendCalResetCommand];
    [self.manager readConfiguration];
    [self showMessage:@"Settings reset"];
}

- (IBAction) onSwitchShowCalibrationOverlay:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.switchShowCalibrationOverlay.on forKey:@"ShowCalibrationOverlay"];
}

@end
