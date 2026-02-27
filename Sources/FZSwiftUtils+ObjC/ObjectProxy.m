//
//  ObjectProxy.m
//
//
//  Created by Florian Zand on 26.01.25.
//

#import "include/ObjectProxy.h"
#import "include/Invocation+Private.h"
#import "include/MethodSignature+Private.h"

@implementation ObjectProxy

- (instancetype)initWithTargetObject:(NSObject *)targetObject {
    __target = targetObject;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    MethodSignature *signature = [self _getMethodSignatureForSelector:sel];
    if (signature != nil) {
        return [signature methodSignature];
    }
    return nil;
}

- (MethodSignature *)_getMethodSignatureForSelector:(SEL)sel {
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
