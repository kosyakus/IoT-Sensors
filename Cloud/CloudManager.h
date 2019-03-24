/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#ifndef CloudManager_h
#define CloudManager_h

#import <Foundation/Foundation.h>
#import "IotSensorsDevice.h"

extern NSString *const NotificationBLEAdvertisementRx;

@interface CloudManager : NSObject

+(id)sharedCloudManager;

- (void)startCloudManager;
- (void)stopCloudManager;

- (IotSensorsDevice *)getConnectedDevice;
- (BOOL)isDeviceConnected;

- (void)handleMsg:(NSData *)data;

-(NSString *)getUTCDate:(NSDate *)localDate;
-(NSString *)getUTCDate2:(NSDate *)localDate;

-(void)iftttTimerTemperatureStart:(NSTimeInterval)period;
-(void)iftttTimerTemperatureStop;
-(void)iftttTimerHumidityStart:(NSTimeInterval)period;
-(void)iftttTimerHumidityStop;
-(void)iftttTimerPressureStart:(NSTimeInterval)period;
-(void)iftttTimerPressureStop;

-(void)cloudThrottlingTimersStart;
-(void)cloudThrottlingTimersStop;
-(void)cloudThrottlingTimerTemperatureStart;
-(void)cloudThrottlingTimerTemperatureStop;
-(void)cloudThrottlingTimerHumidityStart;
-(void)cloudThrottlingTimerHumidityStop;
-(void)cloudThrottlingTimerPressureStart;
-(void)cloudThrottlingTimerPressureStop;
-(void)cloudThrottlingTimerAirQualityStart;
-(void)cloudThrottlingTimerAirQualityStop;
-(void)cloudThrottlingTimerBrightnessStart;
-(void)cloudThrottlingTimerBrightnessStop;

-(void)setConnectedDevice;

@end

#endif /* CloudManager_h */
