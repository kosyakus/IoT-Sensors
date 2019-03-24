/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "RingBuffer.h"

@implementation RingBuffer {
    NSMutableArray* buffer;
    NSUInteger start;
}

- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (!self)
        return nil;

    self.capacity = capacity;
    buffer = [NSMutableArray arrayWithCapacity:capacity];
    start = 0;
    return self;
}

- (NSUInteger) count {
    return buffer.count;
}

- (BOOL) isEmpty {
    return buffer.count == 0;
}

- (BOOL) rewind {
    return buffer.count == self.capacity;
}

- (void) add:(NSObject*)object {
    buffer[start++] = object;
    if (start == self.capacity)
        start = 0;
}

- (NSArray*) data {
    if (self.rewind) {
        NSMutableArray* out = [NSMutableArray arrayWithCapacity:buffer.count];
        [out replaceObjectsInRange:NSMakeRange(0, 0) withObjectsFromArray:buffer range:NSMakeRange(start, buffer.count - start)];
        [out replaceObjectsInRange:NSMakeRange(buffer.count - start, 0) withObjectsFromArray:buffer range:NSMakeRange(0, start)];
        return out;
    } else {
        return [NSArray arrayWithArray:buffer];
    }
}

@end


@implementation RingBuffer3D

- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (!self)
        return nil;

    self.capacity = capacity;
    self.X = [[RingBuffer alloc] initWithCapacity:capacity];
    self.Y = [[RingBuffer alloc] initWithCapacity:capacity];
    self.Z = [[RingBuffer alloc] initWithCapacity:capacity];
    return self;
}

- (NSUInteger) count {
    return self.X.count;
}

- (BOOL) isEmpty {
    return self.count == 0;
}

- (void) addX:(NSObject*)x Y:(NSObject*)y Z:(NSObject*)z {
    [self.X add:x];
    [self.Y add:y];
    [self.Z add:z];
}

- (NSArray*) data {
    return @[ self.X.data, self.Y.data, self.Z.data ];
}

@end
