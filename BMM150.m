/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BMM150.h"

@interface Magnetometer_BMM150 : Magnetometer{
    int16_t raw[3];
}
@end

@implementation Magnetometer_BMM150

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [self get3DValuesLE:raw data:data offset:offset];
    x = raw[0] * 0.3174f;
    y = raw[1] * 0.3174f;
    z = raw[2] * 0.1526f;
    [self calculateHeading];
    self.value = [[IotSensorValue3D alloc] initWithX:x Y:y Z:z];
    return self.value;
}

@end


@implementation BMM150

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.magnetometer = [[Magnetometer_BMM150 alloc] init];
    return self;
}

@end
