/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorFusionSettingsManager.h"
#import "IotSensorsDevice.h"
#import "BluetoothDefines.h"

@implementation SensorFusionSettingsManager

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super initWithDevice:device];
    if (!self)
        return nil;

    NSArray* items = @[
            [IotSettingsItem numericWithKey:@"BetaA" min:0 max:32768 title:@"Beta A" message:@"Enter the Beta A value, [0..32768]"],
            [IotSettingsItem numericWithKey:@"BetaM" min:0 max:32768 title:@"Beta M" message:@"Enter the Beta M value, [0..32768]"],
    ];
    [self initSpec:items];

    self.settings = device.sensorFusionSettings;
    if (self.settings.valid) {
        [self.settings save:self.spec];
        [self updateUI];
    }

    return self;
}

- (void) readConfiguration {
    [self.device.manager sendSflReadCommand];
}

- (BOOL) processConfigurationReport:(int)command data:(NSData*)data {
    if (command != DIALOG_WEARABLES_COMMAND_CALIBRATION_SFL_COEFFICIENTS_READ)
        return false;
    [self.settings save:self.spec];
    [self updateUI];
    return true;
}

- (BOOL) updateValues {
    [super updateValues];

    [self.settings load:self.spec];
    NSData* data = [self.settings pack];
    if (self.settings.modified) {
        [self.device.manager sendSflWriteCommand:data];
        [self.device.manager sendSflReadCommand];
        return true;
    }

    return false;
}

@end
