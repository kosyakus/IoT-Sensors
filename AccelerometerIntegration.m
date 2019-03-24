/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AccelerometerIntegration.h"

static NSString* const LOG_TAG = @"ADV";
static NSString* const LOG_UNIT = @"m/s";

#define G 9.81f

@implementation AccelerometerIntegration

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.averageDelta = [[IotSensorValue alloc] init];
    return self;
}

- (void) setIntegrationRate:(float)integrationRate sensorRate:(float)sensorRate {
    self->integrationRate = integrationRate;
    self->sensorRate = sensorRate;
    samples = (int) (sensorRate / integrationRate);
}

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [data getBytes:&qformat range:NSMakeRange(offset, 1)];
    [self get3DValuesLE:raw data:data offset:offset + 1];

    float q = powf(2, qformat);
    x = raw[0] / q;
    y = raw[1] / q;
    z = raw[2] / q;
    self.value = [[IotSensorValue3D alloc] initWithX:x Y:y Z:z];

    if (samples != 0) {
        avgDeltaX = x / samples;
        avgDeltaY = y / samples;
        avgDeltaZ = z / samples;
        self.averageDelta = [[IotSensorValue3D alloc] initWithX:avgDeltaX Y:avgDeltaY Z:avgDeltaZ];
    }

    accX = x * integrationRate;
    accY = y * integrationRate;
    accZ = z * integrationRate;
    self.acceleration = [[IotSensorValue3D alloc] initWithX:accX Y:accY Z:accZ];
    self.accelerationInG = [[IotSensorValue3D alloc] initWithX:accX / G Y:accY / G Z:accZ / G];

    return self.value;
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return AccelerometerIntegration.LOG_TAG;
}

- (NSString*) logValueUnit {
    return AccelerometerIntegration.LOG_UNIT;
}

- (IotSensorValue*) cloudValue {
    return self.accelerationInG;
}

- (IotSensorValue*) unprocessedGraphValue {
    return self.accelerationInG;
}

@end
