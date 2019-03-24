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

@interface SensorFusion : IotSensor {
    float qx, qy, qz, qw;
    float roll, pitch, yaw;
}

@property IotSensorValue* quaternion;
@property IotSensorValue* valueRad;

- (void) sensorFusionCalculation;

+ (NSString*) LOG_TAG;

@end
