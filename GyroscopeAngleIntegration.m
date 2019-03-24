/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "GyroscopeAngleIntegration.h"

static NSString* const LOG_TAG = @"GDT";
static NSString* const LOG_UNIT = @"deg";

@implementation GyroscopeAngleIntegration

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

    rotRateX = x * integrationRate;
    rotRateY = y * integrationRate;
    rotRateZ = z * integrationRate;
    self.rotationRate = [[IotSensorValue3D alloc] initWithX:rotRateX Y:rotRateY Z:rotRateZ];

    accRotX += x;
    accRotY += y;
    accRotZ += z;
    if (accRotX > 360)
        accRotX -= 360;
    if (accRotX < 0)
        accRotX += 360;
    if (accRotY > 360)
        accRotY -= 360;
    if (accRotY < 0)
        accRotY += 360;
    if (accRotZ > 360)
        accRotZ -= 360;
    if (accRotZ < 0)
        accRotZ += 360;
    self.accumulatedRotation = [[IotSensorValue3D alloc] initWithX:accRotX Y:accRotY Z:accRotZ];

    return self.value;
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return GyroscopeAngleIntegration.LOG_TAG;
}

- (NSString*) logValueUnit {
    return GyroscopeAngleIntegration.LOG_UNIT;
}

- (IotSensorValue*)cloudValue {
    return self.accumulatedRotation;
}

- (IotSensorValue*)unprocessedGraphValue {
    return self.rotationRate;
}

@end
