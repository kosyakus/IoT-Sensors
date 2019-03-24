/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "MqttClient.h"
#import "SettingsVault.h"
#import "CloudManager.h"

#define kMqttTopic_publish @"dialogek/gw/toservice/"    // Full topic: dialogek/gw/toservice/{APPID}
#define kMqttTopic_subscribe @"dialogek/fromservice/"   // Full topic: dialogek/fromservice/{USERID}/#

NSString *const NotificationConnectedToCloudService = @"NotificationConnectedToCloudService";

@interface MqttClient ()

@property (strong, nonatomic) MQTTSession *mqttClient;
@property (strong, nonatomic) NSString *subscribeTopic;
@property (strong, nonatomic) NSString *publishTopic;

@property (nonatomic) BOOL isDisconnected;

@end


@implementation MqttClient

-(instancetype)init {
    if (self = [super init]) {
        _mqttClient = [[MQTTSession alloc] init];
        _mqttClient.transport = [[MQTTCFSocketTransport alloc] init];
        _mqttClient.transport.host = @"cyan.yodiwo.com";
        _mqttClient.transport.port = 8883;
        _mqttClient.streamSSLLevel = (NSString *)kCFStreamSocketSecurityLevelTLSv1;
        _mqttClient.willQoS = MQTTQosLevelExactlyOnce;
        _mqttClient.clientId = [[SettingsVault sharedSettingsVault] getAPPID];
        _mqttClient.userName = @"DialogEdgeDevices";
        _mqttClient.password = @"Tamed.Piranha!";
    }

    return self;
}

// Start MQTT client
- (void)start
{
    NSString *baseSubscribeTopic = kMqttTopic_subscribe;
    NSString *basePublishTopic = kMqttTopic_publish;


    self.subscribeTopic = [[baseSubscribeTopic stringByAppendingString:[[SettingsVault sharedSettingsVault] getUSERID]]
                       stringByAppendingString:@"/#"];

    self.publishTopic = [basePublishTopic stringByAppendingString:[[SettingsVault sharedSettingsVault] getAPPID]];

    [self.mqttClient setDelegate:self];

    [self connect];
}

// Stop MQTT client
- (void)stop {
    [self disconnect];
}

// Disconnect client from MQTT broker
- (void)disconnect{
    [self.mqttClient close];
}

// Connect client to MQTT broker
- (void)connect {

    [self.mqttClient connectToHost:self.mqttClient.transport.host port:self.mqttClient.transport.port usingSSL:true connectHandler:^(NSError *error) {

        if (error == nil) {
            NSLog(@"MQTT client: connected with id: %@", self.mqttClient.clientId);
        }
        else {
            NSLog(@"MQTT client: error connecting to broker --> %@", [error localizedDescription]);
        }
    }];
}

// Subscribe client to topic
- (void)subscribe {

    [self.mqttClient subscribeToTopic:self.subscribeTopic
                              atLevel:MQTTQosLevelExactlyOnce
                     subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {

                         if (error != nil) {
                             NSLog(@"MQTT client: Error subscribing to topic: %@ --> %@", self.subscribeTopic, [error localizedDescription]);
                             return;
                         }

                         dispatch_async(dispatch_get_main_queue(), ^{
                             [[NSNotificationCenter defaultCenter]
                              postNotificationName:NotificationConnectedToCloudService
                              object:self
                              userInfo:nil];
                         });

                         NSLog(@"MQTT client: subscribed to topic: %@ (QoS ==> %@)", self.subscribeTopic, gQoss[0]);
    }];
}

// Publish message
- (void)publishMessage:(NSString *)msg inTopic:(NSString *)topic {

    [self.mqttClient publishData:[msg dataUsingEncoding:NSUTF8StringEncoding]
                         onTopic:[self.publishTopic stringByAppendingString:topic]
                          retain:NO
                             qos:MQTTQosLevelExactlyOnce
                  publishHandler:^(NSError *error) {

        if (error != nil) {
            NSLog(@"MQTT client: Error publishing message: %@ in topic:%@", msg, [self.publishTopic stringByAppendingString:topic]);
            return;
        }

        NSLog(@"===> MQTT client: Published message: %@ in topic:%@", msg, [self.publishTopic stringByAppendingString:topic]);
    }];
}

//***** Delegates

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {

    NSLog(@"<=== MQTT client: Topic: %@ Payload: %@", topic, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);

    // CloudManager consume the message
    [[CloudManager sharedCloudManager] handleMsg:data];
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {
    switch (eventCode) {
        case MQTTSessionEventConnected:
        {
            NSLog(@"MQTT client: Connection established");

            self.isDisconnected = NO;

            [self subscribe];

            break;
        }
        case MQTTSessionEventConnectionClosed:
        {

            NSLog(@"MQTT client: Connection closed");

            if (self.isDisconnected == NO) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"yodiwoDisconnectedFromCloudServiceNotification"
                     object:nil
                     userInfo:nil];
                });

                self.isDisconnected = YES;
            }

            [self connect];

            break;
        }
        case MQTTSessionEventConnectionClosedByBroker:
        {
            NSLog(@"MQTT client: Connection closed by broker");
            break;
        }
        case MQTTSessionEventConnectionError:
        {
            NSLog(@"MQTT client: Connection error");
            break;
        }
        case MQTTSessionEventConnectionRefused:
        {
            NSLog(@"MQTT client: Connection refused");
            break;
        }
        case MQTTSessionEventProtocolError:
        {
            NSLog(@"MQTT client: Protocol error");
            break;
        }
        default:
        {
            NSLog(@"MQTT client: Unknown event");
            break;
        }
    }
}


@end
