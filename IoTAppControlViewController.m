/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IoTAppControlViewController.h"
#import "Cloud/CloudManager.h"
#import "CloudAPI.h"
#import "SettingsVault.h"

#import "IoT_Sensors-Swift.h"

#import "MBProgressHUD.h"

//******************************************************************************
//******************************************************************************

static NSInteger const RULENAME_PV_TAG = 31;
static NSInteger const DEVICE_PV_TAG = 32;
static NSInteger const CONDITION_PV_TAG = 33;
static NSInteger const SUBCONDITION_PV_TAG = 34;
static NSInteger const CITY_PV_TAG = 35;
static NSInteger const OPERATOR_PV_TAG = 36;
static NSInteger const VALUE_PV_TAG = 37;
static NSInteger const ACTUATOR_PV_TAG = 38;
static NSInteger const ACTUATORSTATE_PV_TAG = 39;


@interface IoTAppControlViewController ()

@property (strong, nonatomic) NSString *selectedDevice;
@property (nonatomic) NSInteger selectedCondition;
@property (strong, nonatomic) NSString *selectedSubCondition;
@property (nonatomic) NSInteger selectedOperator;
@property (nonatomic) NSInteger selectedActuator;
@property (nonatomic) BOOL selectedActuatorState;

@property (strong, nonatomic) NSMutableArray<EKDevice> *userDevices;

@property (strong, nonatomic) NSArray *alertingSensorsArray;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;
@property (weak, nonatomic) IBOutlet UILabel *activeRulesLabel;
@property (weak, nonatomic) IBOutlet UITextField *selectConditionTextField;
@property (weak, nonatomic) IBOutlet UILabel *inCityLabel;
@property (weak, nonatomic) IBOutlet UITextField *selectSubConditionTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UIButton *rulesSyncButton;
@property (weak, nonatomic) IBOutlet UITextField *ruleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *editValueTextField;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UITextField *selectDeviceTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectOperatorTextField;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (weak, nonatomic) IBOutlet UITextField *selectActuatorTextField;
@property (weak, nonatomic) IBOutlet UITextField *selectActuatorStateTextField;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@end



