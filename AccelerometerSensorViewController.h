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

@interface AccelerometerSensorViewController : ThreeDimensionSensorViewController

@property (weak, nonatomic) IBOutlet UILabel *accelerometerIntegrationLabel;

@end

@interface AccelerometerGraphValueProcessor : NSObject<GraphValueProcessor>
@end
