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
@class IotSensorValue;


@protocol GraphValueProcessor <NSObject>

- (IotSensorValue*) process:(IotSensorValue*) v;

@end


@interface IotSensor : NSObject

@property IotSensorValue* value;
@property id<GraphValueProcessor> graphValueProcessor;

- (BOOL) validValue;

- (NSString*) logTag;
- (IotSensorValue*) logValue;
- (NSString*) logValueUnit;
- (NSString*) logEntry;
- (float) displayValue;
- (IotSensorValue*) graphValue;
- (IotSensorValue*) unprocessedGraphValue;

- (void) get3DValuesLE:(int16_t*)values data:(NSData*)data offset:(int)offset;
- (void) get4DValuesLE:(int16_t*)values data:(NSData*)data offset:(int)offset;
- (IotSensorValue*) processRawData:(NSData*)data offset:(int)offset;

- (IotSensorValue*) cloudValue;
- (NSString*) cloudData;

@end


@interface IotSensorValue : NSObject

- (id) initWithValue:(float)value;
- (int) dim;
- (float) get;
- (float) x;
- (float) y;
- (float) z;
- (float) w;
- (float) roll;
- (float) pitch;
- (float) yaw;

@end

@interface IotSensorValue3D : IotSensorValue

- (id) initWithX:(float)x Y:(float)y Z:(float)z;

@end

@interface IotSensorValue4D : IotSensorValue3D

- (id) initWithX:(float)x Y:(float)y Z:(float)z W:(float)w;

@end
