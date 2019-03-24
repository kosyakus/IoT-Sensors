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

@interface AccelerometerIntegration : IotSensor {
    uint8_t qformat;
    int16_t raw[3];
    float x, y, z;
    float integrationRate;
    float sensorRate;
    int samples;
    float avgDeltaX, avgDeltaY, avgDeltaZ;
    float accX, accY, accZ;
}

@property IotSensorValue* averageDelta;
@property IotSensorValue* acceleration;
@property IotSensorValue* accelerationInG;

- (void) setIntegrationRate:(float)integrationRate sensorRate:(float)sensorRate;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT;

@end
