/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotDeviceSettings.h"

@interface CalibrationSettings : IotDeviceSettings

@property int calMode;
@property int calAutoMode;

- (void) enableSettingsForCalibrationMode:(NSDictionary*)spec;

@end
