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

@interface CalibrationModesSettings : IotDeviceSettings

@property NSData* raw;
@property uint8_t accCalMode;
@property uint8_t accAutoCalMode;
@property uint8_t gyroCalMode;
@property uint8_t gyroAutoCalMode;
@property uint8_t magnetoCalMode;
@property uint8_t magnetoAutoCalMode;
@property int accMode;
@property int gyroMode;
@property int magnetoMode;

@end
