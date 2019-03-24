/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "CloudManager.h"
#import "MqttClient.h"
#import "SettingsVault.h"
#import "InternalAPI.h"
#import "CloudAPI.h"

#import "BluetoothManager.h"
#import "IotSensorsDevice.h"

#define kCloudTimersPeriod 10 // in seconds

NSString *const NotificationBLEAdvertisementRx = @"NotificationBLEAdvertisementRx";

@interface CloudManager ()

@property (strong, nonatomic) MqttClient *mqttClient;

@property (strong, nonatomic) dispatch_queue_t serialMqttClientPublishQueue;

@property (strong, nonatomic) NSTimer *iftttTemperatureTimer;
@property (nonatomic) BOOL isClearToSendTemperatureIfttt;
@property (strong, nonatomic) NSTimer *iftttHumidityTimer;
@property (nonatomic) BOOL isClearToSendHumidityIfttt;
@property (strong, nonatomic) NSTimer *iftttPressureTimer;
@property (nonatomic) BOOL isClearToSendPressureIfttt;

@property (strong, nonatomic) NSTimer *cloudThrottlingTemperatureTimer;
@property (nonatomic) BOOL isClearToSendTemperatureCloud;
@property (strong, nonatomic) NSTimer *cloudThrottlingHumidityTimer;
@property (nonatomic) BOOL isClearToSendHumidityCloud;
@property (strong, nonatomic) NSTimer *cloudThrottlingPressureTimer;
@property (nonatomic) BOOL isClearToSendPressureCloud;
@property (strong, nonatomic) NSTimer *cloudThrottlingAirQualityTimer;
@property (nonatomic) BOOL isClearToSendAirQualityCloud;
@property (strong, nonatomic) NSTimer *cloudThrottlingBrightnessTimer;
@property (nonatomic) BOOL isClearToSendBrightnessCloud;

@property (strong, nonatomic) NSMutableSet *trackedDevicesSet; // Of <NSString> = (DeviceId)

@property (nonatomic) Boolean lastProximityValue;
@end


@implementation CloudManager

