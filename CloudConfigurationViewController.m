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

#import <UIKit/UIKit.h>
#import "CloudConfigurationViewController.h"
#import "SettingsVault.h"
#import "CloudManager.h"
#import "CloudAPI.h"
#import "MBProgressHUD.h"

//******************************************************************************
// From: http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 235;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static CGFloat animatedDistance;
//******************************************************************************

@interface CloudConfigurationViewController()
@property (weak, nonatomic) IBOutlet UISwitch *enableCloudSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cloudLinkGeneratedStatus;
@property (weak, nonatomic) IBOutlet UIButton *sendCloudLinkButton;
@property (weak, nonatomic) IBOutlet UITextField *cloudLinkTextField;
@property (weak, nonatomic) IBOutlet UISwitch *enableHistoricalSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableAlertingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableControlSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableIftttSwitch;
@property (weak, nonatomic) IBOutlet UITextField *iftttApiKeyTextField;
@property (weak, nonatomic) IBOutlet UIButton *setIftttApiKeyButton;
@property (weak, nonatomic) IBOutlet UIButton *retrieveIftttApiKeyButton;
@property (weak, nonatomic) IBOutlet UITextField *iftttEventPeriodTextField;
@property (weak, nonatomic) IBOutlet UISwitch *enableAssetTrackingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enable3DGameSwitch;
@end


@implementation CloudConfigurationViewController {}

