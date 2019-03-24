/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

/*
 * This file includes code snippets from:
 * http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
 *
 * Copyright (C) 2008-2018 Matt Gallagher ( https://www.cocoawithlove.com ). All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is
 * hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
 * SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
 * THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
 * DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
 * CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "IoTAppAlertingViewController.h"
#import "Cloud/CloudManager.h"
#import "CloudAPI.h"
#import "SettingsVault.h"

#import "IoT_Sensors-Swift.h"

#import "MBProgressHUD.h"

//******************************************************************************
// From: http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static CGFloat animatedDistance;
//******************************************************************************

NSInteger const DEVICE_PV_TAG = 21;
NSInteger const SENSOR_PV_TAG = 22;
NSInteger const OPERATOR_PV_TAG = 23;


@interface IoTAppAlertingViewController ()

@property (strong, nonatomic) NSString *selectedDevice;
@property (nonatomic) NSInteger selectedSensor;
@property (nonatomic) NSInteger selectedOperator;

@property (strong, nonatomic) NSMutableArray<EKDevice> *userDevices;

@property (strong, nonatomic) NSArray *alertingSensorsArray;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;
@property (weak, nonatomic) IBOutlet UILabel *activeRulesLabel;
@property (weak, nonatomic) IBOutlet UIButton *rulesSyncButton;
@property (weak, nonatomic) IBOutlet UITextField *ruleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *editValueTextField;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectDeviceTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectSensorTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectOperatorTextField;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *topLevelView;

@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@end



@implementation IoTAppAlertingViewController{}

- (void) viewDidLoad {
    [super viewDidLoad];

    if (BluetoothManager.instance.device.state != CBPeripheralStateConnected)
        self.navigationItem.rightBarButtonItems = nil;

    [[CloudManager sharedCloudManager] startCloudManager];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];

    // Wait for pickers to populate
    [self setViewLoadingPendingState:YES];

    // Send MgmtGetEKIDReq
    MgmtGetEKIDReq *req = [[MgmtGetEKIDReq alloc] init];
    req.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSString *finalUrl = [[MgmtGetEKIDReq constructGetEKIDReqRoute] stringByAppendingString:[MgmtGetEKIDReq constructUrlParams:req]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    JSONModelError *err;
                                                    MgmtGetEKIDRsp *rsp = [[MgmtGetEKIDRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                    if (err != nil) {
                                                        NSLog(@" MgmtGetEKIDRsp deserialization error: %@ ", error.description);
                                                    }

                                                    self.userDevices = rsp.Devices;

                                                    [self setViewLoadingPendingState:NO];
                                                }];
    [dataTask resume];

    // Send GetAlertingRulesReq
    AlertingGetRulesReq *getRulesReq = [[AlertingGetRulesReq alloc] init];
    getRulesReq.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSURLSession *getRulesReqSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *getRulesRequest = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:[[AlertingGetRulesReq constructRoute]
                                                                              stringByAppendingString:[AlertingGetRulesReq constructUrlParams:getRulesReq]]]];
    [getRulesRequest setHTTPMethod:@"GET"];
    NSURLSessionDataTask *getRulesReqDataTask = [getRulesReqSession dataTaskWithRequest:getRulesRequest
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    JSONModelError *err;
                                                    AlertingGetRulesRsp *rsp = [[AlertingGetRulesRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                    if (err != nil) {
                                                        NSLog(@" AlertingGetRulesRsp deserialization error: %@ ", error.description);
                                                    }

                                                    NSIndexSet *indexes = [rsp.Rules indexesOfObjectsPassingTest:
                                                                           ^BOOL (id el, NSUInteger i, BOOL *stop) {
                                                                               return ((AlertingRule *)rsp.Rules[i]).IsEnabled == YES;
                                                                           }];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.activeRulesLabel.text = [[@([indexes count]) stringValue] stringByAppendingString:@" ACTIVE RULES"];
                                                    });
                                                }];
    [getRulesReqDataTask resume];

    self.sensorToggleButton.title = [[CloudManager sharedCloudManager] getConnectedDevice].isStarted ? @"Stop" : @"Start";
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
}



#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI actions

- (IBAction)applyButton:(UIButton *)sender forEvent:(UIEvent *)event {
    if (sender.state == true) {

        AlertingSetRuleReq *req = [[AlertingSetRuleReq alloc] init];
        req.OperationType = eAlertingSetRuleOperationTypes_Insert;
        req.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
        req.Rule = [[AlertingRule alloc] init];
        req.Rule.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
        req.Rule.EKID = self.selectedDevice;
        req.Rule.Name = self.ruleNameTextField.text;
        req.Rule.SensorType = self.selectedSensor;
        req.Rule.Email = self.emailTextField.text;
        req.Rule.OperatorType = self.selectedOperator;
        req.Rule.Value = [NSNumber numberWithFloat:[self.editValueTextField.text floatValue]];
        req.Rule.FriendlyDescription = [self constructRuleDescription:req.Rule];
        req.Rule.IsEnabled = YES;

        NSString *finalUrl = [AlertingSetRuleReq constructRoute];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                        if (error == nil) {
                                                            NSLog(@"[IoT App Alerting] Alerting rule set request sent.");

                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.topLevelView animated:YES];
                                                                hud.mode = MBProgressHUDModeText;
                                                                hud.labelText = @"Alerting rule successfully set";
                                                                hud.removeFromSuperViewOnHide = YES;
                                                                hud.margin = 10.f;
                                                                hud.yOffset = 150.f;
                                                                [hud hide:YES afterDelay:2];
                                                            });
                                                        }
                                                    }];

        [dataTask resume];
    }
}

- (IBAction)rulesSyncButton:(UIButton *)sender forEvent:(UIEvent *)event {
    // Send GetAlertingRulesReq
    AlertingGetRulesReq *getRulesReq = [[AlertingGetRulesReq alloc] init];
    getRulesReq.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSURLSession *getRulesReqSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *getRulesRequest = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:[[AlertingGetRulesReq constructRoute]
                                                                              stringByAppendingString:[AlertingGetRulesReq constructUrlParams:getRulesReq]]]];
    [getRulesRequest setHTTPMethod:@"GET"];
    NSURLSessionDataTask *getRulesReqDataTask = [getRulesReqSession dataTaskWithRequest:getRulesRequest
                                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                          JSONModelError *err;
                                                                          AlertingGetRulesRsp *rsp = [[AlertingGetRulesRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                                          if (err != nil) {
                                                                              NSLog(@" AlertingGetRulesRsp deserialization error: %@ ", error.description);
                                                                          }

                                                                          NSIndexSet *indexes = [rsp.Rules indexesOfObjectsPassingTest:
                                                                                                 ^BOOL (id el, NSUInteger i, BOOL *stop) {
                                                                                                     return ((AlertingRule *)rsp.Rules[i]).IsEnabled == YES;
                                                                                                 }];
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              self.activeRulesLabel.text = [[@([indexes count]) stringValue] stringByAppendingString:@" ACTIVE RULES"];
                                                                          });

                                                                          [self setViewLoadingPendingState:NO];

                                                                      }];
    [getRulesReqDataTask resume];

}

- (IBAction)ruleNameTextField:(UITextField *)sender {
}

- (IBAction)editValueTextField:(UITextField *)sender {
}

- (IBAction)emailTextField:(UITextField *)sender {
}

// From: http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
- (IBAction)emailTextFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}

// From: http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
- (IBAction)emailTextFieldDidFinishEditing:(UITextField *)sender {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}

- (IBAction)selectDeviceTextFieldTouchDown:(UITextField *)sender {
    if (self.selectDeviceTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectDeviceTextField setInputView:pickerView];
    }
}

- (IBAction)selectSensorTextFieldTouchDown:(UITextField *)sender {
    if (self.selectSensorTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectSensorTextField setInputView:pickerView];
    }
}

- (IBAction)selectOperatorTextFieldTouchDown:(UITextField *)sender {
    if (self.selectOperatorTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectOperatorTextField setInputView:pickerView];
    }
}

- (IBAction)sensorToggleButton:(UIBarButtonItem *)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [[[CloudManager sharedCloudManager] getConnectedDevice].manager sendStopCommand];
    } else {
        [[[CloudManager sharedCloudManager] getConnectedDevice].manager sendStartCommand];
    }
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sensorToggleButton.title = [notification.object boolValue] ? @"Stop" : @"Start";
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

// CAUTION: Use from within the correct context
- (void)setViewLoadingPendingState:(BOOL)state {
    if (state == YES) {
        [self.loadingView setOpaque:true];
        [self.loadingView setHidden:false];
        [self.loadingView setAlpha:0.5];
        [self.topLevelView setUserInteractionEnabled:false];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView setOpaque:false];
            [self.loadingView setHidden:true];
            [self.topLevelView setUserInteractionEnabled:true];

            [self setUIDefaults];
        });
    }
}

-(void)setUIDefaults {
    if ([self.userDevices count] != 0) {
        self.selectedDevice = ((EKDevice *)[self.userDevices objectAtIndex:0]).EKID;
        self.selectDeviceTextField.text = self.selectedDevice;
    }

    self.selectedSensor = eAlertingSensors_Temperature;
    self.selectSensorTextField.text = [[self alertingSensors] objectAtIndex:eAlertingSensors_Temperature];
    self.unitsLabel.text = @"\u00B0 C";

    self.selectedOperator = eCommonComparisonOperators_Greater;
    self.selectOperatorTextField.text = [[self alertingOperators] objectAtIndex:eCommonComparisonOperators_Greater];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*if ([segue.identifier isEqualToString:@"sensorAccelerometer"]) {
     self.sensorViewAccelerometer = segue.destinationViewController;
     }*/
}



