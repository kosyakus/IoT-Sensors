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

@interface SettingsVault : NSObject

+(id)sharedSettingsVault;

-(NSString *)getAPPID;

-(void)setUSERID:(NSString *)userId;
-(NSString *)getUSERID;

-(void)setConfigCloudEnable:(BOOL)status;
-(BOOL)getConfigCloudEnable;

-(void)setConfigCloudLink:(NSString *)userId;
-(NSString *)getConfigCloudLink;
-(BOOL)getConfigIsCloudLinkGenerated;

-(void)setConfigHistoricalEnable:(BOOL)status;
-(BOOL)getConfigHistoricalEnable;
-(void)setConfigAlertingEnable:(BOOL)status;
-(BOOL)getConfigAlertingEnable;
-(void)setConfigControlEnable:(BOOL)status;
-(BOOL)getConfigControlEnable;
- (void)setConfig3DGameEnable:(BOOL)status;
-(BOOL)getConfig3DGameEnable;
- (void)setConfigAssetTrackingEnable:(BOOL)status;
-(BOOL)getConfigAssetTrackingEnable;

-(void)setConfigCloudLinkTargetEmail:(NSString *)email;
-(NSString *)getConfigCloudLinkTargetEmail;

-(void)setConfigHasEnabledCloudAtLeastOnce:(BOOL)status;
-(BOOL)getConfigHasEnabledCloudAtLeastOnce;

-(void)setConfigIftttEnable:(BOOL)status;
-(BOOL)getConfigIftttEnable;
-(void)setConfigIftttApiKey:(NSString *)key;
-(NSString *)getConfigIftttApiKey;
-(void)setConfigIftttEventPeriod:(NSNumber *)period;
-(NSNumber *)getConfigIftttEventPeriod;

-(NSString *)getAmazonScopes;

@end
