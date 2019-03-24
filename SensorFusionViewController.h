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
#import "GLModelView.h"
#import "IotSensorsDevice.h"

@interface SensorFusionViewController : UIViewController

@property IotSensorsDevice* device;
@property SensorFusion* sensor;

@property (weak, nonatomic) IBOutlet GLModelView *modelView;
@property (weak, nonatomic) IBOutlet UIView *magnetoStateOverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *magnetoStateOverlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;

- (IBAction)onSensorToggleButton:(id)sender;
- (IBAction)onShowMenu:(id)sender;

@end