+(id)sharedCloudManager {
    static CloudManager *internalSharedCloudManager = nil;
    static dispatch_once_t once_token;

    dispatch_once(&once_token, ^{
        internalSharedCloudManager =[[self alloc] init];
    });

    return internalSharedCloudManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _serialMqttClientPublishQueue = dispatch_queue_create("serialMqttClientPublishQueue", DISPATCH_QUEUE_SERIAL);
        _mqttClient = [[MqttClient alloc] init];

        _trackedDevicesSet = [NSMutableSet setWithCapacity:0];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCloudCapableEKWillConnect:) name:NotificationCloudCapableEKWillConnect object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLELayerEvent:) name:NotificationBLELayerEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectToCloudService:) name:NotificationConnectedToCloudService object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectedPeripheral:) name:BluetoothManagerConnectedPeripheral object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisconnectedPeripheral:) name:BluetoothManagerDisconnectedPeripheral object:nil];

        if([[SettingsVault sharedSettingsVault] getConfigIftttEnable] == YES) {
            [self iftttTimerTemperatureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
            [self iftttTimerHumidityStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
            [self iftttTimerPressureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
        }
    }

    return self;
}

#pragma mark - Public interface

- (void)startCloudManager {
    [self.mqttClient start];

    [self cloudThrottlingTimersStart];

    NSLog(@"Connected EKID: %@", [self getConnectedDevice].ekid);
}

- (void)stopCloudManager {
    [self.mqttClient stop];

    [self cloudThrottlingTimersStop];
}

- (void)handleMsg:(NSData *)data {
    JSONModelError *err;
    ServiceEdgeApiMsg *wrapperMsg = [[ServiceEdgeApiMsg alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

    if (err != nil) {
        NSLog(@" ServiceEdgeApiMsg deserialization error: %@ ", err.description);
    }

    if (wrapperMsg.Actuations == nil && wrapperMsg.MgmtMsgs == nil) {
        return;
    }

    for (CloudDataMsg *cloudDataMsg in wrapperMsg.Actuations) {

        NSLog(@"Msg EKID: %@, connected EKID: %@", wrapperMsg.EKID, [self getConnectedDevice].ekid);

        if ((wrapperMsg.EKID == nil) ||
            ([wrapperMsg.EKID  isEqualToString:[self getConnectedDevice].ekid])) {

            DataMsg *toBleMsg = [[DataMsg alloc] init];
            toBleMsg.EKID = (wrapperMsg.EKID == nil) ? [self getConnectedDevice].ekid : wrapperMsg.EKID;
            DataEvent *evt = [[DataEvent alloc] init];
            evt.EventType = cloudDataMsg.MsgType;
            evt.Data = cloudDataMsg.Data;
            toBleMsg.Events = (NSMutableArray<DataEvent> *)[NSMutableArray arrayWithObject:evt];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBLELayerActuation object:toBleMsg userInfo:nil];
        }
    }

    for (CloudMgmtMsg *cloudMgmtMsg in wrapperMsg.MgmtMsgs) {
        NSLog(@"<=== MgmtMsg: Operation: %ld, Payload: %@", cloudMgmtMsg.OperationType, cloudMgmtMsg.Payload);

        switch (cloudMgmtMsg.OperationType) {
            case eMgmtEdgeOperations_ThrottlingSet:
            {
                break;
            }
            case eMgmtEdgeOperations_AssetTrackingConfigSet:
            {
                JSONModelError *err;
                MgmtAssetTrackingConfigMsg *config = [[MgmtAssetTrackingConfigMsg alloc] initWithString:cloudMgmtMsg.Payload error:&err];

                if (err != nil) {
                    NSLog(@" MgmtAssetTrackingConfigMsg deserialization error: %@ ", err.description);
                }

                // Handle SetTrackedTags
                if (config.TrackedTags != nil) {
                    switch (config.Operation) {
                        case eMgmtAssetTrackingSetTrackedTagsOperations_Add:
                        {
                            [self.trackedDevicesSet addObjectsFromArray:config.TrackedTags];
                            break;
                        }
                        case eMgmtAssetTrackingSetTrackedTagsOperations_Remove:
                        {
                            for (NSString *device in config.TrackedTags) {
                                [self.trackedDevicesSet removeObject:device];
                            }
                            break;
                        }
                        case eMgmtAssetTrackingSetTrackedTagsOperations_Overwrite:
                        {
                            [self.trackedDevicesSet removeAllObjects];
                            [self.trackedDevicesSet addObjectsFromArray:config.TrackedTags];
                            break;
                        }
                        default:
                        {
                            break;
                        }
                    }
                }

                // Handle RssiDelta
                // TODO: Placeholder for future releases

                // Handle ForceSendAfterSecs
                // TODO: Placeholder for future releases

                // Handle TrackedTagsUpdatePeriod
                // TODO: Placeholder for future releases

                break;
            }
            default:
            {
                break;
            }
        }
    }
}

- (IotSensorsDevice *)getConnectedDevice {
    return BluetoothManager.instance.device;
}

- (BOOL)isDeviceConnected {
    if (BluetoothManager.instance.device.state != CBPeripheralStateConnected) {
        return NO;
    }

    return YES;
}

-(void)iftttTimerTemperatureStart:(NSTimeInterval)period {
    self.iftttTemperatureTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(updateIftttClearToSendTemperatureFlag) userInfo:nil repeats:YES];
}
-(void)iftttTimerHumidityStart:(NSTimeInterval)period {
    self.iftttHumidityTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(updateIftttClearToSendHumidityFlag) userInfo:nil repeats:YES];
}
-(void)iftttTimerPressureStart:(NSTimeInterval)period {
    self.iftttPressureTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(updateIftttClearToSendPressureFlag) userInfo:nil repeats:YES];
}

-(void)iftttTimerTemperatureStop {
    if(self.iftttTemperatureTimer != nil) {
        [self.iftttTemperatureTimer invalidate];
    }
}
-(void)iftttTimerHumidityStop {
    if(self.iftttHumidityTimer != nil) {
        [self.iftttHumidityTimer invalidate];
    }
}
-(void)iftttTimerPressureStop {
    if(self.iftttPressureTimer != nil) {
        [self.iftttPressureTimer invalidate];
    }
}

