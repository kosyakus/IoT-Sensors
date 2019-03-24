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

@interface GyroscopeAngleIntegration : IotSensor {
    uint8_t qformat;
    int16_t raw[3];
    float x, y, z;
    float integrationRate;
    float sensorRate;
    int samples;
    float avgDeltaX, avgDeltaY, avgDeltaZ;
    float rotRateX, rotRateY, rotRateZ;
    float accRotX, accRotY, accRotZ;
}

@property IotSensorValue* averageDelta;
@property IotSensorValue* rotationRate;
@property IotSensorValue* accumulatedRotation;

- (void) setIntegrationRate:(float)integrationRate sensorRate:(float)sensorRate;

+ (NSString*) LOG_TAG;
+ (NSString*) LOG_UNIT;

@end
