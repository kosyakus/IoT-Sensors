/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <MQTTClient/MQTTClient.h>

extern NSString *const NotificationConnectedToCloudService;

@interface MqttClient : NSObject <MQTTSessionDelegate>

- (void)start;

- (void)stop;

- (void)publishMessage:(NSString *)msg inTopic:(NSString *)topic;

@end
