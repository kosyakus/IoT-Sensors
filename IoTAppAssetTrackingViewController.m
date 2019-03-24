/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IoTAppAssetTrackingViewController.h"
#import "Cloud/CloudManager.h"
#import "CloudAPI.h"
#import "SettingsVault.h"
#import "MBProgressHUD.h"
#import "IoT_Sensors-Swift.h"


@interface IoTAppAssetTrackingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *deviceIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *assetNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;
@property (weak, nonatomic) IBOutlet UIView *hudHostView;
@property (weak, nonatomic) IBOutlet UIProgressView *scanProgressView;
@property (weak, nonatomic) IBOutlet UIButton *startScanButton;

@property (strong, nonatomic) NSString *closestDeviceId;
@property (strong, nonatomic) NSNumber *closestDeviceRssi;

@property (strong, nonatomic) NSString *selectedDeviceId;

@end

@implementation IoTAppAssetTrackingViewController{}

- (void) viewDidLoad {
    [super viewDidLoad];

    if (BluetoothManager.instance.device.state != CBPeripheralStateConnected)
        self.navigationItem.rightBarButtonItems = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Set navigation bar sensor toggle button
    self.sensorToggleButton.title = [[CloudManager sharedCloudManager] getConnectedDevice].isStarted ? @"Stop" : @"Start";

    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdvertiseRx:) name:NotificationBLEAdvertisementRx object:nil];

    [self.scanProgressView setHidden:YES];

    self.closestDeviceId = nil;
    self.closestDeviceRssi = [NSNumber numberWithFloat:-100.0];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationBLEAdvertisementRx object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI actions

- (IBAction)assetTrackingStartScanButtonClicked:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudHostView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Scan started. Please bring your IoT+ in close proximity to your mobile device.";
    hud.removeFromSuperViewOnHide = YES;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.labelFont = [UIFont fontWithName:@"Helvetica-Neue" size:8];
    [hud sizeToFit];
    [hud hide:YES afterDelay:4];

    [self.scanProgressView setHidden:NO];
    [self.scanProgressView setProgress:0];

    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onScanTimerFired) userInfo:nil repeats:NO];
}

- (IBAction)assetTrackingSelectButtonClicked:(UIButton *)sender {

    [self.startScanButton setEnabled:YES];
    [self.scanProgressView setHidden:YES];

    self.selectedDeviceId = self.deviceIdTextField.text;
}

- (IBAction)assetTrackingApplyButtonClicked:(UIButton *)sender {

    // Send to cloud
    AssetTrackingSetTagReq *req = [[AssetTrackingSetTagReq alloc] init];
    req.OperationType = eAssetTrackingOperationTypes_Insert;
    req.Tag = [[AssetTrackingTag alloc] init];
    req.Tag.TagId = self.selectedDeviceId;
    req.Tag.FriendlyName = self.assetNameTextField.text;
    req.Tag.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    // Validations
    if ([req.Tag.TagId isEqual:@""] || req.Tag.TagId == nil ||
        [req.Tag.FriendlyName isEqualToString:@""] || req.Tag.FriendlyName == nil) {

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudHostView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Please fill in device id and asset name";
        hud.removeFromSuperViewOnHide = YES;
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        [hud hide:YES afterDelay:4];

        return;
    }

    NSString *finalUrl = [AssetTrackingSetTagReq constructRoute];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    if (error == nil) {
                                                        NSLog(@"[IoT App AssetTracking] SetAssetTrackingTag request sent.");

                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudHostView animated:YES];
                                                            hud.mode = MBProgressHUDModeText;
                                                            hud.labelText = @"New asset successfully set";
                                                            hud.removeFromSuperViewOnHide = YES;
                                                            hud.margin = 10.f;
                                                            hud.yOffset = 150.f;
                                                            [hud hide:YES afterDelay:2];
                                                        });
                                                    }
                                                }];

    [dataTask resume];
}

- (IBAction)sensorToggleButton:(UIBarButtonItem *)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [[[CloudManager sharedCloudManager] getConnectedDevice].manager sendStopCommand];
    } else {
        [[[CloudManager sharedCloudManager] getConnectedDevice].manager sendStartCommand];
    }
}

#pragma mark - Observer handlers

- (void) didUpdateSensorState:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sensorToggleButton.title = [notification.object boolValue] ? @"Stop" : @"Start";
    });
}

- (void) onAdvertiseRx:(NSNotification *)notification {
    NSString *candidateDeviceId = [(NSString *)notification.object componentsSeparatedByString:@" "][0];

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *candidateDeviceRssi = [f numberFromString:[(NSString *)notification.object componentsSeparatedByString:@" "][1]];

    if (candidateDeviceRssi > self.closestDeviceRssi) {
        self.closestDeviceId = candidateDeviceId;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.deviceIdTextField.text = self.closestDeviceId;
    });
}

-(void)onScanTimerFired {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.startScanButton setEnabled:YES];
        [self.scanProgressView setHidden:YES];
    });

    self.selectedDeviceId = self.deviceIdTextField.text;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*if ([segue.identifier isEqualToString:@"sensorAccelerometer"]) {
     self.sensorViewAccelerometer = segue.destinationViewController;
     }*/
}

@end


