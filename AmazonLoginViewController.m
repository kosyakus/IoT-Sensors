/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AmazonLoginViewController.h"
#import <LoginWithAmazon/LoginWithAmazon.h>
#import "IoT_Sensors-Swift.h"
#import "MBProgressHUD.h"
#import "CloudAPI.h"
#import "SettingsVault.h"
#import "CloudManager.h"

@interface AmazonLoginViewController () <AIAuthenticationDelegate>

@property (nonatomic) bool isSavedTokenValid;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation AmazonLoginViewController

-(void) viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([[CloudManager sharedCloudManager] isDeviceConnected] == false) {
        [[NSUserDefaults standardUserDefaults] setObject:@"No connected device" forKey:@"connectedDeviceIndication"];
    }
    else {
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"connectedDeviceIndication"] == nil) {
            [[CloudManager sharedCloudManager] setConnectedDevice];
        }
    }

    if (self.isSavedTokenValid == false) {
        [AIMobileLib getAccessTokenForScopes:@[@"profile", @"alexa:all"]
                          withOverrideParams:nil
                                    delegate:self];
        self.isSavedTokenValid = true;
    }
}

#pragma mark - LoginWithAmazon framework delegate implementation

- (void)requestDidSucceed:(APIResult *)apiResult {
    
    if (apiResult.api == kAPIAuthorizeUser) {
        [AIMobileLib getAccessTokenForScopes:@[@"profile",@"alexa:all"]
                          withOverrideParams:nil
                                    delegate:self];
    }
    else if (apiResult.api == kAPIGetAccessToken){
        // Save Amazon token
        AmazonAccessToken.instance.savedToken = apiResult.result;

        // Set AmazonAccountInfo to cloud
        MgmtAmazonAccountInfoReq *req = [[MgmtAmazonAccountInfoReq alloc] init];

        [AMZNUser fetch:^(AMZNUser *user, NSError *error) {
            if (error == nil) {
                req.AmazonEmail = user.email;

                req.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

                NSString *finalUrl = [MgmtAmazonAccountInfoReq constructRoute];
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                if (error == nil) {
                                                                    NSLog(@"[Alexa] Amazon account info sent.");

                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
                                                                        self.loginButton.hidden = false;
                                                                        [self performSegueWithIdentifier:@"ShowAlexaViewController" sender:nil];
                                                                    });
                                                                }
                                                                else {
                                                                    NSLog(@"[Alexa] Error setting Amazon account info: %@", error.localizedDescription);
                                                                }
                                                            }];

                [dataTask resume];
            }
            else {
                NSLog(@"[Alexa] Error retrieving Amazon profile: %@", error.localizedDescription);
            }
        }];
    }
    else {
        NSLog(@"[Alexa] Reponse for api-code: %lu", apiResult.api);
    }
}

- (void)requestDidFail:(APIError *)apiResult {
    self.loginButton.hidden = false;
    [MBProgressHUD hideAllHUDsForView:self.view animated:true];
}

#pragma mark - UI actions

- (IBAction)loginButtonClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [AIMobileLib authorizeUserForScopes:@[@"profile", @"alexa:all"]
                               delegate:self
                                options:@{kAIOptionScopeData:[[SettingsVault sharedSettingsVault] getAmazonScopes]}];
}

@end
