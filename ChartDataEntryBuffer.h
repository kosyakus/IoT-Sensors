/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <Foundation/Foundation.h>
#import "RingBuffer.h"
@class IotSensorValue;
@class IotSensorValue3D;


@interface ChartDataEntryBuffer : RingBuffer

@property int lastIndex;

- (void) addEntry:(float)value;
- (void) add:(NSObject*)value;

@end


@interface ChartDataEntryBuffer3D : RingBuffer3D

@property int lastIndex;

- (void) addEntryX:(float)x Y:(float)y Z:(float)z;
- (void) add:(IotSensorValue*)value;

@end
