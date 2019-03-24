/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IoTAppHistoricalViewController.h"
#import "Cloud/CloudManager.h"
#import "CloudAPI.h"
#import "SettingsVault.h"

#import "MKDropdownMenu.h"
#import "MBProgressHUD.h"
#import "IoT_Sensors-Swift.h"


//TODO: Remove this after testing
#import "InternalAPI.h"

NS_ENUM(NSInteger, IoTHistoricalDropdownComponents) {
    IoTHistoricalDropdownComponents_Device = 0,
    IoTHistoricalDropdownComponents_Sensor,
    IoTHistoricalDropdownComponentsCount
};

@interface IoTAppHistoricalViewController () <ChartViewDelegate>

@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;
@property (strong, nonatomic) NSString *selectedDevice;
@property (nonatomic) NSInteger selectedSensor;
@property (strong, nonatomic) NSMutableArray<EKDevice> *userDevices;

@property (strong, nonatomic) NSArray *historicalSensorsArray;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sensorToggleButton;
@property (weak, nonatomic) IBOutlet LineChartView *historicalChartView;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UILabel *selectedDeviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedSensorLabel;
@property (weak, nonatomic) IBOutlet MKDropdownMenu *selectDeviceSensorDropdownMenu;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *topLevelView;

@property (strong,nonatomic) NSArray *historicalChartTimestamps;

@end

@implementation IoTAppHistoricalViewController{}

- (void) viewDidLoad {
    [super viewDidLoad];

    if (BluetoothManager.instance.device.state != CBPeripheralStateConnected)
        self.navigationItem.rightBarButtonItems = nil;
}

- (IBAction)endDateTouchDown:(UITextField *)sender {
    if (self.endDateTextField.inputView == nil)
    {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(updateEndDateTextField:)
             forControlEvents:UIControlEventValueChanged];
        [self.endDateTextField setInputView:datePicker];
    }
}
- (IBAction)startDateTouchDown:(UITextField *)sender {
    if (self.startDateTextField.inputView == nil)
    {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(updateStartDateTextField:)
             forControlEvents:UIControlEventValueChanged];
        [self.startDateTextField setInputView:datePicker];
    }
}

-(void)updateStartDateTextField:(UIDatePicker *)sender
{
    self.startDateTextField.text =  [NSDateFormatter localizedStringFromDate:sender.date
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterNoStyle];

    self.selectedStartDate = sender.date;
}

-(void)updateEndDateTextField:(UIDatePicker *)sender
{
    self.endDateTextField.text =  [NSDateFormatter localizedStringFromDate:sender.date
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterNoStyle];

    self.selectedEndDate = sender.date;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


    // Wait for pickers to populate
    [self setViewLoadingPendingState:YES];

    //**************************************************************************

    _historicalChartView.delegate = self;

    _historicalChartView.chartDescription.enabled = NO;

    _historicalChartView.dragEnabled = YES;
    [_historicalChartView setScaleEnabled:YES];
    _historicalChartView.pinchZoomEnabled = YES;
    _historicalChartView.userInteractionEnabled = YES;
    _historicalChartView.drawGridBackgroundEnabled = NO;

    ChartYAxis *leftAxis = _historicalChartView.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.axisMaximum = 200.0;
    leftAxis.axisMinimum = -50.0;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;

    _historicalChartView.rightAxis.enabled = NO;

    _historicalChartView.xAxis.enabled = NO;

    self.historicalChartView.noDataText = @"No data to display";
    
    //**************************************************************************

    self.historicalSensorsArray = @[@"Temperature", @"Humidity", @"Pressure", @"Air Quality", @"Brightness", @"Proximity"];

    //**************************************************************************

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

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.selectDeviceSensorDropdownMenu reloadAllComponents];
                                                    });

                                                    // Wait for pickers to populate
                                                    [self setViewLoadingPendingState:NO];

                                                }];
    [dataTask resume];

    self.sensorToggleButton.title = [[CloudManager sharedCloudManager] getConnectedDevice].isStarted ? @"Stop" : @"Start";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
    [self.selectDeviceSensorDropdownMenu closeAllComponentsAnimated:false];
}

