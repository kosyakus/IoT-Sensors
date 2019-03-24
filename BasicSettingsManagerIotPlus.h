/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSettingsManager.h"
#import "BasicSettingsIotPlus.h"

@interface BasicSettingsManagerIotPlus : IotSettingsManager

@property IotDeviceSettings* basicSettings;
@property IotDeviceSettings* calibrationSettings;
@property IotDeviceSettings* proximitySettings;

@end
