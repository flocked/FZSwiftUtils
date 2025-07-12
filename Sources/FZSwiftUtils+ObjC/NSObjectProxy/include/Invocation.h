//
//  Invocation.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "MethodSignature.h"

/**
 An Objective-C message rendered as an object.
 
 `Inovation` objects contains all elements of an Objective-C message: a target, a selector, arguments, and the return value. Each of these elements can be set directly, and the return value is set automatically when the invocation is dispatched.
 
 They are used to store and forward messages between objects and between applications, primarily by `Timer` objects and the distributed objects system.
 
 An invocation can be repeatedly dispatched to different targets; its arguments can be modified between dispatch for varying results; even its `selector` can be changed to another with the same method signature (argument and return types).
 
 `Inovation` does not support invocations of methods with either variable numbers of arguments or union arguments.
 */
@interface Invocation : NSObject

/// The target of the invocation.
@property (nonatomic, strong) id _Nullable target;
/// The selector of the invocation.
@property (nonatomic) SEL _Nonnull selector;
/// The arguments of the invocation.
@property (nonatomic, strong) NSArray * _Nonnull _arguments;
/// The return value of the invocation.
@property (nonatomic, strong) id _Nullable _returnValue;
/// A Boolean value indicating whether the return value returns void.
@property (nonatomic, readonly) BOOL isVoidReturnType;

- (nonnull instancetype)initWithSignature:(nonnull MethodSignature *)methodSignature;

/// Sends the invocation’s message (with arguments) to its target and sets the return value.
- (void)invoke;
/// Sets the receiver’s target, sends the receiver’s message (with arguments) to that target, and sets the return value.
- (void) invokeWithTarget:(id _Nonnull) target;

@end