-(void)setUIDefaults {
    self.selectedSensor = eAlertingSensors_Temperature;
    self.selectedSensorLabel.text = [[self historicalSensorsArray] objectAtIndex:0];

    self.selectedStartDate = [NSDate date];
    self.startDateTextField.text = [NSDateFormatter localizedStringFromDate:self.selectedStartDate
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterNoStyle];

    self.selectedEndDate = [NSDate date];
    self.endDateTextField.text = [NSDateFormatter localizedStringFromDate:self.selectedEndDate
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterNoStyle];
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

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI actions

- (IBAction)historicalApplyButton:(UIButton *)sender forEvent:(UIEvent *)event {

    if (sender.state == true) {

        HistoricalGetEnvironmentalReq *req = [[HistoricalGetEnvironmentalReq alloc] init];
        req.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
        req.EKID = self.selectedDevice;
        req.StartDate = [[CloudManager sharedCloudManager] getUTCDate2:self.selectedStartDate];
        req.EndDate = [[CloudManager sharedCloudManager] getUTCDate2:self.selectedEndDate] ;
        req.APPID = [[SettingsVault sharedSettingsVault] getAPPID];

        if (req.EKID == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Please select a device";
                hud.removeFromSuperViewOnHide = YES;
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                [hud hide:YES afterDelay:2];
            });
            return;
        }

        NSString *route = nil;
        if (self.selectedSensor == 0) {
            route = [IoTAppsApi constructGetTemperatureReqRoute];
        }
        else if (self.selectedSensor == 1) {
            route = [IoTAppsApi constructGetHumidityReqRoute];
        }
        else if (self.selectedSensor == 2) {
            route = [IoTAppsApi constructGetPressureReqRoute];
        }
        else if (self.selectedSensor == 3) {
            route = [IoTAppsApi constructGetAirQualityReqRoute];
        }
        else if (self.selectedSensor == 4) {
            route = [IoTAppsApi constructGetBrightnessReqRoute];
        }
        else if (self.selectedSensor == 5) {
            route = [IoTAppsApi constructGetProximityReqRoute];
        }

        NSString *finalUrl = [route stringByAppendingString:[IoTAppsApi constructUrlParams:req]];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                        JSONModelError *err;
                                                        HistoricalGetEnvironmentalRsp *rsp = [[HistoricalGetEnvironmentalRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                        if (err != nil) {
                                                            NSLog(@" HistoricalGetEnvironmentalRsp deserialization error: %@ ", error.description);
                                                        }

                                                        if ([rsp.Values count] == 0)
                                                        {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.historicalChartView.data = nil;
                                                                [self.historicalChartView notifyDataSetChanged];
                                                            });
                                                            return;
                                                        }

                                                        ChartDataEntryBuffer *historicalData = [[ChartDataEntryBuffer alloc] initWithCapacity:[rsp.Values count]];
                                                        for (NSNumber *val in rsp.Values) {
                                                            [historicalData addEntry:[val floatValue]];
                                                        }

                                                        // x-axis
                                                        self.historicalChartTimestamps = rsp.Timestamps;

                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self updateChartWithData:historicalData forSensorType:_historicalSensorsArray[self.selectedSensor]];
                                                        });
                                                    }];

        [dataTask resume];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*if ([segue.identifier isEqualToString:@"sensorAccelerometer"]) {
     self.sensorViewAccelerometer = segue.destinationViewController;
     }*/
}


#pragma mark - Linechart
- (void) updateChartWithData: (ChartDataEntryBuffer *)historicalData forSensorType:(NSString *)sensorType{

    LineChartDataSet *set = [self generateDataSetFromData:historicalData.data forSensor:sensorType];
    LineChartData *data = [[LineChartData alloc] initWithDataSet:set];
    [self updateChartMinMax:data];
    data.drawValues = NO;

    self.historicalChartView.xAxis.axisMinimum = historicalData.lastIndex - (int) historicalData.capacity + 1;
    self.historicalChartView.autoScaleMinMaxEnabled = YES;

    [self.historicalChartView getAxis:AxisDependencyLeft].axisMinimum = (float) data.yMin / 1.01f;
    [self.historicalChartView getAxis:AxisDependencyLeft].axisMaximum = (float) data.yMax * 1.01f;;


    self.historicalChartView.data = data;
}

