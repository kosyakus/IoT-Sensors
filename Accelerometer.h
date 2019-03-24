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

@interface Accelerometer : IotSensor {
    float x, y, z;
}

@property (nonatomic) float sensitivity;

- (IotSensorValue*) processRawData:(int16_t*)raw;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT;

@end
