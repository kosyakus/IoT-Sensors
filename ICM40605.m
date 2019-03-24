/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ICM40605.h"

@interface Accelerometer_ICM40605 : Accelerometer {
    int16_t raw[3];
}
@end

@implementation Accelerometer_ICM40605

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [self get3DValuesLE:raw data:data offset:offset];
    return [super processRawData:raw];
}

@end


@interface Gyroscope_ICM40605 : Gyroscope {
    int16_t raw[3];
}
@end

@implementation Gyroscope_ICM40605

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [self get3DValuesLE:raw data:data offset:offset];
    return [super processRawData:raw];
}

@end


static const float ACCELEROMETER_SENSITIVITY[] = { 2048.f, 4096.f, 8192.f, 16384.f };
static const float GYROSCOPE_SENSITIVITY[] = { 16.4f, 32.8f, 65.6f, 131.2f, 262.4f };
static NSDictionary* GYROSCOPE_RATES;
static NSDictionary* ACCELEROMETER_RATES;


@implementation ICM40605

+ (void) initialize {
    if (self != [ICM40605 class])
        return;

    GYROSCOPE_RATES = @{
            @10 : @25.f,
            @9 : @50.f,
            @8 : @100.f,
            @7 : @200.f,
            @6 : @1000.f
    };
    ACCELEROMETER_RATES = @{
            @10 : @25.f,
            @9 : @50.f,
            @8 : @100.f,
            @7 : @200.f,
            @6 : @1000.f
    };
}

- (id) init {
    self = [super init];
    if (!self)
        return nil;

    self.accelerometer = [[Accelerometer_ICM40605 alloc] init];
    self.gyroscope = [[Gyroscope_ICM40605 alloc] init];
    self.accelerometer.sensitivity = 16384;
    self.gyroscope.rate = 10;
    self.gyroscope.sensitivity = 16.4;
    return self;
}

- (void) processAccelerometerRawConfigRange:(int)range {
    self.accelerometer.sensitivity = ACCELEROMETER_SENSITIVITY[range];
}

- (void) processGyroscopeRawConfigRange:(int)range rate:(int)rate {
    self.gyroscope.sensitivity = GYROSCOPE_SENSITIVITY[range];
    if (rate > 0) {
        self.gyroscope.rate = [GYROSCOPE_RATES[@(rate)] floatValue];
    }
}

- (float) getAccelerometerRateFromRawConfig:(int)raw {
    return [ACCELEROMETER_RATES[@(raw)] floatValue];
}

- (float) getGyroscopeRateFromRawConfig:(int)raw {
    return [GYROSCOPE_RATES[@(raw)] floatValue];
}

@end
