//
//  Invocation.m
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import "include/Invocation.h"
#import "internal/Invocation+Private.h"
#import "internal/MethodSignature+Private.h"

NS_INLINE const char *SkipTypeQualifiers(const char *type) {
    while (*type == 'r' || *type == 'n' || *type == 'N' ||
           *type == 'o' || *type == 'O' || *type == 'R' || *type == 'V') {
        type++;
    }
    return type;
}

@interface Invocation ()

@property (nonatomic, readwrite) BOOL isVoidReturnType;

@end

@implementation Invocation {
    NSInvocation *_invocation;
    NSArray *_cachedArguments;
    id _cachedReturnValue;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super init];
    if (self) {
        _invocation = invocation;
        _isVoidReturnType = NO;
    }
    return self;
}

- (instancetype)initWithMethodSignature:(NSMethodSignature *)methodSignature {
    self = [super init];
    if (self) {
        _invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        _isVoidReturnType = NO;
    }
    return self;
}

- (instancetype)initWithSignature:(MethodSignature *)methodSignature {
    self = [super init];
    if (self) {
        _invocation = [NSInvocation invocationWithMethodSignature:[methodSignature methodSignature]];
        _isVoidReturnType = NO;
    }
    return self;
}

- (SEL)selector { return _invocation.selector; }
- (void)setSelector:(SEL)selector { _invocation.selector = selector; }

- (id)target { return _invocation.target; }
- (void)setTarget:(id)target { _invocation.target = target; }

- (NSArray *)_arguments {
    if (_cachedArguments) return _cachedArguments;

    NSMutableArray *args = [NSMutableArray array];
    NSMethodSignature *sig = _invocation.methodSignature;

    for (NSUInteger i = 2; i < sig.numberOfArguments; i++) {
        const char *rawType = [sig getArgumentTypeAtIndex:i];
        const char *argType = SkipTypeQualifiers(rawType);
        id value = [self getArgumentAtIndex:i type:argType];
        [args addObject:value ?: NSNull.null];
    }

    _cachedArguments = [args copy];
    return _cachedArguments;
}

- (void)set_arguments:(NSArray *)arguments {
    NSMethodSignature *sig = _invocation.methodSignature;
    NSAssert(arguments.count == sig.numberOfArguments - 2, @"Argument count mismatch");

    for (NSUInteger i = 2; i < sig.numberOfArguments; i++) {
        const char *rawType = [sig getArgumentTypeAtIndex:i];
        const char *argType = SkipTypeQualifiers(rawType);
        id value = arguments[i - 2];
        [self setArgument:value atIndex:i type:argType];
    }
    _cachedArguments = [arguments copy];
}

- (id)_returnValue {
    if (_cachedReturnValue) {
        if (_cachedReturnValue == NSNull.null) {
            return nil;
        }
        return _cachedReturnValue;
    }
    
    const char *rawType = _invocation.methodSignature.methodReturnType;
    const char *type = SkipTypeQualifiers(rawType);
    if (strcmp(type, @encode(void)) == 0) {
        _isVoidReturnType = true;
        _cachedReturnValue = NSNull.null;
    } else {
        _cachedReturnValue = [self getArgumentAtIndex:-1 type:type] ?: NSNull.null;
    }
    if (_cachedReturnValue == NSNull.null) {
        return nil;
    }
    return _cachedReturnValue;
}

- (void)set_returnValue:(id)returnValue {
    const char *rawType = _invocation.methodSignature.methodReturnType;
    const char *type = SkipTypeQualifiers(rawType);
    [self setArgument:returnValue atIndex:-1 type:type];
    _cachedReturnValue = returnValue;
}

- (void)invoke {
    [_invocation invoke];
    _cachedReturnValue = nil;
}

- (void) invokeWithTarget:(id)target {
    [_invocation invokeWithTarget: target];
    _cachedReturnValue = nil;
}

