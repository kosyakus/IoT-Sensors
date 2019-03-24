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

@interface Magnetometer : IotSensor {
    float x, y, z;
}

@property float rad;
@property float degrees;
@property float heading;

- (void) calculateHeading;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT;

+ (NSString*) getCompassHeading:(float)degrees;

@end
