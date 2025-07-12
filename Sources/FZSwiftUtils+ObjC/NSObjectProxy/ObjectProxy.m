//
//  ObjectProxy.m
//
//
//  Created by Florian Zand on 26.01.25.
//

#import "include/ObjectProxy.h"
#import "internal/Invocation+Private.h"
#import "internal/MethodSignature+Private.h"

@implementation ObjectProxy

- (instancetype)initWithTarget:(NSObject *)target {
    __target = target;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    MethodSignature *signature = [self getMethodSignatureForSelector:sel];
    if (signature != nil) {
        return [signature methodSignature];
    }
    return nil;
}

- (MethodSignature *)getMethodSignatureForSelector:(SEL)sel {
    NSMethodSignature *methodSignature = [__target methodSignatureForSelector:sel];
    if (methodSignature != nil) {
        return [[MethodSignature alloc] initWithMethodSignature:methodSignature];;
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self forwardingInvocation:[[Invocation alloc] initWithInvocation:invocation]];
}

- (void)forwardingInvocation:(Invocation *)invocation {
    [invocation setTarget:__target];
    [invocation invoke];
}

@end

@implementation NSObject (ProxyMapping)

- (instancetype)_mapToProxy:(ObjectProxy *)proxy {
    return (id)proxy;
}

@end
