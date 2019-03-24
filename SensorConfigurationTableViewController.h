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
#import "BluetoothManager.h"
#import "BasicSensorConfigurationTableViewController.h"
#import "TTRangeSlider.h"

@interface SensorConfigurationTableViewController : BasicSensorConfigurationTableViewController<TTRangeSliderDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *sensorCombinationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *environmentalSensorsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *gasSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ambientLightSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *proximitySensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerRangeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *gyroscopeRangeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *gyroscopeRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *magnetometerRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *environmentalRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *proximityAmbientLightRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *operationModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sensorFusionEnabledCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sensorFusionRateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sensorFusionRawEnabledCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *calibrationModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *autoCalibrationModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerCalibrationModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *gyroscopeCalibrationModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *magnetometerCalibrationModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *proximityHysteresisRangeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *proximityCalibration;

@property (weak, nonatomic) IBOutlet UISwitch *environmentalSensorsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *gasSensorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ambientLightSensorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *proximitySensorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sensorFusionEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sensorFusionRawEnabledSwitch;
@property (weak, nonatomic) IBOutlet TTRangeSlider *proximityHysteresisRange;

@property (weak, nonatomic) IBOutlet UITableViewCell *temperatureUnitCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *firmwareVersionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *loggingEnabledCell;
@property (weak, nonatomic) IBOutlet UISwitch *loggingEnabledSwitch;

@property (weak, nonatomic) IBOutlet UIButton *storeConfigurationNVButton;
@property (weak, nonatomic) IBOutlet UIButton *readFromNVButton;
@property (weak, nonatomic) IBOutlet UIButton *resetToDefaultsButton;

- (IBAction)onLogEnableSwitch:(id)sender;
- (IBAction)onStoreConfigToNV:(id)sender;
- (IBAction)onReadFromNV:(id)sender;
- (IBAction)onResetToDefaults:(id)sender;

@end
