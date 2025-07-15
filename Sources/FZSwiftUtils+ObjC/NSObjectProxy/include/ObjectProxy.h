//
//  ObjectProxy.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "Invocation.h"
#import "MethodSignature.h"

@interface ObjectProxy : NSProxy

@property (nonatomic, strong, nonnull) NSObject *_target;

- (nonnull instancetype)initWithTargetObject:(nonnull NSObject *)targetObject;
- (void)forwardingInvocation:(Invocation *_Nonnull)invocation;
- (MethodSignature *_Nullable)getMethodSignatureForSelector:(SEL _Nonnull )sel;

@end

@interface NSObject (ProxyMapping)
- (nonnull instancetype)_mapToProxy:(ObjectProxy *_Nonnull)proxy;
@end
