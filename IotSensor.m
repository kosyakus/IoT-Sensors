/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSensor.h"

@implementation IotSensor

- (BOOL) validValue {
    return self.value != nil;
}

- (NSString*) logTag {
    return @"";
}

- (IotSensorValue*) logValue {
    return self.value;
}

- (NSString*) logValueUnit {
    return @"";
}

- (NSString*) logEntry {
    IotSensorValue* value = self.logValue;
    NSString* unit = self.logValueUnit;
    switch (value.dim) {
        case 1:
            return [NSString stringWithFormat:@"%.2f%@", value.get, unit];
        case 3:
            return [NSString stringWithFormat:@"%8.2f%@ %8.2f%@ %8.2f%@", value.x, unit, value.y, unit, value.z, unit];
        case 4:
            return [NSString stringWithFormat:@"%8.2f%@ %8.2f%@ %8.2f%@ %8.2f%@", value.w, unit, value.x, unit, value.y, unit, value.z, unit];
    }
    return nil;
}

- (float) displayValue {
    return self.value.get;
}

- (IotSensorValue*) graphValue {
    IotSensorValue* value = self.unprocessedGraphValue;
    return !self.graphValueProcessor ? value : [self.graphValueProcessor process:value];
}

- (IotSensorValue*) unprocessedGraphValue {
    return self.value;
}

- (void) get3DValuesLE:(int16_t*)values data:(NSData*)data offset:(int)offset {
    [data getBytes:values range:NSMakeRange(offset, 6)];
    for (int i = 0; i < 3; ++i)
        values[i] = CFSwapInt16LittleToHost(values[i]);
}

- (void) get4DValuesLE:(int16_t*)values data:(NSData*)data offset:(int)offset {
    // [ w, x, y, z ] -> [ x, y, z, w ]
    [data getBytes:values range:NSMakeRange(offset + 2, 6)];
    [data getBytes:values + 3 range:NSMakeRange(offset, 2)];
    for (int i = 0; i < 4; ++i)
        values[i] = CFSwapInt16LittleToHost(values[i]);
}

- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset {
    return nil;
}

- (IotSensorValue*) cloudValue {
    return self.value;
}

- (NSString*) cloudData {
    IotSensorValue* value = self.cloudValue;
    switch (value.dim) {
        case 1:
            return [NSString stringWithFormat:@"%.3f", value.get];
        case 3:
            return [NSString stringWithFormat:@"%.3f %.3f %.3f", value.x, value.y, value.z];
        case 4:
            return [NSString stringWithFormat:@"%.3f %.3f %.3f %.3f", value.x, value.y, value.z, value.w];
    }
    return nil;
}

@end


@implementation IotSensorValue {
    float value1;
}

- (id) init {
    return [self initWithValue:0];
}

- (id) initWithValue:(float)value {
    self = [super init];
    if (!self)
        return nil;
    value1 = value;
    return self;
}

- (float) get {
    return value1;
}

- (float) x {
    return value1;
}

- (float) y {
    return value1;
}

- (float) z {
    return value1;
}

- (float) w {
    return value1;
}

- (float) roll {
    return value1;
}

- (float) pitch {
    return value1;
}

- (float) yaw {
    return value1;
}

- (int) dim {
    return 1;
}

@end


@implementation IotSensorValue3D {
    float value2, value3;
}

- (id) init {
    return [self initWithX:0 Y:0 Z:0];
}

- (id) initWithX:(float)x Y:(float)y Z:(float)z {
    self = [super initWithValue:x];
    if (!self)
        return nil;
    value2 = y;
    value3 = z;
    return self;
}

- (float) y {
    return value2;
}

- (float) z {
    return value3;
}

- (float) pitch {
    return value2;
}

- (float) yaw {
    return value3;
}

- (int) dim {
    return 3;
}

@end


@implementation IotSensorValue4D {
    float value4;
}

- (id) init {
    return [self initWithX:0 Y:0 Z:0 W:0];
}

- (id) initWithX:(float)x Y:(float)y Z:(float)z W:(float)w {
    self = [super initWithX:x Y:y Z:z];
    if (!self)
        return nil;
    value4 = w;
    return self;
}

- (float) w {
    return value4;
}

- (int) dim {
    return 4;
}

@end
