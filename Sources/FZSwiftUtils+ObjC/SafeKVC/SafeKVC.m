//
//  SafeKVC.m
//  FZSwiftUtils
//
//  Created by Florian Zand on 05.04.25.
//

#import "include/SafeKVC.h"

@implementation NSObject (SafeKVC)

- (id)safeValueForKey:(NSString *)key {
    @try {
        return [self valueForKey:key];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)safeSetValue:(id)value forKey:(NSString *)key {
    @try {
        [self setValue:value forKey:key];
        return YES;
    }
    @catch (NSException *exception) {
        return NO;
    }
}

@end
