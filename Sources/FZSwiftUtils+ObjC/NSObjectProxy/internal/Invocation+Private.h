//
//  Invocation+Private.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "Invocation.h"

@interface Invocation ()
- (nonnull instancetype)initWithInvocation:(nonnull NSInvocation *)invocation;
- (nonnull instancetype)initWithMethodSignature:(nonnull NSMethodSignature *)methodSignature;
- (nullable instancetype)initWithTarget:(nonnull NSObject *)target selector:(nonnull SEL)selector;
- (nullable instancetype)initWithClass:(nonnull Class)target selector:(nonnull SEL)selector;
@end