-(void)cloudThrottlingTimersStart {
    [self cloudThrottlingTimerTemperatureStart];
    [self cloudThrottlingTimerHumidityStart];
    [self cloudThrottlingTimerPressureStart];
    [self cloudThrottlingTimerAirQualityStart];
    [self cloudThrottlingTimerBrightnessStart];
}

-(void)cloudThrottlingTimersStop {
    if(self.cloudThrottlingTemperatureTimer != nil) {
        [self cloudThrottlingTimerTemperatureStop];
    }
    if(self.cloudThrottlingHumidityTimer != nil) {
        [self cloudThrottlingTimerHumidityStop];
    }
    if(self.cloudThrottlingPressureTimer != nil) {
        [self cloudThrottlingTimerPressureStop];
    }
    if(self.cloudThrottlingAirQualityTimer != nil) {
        [self cloudThrottlingTimerAirQualityStop];
    }
    if(self.cloudThrottlingBrightnessTimer != nil) {
        [self cloudThrottlingTimerBrightnessStop];
    }
}


-(void)cloudThrottlingTimerTemperatureStart {
    if(!self.cloudThrottlingTemperatureTimer)
        self.cloudThrottlingTemperatureTimer = [NSTimer scheduledTimerWithTimeInterval:kCloudTimersPeriod target:self selector:@selector(updateCloudClearToSendTemperatureFlag) userInfo:nil repeats:YES];
}
-(void)cloudThrottlingTimerTemperatureStop {
    if(self.cloudThrottlingTemperatureTimer != nil) {
        [self.cloudThrottlingTemperatureTimer invalidate];
        self.cloudThrottlingTemperatureTimer = nil;
    }
}

-(void)cloudThrottlingTimerHumidityStart {
    if(!self.cloudThrottlingHumidityTimer)
        self.cloudThrottlingHumidityTimer = [NSTimer scheduledTimerWithTimeInterval:kCloudTimersPeriod target:self selector:@selector(updateCloudClearToSendHumidityFlag) userInfo:nil repeats:YES];
}
-(void)cloudThrottlingTimerHumidityStop {
    if(self.cloudThrottlingHumidityTimer != nil) {
        [self.cloudThrottlingHumidityTimer invalidate];
        self.cloudThrottlingHumidityTimer = nil;
    }
}

-(void)cloudThrottlingTimerPressureStart {
    if(!self.cloudThrottlingPressureTimer)
        self.cloudThrottlingPressureTimer = [NSTimer scheduledTimerWithTimeInterval:kCloudTimersPeriod target:self selector:@selector(updateCloudClearToSendPressureFlag) userInfo:nil repeats:YES];
}
-(void)cloudThrottlingTimerPressureStop {
    if(self.cloudThrottlingPressureTimer != nil) {
        [self.cloudThrottlingPressureTimer invalidate];
        self.cloudThrottlingPressureTimer = nil;
    }
}

-(void)cloudThrottlingTimerAirQualityStart {
    if(!self.cloudThrottlingAirQualityTimer)
        self.cloudThrottlingAirQualityTimer = [NSTimer scheduledTimerWithTimeInterval:kCloudTimersPeriod target:self selector:@selector(updateCloudClearToSendAirQualityFlag) userInfo:nil repeats:YES];
}
-(void)cloudThrottlingTimerAirQualityStop {
    if(self.cloudThrottlingAirQualityTimer != nil) {
        [self.cloudThrottlingAirQualityTimer invalidate];
        self.cloudThrottlingAirQualityTimer = nil;
    }
}

-(void)cloudThrottlingTimerBrightnessStart {
    if(!self.cloudThrottlingBrightnessTimer)
        self.cloudThrottlingBrightnessTimer = [NSTimer scheduledTimerWithTimeInterval:kCloudTimersPeriod target:self selector:@selector(updateCloudClearToSendBrightnessFlag) userInfo:nil repeats:YES];
}
-(void)cloudThrottlingTimerBrightnessStop {
    if(self.cloudThrottlingBrightnessTimer != nil) {
        [self.cloudThrottlingBrightnessTimer invalidate];
        self.cloudThrottlingBrightnessTimer = nil;
    }
}

