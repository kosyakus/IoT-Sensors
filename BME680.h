/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BME280.h"
#import "GasSensor.h"
#import "AirQualitySensor.h"

@interface BME680 : BME280

@property GasSensor* gasSensor;
@property AirQualitySensor* airQualitySensor;

@end
