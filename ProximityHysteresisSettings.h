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

@interface ProximityHysteresisSettings : IotDeviceSettings

@property NSData* raw;
@property uint16_t lowLimit;
@property uint16_t highLimit;

@end
