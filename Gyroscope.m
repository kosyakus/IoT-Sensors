/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "Gyroscope.h"

static NSString* const LOG_TAG = @"GYR";
static NSString* const LOG_UNIT = @"deg";

@implementation Gyroscope

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.rotation = [[IotSensorValue alloc] init];
    self.accumulatedRotation = [[IotSensorValue alloc] init];
    accRotX = accRotY = accRotZ = 0;
    return self;
}

- (void) setSensitivity:(float)sensitivity {
    NSLog(@"Gyroscope sensitivity: %.2f", sensitivity);
    _sensitivity = sensitivity;
}

- (void) setRate:(float)rate {
    NSLog(@"Gyroscope rate: %.2f", rate);
    _rate = rate;
}

- (IotSensorValue*) processRawData:(int16_t*)raw {
    x = raw[0] / self.sensitivity;
    y = raw[1] / self.sensitivity;
    z = raw[2] / self.sensitivity;
    self.value = [[IotSensorValue3D alloc] initWithX:x Y:y Z:z];

    rotX = x / self.rate;
    rotY = y / self.rate;
    rotZ = z / self.rate;
    self.rotation = [[IotSensorValue3D alloc] initWithX:rotX Y:rotY Z:rotZ];

    accRotX += rotX;
    accRotY += rotY;
    accRotZ += rotZ;
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

- (IotSensorValue*) logValue {
    return self.rotation;
}

- (NSString*) logTag {
    return Gyroscope.LOG_TAG;
}

- (NSString*) logValueUnit {
    return Gyroscope.LOG_UNIT;
}

- (IotSensorValue*) cloudValue {
    return self.accumulatedRotation;
}

@end