-(void)setConnectedDevice {
    IotSensorsDevice *connectedDevice = [[CloudManager sharedCloudManager] getConnectedDevice];

    if (connectedDevice != nil && [[SettingsVault sharedSettingsVault] getUSERID] != nil) {
        // Send MgmtGetEKIDReq
        MgmtGetEKIDReq *req = [[MgmtGetEKIDReq alloc] init];
        req.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

        NSString *finalUrl = [[MgmtGetEKIDReq constructGetEKIDReqRoute] stringByAppendingString:[MgmtGetEKIDReq constructUrlParams:req]];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                        JSONModelError *err;
                                                        MgmtGetEKIDRsp *rsp = [[MgmtGetEKIDRsp alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] error:&err];

                                                        if (err != nil) {
                                                            NSLog(@" MgmtGetEKIDRsp deserialization error: %@ ", error.description);
                                                        }

                                                        NSUInteger barIndex = [rsp.Devices indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                                            if ([((EKDevice *)obj).EKID isEqualToString:connectedDevice.ekid]) {
                                                                *stop = YES;
                                                                return YES;
                                                            }
                                                            return NO;
                                                        }];

                                                        NSString *devIndication = @"";
                                                        if (barIndex != NSNotFound) {
                                                            EKDevice *dev = (EKDevice *)[rsp.Devices objectAtIndex:barIndex];
                                                            devIndication = [[[dev.EKID stringByAppendingString:@" ("] stringByAppendingString:dev.FriendlyName] stringByAppendingString:@")"];
                                                        }
                                                        else {
                                                            devIndication = @"No connected device";
                                                        }

                                                        [[NSUserDefaults standardUserDefaults] setObject:devIndication forKey:@"connectedDeviceIndication"];
                                                    }];
        [dataTask resume];
    }
    else {
        NSLog(@"=========> No connected device or cloud not initialized");
    }
}

#pragma mark - Notifications

- (void) onConnectedPeripheral:(NSNotification*)notification {
    [self setConnectedDevice];
}

- (void) onDisconnectedPeripheral:(NSNotification*)notification {
    [[NSUserDefaults standardUserDefaults] setObject:@"No connected device" forKey:@"connectedDeviceIndication"];
}

- (void) onConnectToCloudService:(NSNotification*)notification {
    // Send AssetTrackingGetCongig request

    // Construct CloudMgmtMsg
    CloudMgmtMsg *cloudMgmtMsg = [[CloudMgmtMsg alloc] init];
    cloudMgmtMsg.OperationType = eMgmtServiceOperations_AssetTrackingConfigGet;
    cloudMgmtMsg.Payload = @"";
    // Construct API msg
    EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
    msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
    msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
    msg.Timestamp = [self getUTCDate:[NSDate date]];
    msg.MgmtMsgs = (NSMutableArray<CloudMgmtMsg> *)[NSMutableArray arrayWithObject:cloudMgmtMsg];;
    msg.Events = nil;

    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
}

- (void) onCloudCapableEKWillConnect:(NSNotification*)notification {
    NSString *EKID = (NSString *)notification.object;

    if([[SettingsVault sharedSettingsVault] getConfigHasEnabledCloudAtLeastOnce] == NO ||
       [[SettingsVault sharedSettingsVault] getUSERID] == nil) {
        return;
    }

    // Send SetDeviceReq
    MgmtSetDeviceReq *req = [[MgmtSetDeviceReq alloc] init];
    req.OperationType = eCommonOperationTypes_Insert;
    req.DeviceInfo = [[EKDevice alloc] init];
    req.DeviceInfo.EKID = EKID;
    req.DeviceInfo.UserId = [[SettingsVault sharedSettingsVault] getUSERID];

    NSString *finalUrl = [MgmtSetDeviceReq constructRoute];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    if (error == nil) {
                                                        NSLog(@"[[MGMT] SetDeviceReq request sent");
                                                    }
                                                }];

    [dataTask resume];
}

