/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "Accelerometer.h"
#import "Gyroscope.h"

@interface ICM40605 : NSObject

@property Accelerometer* accelerometer;
@property Gyroscope* gyroscope;

- (void) processAccelerometerRawConfigRange:(int)range;
- (void) processGyroscopeRawConfigRange:(int)range rate:(int)rate;
- (float) getAccelerometerRateFromRawConfig:(int)raw;
- (float) getGyroscopeRateFromRawConfig:(int)raw;

@end
