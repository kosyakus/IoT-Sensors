/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSensor.h"

@interface ProximitySensor : IotSensor

@property BOOL objectNearby;
@property BOOL lowVoltage;

+ (NSString*) LOG_TAG;

@end
