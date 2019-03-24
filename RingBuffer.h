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

@interface RingBuffer : NSObject

@property NSUInteger capacity;
- (NSUInteger) count;
- (BOOL) isEmpty;
- (NSArray*) data;

- (id) initWithCapacity:(NSUInteger)capacity;
- (void) add:(NSObject*)object;

@end


@interface RingBuffer3D : NSObject

@property NSUInteger capacity;
@property RingBuffer* X;
@property RingBuffer* Y;
@property RingBuffer* Z;
- (NSUInteger) count;
- (BOOL) isEmpty;
- (NSArray*) data;

- (id) initWithCapacity:(NSUInteger)capacity;
- (void) addX:(NSObject*)x Y:(NSObject*)y Z:(NSObject*)z;

@end
