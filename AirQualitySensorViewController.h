/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicImageSensorViewController.h"

@interface AirQualitySensorViewController : BasicImageSensorViewController

@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accuracyLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accuracyLabelTopMargin;

@end
