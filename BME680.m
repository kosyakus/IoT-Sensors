/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BME680.h"

@interface GasSensor_BME680 : GasSensor {
    int32_t raw;
}
@end

@implementation GasSensor_BME680

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [data getBytes:&raw range:NSMakeRange(offset, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.reading = raw;
    self.value = [[IotSensorValue alloc] initWithValue:self.reading];
    return self.value;
}

@end


@interface AirQualitySensor_BME680 : AirQualitySensor {
    int32_t raw;
}
@end

@implementation AirQualitySensor_BME680

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    self.accuracy = ((uint8_t*)data.bytes)[offset];
    [data getBytes:&raw range:NSMakeRange(offset + 1, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.quality = raw;
    [self calculateAirQualityIndex];
    self.value = [[IotSensorValue alloc] initWithValue:self.quality];
    return self.value;
}

@end


@implementation BME680

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.gasSensor = [[GasSensor_BME680 alloc] init];
    self.airQualitySensor = [[AirQualitySensor_BME680 alloc] init];
    return self;
}

@end