- (void) updateChartMinMax:(LineChartData*)data {
}

- (LineChartDataSet*) generateDataSetFromData:(NSArray*)data forSensor:(NSString *)sensorType{
    LineChartDataSet* set = [[LineChartDataSet alloc] initWithValues:data label:sensorType];
    set.drawCubicEnabled = YES;
    set.cubicIntensity = 0.2;
    set.drawCirclesEnabled = YES;
    set.lineWidth = 4;
    set.circleRadius = 6.0;
    set.circleColor = UIColor.redColor;
    set.highlightEnabled = YES;
    set.color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    set.fillColor = UIColor.redColor;
    set.fillAlpha = 0.05f;
    set.drawHorizontalHighlightIndicatorEnabled = YES;
    set.highlightColor = [UIColor blueColor];
    set.drawFilledEnabled = YES;
    return set;
}

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    //NSLog(@"[Selection] x: %@ y: %f", self.historicalChartTimestamps[(NSInteger)entry.x], entry.y);

    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [[[@"Value: " stringByAppendingString:[NSString stringWithFormat:@"%.02f", entry.y]]
                         stringByAppendingString:@", Time: "] stringByAppendingString:self.historicalChartTimestamps[(NSInteger)entry.x - 1]];
        hud.labelFont = [UIFont systemFontOfSize:10];
        hud.removeFromSuperViewOnHide = YES;
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        [hud hide:YES afterDelay:2];
    });
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}


#pragma mark - MKDropdownMenu interfaces

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch(component)
    {
        case IoTHistoricalDropdownComponents_Device:
        {
            self.selectedDevice = ((EKDevice *)[self.userDevices objectAtIndex:row]).EKID;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.selectedDeviceLabel.text = self.selectedDevice;
            });
            break;
        }
        case IoTHistoricalDropdownComponents_Sensor:
        {
            self.selectedSensor = row;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.selectedSensorLabel.text = self.historicalSensorsArray[row];
            });
            break;
        }
    }
    [dropdownMenu closeAllComponentsAnimated:YES];
}

- (NSInteger)dropdownMenu:(nonnull MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    switch(component)
    {
        case IoTHistoricalDropdownComponents_Device:
        {
            return [self.userDevices count];
            break;
        }
        case IoTHistoricalDropdownComponents_Sensor:
        {
            return 6;
            break;
        }
            default:
        {
            break;
        }
    }

    return 0;
}

- (NSInteger)numberOfComponentsInDropdownMenu:(nonnull MKDropdownMenu *)dropdownMenu {
    return IoTHistoricalDropdownComponentsCount;
}

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 0; // use default row height
}

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu widthForComponent:(NSInteger)component {
    return 0;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    switch(component)
    {
        case IoTHistoricalDropdownComponents_Device:
        {
            return [[NSAttributedString alloc] initWithString:@"Select device"
                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                                                                NSForegroundColorAttributeName: [UIColor blackColor]}];
            break;
        }
        case IoTHistoricalDropdownComponents_Sensor:
        {
            return [[NSAttributedString alloc] initWithString:@"Select sensor"
                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                                                                NSForegroundColorAttributeName: [UIColor blackColor]}];
            break;
        }
        default:
        {
            break;
        }
    }

    return [[NSAttributedString alloc] initWithString:@""];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSMutableAttributedString *string;
    switch(component)
    {
        case IoTHistoricalDropdownComponents_Device:
        {
            EKDevice *device = [self.userDevices objectAtIndex:row];
            string = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@", device.EKID]//[NSString stringWithFormat:@"%@(%@)", device.EKID, device.FriendlyName == nil ? @"" : device.FriendlyName]
                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightMedium],
                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
            break;
        }
        case IoTHistoricalDropdownComponents_Sensor:
        {
            string = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@", self.historicalSensorsArray[row]]
                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightMedium],
                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
            break;
        }
    }

    return string;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [UIColor whiteColor];
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForHighlightedRowsInComponent:(NSInteger)component {
    return [UIColor blueColor];
}

- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component {
    return NO;
}

@end

