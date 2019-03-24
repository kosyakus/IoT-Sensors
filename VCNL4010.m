/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "VCNL4010.h"

@interface AmbientLightSensor_VCNL4010 : AmbientLightSensor {
    int32_t raw;
}
@end

@implementation AmbientLightSensor_VCNL4010

- (IotSensorValue*) processRawData: (NSData*)data offset:(int)offset {
    uint8_t state;
    [data getBytes:&state range:NSMakeRange(offset, 1)];
    self.lowVoltage = state == 0;
    [data getBytes:&raw range:NSMakeRange(offset + 2, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.ambientLight = raw / 4;
    self.value = [[IotSensorValue alloc] initWithValue:self.ambientLight];
    return self.value;
}

@end


@interface ProximitySensor_VCNL4010 : ProximitySensor {
    int32_t raw;
}
@end

@implementation ProximitySensor_VCNL4010

- (IotSensorValue*) processRawData: (NSData*)data offset:(int)offset {
    uint8_t state;
    [data getBytes:&state range:NSMakeRange(offset, 1)];
    self.lowVoltage = state == 0;
    [data getBytes:&raw range:NSMakeRange(offset + 2, 4)];
    raw = CFSwapInt32LittleToHost(raw);
    self.objectNearby = raw != 0;
    self.value = [[IotSensorValue alloc] initWithValue:self.objectNearby ? 1 : 0];
    return self.value;
}

@end


@implementation VCNL4010

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.ambientLightSensor = [[AmbientLightSensor_VCNL4010 alloc] init];
    self.proximitySensor = [[ProximitySensor_VCNL4010 alloc] init];
    return self;
}

@end