#pragma mark - Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    NSInteger nRows = 0;
    if (pickerView.tag == DEVICE_PV_TAG) {
        nRows = [self.userDevices count];
    }
    else if (pickerView.tag == SENSOR_PV_TAG) {
        nRows = eAlertingSensors_Count;
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        nRows = eCommonComparisonOperators_Count;
    }

    return nRows;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSAttributedString *title;
    if (pickerView.tag == DEVICE_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:((EKDevice *)[self.userDevices objectAtIndex:row]).EKID
                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightLight],
                                                             NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    else if (pickerView.tag == SENSOR_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self alertingSensors] objectAtIndex:row]
                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightLight],
                                                             NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self alertingOperators] objectAtIndex:row]
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightLight],
                                                     NSForegroundColorAttributeName: [UIColor blackColor]}];
    }

    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (pickerView.tag == DEVICE_PV_TAG) {
        self.selectedDevice = ((EKDevice *)[self.userDevices objectAtIndex:row]).EKID;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectDeviceTextField.text = self.selectedDevice;
        });
    }
    else if (pickerView.tag == SENSOR_PV_TAG) {
        self.selectedSensor = row;

        // Modify units label based on sensor selection
        NSString *unitsStr = @"PA";
        switch(self.selectedSensor) {
            case eAlertingSensors_Temperature:
                unitsStr = @"\u00B0 C";
                break;
            case eAlertingSensors_Humidity:
                unitsStr = @"%";
                break;
            case eAlertingSensors_Pressure:
                unitsStr = @"PA";
                break;
            case eAlertingSensors_AirQuality:
                unitsStr = @"-";
                break;
            case eAlertingSensors_Brightness:
                unitsStr = @"lux";
                break;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectSensorTextField.text = (NSString *)[[self alertingSensors] objectAtIndex:row];
            self.unitsLabel.text = unitsStr;
        });
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        self.selectedOperator = row;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectOperatorTextField.text = (NSString *)[[self alertingOperators] objectAtIndex:row];
        });
    }
}

#pragma mark - Helpers

- (NSArray *)alertingSensors {
    return [NSArray arrayWithObjects:@"Temperature",@"Humidity",@"Pressure",@"AirQuality",@"Brightness", nil];
}

- (NSArray *)alertingOperators {
    return [NSArray arrayWithObjects:@"==",@">",@">=",@"<",@"<=", nil];
}

-(NSString *)constructRuleDescription:(AlertingRule *)rule {
    NSMutableString *d = [NSMutableString stringWithString:@"If "];

    [d appendString:[[self alertingSensors] objectAtIndex:rule.SensorType]];
    [d appendString:@" becomes "];
    [d appendString:[[self alertingOperators] objectAtIndex:rule.OperatorType]];
    [d appendString:@" "];
    [d appendString:[rule.Value stringValue]];
    [d appendString:@" then send e-mail to "];
    [d appendString:rule.Email];
    return d;
}

@end

