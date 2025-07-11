//
//  ObjectProxy.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "Invocation.h"

@interface ObjectProxy : NSProxy

@property (nonatomic, strong) id _Nonnull target;
@property (nonatomic, copy, nullable) void (^invocationHandler)(Invocation * _Nullable invocation);

- (nonnull instancetype)initWithTarget:( nonnull id)target;

@end
