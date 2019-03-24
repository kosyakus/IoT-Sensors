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
#import "IotSensorsDevice.h"

@interface MenuViewController : UIViewController {
    int magnetometerCalibrationStatusPrevious;
}

@property IotSensorsDevice* device;

- (IBAction)disconnect:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *magnetometerStatusIntroLabel;
@property (weak, nonatomic) IBOutlet UIView *magnetometerStatusIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *magnetometerStatusLabel;

@end
