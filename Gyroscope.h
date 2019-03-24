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

@interface Gyroscope : IotSensor {
    float x, y, z;
    float rotX, rotY, rotZ;
    float accRotX, accRotY, accRotZ;
}

@property (nonatomic) float sensitivity;
@property (nonatomic) float rate;
@property IotSensorValue* rotation;
@property IotSensorValue* accumulatedRotation;

- (IotSensorValue*) processRawData:(int16_t*)raw;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT;

@end
