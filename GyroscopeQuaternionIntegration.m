/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "GyroscopeQuaternionIntegration.h"

static NSString* const LOG_TAG = @"GDQ";

@implementation GyroscopeQuaternionIntegration

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    return self;
}

- (void) setIntegrationRate:(float)integrationRate sensorRate:(float)sensorRate {
    self->integrationRate = integrationRate;
    self->sensorRate = sensorRate;
    samples = (int) (sensorRate / integrationRate);
}

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [self get4DValuesLE:raw data:data offset:offset];
    qx = raw[0] / 32768.f;
    qy = raw[1] / 32768.f;
    qz = raw[2] / 32768.f;
    qw = raw[3] / 32768.f;
    self.value = [[IotSensorValue4D alloc] initWithX:qx Y:qy Z:qz W:qw];
    return self.value;
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

- (NSString*) logTag {
    return GyroscopeQuaternionIntegration.LOG_TAG;
}

@end
