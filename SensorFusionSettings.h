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

@interface SensorFusionSettings : IotDeviceSettings

@property NSData* raw;
@property uint16_t sflBetaA;
@property uint16_t sflBetaM;

@end