- (id)getArgumentAtIndex:(NSUInteger)index type:(const char *)argType {
    #define GET_ARG(type, selector) do { \
        type val = 0; \
        if (index == -1) { \
            [_invocation getReturnValue:&val]; \
        } else { \
            [_invocation getArgument:&val atIndex:index]; \
        } \
        return @(val); \
    } while(0)

    if (strcmp(argType, "@") == 0) {
        __unsafe_unretained id val = nil;
        if (index == -1) {
            [_invocation getReturnValue:&val];
        } else {
            [_invocation getArgument:&val atIndex:index];
        }
        return val;
    } else if (strcmp(argType, "#") == 0) {
        Class cls = nil;
        if (index == -1) {
            [_invocation getReturnValue:&cls];
        } else {
            [_invocation getArgument:&cls atIndex:index];
        }
        return cls;
    } else if (strcmp(argType, ":") == 0) {
        SEL sel = NULL;
        if (index == -1) {
            [_invocation getReturnValue:&sel];
        } else {
            [_invocation getArgument:&sel atIndex:index];
        }
        return sel ? NSStringFromSelector(sel) : nil;
    } else if (argType[0] == '^') {
        void *ptr = NULL;
        if (index == -1) {
            [_invocation getReturnValue:&ptr];
        } else {
            [_invocation getArgument:&ptr atIndex:index];
        }
        return ptr ? [NSValue valueWithPointer:ptr] : nil;
    } else if (argType[0] == '{' || argType[0] == '(') {
        NSUInteger size;
        NSGetSizeAndAlignment(argType, &size, NULL);
        void *buffer = malloc(size);
        if (index == -1) {
            [_invocation getReturnValue:buffer];
        } else {
            [_invocation getArgument:buffer atIndex:index];
        }
        id val = [NSValue valueWithBytes:buffer objCType:argType];
        free(buffer);
        return val;
    } else if (strcmp(argType, "?") == 0 || strcmp(argType, "@?") == 0) {
        void *block = NULL;
        if (index == -1) {
            [_invocation getReturnValue:&block];
        } else {
            [_invocation getArgument:&block atIndex:index];
        }
        return block ? [NSValue valueWithPointer:block] : nil;
    } else if (strcmp(argType, "*") == 0) {
        const char *cstr = NULL;
        if (index == -1) {
            [_invocation getReturnValue:&cstr];
        } else {
            [_invocation getArgument:&cstr atIndex:index];
        }
        return cstr ? [NSString stringWithUTF8String:cstr] : nil;
    } else if (strcmp(argType, "c") == 0) GET_ARG(char, charValue);
    else if (strcmp(argType, "i") == 0) GET_ARG(int, intValue);
    else if (strcmp(argType, "s") == 0) GET_ARG(short, shortValue);
    else if (strcmp(argType, "l") == 0) GET_ARG(long, longValue);
    else if (strcmp(argType, "q") == 0) GET_ARG(long long, longLongValue);
    else if (strcmp(argType, "C") == 0) GET_ARG(unsigned char, unsignedCharValue);
    else if (strcmp(argType, "I") == 0) GET_ARG(unsigned int, unsignedIntValue);
    else if (strcmp(argType, "S") == 0) GET_ARG(unsigned short, unsignedShortValue);
    else if (strcmp(argType, "L") == 0) GET_ARG(unsigned long, unsignedLongValue);
    else if (strcmp(argType, "Q") == 0) GET_ARG(unsigned long long, unsignedLongLongValue);
    else if (strcmp(argType, "f") == 0) GET_ARG(float, floatValue);
    else if (strcmp(argType, "d") == 0) GET_ARG(double, doubleValue);
    else if (strcmp(argType, "B") == 0) GET_ARG(bool, boolValue);
    return nil;
    #undef GET_ARG
}