- (void) onBLELayerEvent:(NSNotification*)notification {
    DataMsg *dataMsg = (DataMsg *)notification.object;

    //NSLog(@"[BLE msg Rx] EKID: %@, Number of events: %tu", dataMsg.EKID, [dataMsg.Events count]);

    // Handle
    for (DataEvent *evt in dataMsg.Events) {
        switch (evt.EventType)
        {
            case eEventTypes_Temperature:
            {
                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Temperature;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   self.isClearToSendTemperatureCloud == YES) {
                    self.isClearToSendTemperatureCloud = NO;
                    [self cloudThrottlingTimerTemperatureStop];
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                    [self cloudThrottlingTimerTemperatureStart];
                }

                // Post IFTTT
                if([[SettingsVault sharedSettingsVault] getConfigIftttEnable] == YES &&
                   self.isClearToSendTemperatureIfttt == YES) {
                    self.isClearToSendTemperatureIfttt = NO;
                    [self iftttTimerTemperatureStop];
                    [self sendIFTTT:@"T" withValue:evt.Data];
                    [self iftttTimerTemperatureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
                }
                break;
            }
            case eEventTypes_Humidity:
            {
                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Humidity;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   self.isClearToSendHumidityCloud == YES) {
                    self.isClearToSendHumidityCloud = NO;
                    [self cloudThrottlingTimerHumidityStop];
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                    [self cloudThrottlingTimerHumidityStart];
                }

                // Post IFTTT
                if([[SettingsVault sharedSettingsVault] getConfigIftttEnable] == YES &&
                   self.isClearToSendHumidityIfttt == YES) {
                    self.isClearToSendHumidityIfttt = NO;
                    [self iftttTimerHumidityStop];
                    [self sendIFTTT:@"H" withValue:evt.Data];
                    [self iftttTimerHumidityStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
                }

                break;
            }
            case eEventTypes_Pressure:
            {
                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Pressure;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   self.isClearToSendPressureCloud == YES) {
                    self.isClearToSendPressureCloud = NO;
                    [self cloudThrottlingTimerPressureStop];
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                    [self cloudThrottlingTimerPressureStart];
                }

                // Post IFTTT
                if([[SettingsVault sharedSettingsVault] getConfigIftttEnable] == YES &&
                   self.isClearToSendPressureIfttt == YES) {
                    self.isClearToSendPressureIfttt = NO;
                    [self iftttTimerPressureStop];
                    [self sendIFTTT:@"P" withValue:evt.Data];
                    [self iftttTimerPressureStart:[[[SettingsVault sharedSettingsVault] getConfigIftttEventPeriod] doubleValue]];
                }

                break;
            }
            case eEventTypes_Button:
            {
                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Button;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Post IFTTT
                if([[SettingsVault sharedSettingsVault] getConfigIftttEnable] == YES) {
                    [self sendIFTTT:@"B" withValue:evt.Data];
                }

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES && [[SettingsVault sharedSettingsVault] getConfig3DGameEnable] == YES) {
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                }

                break;
            }
            case eEventTypes_Fusion:
            {
                // Dbg
                //NSLog(@"------->>> %@", evt.Data);

                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Fusion;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   [[SettingsVault sharedSettingsVault] getConfig3DGameEnable] == YES) {
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                }

                break;
            }
            case eEventTypes_Advertise:
            {
                // Dbg
                NSLog(@"[CloudManager][BLE -> Cloud][ADVERTISEMENT] %@", evt.Data);

                // Inform interested VCs
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBLEAdvertisementRx object:evt.Data userInfo:nil];

                // Check if this is a tracked device
                if ([self.trackedDevicesSet containsObject:[evt.Data componentsSeparatedByString:@" "][0]] == NO) {
                    break;
                }

                // Send to cloud
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Advertise;
                AssetTrackingAdvertiseMsg *advMsg = [[AssetTrackingAdvertiseMsg alloc] init];
                advMsg.Mac = [evt.Data componentsSeparatedByString:@" "][0];
                advMsg.Rssi = [[evt.Data componentsSeparatedByString:@" "][1] integerValue];
                cloudDataMsg.Data = [advMsg toJSONString];
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   [[SettingsVault sharedSettingsVault] getConfigAssetTrackingEnable] == YES) {
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                }

                break;
            }
            case eEventTypes_Gyroscope:
                break;
            case eEventTypes_Proximity:
            {
                if ([evt.Data boolValue] == self.lastProximityValue)
                    break;

                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Proximity;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES) {
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                }

                self.lastProximityValue = [evt.Data boolValue];

                break;
            }
            case eEventTypes_AirQuality:
            {
                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_AirQuality;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   self.isClearToSendAirQualityCloud == YES) {
                    self.isClearToSendAirQualityCloud = NO;
                    [self cloudThrottlingTimerAirQualityStop];
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                    [self cloudThrottlingTimerAirQualityStart];
                }

                break;
            }
            case eEventTypes_Magnetometer:
                break;
            case eEventTypes_Brightness:
            {
                // Construct CloudDataMsg
                CloudDataMsg *cloudDataMsg = [[CloudDataMsg alloc] init];
                cloudDataMsg.MsgType = eEventTypes_Brightness;
                cloudDataMsg.Data = evt.Data;

                // Construct API msg
                EdgeServiceApiMsg *msg = [[EdgeServiceApiMsg alloc] init];
                msg.UserId = [[SettingsVault sharedSettingsVault] getUSERID];
                msg.APPID = [[SettingsVault sharedSettingsVault] getAPPID];
                msg.EKID = dataMsg.EKID;
                msg.Timestamp = [self getUTCDate:[NSDate date]];
                msg.MgmtMsgs = nil;
                msg.Events = (NSMutableArray<CloudDataMsg> *)[NSMutableArray arrayWithObject:cloudDataMsg];

                // Publish cloud
                if([[SettingsVault sharedSettingsVault] getConfigCloudEnable] == YES &&
                   self.isClearToSendBrightnessCloud == YES) {
                    self.isClearToSendBrightnessCloud = NO;
                    [self cloudThrottlingTimerBrightnessStop];
                    [self.mqttClient publishMessage:[msg toJSONString] inTopic:@""];
                    [self cloudThrottlingTimerBrightnessStart];
                }

                break;
            }
            case eEventTypes_Accelerometer:
                break;
            case eEventTypes_Gas:
                break;
            case eEventTypes_Custom:
                break;
            default:
                break;
        }
    }
}

