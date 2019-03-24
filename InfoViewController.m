/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "InfoViewController.h"
#import "APLSlideMenuViewController.h"
#import "IotSensorsManager.h"
#import "BluetoothDefines.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    self.appVersionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateValueForCharacteristic:) name:IotSensorsManagerCharacteristicValueUpdated object:nil];
    
    [self.device.manager readValue:[CBUUID UUIDWithString:DIALOG_WEARABLES_SERVICE] characteristicUUID:[CBUUID UUIDWithString:DIALOG_WEARABLES_CHARACTERISTIC_FEATURES]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerCharacteristicValueUpdated object:nil];
}

- (void) didUpdateValueForCharacteristic:(NSNotification*)notification {
    CBCharacteristic *characteristic = (CBCharacteristic*) notification.object;
    
    if ([characteristic.UUID.UUIDString.lowercaseString isEqualToString:DIALOG_WEARABLES_CHARACTERISTIC_FEATURES]) {
        UInt8 version[17] = { 0 }; //version, BCD format
        if (characteristic.value.length < 16)
            return;
        
        [[characteristic.value subdataWithRange:NSMakeRange(7, 16)] getBytes:&version length:16];
        
        [self.firmwareVersionLabel setText:[NSString stringWithFormat:@"%s", version]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        /* define email address */
        NSString *mail = @"bluetooth.support@diasemi.com";
        NSString *subject = @"IoT Sensors application question";

        /* create the URL */
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@", mail,
                                                    [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];

        /* load the URL */
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)showMenu:(id)sender {
    [self.slideMenuController showLeftMenu:YES];
}

@end
