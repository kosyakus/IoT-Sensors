/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ThreeDimensionSensorViewController.h"

@interface MagnetoSensorViewController : ThreeDimensionSensorViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageViewCalibrated;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewWarning;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@end

@interface MagnetometerGraphValueProcessor : NSObject<GraphValueProcessor>
@end