@implementation IoTAppControlViewController{}

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

    // Send GetControlRulesReq
    ControlGetRulesReq *getRulesReq = [[ControlGetRulesReq alloc] init];
    getRulesReq.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSURLSession *getRulesReqSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString *getRulesUrl = [[ControlGetRulesReq constructRoute]
                             stringByAppendingString:[ControlGetRulesReq constructUrlParams:getRulesReq]];
    NSMutableURLRequest *getRulesRequest = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:getRulesUrl]];
    [getRulesRequest setHTTPMethod:@"GET"];
    NSURLSessionDataTask *getRulesReqDataTask = [getRulesReqSession dataTaskWithRequest:getRulesRequest
                                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                          JSONModelError *err;
                                                                          ControlGetRulesRsp *rsp = [[ControlGetRulesRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                                          if (err != nil) {
                                                                              NSLog(@" ControlGetRulesRsp deserialization error: %@ ", error.description);
                                                                          }

                                                                          NSIndexSet *indexes = [rsp.ControlRules indexesOfObjectsPassingTest:
                                                                                                 ^BOOL (id el, NSUInteger i, BOOL *stop) {
                                                                                                     return ((ControlRule *)rsp.ControlRules[i]).IsEnabled == YES;
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

-(NSString *)constructRuleDescription:(ControlRule *)rule {
    NSMutableString *d = [NSMutableString stringWithString:@"If "];

    [d appendString:[[self controlConditions] objectAtIndex:rule.Condition]];
    [d appendString:@","];
    [d appendString: rule.SubCondition];
    [d appendFormat:@" "];
    if (rule.Condition == eControlCloudRuleConditions_Weather) {
        [d appendString:@"in "];
        [d appendString:rule.City];
    }

    [d appendString:@" becomes "];
    [d appendString:[[self controlOperators] objectAtIndex:rule.OperatorType]];
    [d appendString:@" "];
    [d appendString:[rule.Value stringValue]];
    [d appendString:@" then switch led "];
    [d appendString:[[self controlActuatorsStates] objectAtIndex:(rule.ActuatorValue == YES) ? 0 : 1]];
    
    return d;
}

#pragma mark - UI actions

- (IBAction)applyButton:(UIButton *)sender forEvent:(UIEvent *)event {
    if (sender.state == true) {

        ControlSetRuleReq *req = [[ControlSetRuleReq alloc] init];
        req.OperationType = eControlSetRuleOperationTypes_Insert;
        req.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
        req.Rule = [[ControlRule alloc] init];
        req.Rule.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
        req.Rule.EKID = self.selectedDevice;
        req.Rule.Name = self.ruleNameTextField.text;
        req.Rule.Condition = self.selectedCondition;
        req.Rule.SubCondition = self.selectedSubCondition;
        req.Rule.City = self.cityTextField.text;
        req.Rule.OperatorType = self.selectedOperator;
        req.Rule.Value = [NSNumber numberWithFloat:[self.editValueTextField.text floatValue]];
        req.Rule.ActuatorType = self.selectedActuator;
        req.Rule.ActuatorValue = self.selectedActuatorState;
        req.Rule.FriendlyDescription = [self constructRuleDescription:req.Rule];
        req.Rule.IsEnabled = YES;

        NSString *finalUrl = [ControlSetRuleReq constructRoute];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                        if (error == nil) {
                                                            NSLog(@"[IoT App Control] Control rule set request sent.");

                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.topLevelView animated:YES];
                                                                hud.mode = MBProgressHUDModeText;
                                                                hud.labelText = @"Control rule successfully set";
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
    // Send GetControlRulesReq
    ControlGetRulesReq *getRulesReq = [[ControlGetRulesReq alloc] init];
    getRulesReq.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSURLSession *getRulesReqSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString *getRulesUrl = [[ControlGetRulesReq constructRoute]
                             stringByAppendingString:[ControlGetRulesReq constructUrlParams:getRulesReq]];
    NSMutableURLRequest *getRulesRequest = [[NSMutableURLRequest alloc]
                                            initWithURL:[NSURL URLWithString:getRulesUrl]];
    [getRulesRequest setHTTPMethod:@"GET"];
    NSURLSessionDataTask *getRulesReqDataTask = [getRulesReqSession dataTaskWithRequest:getRulesRequest
                                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                          JSONModelError *err;
                                                                          ControlGetRulesRsp *rsp = [[ControlGetRulesRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                                          if (err != nil) {
                                                                              NSLog(@" ControlGetRulesRsp deserialization error: %@ ", error.description);
                                                                          }

                                                                          NSIndexSet *indexes = [rsp.ControlRules indexesOfObjectsPassingTest:
                                                                                                 ^BOOL (id el, NSUInteger i, BOOL *stop) {
                                                                                                     return ((ControlRule *)rsp.ControlRules[i]).IsEnabled == YES;
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

- (IBAction)selectDeviceTextFieldTouchDown:(UITextField *)sender {
    if (self.selectDeviceTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [pickerView setBackgroundColor:[UIColor whiteColor]];
        [self.selectDeviceTextField setInputView:pickerView];
    }
}

- (IBAction)selectConditionTextFieldTouchDown:(UITextField *)sender {
    if (self.selectConditionTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectConditionTextField setInputView:pickerView];
    }
}

- (IBAction)selectSubConditionTextFieldTouchDown:(UITextField *)sender {
    if (self.selectSubConditionTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectSubConditionTextField setInputView:pickerView];
    }
}

- (IBAction)selectActuatorTextFieldTouchDown:(UITextField *)sender {
    if (self.selectActuatorTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectActuatorTextField setInputView:pickerView];
    }
}

- (IBAction)selectActuatorStateTextFieldTouchDown:(UITextField *)sender {
    if (self.selectActuatorStateTextField.inputView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.tag = sender.tag;
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        [self.selectActuatorStateTextField setInputView:pickerView];
    }
}

- (IBAction)cityTextFieldDidFinishEditing:(UITextField *)sender {
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

    self.selectedCondition = eControlCloudRuleConditions_Weather;
    self.selectConditionTextField.text = [[self controlConditions] objectAtIndex:eControlCloudRuleConditions_Weather];

    self.selectedSubCondition = @"Temperature";
    self.selectSubConditionTextField.text = self.selectedSubCondition;
    self.unitsLabel.text = @"\u00B0 C";

    self.selectedOperator = eCommonComparisonOperators_Greater;
    self.selectOperatorTextField.text = [[self controlOperators] objectAtIndex:eCommonComparisonOperators_Greater];

    self.selectedActuator = eControlActuators_Led;
    self.selectActuatorTextField.text = [[self controlActuators] objectAtIndex:eControlActuators_Led];

    self.selectedActuatorState = YES;
    self.selectActuatorStateTextField.text = [[self controlActuatorsStates] objectAtIndex:0];
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
    else if (pickerView.tag == CONDITION_PV_TAG) {
        nRows = eControlCloudRuleConditions_Count;
    }
    else if (pickerView.tag == SUBCONDITION_PV_TAG) {
        nRows = [[self controlForexSymbols] count];
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        nRows = eCommonComparisonOperators_Count;
    }
    else if (pickerView.tag == ACTUATOR_PV_TAG) {
        nRows = [[self controlActuators] count];
    }
    else if (pickerView.tag == ACTUATORSTATE_PV_TAG) {
        nRows = [[self controlActuatorsStates] count];
    }

    return nRows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];

    if (pickerView.tag == DEVICE_PV_TAG) {
        label.text  = ((EKDevice *)[self.userDevices objectAtIndex:row]).EKID;
    }
    else if (pickerView.tag == CONDITION_PV_TAG) {
        label.text  = [[self controlConditions] objectAtIndex:row];
    }
    else if (pickerView.tag == SUBCONDITION_PV_TAG) {
        label.text  = [[self controlForexSymbols] objectAtIndex:row];
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        label.text  = [[self controlOperators] objectAtIndex:row];
    }
    else if (pickerView.tag == ACTUATOR_PV_TAG) {
        label.text  = [[self controlActuators] objectAtIndex:row];
    }
    else if (pickerView.tag == ACTUATORSTATE_PV_TAG) {
        label.text  = [[self controlActuatorsStates] objectAtIndex:row];
    }

    return label;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSAttributedString *title;
    if (pickerView.tag == DEVICE_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:((EKDevice *)[self.userDevices objectAtIndex:row]).EKID
                                                attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:8],
                                                             NSForegroundColorAttributeName: [UIColor blueColor]}];
    }
    else if (pickerView.tag == CONDITION_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self controlConditions] objectAtIndex:row]
                                                attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:10],
                                                             NSForegroundColorAttributeName: [UIColor blueColor]}];
    }
    else if (pickerView.tag == SUBCONDITION_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self controlForexSymbols] objectAtIndex:row]
                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightLight],
                                                             NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self controlOperators] objectAtIndex:row]
                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightLight],
                                                             NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    else if (pickerView.tag == ACTUATOR_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self controlActuators] objectAtIndex:row]
                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightLight],
                                                             NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    else if (pickerView.tag == ACTUATORSTATE_PV_TAG) {
        title = [[NSAttributedString alloc] initWithString:[[self controlActuatorsStates] objectAtIndex:row]
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
    else if (pickerView.tag == CONDITION_PV_TAG) {
        self.selectedCondition = row;

        // Modify UI based on condition selection
        NSString *unitsStr = @"-";
        if(self.selectedCondition == eControlCloudRuleConditions_Weather) {
            unitsStr = @"\u00B0 C";
            self.selectedSubCondition = @"Temperature";

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cityTextField setHidden:NO];
                [self.inCityLabel setHidden:NO];

                self.selectConditionTextField.text = (NSString *)[[self controlConditions] objectAtIndex:row];
                self.unitsLabel.text = unitsStr;

                self.selectSubConditionTextField.text = @"Temperature";
                [self.selectSubConditionTextField setUserInteractionEnabled:NO];
            });
        }
        else if (self.selectedCondition == eControlCloudRuleConditions_Forex) {
            unitsStr = @"-";
            self.selectedSubCondition = @"EURUSD";

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cityTextField setHidden:YES];
                [self.inCityLabel setHidden:YES];

                self.selectConditionTextField.text = (NSString *)[[self controlConditions] objectAtIndex:row];
                self.unitsLabel.text = unitsStr;

                self.selectSubConditionTextField.text = @"EURUSD";
                [self.selectSubConditionTextField setUserInteractionEnabled:YES];
            });
        }
    }
    else if (pickerView.tag == SUBCONDITION_PV_TAG) {
        if(self.selectedCondition == eControlCloudRuleConditions_Weather) {

        }
        else if (self.selectedCondition == eControlCloudRuleConditions_Forex) {
            self.selectedSubCondition = (NSString *)[[self controlForexSymbols] objectAtIndex:row];

            dispatch_async(dispatch_get_main_queue(), ^{
                self.selectSubConditionTextField.text = self.selectedSubCondition;
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.selectSubConditionTextField setUserInteractionEnabled:NO];
            });
        }
    }
    else if (pickerView.tag == OPERATOR_PV_TAG) {
        self.selectedOperator = row;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectOperatorTextField.text = (NSString *)[[self controlOperators] objectAtIndex:row];
        });
    }
    else if (pickerView.tag == ACTUATOR_PV_TAG) {
        self.selectedActuator = row;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectActuatorTextField.text = (NSString *)[[self controlActuators] objectAtIndex:row];
        });
    }
    else if (pickerView.tag == ACTUATORSTATE_PV_TAG) {
        self.selectedActuatorState = (row == 0) ? YES : NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectActuatorStateTextField.text = (NSString *)[[self controlActuatorsStates] objectAtIndex:row];
        });
    }
}

#pragma mark - Helpers

- (NSArray *)controlConditions {
    return [NSArray arrayWithObjects:@"Weather",@"FOREX", nil];
}

- (NSArray *)controlOperators {
    return [NSArray arrayWithObjects:@"==",@">",@">=",@"<",@"<=", nil];
}

- (NSArray *)controlForexSymbols {
    return [NSArray arrayWithObjects:@"EURUSD", @"USDJPY",@"GBPUSD",@"USDCHF",@"EURGBP",@"EURJPY",@"EURCHF",@"AUDUSD",@"USDCAD",@"NZDUSD", nil];
}

- (NSArray *)controlActuators {
    return [NSArray arrayWithObjects:@"Led", nil];
}

- (NSArray *)controlActuatorsStates {
    return [NSArray arrayWithObjects:@"On", @"Off", nil];
}

@end