#pragma mark - VC lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [self.enableCloudSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    [self.cloudLinkGeneratedStatus setOn:[[SettingsVault sharedSettingsVault] getConfigIsCloudLinkGenerated]];
    [self.enableHistoricalSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    [self.enableAlertingSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    [self.enableControlSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    [self.enableAssetTrackingSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigAssetTrackingEnable]];
    [self.enable3DGameSwitch setOn:[[SettingsVault sharedSettingsVault] getConfig3DGameEnable]];
    [self.enableControlSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    [self.enableHistoricalSwitch setUserInteractionEnabled:NO];
    [self.enableAlertingSwitch setUserInteractionEnabled:NO];
    [self.enableControlSwitch setUserInteractionEnabled:NO];
    [self.enableHistoricalSwitch setEnabled:NO];
    [self.enableAlertingSwitch setEnabled:NO];
    [self.enableControlSwitch setEnabled:NO];
    [self.enableAssetTrackingSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    [self.enable3DGameSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];

    [self.cloudLinkTextField setText:[[SettingsVault sharedSettingsVault] getConfigCloudLinkTargetEmail]];

    [self.enableIftttSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigIftttEnable]];

    if ([[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] != nil) {
        [self.iftttEventPeriodTextField setText:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] stringValue]];
    }

    if ([[SettingsVault sharedSettingsVault] getConfigIftttApiKey] != nil) {
        [self.iftttApiKeyTextField setText:[[SettingsVault sharedSettingsVault] getConfigIftttApiKey]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    // Send StopFw notification to BLE layer
    ConfigurationMsg *toBleMsg = [[ConfigurationMsg alloc] init];

    NSMutableArray *stopFwArray = [[NSMutableArray alloc] init];
    if (self.enableCloudSwitch.isOn == YES) {
        if(self.enableAssetTrackingSwitch.isOn == NO) {
            [stopFwArray addObject:[NSNumber numberWithInteger:eEventTypes_Advertise]];
        }

        if(self.enable3DGameSwitch.isOn == NO) {
            [stopFwArray addObject:[NSNumber numberWithInteger:eEventTypes_Fusion]];
        }

        if(self.enableIftttSwitch.isOn == NO) {
            [stopFwArray addObject:[NSNumber numberWithInteger:eEventTypes_Button]];
        }
    }
    else {
        [stopFwArray addObjectsFromArray:[NSArray arrayWithObjects:
                                          [NSNumber numberWithInteger:eEventTypes_Proximity],
                                          [NSNumber numberWithInteger:eEventTypes_Brightness],
                                          [NSNumber numberWithInteger:eEventTypes_AirQuality],
                                          [NSNumber numberWithInteger:eEventTypes_Advertise],
                                          [NSNumber numberWithInteger:eEventTypes_Fusion],
                                          nil]];

        if (self.enableIftttSwitch.isOn == NO) {
            [stopFwArray addObjectsFromArray:[NSArray arrayWithObjects:
                                              [NSNumber numberWithInteger:eEventTypes_Temperature],
                                              [NSNumber numberWithInteger:eEventTypes_Humidity],
                                              [NSNumber numberWithInteger:eEventTypes_Pressure],
                                              [NSNumber numberWithInteger:eEventTypes_Button],
                                              nil]];

        }
    }

    toBleMsg.StopFw = [NSArray arrayWithArray:stopFwArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBLELayerConfiguration object:toBleMsg userInfo:nil];
}


//******************************************************************************
//******************************************************************************


#pragma mark - UI actions

- (IBAction)onEnableCloudSwitchToggle:(UISwitch *)sender {
    if (sender.isOn == YES) {
        if ([[SettingsVault sharedSettingsVault] getConfigHasEnabledCloudAtLeastOnce] == NO) {
            // The very first time the user enables Cloud has to two options:
            //      1) Create new user account
            //      2) Add this mobile device to an existing account
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"User Management"
                                          message:@"In order to add this mobile device to an existing account enter a valid 6-digit PIN and click \"Add\". Otherwise, click \"Create new\" to create a new user account."
                                          preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *addToExisting = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           // Send MgmtGetUserIdByTokenReq
                                                           MgmtGetUserIdByTokenReq *req = [[MgmtGetUserIdByTokenReq alloc] init];
                                                           req.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                                                           req.Token = alert.textFields[0].text;

                                                           NSString *finalUrl = [[MgmtGetUserIdByTokenReq constructRoute] stringByAppendingString:[MgmtGetUserIdByTokenReq constructUrlParams:req]];
                                                           NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                                           NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
                                                           [request setHTTPMethod:@"GET"];
                                                           NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                                                                       completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                                                           JSONModelError *err;
                                                                                                           MgmtGetUserIdByTokenRsp *rsp = [[MgmtGetUserIdByTokenRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                                                                           if (err != nil) {
                                                                                                               NSLog(@" MgmtGetUserIdByTokenRsp deserialization error: %@ ", error.description);
                                                                                                               return;
                                                                                                           }

                                                                                                           [[SettingsVault sharedSettingsVault] setUSERID:rsp.UserId];
                                                                                                           [[SettingsVault sharedSettingsVault] setConfigCloudLink:rsp.UserId];

                                                                                                           [[SettingsVault sharedSettingsVault] setConfigCloudEnable:YES];
                                                                                                           [[SettingsVault sharedSettingsVault] setConfigHasEnabledCloudAtLeastOnce:YES];

                                                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                               [self.cloudLinkGeneratedStatus setOn:YES];

                                                                                                               [self.enableHistoricalSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                               [self.enableAlertingSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                               [self.enableControlSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                               [self.enableAssetTrackingSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                               [self.enable3DGameSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                           });

                                                                                                           // Send SetDeviceReq
                                                                                                           MgmtSetDeviceReq *req = [[MgmtSetDeviceReq alloc] init];
                                                                                                           req.OperationType = eCommonOperationTypes_Insert;
                                                                                                           req.DeviceInfo = [[EKDevice alloc] init];
                                                                                                           req.DeviceInfo.EKID = [[CloudManager sharedCloudManager] getConnectedDevice].ekid;
                                                                                                           req.DeviceInfo.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

                                                                                                           NSString *finalUrl = [MgmtSetDeviceReq constructRoute];
                                                                                                           NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                                                                                           NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
                                                                                                           [request setHTTPMethod:@"POST"];
                                                                                                           [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

                                                                                                           NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                                                                                                                       completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                                                                                                           if (error == nil) {
                                                                                                                                                               NSLog(@"[[MGMT] SetDeviceReq request sent");
                                                                                                                                                           }

                                                                                                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                                                               [[CloudManager sharedCloudManager] startCloudManager];
                                                                                                                                                           });
                                                                                                                                                       }];
                                                                                                           [dataTask resume];
                                                                                                       }];
                                                           [dataTask resume];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];

                                                       }];
            UIAlertAction *createNew = [UIAlertAction actionWithTitle:@"Create new" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               // Send MgmtGetUserIdByTokenReq
                                                               MgmtGetUserIdByTokenReq *req = [[MgmtGetUserIdByTokenReq alloc] init];
                                                               req.APPID = [[SettingsVault sharedSettingsVault] getAPPID];

                                                               NSString *finalUrl = [[MgmtGetUserIdByTokenReq constructRoute] stringByAppendingString:[MgmtGetUserIdByTokenReq constructUrlParams:req]];
                                                               NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                                               NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
                                                               [request setHTTPMethod:@"GET"];
                                                               NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                                                                           completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                                                               JSONModelError *err;
                                                                                                               MgmtGetUserIdByTokenRsp *rsp = [[MgmtGetUserIdByTokenRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                                                                               if (err != nil) {
                                                                                                                   NSLog(@" MgmtGetUserIdByTokenRsp deserialization error: %@ ", error.description);
                                                                                                                   return;
                                                                                                               }

                                                                                                               [[SettingsVault sharedSettingsVault] setUSERID:rsp.UserId];
                                                                                                               [[SettingsVault sharedSettingsVault] setConfigCloudLink:rsp.UserId];

                                                                                                               [[SettingsVault sharedSettingsVault] setConfigCloudEnable:YES];
                                                                                                               [[SettingsVault sharedSettingsVault] setConfigHasEnabledCloudAtLeastOnce:YES];

                                                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                   [self.cloudLinkGeneratedStatus setOn:YES];

                                                                                                                   [self.enableHistoricalSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                                   [self.enableAlertingSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                                   [self.enableControlSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                                   [self.enableAssetTrackingSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                                   [self.enable3DGameSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
                                                                                                               });

                                                                                                               // Send SetDeviceReq
                                                                                                               MgmtSetDeviceReq *req = [[MgmtSetDeviceReq alloc] init];
                                                                                                               req.OperationType = eCommonOperationTypes_Insert;
                                                                                                               req.DeviceInfo = [[EKDevice alloc] init];
                                                                                                               req.DeviceInfo.EKID = [[CloudManager sharedCloudManager] getConnectedDevice].ekid;
                                                                                                               req.DeviceInfo.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

                                                                                                               NSString *finalUrl = [MgmtSetDeviceReq constructRoute];
                                                                                                               NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                                                                                               NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
                                                                                                               [request setHTTPMethod:@"POST"];
                                                                                                               [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

                                                                                                               NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                                                                                                                           completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                                                                                                               if (error == nil) {
                                                                                                                                                                   NSLog(@"[[MGMT] SetDeviceReq request sent");
                                                                                                                                                               }

                                                                                                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                                                                   [[CloudManager sharedCloudManager] startCloudManager];
                                                                                                                                                               });
                                                                                                                                                           }];
                                                                                                               [dataTask resume];
                                                                                                           }];
                                                               [dataTask resume];
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];

            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];

            [alert addAction:addToExisting];
            [alert addAction:createNew];
            [alert addAction:cancel];

            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"PIN";
            }];

            [self presentViewController:alert animated:YES completion:nil];
        }
        else { //Cloud switched on
            [[CloudManager sharedCloudManager] startCloudManager];
            [[SettingsVault sharedSettingsVault] setConfigCloudEnable:YES];

            [self.enableHistoricalSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
            [self.enableAlertingSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
            [self.enableControlSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
            [self.enableAssetTrackingSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
            [self.enable3DGameSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
        }
    }
    else { //Cloud switched off
        [[CloudManager sharedCloudManager] stopCloudManager];
        [[SettingsVault sharedSettingsVault] setConfigCloudEnable:NO];

        [self.enableHistoricalSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
        [self.enableAlertingSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
        [self.enableControlSwitch setOn:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
        [self.enableAssetTrackingSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
        [self.enable3DGameSwitch setEnabled:[[SettingsVault sharedSettingsVault] getConfigCloudEnable]];
    }
}

- (IBAction)onSendCloudLinkButtonClicked:(UIButton *)sender {

    if([[SettingsVault sharedSettingsVault] getConfigCloudLink] == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Please specify a valid e-mail address";
            hud.removeFromSuperViewOnHide = YES;
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            [hud hide:YES afterDelay:2];
        });

        return;
    }

    MgmtWebAppLinkInfo *req = [[MgmtWebAppLinkInfo alloc] init];
    req.Email = self.cloudLinkTextField.text;
    req.Url = [[SettingsVault sharedSettingsVault] getConfigCloudLink];

    NSString *finalUrl = [MgmtWebAppLinkInfo constructRoute];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    if (error == nil) {
                                                        NSLog(@"[User Management] Cloud link e-mail successfully sent");

                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                            hud.mode = MBProgressHUDModeText;
                                                            hud.labelText = [@"Link sent to: " stringByAppendingString:req.Email];
                                                            hud.removeFromSuperViewOnHide = YES;
                                                            hud.margin = 10.f;
                                                            hud.yOffset = 150.f;
                                                            [hud hide:YES afterDelay:2];
                                                        });
                                                    }
                                                }];

    [dataTask resume];
}

- (IBAction)onEmailTextFieldDidFinishEditing:(UITextField *)sender {
    if([sender.text isEqualToString:@""] == NO && sender.text != nil) {
        [[SettingsVault sharedSettingsVault] setConfigCloudLinkTargetEmail:sender.text];
    }
}

- (IBAction)onEnableHistoricalSwitchToggle:(UISwitch *)sender {
}

- (IBAction)onEnableAlertingSwitchToggle:(UISwitch *)sender {
}

- (IBAction)onEnableControlSwitchToggle:(UISwitch *)sender {
}

- (IBAction)onEnableAssetTrackingSwitchToggle:(UISwitch *)sender {
    [[SettingsVault sharedSettingsVault] setConfigAssetTrackingEnable:sender.isOn];
}

- (IBAction)onEnable3DGameSwitchToggle:(UISwitch *)sender {
    [[SettingsVault sharedSettingsVault] setConfig3DGameEnable:sender.isOn];
}


- (IBAction)onEnableIftttSwitchToggle:(UISwitch *)sender {
    if (sender.isOn) {
        if([[SettingsVault sharedSettingsVault] getConfigIftttApiKey] == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.enableIftttSwitch setOn:NO];

                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"No IFTTT api key has been specified";
                hud.removeFromSuperViewOnHide = YES;
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                [hud hide:YES afterDelay:2];
            });
            [[SettingsVault sharedSettingsVault] setConfigIftttEnable:NO];
        }
        else {
            [[SettingsVault sharedSettingsVault] setConfigIftttEnable:YES];
            [[CloudManager sharedCloudManager] iftttTimerTemperatureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
            [[CloudManager sharedCloudManager] iftttTimerHumidityStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
            [[CloudManager sharedCloudManager] iftttTimerPressureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
        }
    }
    else {
        [[SettingsVault sharedSettingsVault] setConfigIftttEnable:NO];
        [[CloudManager sharedCloudManager] iftttTimerTemperatureStop];
        [[CloudManager sharedCloudManager] iftttTimerHumidityStop];
        [[CloudManager sharedCloudManager] iftttTimerPressureStop];
    }
}

- (IBAction)onSetIftttApiKeyButtonClicked:(UIButton *)sender {
    if(self.iftttApiKeyTextField.text == nil ||
       [self.iftttApiKeyTextField.text isEqualToString:@""]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Please enter a valid IFTTT api key";
            hud.removeFromSuperViewOnHide = YES;
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            [hud hide:YES afterDelay:2];
        });
    }
    else {
        [[SettingsVault sharedSettingsVault] setConfigIftttApiKey:self.iftttApiKeyTextField.text];
    }
}