#pragma mark - Helpers

-(NSString *)getUTCDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

-(NSString *)getUTCDate2:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

#pragma mark - IFTTT related

-(void)sendIFTTT:(NSString *)sensorType withValue:(NSString *)value {
    NSDictionary const *sensorToIftttMakerUrl = @{@"T":@"https://maker.ifttt.com/trigger/temperature/with/key/",
                                            @"H":@"https://maker.ifttt.com/trigger/humidity/with/key/",
                                            @"P":@"https://maker.ifttt.com/trigger/pressure/with/key/",
                                            @"B":@"https://maker.ifttt.com/trigger/button/with/key/"};

    if ([[SettingsVault sharedSettingsVault] getConfigIftttApiKey] == nil) {
        NSLog(@"[IFTTT] Error: tried to send message without a valid IFTTT api key");
        return;
    }

    NSString *finalUrl = [sensorToIftttMakerUrl[sensorType] stringByAppendingString:[[SettingsVault sharedSettingsVault] getConfigIftttApiKey]];

    // Send IFTTT message
    IftttMsg *msg = [[IftttMsg alloc] init];
    msg.value1 = value;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[msg toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                    if (error != nil) {
                                                        NSLog(@"[[IFTTT] Error sending message: %@", error.description);
                                                    }
                                                    NSLog(@"[[IFTTT] ===> %@", [msg toJSONString]);
                                                }];

    [dataTask resume];
}

-(void)updateIftttClearToSendTemperatureFlag {
    self.isClearToSendTemperatureIfttt = YES;
}
-(void)updateIftttClearToSendHumidityFlag {
    self.isClearToSendHumidityIfttt = YES;
}
-(void)updateIftttClearToSendPressureFlag {
    self.isClearToSendPressureIfttt = YES;
}

-(void)updateCloudClearToSendTemperatureFlag {
    self.isClearToSendTemperatureCloud = YES;
}
-(void)updateCloudClearToSendHumidityFlag {
    self.isClearToSendHumidityCloud = YES;
}
-(void)updateCloudClearToSendPressureFlag {
    self.isClearToSendPressureCloud = YES;
}
-(void)updateCloudClearToSendAirQualityFlag {
    self.isClearToSendAirQualityCloud = YES;
}
-(void)updateCloudClearToSendBrightnessFlag {
    self.isClearToSendBrightnessCloud = YES;
}
@end
