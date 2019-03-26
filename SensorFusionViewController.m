/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorFusionViewController.h"
#import "FileLogger.h"
#import "BluetoothDefines.h"
#import "IotSensorsManager.h"
#import "BluetoothManager.h"
#import "APLSlideMenuViewController.h"

@implementation SensorFusionViewController {
    int calibrationState;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    self.sensor = self.device.sensorFusion;

    self.modelView.texture = [GLImage imageNamed:self.device.texture];
    self.modelView.backgroundColor = [UIColor colorWithRed:0.88 green:0.93 blue:0.96 alpha:1];
    self.modelView.blendColor = [UIColor whiteColor];
    self.modelView.modelTransform = [self createModelTransformWithRoll:0 yaw:0 pitch:0];
    self.modelView.fov = -1.0f;

    GLLight *light = [[GLLight alloc] init];
    light.transform = CATransform3DMakeTranslation(0.0f, 0.0f, -10.0f);
    light.ambientColor = [UIColor colorWithWhite:0.50f alpha:1.0f];
    self.modelView.lights = @[light];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        GLModel *model = [GLModel modelWithContentsOfFile:self.device.model];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.modelView.model = model;
        });
    });
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sensorToggleButton.title = self.device.isStarted ? @"Stop" : @"Start";
    self.magnetoStateOverlayView.hidden = YES;
    calibrationState = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSensorReport:) name:IotSensorsManagerSensorReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateMagnetometerState:) name:IotSensorsManagerMagnetometerState object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerMagnetometerState object:nil];
}

- (void) onSensorReport:(NSNotification*)notification {
    NSArray* reports = (NSArray*) notification.object;
    if (![reports containsObject:@(SENSOR_REPORT_SENSOR_FUSION)])
        return;

    IotSensorValue* value = self.sensor.valueRad;
    self.modelView.modelTransform = [self createModelTransformWithRoll:value.roll yaw:value.yaw pitch:value.pitch];
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    BOOL sensorState = [notification.object boolValue];
    self.sensorToggleButton.title = sensorState ? @"Stop" : @"Start";
}

- (CATransform3D) createModelTransformWithRoll:(float)roll yaw:(float)yaw pitch:(float)pitch {
    // Scale model
    CGFloat modelScale = 1.f;
    switch (self.device.type) {
        case DEVICE_TYPE_IOT_580:
            modelScale = self.view.frame.size.height / 70;
            break;
        case DEVICE_TYPE_WEARABLE:
            modelScale = self.view.frame.size.height / 130;
            break;
        case DEVICE_TYPE_IOT_585:
            modelScale = self.view.frame.size.height / 1400; //Natali changed 14 to 1400
            break;
    }
    CATransform3D transform = CATransform3DMakeScale(modelScale, -modelScale, modelScale);

    // Add roll, pitch, yaw.
    transform = CATransform3DRotate(transform, roll, 1.0f, 0.0f, 0.0f);
    transform = CATransform3DRotate(transform, yaw, 0.0f, 1.0f, 0.0f);
    transform = CATransform3DRotate(transform, pitch, 0.0f, 0.0f, 1.0f);

    if (self.device.type == DEVICE_TYPE_IOT_580) {
        // Apply transformations necessary for the object.
        transform = CATransform3DRotate(transform, M_PI/2, 1.0f, 0.0f, 0.0f);
        transform = CATransform3DRotate(transform, M_PI, 0.0f, 1.0f, 0.0f);
        // Align object's center.
        transform = CATransform3DTranslate(transform, 0, -12.0f, 0);
    }

    return transform;
}

- (void)didUpdateMagnetometerState:(NSNotification*)notification {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowCalibrationOverlay"])
        return;
    if (!self.device.isNewVersion)
        return;

    int oldCalibrationState = calibrationState;
    calibrationState = [notification.object[@"calibrationState"] intValue];
    if (calibrationState == oldCalibrationState)
        return;

    self.magnetoStateOverlayView.hidden = NO;
    switch (calibrationState) {
        case 0: // DISABLED
            [self.magnetoStateOverlay setImage:[UIImage imageNamed:@"mag_disabled"]];
            break;
        case 1: // INIT
            [self.magnetoStateOverlay setImage:[UIImage imageNamed:@"mag_init"]];
            break;
        case 2: // BAD
            [self.magnetoStateOverlay setImage:[UIImage imageNamed:@"mag_bad"]];
            break;
        case 3: // OK
            [self.magnetoStateOverlay setImage:[UIImage imageNamed:@"mag_ok"]];
            break;
        case 4: // GOOD
            [self.magnetoStateOverlay setImage:[UIImage imageNamed:@"mag_good"]];
            break;
        case 5: // ERROR
            [self.magnetoStateOverlay setImage:[UIImage imageNamed:@"mag_error"]];
            break;
    }
}

- (IBAction)onSensorToggleButton:(id)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [self.device.manager sendStopCommand];
    } else {
        [self.device.manager sendStartCommand];
    }
}

- (IBAction)onShowMenu:(id)sender {
    [self.slideMenuController showLeftMenu:YES];
}

@end
