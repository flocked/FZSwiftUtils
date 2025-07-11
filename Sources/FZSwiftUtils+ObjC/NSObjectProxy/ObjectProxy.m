//
//  ObjectProxy.m
//
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "internal/ObjectProxy.h"
#import "internal/Invocation+Private.h"

@implementation ObjectProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation setTarget:_target];
    if (self.invocationHandler) {
        Invocation *proxyInvocation = [[Invocation alloc] initWithInvocation:invocation];
        self.invocationHandler(proxyInvocation);
    } else {
        [invocation invoke];
    }
}

@end
