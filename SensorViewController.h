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
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothManager.h"
#import "IotSensorsManager.h"
#import "IotSensorsDevice.h"
#import "BasicSensorViewController.h"
#import "MagnetoSensorViewController.h"

@interface SensorViewController : UIViewController <UIActionSheetDelegate>

@property IotSensorsDevice* device;

@property BasicSensorViewController *sensorViewAccelerometer;
@property BasicSensorViewController *sensorViewGyroscope;
@property MagnetoSensorViewController *sensorViewMagnetometer;
@property BasicSensorViewController *sensorViewTemperature;
@property BasicSensorViewController *sensorViewHumidity;
@property BasicSensorViewController *sensorViewPressure;
@property BasicSensorViewController *sensorViewAmbientLight;
@property BasicSensorViewController *sensorViewAirQuality;
@property BasicSensorViewController *sensorViewProximity;

@property (weak, nonatomic) IBOutlet UIView *magnetoStateOverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *magnetoStateOverlay;
@property (weak, nonatomic) IBOutlet UIView *buttonOverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *buttonOverlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;

//Natali added
@property (weak, nonatomic) IBOutlet GLModelView *modelView;
@property SensorFusion* sensor;


- (IBAction)onSensorToggleButton:(id)sender;
- (IBAction)onShowMenu:(id)sender;

@end
