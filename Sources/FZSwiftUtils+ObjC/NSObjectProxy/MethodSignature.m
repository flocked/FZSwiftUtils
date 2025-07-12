//
//  MethodSignature.m
//
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "include/MethodSignature.h"
#import "internal/MethodSignature+Private.h"

@implementation MethodSignature

- (instancetype)initWithMethodSignature:(NSMethodSignature *)methodSignature
{
    self = [super init];
    if (self) {
        self.methodSignature = methodSignature;
    }
    return self;
}

- (NSArray<NSString *> *)argumentTypes
{
    NSUInteger numberOfArguments = self.methodSignature.numberOfArguments;
    NSMutableArray *argumentTypes = [[NSMutableArray alloc] initWithCapacity:numberOfArguments];
    for (int i = 0; i < numberOfArguments; i++) {
        NSString *argumentType = [[NSString alloc] initWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:i]];
        [argumentTypes addObject: [self ignoreUnusedChar:argumentType]];
    }
    return [argumentTypes copy];
}

- (NSString *)returnType
{
    return [self ignoreUnusedChar:[[NSString alloc] initWithUTF8String:self.methodSignature.methodReturnType]];
}

static NSRegularExpression *regex;
// We need to remove the unused char like from "@?<@"NSNumber"@?@:q>" to "@?<@@?@:q>". Because we can get "NSNumber" from block. But can't get this from method. When do the metching. "NSNumber" is not helpful.
- (NSString *)ignoreUnusedChar:(NSString *)type
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\\".+?\\\"" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    NSMutableString *result = [[NSMutableString alloc] initWithString:type];
    [regex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    return [result copy];
}

@end

@implementation NSObject (MethodSignature)
- (MethodSignature *)getMethodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    if (!signature) {
        return;
    }
    return [[MethodSignature alloc] initWithMethodSignature:signature];
}
@end
