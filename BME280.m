/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BME280.h"

@interface TemperatureSensor_BME280 : TemperatureSensor {
    int32_t raw;
}
@end

@implementation TemperatureSensor_BME280

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [data getBytes:&raw range:NSMakeRange(offset, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.temperature = raw / 100.f;
    self.value = [[IotSensorValue alloc] initWithValue:self.temperature];
    return self.value;
}

@end


@interface HumiditySensor_BME280 : HumiditySensor {
    int32_t raw;
}
@end

@implementation HumiditySensor_BME280

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [data getBytes:&raw range:NSMakeRange(offset, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.humidity = raw / 1024.f;
    self.value = [[IotSensorValue alloc] initWithValue:self.humidity];
    return self.value;
}

@end


@interface PressureSensor_BME280 : PressureSensor {
    int32_t raw;
}
@end

@implementation PressureSensor_BME280

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    [data getBytes:&raw range:NSMakeRange(offset, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.pressure = raw;
    self.value = [[IotSensorValue alloc] initWithValue:self.pressure];
    return self.value;
}

@end


@implementation BME280

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.temperatureSensor = [[TemperatureSensor_BME280 alloc] init];
    self.humiditySensor = [[HumiditySensor_BME280 alloc] init];
    self.pressureSensor = [[PressureSensor_BME280 alloc] init];
    return self;
}

@end
