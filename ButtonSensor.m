/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ButtonSensor.h"

static NSString* const LOG_TAG = @"BTN";

@implementation ButtonSensor

- (BOOL) isPressed:(int)ID {
    return self.state;
}

- (BOOL) isPressed {
    return self.state;
}

+ (NSString*) LOG_TAG {
    return LOG_TAG;
}

- (NSString*) logTag {
    return ButtonSensor.LOG_TAG;
}

- (NSString*) logEntry {
    return [NSString stringWithFormat:@"%02X %@", self.ID, self.isPressed ? @"pressed" : @"released"];
}

- (NSString*) cloudData {
    return self.isPressed ? @"true" : @"false";
}

@end
