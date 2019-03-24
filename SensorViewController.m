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
