/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "TemperatureSensor.h"
#import "HumiditySensor.h"
#import "PressureSensor.h"

@interface BME280 : NSObject

@property TemperatureSensor* temperatureSensor;
@property HumiditySensor* humiditySensor;
@property PressureSensor* pressureSensor;

@end
