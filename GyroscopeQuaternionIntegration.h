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

@interface GyroscopeQuaternionIntegration : IotSensor {
    int16_t raw[4];
    float qx, qy, qz, qw;
    float integrationRate;
    float sensorRate;
    int samples;
}

- (void) setIntegrationRate:(float)integrationRate sensorRate:(float)sensorRate;

+ (NSString*) LOG_TAG;

@end
