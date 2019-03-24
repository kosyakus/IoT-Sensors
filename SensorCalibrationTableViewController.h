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
#import "IotSensorsManager.h"
#import "BasicSensorConfigurationTableViewController.h"

@interface SensorCalibrationTableViewController : BasicSensorConfigurationTableViewController

@property (weak, nonatomic) IBOutlet UISwitch *switchApply;
@property (weak, nonatomic) IBOutlet UISwitch *switchMatrixApply;
@property (weak, nonatomic) IBOutlet UISwitch *switchUpdate;
@property (weak, nonatomic) IBOutlet UISwitch *switchMatrixUpdate;
@property (weak, nonatomic) IBOutlet UISwitch *switchInitFromStatic;
@property (weak, nonatomic) IBOutlet UISwitch *switchShowCalibrationOverlay;

@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellCalibrationMode;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellApply;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMatrixApply;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellUpdate;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMatrixUpdate;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellInitFromStatic;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellReferenceMagnitude;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMagnitudeRange;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMu;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMagAlpha;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMagnitudeGradientThreshold;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellOffsetMu;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellMatrixMu;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellErrorAlpha;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableCellErrorThreshold;

@property (weak, nonatomic) IBOutlet UIButton *buttonLoadFromFile;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveToFile;
@property (weak, nonatomic) IBOutlet UIButton *buttonStoreToNV;
@property (weak, nonatomic) IBOutlet UIButton *buttonReset;

- (IBAction) onSaveCoefficients:(id)sender;
- (IBAction) onStoreToNV:(id)sender;
- (IBAction) onResetCurrentValues:(id)sender;
- (IBAction) onSwitchShowCalibrationOverlay:(id)sender;

- (void) loadCoefficients:(NSString*)fileName;

@end
