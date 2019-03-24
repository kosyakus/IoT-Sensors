/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSensorViewController.h"
#import "GLModelView.h"

@interface ThreeDimensionSensorViewController : BasicSensorViewController

@property (weak, nonatomic) IBOutlet GLModelView *modelView;

- (ChartDataEntryBuffer3D*) graphData3D;

@end