- (IBAction)onRetrieveIftttApiKeyButtonClicked:(UIButton *)sender {

    if([[SettingsVault sharedSettingsVault] getConfigHasEnabledCloudAtLeastOnce] == NO) {

        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Please enable cloud to proceed";
            hud.removeFromSuperViewOnHide = YES;
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            [hud hide:YES afterDelay:2];
        });
        return;
    }

    // Send MgmtGetIftttinfoReq
    MgmtGetIftttInfoReq *req = [[MgmtGetIftttInfoReq alloc] init];
    req.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSString *finalUrl = [[MgmtGetIftttInfoReq constructRoute] stringByAppendingString:[MgmtGetIftttInfoReq constructUrlParams:req]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    JSONModelError *err;
                                                    MgmtIftttInfo *rsp = [[MgmtIftttInfo alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                    if (err != nil) {
                                                        NSLog(@" MgmtIftttInfo deserialization error: %@ ", error.description);
                                                        return;
                                                    }

                                                    [[SettingsVault sharedSettingsVault] setConfigIftttApiKey:rsp.IftttApiKey];

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.iftttApiKeyTextField setText:rsp.IftttApiKey];
                                                    });
                                                }];
    [dataTask resume];
}

// From: http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
- (IBAction)onIftttApiKeyTextFieldDidStartEditing:(UITextField *)textField {
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
- (IBAction)onIftttApiKeyTextFieldDidFinishEditing:(UITextField *)sender {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
}

- (IBAction)onIftttEventPeriodTextFieldDidStartEditing:(UITextField *)textField {
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
- (IBAction)onIftttEventPeriodTextFieldDidFinishEditing:(UITextField *)sender {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *period = [f numberFromString:sender.text];

    if(period == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Please enter an integer value";
            hud.removeFromSuperViewOnHide = YES;
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            [hud hide:YES afterDelay:2];

            self.iftttEventPeriodTextField.text = @"";
        });

        return;
    }

    period = [NSNumber numberWithInteger:[period integerValue]];
    [[SettingsVault sharedSettingsVault] setConfigIftttEventPeriod:period];

    [[CloudManager sharedCloudManager] iftttTimerTemperatureStop];
    [[CloudManager sharedCloudManager] iftttTimerHumidityStop];
    [[CloudManager sharedCloudManager] iftttTimerPressureStop];
    [[CloudManager sharedCloudManager] iftttTimerTemperatureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
    [[CloudManager sharedCloudManager] iftttTimerHumidityStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
    [[CloudManager sharedCloudManager] iftttTimerPressureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

//******************************************************************************
//******************************************************************************


@end
