//
//  SafeKVC.h
//  FZSwiftUtils
//
//  Created by Florian Zand on 05.04.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SafeKVC)
- (nullable id)safeValueForKey:(NSString *)key;
- (BOOL)safeSetValue:(nullable id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
