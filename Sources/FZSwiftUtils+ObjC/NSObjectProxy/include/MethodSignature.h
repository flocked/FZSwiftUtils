//
//  MethodSignature.h
//
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface MethodSignature : NSObject

@property (readonly) NSArray<NSString *> *argumentTypes;
@property (readonly) NSString *returnType;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@interface NSObject (MethodSignature)
- (nullable MethodSignature *)getMethodSignatureForSelector:(SEL)aSelector;
@end

NS_ASSUME_NONNULL_END
