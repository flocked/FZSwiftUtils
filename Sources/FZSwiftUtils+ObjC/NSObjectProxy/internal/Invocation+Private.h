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
@end
