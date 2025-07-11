//
//  NSObject+Proxy.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "Invocation.h"

@interface NSObject (Proxy)

- (nonnull instancetype)_objectProxy;
- (nonnull instancetype)_objectProxyWithInvocationHandler:(void (^_Nonnull)(Invocation * _Nonnull invocation))invocationHandler;
- (nullable id)_performSelectorAndReturn:(SEL _Nonnull)selector withArguments:(NSArray * _Nonnull)arguments;
- (void)_performingSelector:(SEL _Nonnull)selector withArguments:(NSArray * _Nonnull)arguments;
@end