- (void)setArgument:(id)arg atIndex:(NSUInteger)index type:(const char *)argType {
    #define SET_ARG(type, sel, method) do { \
        type val = 0; \
        if ([arg respondsToSelector:sel]) val = [arg method]; \
        if (index == -1) { \
            [_invocation setReturnValue:&val]; \
        } else { \
            [_invocation setArgument:&val atIndex:index]; \
        } \
        return; \
    } while(0)
    
    if (strcmp(argType, "@") == 0) {
        id obj = (arg == NSNull.null) ? nil : arg;
        if (index == -1) {
            [_invocation setReturnValue:&obj];
        } else {
            [_invocation setArgument:&obj atIndex:index];
        }
    } else if (strcmp(argType, "#") == 0) {
        Class cls = (arg == NSNull.null) ? Nil : arg;
        if (index == -1) {
            [_invocation setReturnValue:&cls];
        } else {
            [_invocation setArgument:&cls atIndex:index];
        }
    } else if (strcmp(argType, ":") == 0) {
        SEL sel = NULL;
        if ([arg isKindOfClass:[NSString class]]) sel = NSSelectorFromString(arg);
        if (index == -1) {
            [_invocation setReturnValue:&sel];
        } else {
            [_invocation setArgument:&sel atIndex:index];
        }
    } else if (argType[0] == '^') {
        void *ptr = NULL;
        if ([arg isKindOfClass:[NSValue class]]) ptr = [arg pointerValue];
        if (index == -1) {
            [_invocation setReturnValue:&ptr];
        } else {
            [_invocation setArgument:&ptr atIndex:index];
        }
    } else if (argType[0] == '{' || argType[0] == '(') {
        NSUInteger size;
        NSGetSizeAndAlignment(argType, &size, NULL);
        void *buffer = malloc(size);
        if ([arg isKindOfClass:[NSValue class]] && strcmp([arg objCType], argType) == 0) {
            [arg getValue:buffer];
        } else {
            memset(buffer, 0, size);
        }
        if (index == -1) {
            [_invocation setReturnValue:buffer];
        } else {
            [_invocation setArgument:buffer atIndex:index];
        }
        free(buffer);
    } else if (strcmp(argType, "?") == 0 || strcmp(argType, "@?") == 0) {
        void *block = NULL;
        if ([arg isKindOfClass:[NSValue class]]) {
            block = [arg pointerValue];
        }
        if (index == -1) {
            [_invocation setReturnValue:&block];
        } else {
            [_invocation setArgument:&block atIndex:index];
        }
    } else if (strcmp(argType, "*") == 0) {
        const char *cstr = NULL;
        if ([arg isKindOfClass:[NSString class]]) {
            cstr = [(NSString *)arg UTF8String];
        } else if ([arg isKindOfClass:[NSValue class]]) {
            cstr = [arg pointerValue];
        }
        if (index == -1) {
            [_invocation setReturnValue:&cstr];
        } else {
            [_invocation setArgument:&cstr atIndex:index];
        }
    } else if (strcmp(argType, "c") == 0) SET_ARG(char, @selector(charValue), charValue);
    else if (strcmp(argType, "i") == 0) SET_ARG(int, @selector(intValue), intValue);
    else if (strcmp(argType, "s") == 0) SET_ARG(short, @selector(shortValue), shortValue);
    else if (strcmp(argType, "l") == 0) SET_ARG(long, @selector(longValue), longValue);
    else if (strcmp(argType, "q") == 0) SET_ARG(long long, @selector(longLongValue), longLongValue);
    else if (strcmp(argType, "C") == 0) SET_ARG(unsigned char, @selector(unsignedCharValue), unsignedCharValue);
    else if (strcmp(argType, "I") == 0) SET_ARG(unsigned int, @selector(unsignedIntValue), unsignedIntValue);
    else if (strcmp(argType, "S") == 0) SET_ARG(unsigned short, @selector(unsignedShortValue), unsignedShortValue);
    else if (strcmp(argType, "L") == 0) SET_ARG(unsigned long, @selector(unsignedLongValue), unsignedLongValue);
    else if (strcmp(argType, "Q") == 0) SET_ARG(unsigned long long, @selector(unsignedLongLongValue), unsignedLongLongValue);
    else if (strcmp(argType, "f") == 0) SET_ARG(float, @selector(floatValue), floatValue);
    else if (strcmp(argType, "d") == 0) SET_ARG(double, @selector(doubleValue), doubleValue);
    else if (strcmp(argType, "B") == 0) SET_ARG(bool, @selector(boolValue), boolValue);
    #undef SET_ARG
}

@end
