//
//  NSObject+Proxy.m
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "include/NSObject+Proxy.h"
#import "internal/Invocation+Private.h"
#import "internal/ObjectProxy.h"

@implementation NSObject (Proxy)

- (nonnull instancetype)_objectProxy {
    return (id)[[ObjectProxy alloc] initWithTarget:self];
}

- (nonnull instancetype)_objectProxyWithInvocationHandler:(void (^_Nonnull)(Invocation * _Nullable invocation))invocationHandler {
    ObjectProxy *proxy = [[ObjectProxy alloc] initWithTarget:self];
    proxy.invocationHandler = invocationHandler;
    return (id)proxy;
}

- (nullable id)_performSelectorAndReturn:(SEL _Nonnull)selector withArguments:(NSArray * _Nonnull)arguments {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (!signature) {
        NSLog(@"Selector %@ not found on %@", NSStringFromSelector(selector), self);
        return nil;
    }
    Invocation *invocation = [[Invocation alloc] initWithMethodSignature:signature];
    [invocation setTarget: self];
    [invocation setSelector: selector];
    [invocation setArguments:arguments];
    [invocation invoke];
    return [invocation returnValue];
}

- (void)_performingSelector:(SEL _Nonnull)selector withArguments:(NSArray * _Nonnull)arguments {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (!signature) {
        NSLog(@"Selector %@ not found on %@", NSStringFromSelector(selector), self);
        return;
    }
    Invocation *invocation = [[Invocation alloc] initWithMethodSignature:signature];
    [invocation setTarget: self];
    [invocation setSelector: selector];
    [invocation setArguments:arguments];
    [invocation invoke];
}

@end
