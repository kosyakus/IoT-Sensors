/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSensorConfigurationTableViewController.h"
#import "BluetoothDefines.h"
#import "IotSensorsManager.h"
#import "BluetoothManager.h"
#import "IotSensorsDevice.h"

@interface SensorAccelerometerCalibrationViewController : UIViewController

@property IotSensorsDevice* device;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *startCalibrationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;

- (IBAction) onStartCalibration:(id)sender;
- (IBAction) onSensorToggle:(id)sender;

@end
