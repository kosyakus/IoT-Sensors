/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorViewController.h"
#import "BluetoothDefines.h"
#import "BluetoothManager.h"
#import "GyroscopeSensorViewController.h"
#import "AccelerometerSensorViewController.h"

#import "APLSlideMenuViewController.h"

@implementation SensorViewController {
    int calibrationState;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;

    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    [self.navigationItem setRightBarButtonItems:toolbarButtons animated:NO];
    self.sensorViewMagnetometer.imageViewCalibrated.hidden = YES;
    self.sensorViewMagnetometer.imageViewWarning.hidden = YES;
    self.buttonOverlay.tintColor = UIColorWithRGB(0x1E88E5);
    self.buttonOverlayView.hidden = YES;
    
    //Natali addede for model
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
    
    //
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sensorToggleButton.title = self.device.isStarted ? @"Stop" : @"Start";
    self.buttonOverlayView.hidden = !self.device.buttonSensor.isPressed;
    self.magnetoStateOverlayView.hidden = YES;
    calibrationState = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSensorReport:) name:IotSensorsManagerSensorReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfigurationReport:) name:IotSensorsManagerConfigurationReport object:nil];
    if (self.magnetoStateOverlay)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateMagnetometerState:) name:IotSensorsManagerMagnetometerState object:nil];

    if (self.device.features.hasIntegrationEngine) {
        self.sensorViewAccelerometer.sensor = !self.device.integrationEngine ? self.device.accelerometer : self.device.accelerometerIntegration;
        self.sensorViewGyroscope.sensor = !self.device.integrationEngine ? self.device.gyroscope : self.device.gyroscopeAngleIntegration;
    }
    
    
    //Natali added for model view
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSensorReport1:) name:IotSensorsManagerSensorReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState1:) name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateMagnetometerState1:) name:IotSensorsManagerMagnetometerState object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerConfigurationReport object:nil];
    if (self.magnetoStateOverlay)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerMagnetometerState object:nil];
}

- (void) onSensorReport:(NSNotification*)notification {
    NSArray* reports = (NSArray*) notification.object;
    for (NSNumber* id in reports) {
        switch (id.intValue) {
            case SENSOR_REPORT_TEMPERATURE:
                self.sensorViewTemperature.needsUpdate = true;
                break;
            case SENSOR_REPORT_HUMIDITY:
                self.sensorViewHumidity.needsUpdate = true;
                break;
            case SENSOR_REPORT_PRESSURE:
                self.sensorViewPressure.needsUpdate = true;
                break;
            case SENSOR_REPORT_ACCELEROMETER:
            case SENSOR_REPORT_VELOCITY_DELTA:
                self.sensorViewAccelerometer.needsUpdate = true;
                break;
            case SENSOR_REPORT_GYROSCOPE:
            case SENSOR_REPORT_EULER_ANGLE_DELTA:
                self.sensorViewGyroscope.needsUpdate = true;
                break;
            case SENSOR_REPORT_MAGNETOMETER:
                self.sensorViewMagnetometer.needsUpdate = true;
                break;
            case SENSOR_REPORT_AMBIENT_LIGHT:
                self.sensorViewAmbientLight.needsUpdate = true;
                break;
            case SENSOR_REPORT_AIR_QUALITY:
                self.sensorViewAirQuality.needsUpdate = true;
                break;
            case SENSOR_REPORT_PROXIMITY:
                self.sensorViewProximity.needsUpdate = true;
                break;
            case SENSOR_REPORT_BUTTON:
                self.buttonOverlayView.hidden = !self.device.buttonSensor.isPressed;
                break;
        }
    }
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    BOOL sensorState = [notification.object boolValue];
    self.sensorToggleButton.title = sensorState ? @"Stop" : @"Start";
}

- (void) onConfigurationReport:(NSNotification*)notification {
    if (self.device.features.hasIntegrationEngine) {
        self.sensorViewAccelerometer.sensor = !self.device.integrationEngine ? self.device.accelerometer : self.device.accelerometerIntegration;
        self.sensorViewGyroscope.sensor = !self.device.integrationEngine ? self.device.gyroscope : self.device.gyroscopeAngleIntegration;
    }
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


//Natali added for model view
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
            modelScale = self.view.frame.size.height / 14;
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

- (void) onSensorReport1:(NSNotification*)notification {
    NSArray* reports = (NSArray*) notification.object;
    if (![reports containsObject:@(SENSOR_REPORT_SENSOR_FUSION)])
        return;
    
    IotSensorValue* value = self.sensor.valueRad;
    self.modelView.modelTransform = [self createModelTransformWithRoll:value.roll yaw:value.yaw pitch:value.pitch];
}

- (void) didUpdateSensorState1:(NSNotification*)notification {
    BOOL sensorState = [notification.object boolValue];
    self.sensorToggleButton.title = sensorState ? @"Stop" : @"Start";
}

- (void)didUpdateMagnetometerState1:(NSNotification*)notification {
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




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sensorAccelerometer"]) {
        self.sensorViewAccelerometer = segue.destinationViewController;
        self.sensorViewAccelerometer.sensor = !self.device.integrationEngine ? self.device.accelerometer : self.device.accelerometerIntegration;
    } else if ([segue.identifier isEqualToString:@"sensorGyroscope"]) {
        self.sensorViewGyroscope = segue.destinationViewController;
        self.sensorViewGyroscope.sensor = !self.device.integrationEngine ? self.device.gyroscope : self.device.gyroscopeAngleIntegration;
    } else if ([segue.identifier isEqualToString:@"sensorMagnetometer"]) {
        self.sensorViewMagnetometer = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"sensorTemperature"]) {
        self.sensorViewTemperature = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"sensorPressure"]) {
        self.sensorViewPressure = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"sensorHumidity"]) {
        self.sensorViewHumidity = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"sensorAmbientLight"]) {
        self.sensorViewAmbientLight = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"sensorAirQuality"]) {
        self.sensorViewAirQuality = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"sensorProximity"]) {
        self.sensorViewProximity = segue.destinationViewController;
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
