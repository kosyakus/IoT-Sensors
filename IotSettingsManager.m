/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "IotSettingsManager.h"
#import "IotSensorsDevice.h"
#import "TTRangeSlider.h"

@implementation IotSettingsManager

- (id) initWithDevice:(IotSensorsDevice*)device {
    self = [super init];
    if (!self)
        return nil;

    self.device = device;
    return self;
}

- (void) initSpec:(NSArray*)items {
    NSMutableDictionary* spec = [NSMutableDictionary dictionaryWithCapacity:items.count];
    for (IotSettingsItem* item in items) {
        spec[item.key] = item;
    }
    self.spec = [NSDictionary dictionaryWithDictionary:spec];
    self.specIndex = [NSMutableDictionary dictionaryWithCapacity:items.count];
}

- (void) setSensorState:(BOOL)started {
    for (IotSettingsItem* item in self.spec.allValues) {
        item.enabled = !started;
    }
    [self updateUI];
}

- (void) readConfiguration {
}

- (BOOL) processConfigurationReport:(int)command data:(NSData*)data {
    return false;
}

- (void) updateUI {
    for (IotSettingsItem* i in self.spec.allValues) {
        [i updateUI];
    }
}

- (BOOL) updateValues {
    for (IotSettingsItem* i in self.spec.allValues) {
        [i updateValue];
    }
    return true;
}

@end


@implementation IotSettingsItem

- (id) initSwitchWithKey:(NSString*)key value:(BOOL)value {
    self = [super init];
    if (!self)
        return nil;

    self.type = IOT_SETTINGS_TYPE_SWITCH;
    self.key = key;
    self.value = @(value);
    return self;
}

- (id) initListWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values value:(NSNumber*)value title:(NSString*)title {
    self = [super init];
    if (!self)
        return nil;

    self.type = IOT_SETTINGS_TYPE_LIST;
    self.key = key;
    self.labels = labels;
    self.values = values;
    self.value = value;
    self.title = title;
    return self;
}

- (id) initNumericWithKey:(NSString*)key min:(int)min max:(int)max value:(int)value title:(NSString*)title message:(NSString*)message {
    self = [super init];
    if (!self)
        return nil;

    self.type = IOT_SETTINGS_TYPE_NUMERIC;
    self.key = key;
    self.min = min;
    self.max = max;
    self.value = @(value);
    self.title = title;
    self.message = message;
    return self;
}

- (id) initRangeWithKey:(NSString*)key min:(int)min max:(int)max minValue:(int)minValue maxValue:(int)maxValue {
    self = [super init];
    if (!self)
        return nil;

    self.type = IOT_SETTINGS_TYPE_RANGE;
    self.key = key;
    self.min = min;
    self.max = max;
    self.values = @[ @(minValue), @(maxValue) ];
    return self;
}

- (id) initActionWithKey:(NSString*)key {
    self = [super init];
    if (!self)
        return nil;

    self.type = IOT_SETTINGS_TYPE_ACTION;
    self.key = key;
    return self;
}


+ (id) switchWithKey:(NSString*)key value:(BOOL)value {
    return [[IotSettingsItem alloc] initSwitchWithKey:key value:value];
}

+ (id) switchWithKey:(NSString*)key {
    return [[IotSettingsItem alloc] initSwitchWithKey:key value:false];
}

+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values value:(NSNumber*)value title:(NSString*)title {
    return [[IotSettingsItem alloc] initListWithKey:key labels:labels values:values value:value title:title];
}

+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values value:(NSNumber*)value {
    return [[IotSettingsItem alloc] initListWithKey:key labels:labels values:values value:value title:@"Select a value"];
}

+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values title:(NSString*)title {
    return [[IotSettingsItem alloc] initListWithKey:key labels:labels values:values value:values[0] title:title];
}

+ (id) listWithKey:(NSString*)key labels:(NSArray*)labels values:(NSArray*)values {
    return [[IotSettingsItem alloc] initListWithKey:key labels:labels values:values value:values[0] title:@"Select a value"];
}

+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max value:(int)value title:(NSString*)title message:(NSString*)message {
    return [[IotSettingsItem alloc] initNumericWithKey:key min:min max:max value:value title:title message:message];
}

+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max title:(NSString*)title message:(NSString*)message {
    return [[IotSettingsItem alloc] initNumericWithKey:key min:min max:max value:0 title:title message:message];
}

+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max value:(int)value {
    return [[IotSettingsItem alloc] initNumericWithKey:key min:min max:max value:value title:@"Enter a value" message:nil];
}

+ (id) numericWithKey:(NSString*)key min:(int)min max:(int)max {
    return [[IotSettingsItem alloc] initNumericWithKey:key min:min max:max value:0 title:@"Enter a value" message:nil];
}

+ (id) rangeWithKey:(NSString*)key min:(int)min max:(int)max minValue:(int)minValue maxValue:(int)maxValue {
    return [[IotSettingsItem alloc] initRangeWithKey:key min:min max:max minValue:minValue maxValue:maxValue];
}

+ (id) rangeWithKey:(NSString*)key min:(int)min max:(int)max {
    return [[IotSettingsItem alloc] initRangeWithKey:key min:min max:max minValue:min maxValue:max];
}

+ (id) actionWithKey:(NSString*)key {
    return [[IotSettingsItem alloc] initActionWithKey:key];
}


- (NSString*) labelForValue:(NSNumber*)value {
    NSUInteger index = [self.values indexOfObject:value];
    return index != NSNotFound ? self.labels[index] : nil;
}

- (NSString*) label {
    return [self labelForValue:self.value];
}

- (void) initUI {
    if (self.type == IOT_SETTINGS_TYPE_RANGE && self.element) {
        TTRangeSlider* slider = (TTRangeSlider*) self.element;
        slider.minValue = self.min;
        slider.maxValue = self.max;
    }
    [self updateUI];
}

- (void) updateUI {
    if (!self.cell && !self.element)
        return;
    switch (self.type) {
        case IOT_SETTINGS_TYPE_SWITCH:
            [(UISwitch*)self.element setOn:self.value.boolValue animated:YES];
            break;
        case IOT_SETTINGS_TYPE_LIST:
            self.cell.detailTextLabel.text = self.text ? self.text : self.label;
            break;
        case IOT_SETTINGS_TYPE_NUMERIC:
            self.cell.detailTextLabel.text = self.text ? self.text : [NSString stringWithFormat:@"%d", self.value.intValue];
            break;
        case IOT_SETTINGS_TYPE_RANGE: {
            TTRangeSlider* slider = (TTRangeSlider*) self.element;
            slider.selectedMinimum = MAX([self.values[0] intValue], self.min);
            slider.selectedMaximum = MAX(MIN([self.values[1] intValue], self.max), slider.selectedMinimum);
            break;
        }
    }
}

- (void) updateState {
    if (!self.cell)
        return;
    self.cell.alpha = self.enabled ? 1.f : 0.45f;
    self.cell.userInteractionEnabled = self.enabled;
}

- (void) updateValue {
    switch (self.type) {
        case IOT_SETTINGS_TYPE_SWITCH:
            if (self.element)
                self.value = @([(UISwitch*)self.element isOn]);
            break;
        case IOT_SETTINGS_TYPE_RANGE: {
            if (self.element) {
                TTRangeSlider* slider = (TTRangeSlider*) self.element;
                self.values = @[ @(slider.selectedMinimum), @(slider.selectedMaximum) ];
            }
            break;
        }
    }
}

@end
