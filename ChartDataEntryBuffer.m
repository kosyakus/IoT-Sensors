/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ChartDataEntryBuffer.h"
#import "IoT_Sensors-Swift.h"
#import "IotSensor.h"

@implementation ChartDataEntryBuffer

- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super initWithCapacity:capacity];
    return self;
}

- (void) addEntry:(float)value {
    [super add:[[ChartDataEntry alloc] initWithX:++self.lastIndex y:value]];
}

- (void) add:(NSObject*)value {
    [self addEntry:((IotSensorValue*)value).get];
}

@end


@implementation ChartDataEntryBuffer3D

- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super initWithCapacity:capacity];
    return self;
}

- (void) addEntryX:(float)x Y:(float)y Z:(float)z {
    ++self.lastIndex;
    [super addX:[[ChartDataEntry alloc] initWithX:++self.lastIndex y:x]
              Y:[[ChartDataEntry alloc] initWithX:++self.lastIndex y:y]
              Z:[[ChartDataEntry alloc] initWithX:++self.lastIndex y:z]];
}

- (void) add:(IotSensorValue*)value {
    [self addEntryX:value.x Y:value.y Z:value.z];
}

@end
