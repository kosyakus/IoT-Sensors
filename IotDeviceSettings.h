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
@class IotSensorsDevice;

@interface IotDeviceSettings : NSObject

@property (weak) IotSensorsDevice* device;
@property int length;
@property BOOL valid;
@property BOOL modified;
@property void (^processCallback)(void);

- (id) initWithDevice:(IotSensorsDevice*)device;
- (void) process:(NSData*)data offset:(int)offset;
- (NSData*) pack;
- (void) save:(NSDictionary*)spec;
- (void) load:(NSDictionary*)spec;

@end
