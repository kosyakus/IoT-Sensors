/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AmbientLightSensor.h"
#import "ProximitySensor.h"

@interface VCNL4010 : NSObject

@property AmbientLightSensor* ambientLightSensor;
@property ProximitySensor* proximitySensor;

@end
