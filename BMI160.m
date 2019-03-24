/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BMI160.h"

@interface Accelerometer_BMI160 : Accelerometer {
    int16_t raw[3];
}
@end

@implementation Accelerometer_BMI160

- (IotSensorValue*) processRawData: (NSData*)data offset:(int)offset {
    [self get3DValuesLE:raw data:data offset:offset];
    return [super processRawData:raw];
}

@end


@interface Gyroscope_BMI160 : Gyroscope {
    int16_t raw[3];
}
@end

@implementation Gyroscope_BMI160

- (IotSensorValue*) processRawData: (NSData*)data offset:(int)offset {
    [self get3DValuesLE:raw data:data offset:offset];
    return [super processRawData:raw];
}

@end


static NSDictionary* ACCELEROMETER_SENSITIVITY;
static const float GYROSCOPE_SENSITIVITY[] = { 16.4f, 32.8f, 65.6f, 131.2f, 262.4f };
static const float GYROSCOPE_RATES[] = { 0.78f, 1.56f, 3.12f, 6.25f, 12.5f, 25.f, 50.f, 100.f };


@implementation BMI160

+ (void) initialize {
    if (self != [BMI160 class])
        return;

    ACCELEROMETER_SENSITIVITY = @{
            @3 : @16384.f,
            @5 : @8192.f,
            @8 : @4096.f,
            @12 : @2048.f
    };
}

- (id) init {
    self = [super init];
    if (!self)
        return nil;

    self.accelerometer = [[Accelerometer_BMI160 alloc] init];
    self.gyroscope = [[Gyroscope_BMI160 alloc] init];
    self.accelerometer.sensitivity = 16384;
    self.gyroscope.rate = 10;
    self.gyroscope.sensitivity = 16.4;
    return self;
}

- (void) processAccelerometerRawConfigRange:(int)range {
    self.accelerometer.sensitivity = [ACCELEROMETER_SENSITIVITY[@(range)] floatValue];
}

- (void) processGyroscopeRawConfigRange:(int)range rate:(int)rate {
    self.gyroscope.sensitivity = GYROSCOPE_SENSITIVITY[range];
    if (rate > 0) {
        self.gyroscope.rate = GYROSCOPE_RATES[rate - 1];
    }
}

@end
