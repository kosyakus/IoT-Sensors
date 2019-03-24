/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "Accelerometer.h"

static NSString* const LOG_TAG = @"ACC";
static NSString* const LOG_UNIT = @"g";

@implementation Accelerometer

- (void) setSensitivity:(float)sensitivity {
    NSLog(@"Accelerometer sensitivity: %.2f", sensitivity);
    _sensitivity = sensitivity;
}

- (IotSensorValue*) processRawData:(int16_t*)raw {
    x = raw[0] / self.sensitivity;
    y = raw[1] / self.sensitivity;
    z = raw[2] / self.sensitivity;
    self.value = [[IotSensorValue3D alloc] initWithX:x Y:y Z:z];
    return self.value;
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

+ (NSString*) LOG_UNIT {
    return LOG_UNIT;
}

- (NSString*) logTag {
    return Accelerometer.LOG_TAG;
}

- (NSString*) logValueUnit {
    return Accelerometer.LOG_UNIT;
}

@end
