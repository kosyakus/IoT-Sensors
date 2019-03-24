/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#include <math.h>
#import "SensorFusion.h"

static NSString* const LOG_TAG = @"SFL";

@implementation SensorFusion

- (void) sensorFusionCalculation {
    roll = atan2(2 * qy * qw - 2 * qx * qz, 1 - 2 * qy * qy - 2 * qz * qz);
    pitch = atan2(2 * qx * qw - 2 * qy * qz, 1 - 2 * qx * qx - 2 * qz * qz);
    yaw = asin(2 * qx * qy + 2 * qz * qw);

    self.valueRad = [[IotSensorValue3D alloc] initWithX:roll Y:pitch Z:yaw];
    self.value = [[IotSensorValue3D alloc] initWithX:roll * 180 / M_PI Y:pitch * 180 / M_PI Z:yaw * 180 / M_PI];
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

- (NSString*) logTag {
    return SensorFusion.LOG_TAG;
}

- (IotSensorValue*) cloudValue {
    return self.quaternion;
}

@end
