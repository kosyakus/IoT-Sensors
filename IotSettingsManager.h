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
#import <UIKit/UIKit.h>
@class IotSensorsDevice;
@class IotSettingsItem;

@interface IotSettingsManager : NSObject

@property IotSensorsDevice* device;
@property NSDictionary<NSString*, IotSettingsItem*>* spec;
@property NSMutableDictionary<NSIndexPath*, IotSettingsItem* >* specIndex;

- (id) initWithDevice:(IotSensorsDevice*)device;
- (void) initSpec:(NSArray*)items;

- (void) setSensorState:(BOOL)started;
- (void) readConfiguration;
- (BOOL) processConfigurationReport:(int)command data:(NSData*)data;
- (void) updateUI;
- (BOOL) updateValues;

@end


enum {
    IOT_SETTINGS_TYPE_SWITCH,
    IOT_SETTINGS_TYPE_LIST,
    IOT_SETTINGS_TYPE_NUMERIC,
    IOT_SETTINGS_TYPE_RANGE,
    IOT_SETTINGS_TYPE_ACTION,
};

@interface IotSettingsItem : NSObject

@property NSString* key;
@property int type;
@property BOOL hidden;
@property BOOL enabled;
@property BOOL readOnly;
@property NSArray* labels;
@property NSArray* values;
@property NSNumber* value;
@property int min;
@property int max;
@property UITableViewCell* cell;
@property NSIndexPath* indexPath;
@property NSObject* element;
@property NSString* title;
@property NSString* message;
@property NSString* text;
@property SEL action;

- (id) initSwitchWithKey:(NSString*)key value:(BOOL)value;
- (id) initListWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values value:(NSNumber*)value title:(NSString*)title;
- (id) initNumericWithKey:(NSString*)key min:(int)min max:(int)max value:(int)value title:(NSString*)title message:(NSString*)message;
- (id) initRangeWithKey:(NSString*)key min:(int)min max:(int)max minValue:(int)minValue maxValue:(int)maxValue;
- (id) initActionWithKey:(NSString*)key;

+ (id) switchWithKey:(NSString*)key value:(BOOL)value;
+ (id) switchWithKey:(NSString*)key;
+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values value:(NSNumber*)value title:(NSString*)title;
+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values value:(NSNumber*)value;
+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values title:(NSString*)title;
+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values;
+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max value:(int)value title:(NSString*)title message:(NSString*)message;
+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max title:(NSString*)title message:(NSString*)message;
+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max value:(int)value;
+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max;
+ (id) rangeWithKey:(NSString*)key min:(int)min max:(int)max minValue:(int)minValue maxValue:(int)maxValue;
+ (id) rangeWithKey:(NSString*)key min:(int)min max:(int)max;
+ (id) actionWithKey:(NSString*)key;

- (NSString*) labelForValue:(NSNumber*)value;
- (NSString*) label;

- (void) initUI;
- (void) updateUI;
- (void) updateState;
- (void) updateValue;

@end
