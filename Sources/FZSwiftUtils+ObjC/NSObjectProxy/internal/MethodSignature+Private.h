//
//  Invocation+Private.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "MethodSignature.h"

@interface MethodSignature ()
@property (nonatomic, strong) NSMethodSignature *methodSignature;
- (instancetype)initWithMethodSignature:(NSMethodSignature *)methodSignature;
@end
