/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "InternalAPI.h"

NSString *const NotificationBLELayerEvent = @"BLELayerEvent";
NSString *const NotificationCloudCapableEKWillConnect = @"NotificationCloudCapableEKWillConnect";
NSString *const NotificationBLELayerActuation = @"BLELayerActuation";
NSString *const NotificationBLELayerConfiguration = @"BLELayerConfiguration";

@implementation DataEvent

- (id) initWithType:(NSInteger)type data:(NSString*)data {
    self = [super init];
    if (!self)
        return nil;
    self.EventType = type;
    self.Data = data;
    return self;
}

@end

//******************************************************************************

@implementation DataMsg

- (id) initWithEKID:(NSString*)EKID {
    self = [super init];
    if (!self)
        return nil;
    self.EKID = EKID;
    self.Events = [NSMutableArray arrayWithCapacity:5];
    return self;
}

@end

//******************************************************************************

@implementation ConfigurationMsg

@end
