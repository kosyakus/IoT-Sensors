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

@interface PressureSensor : IotSensor

@property float pressure;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT;

@end
