//
//  Cast.swift
//
//
//  Created by Florian Zand on 12.08.25.
//

import Foundation

/**
 Returns the bits of the given instance, interpreted as having the specified type.

 Use this function only to convert the instance passed as `x` to a layout-compatible type when conversion through other means is not possible. Common conversions supported by the Swift standard library include the following:
 
    - Value conversion from one integer type to another. Use the destination type’s initializer or the [numericCast(_:)](https://developer.apple.com/documentation/swift/numericcast(_:)) function.
    - Bitwise conversion from one integer type to another. Use the destination type’s [init(truncatingIfNeeded:)](https://developer.apple.com/documentation/swift/int/init(truncatingifneeded:)) or [init(bitPattern:)](https://developer.apple.com/documentation/swift/int/init(bitpattern:)-72037) initializer.
    - Conversion from a pointer to an integer value with the bit pattern of the pointer’s address in memory, or vice versa. Use the [init(bitPattern:)](https://developer.apple.com/documentation/swift/int/init(bitpattern:)-72037) initializer for the destination type.
    - Casting an instance of a reference type. Use the casting operators (`as`, `as!`, or `as?`) or the ``unsafeDowncast(_:)`` function. Do not use ``unsafeBitCast(_:)`` with class or pointer types; doing so may introduce undefined behavior.
 
 Warning: Calling this function breaks the guarantees of the Swift type system; use with extreme care.
 
 Warning: Casting from an integer or a pointer type to a reference type is undefined behavior. It may result in incorrect code in any future compiler release. To convert a bit pattern to a reference type:
    1. convert the bit pattern to an [UnsafeRawPointer](https://developer.apple.com/documentation/swift/unsaferawpointer).
    2. create an unmanaged reference using [Unmanaged.fromOpaque()](https://developer.apple.com/documentation/swift/unmanaged/fromopaque(_:))
    3. obtain a managed reference using [Unmanaged.takeUnretainedValue()](https://developer.apple.com/documentation/swift/unmanaged/takeunretainedvalue()) The programmer must ensure that the resulting reference has already been manually retained.
 
 - Parameter x: The instance to cast to `U`.
 - Returns: A new instance of type `U`, cast from `x`.
 */
public func unsafeBitCast<T, U>(_ x: T) -> U {
    unsafeBitCast(x, to: U.self)
}

/**
 Returns the given instance cast unconditionally to the specified type.
 
 The instance passed as `x` must be an instance of type `T`.
 
 Use this function instead of ``unsafeBitCast(_:)`` because this function is more restrictive and still performs a check in debug builds. In -O builds, no test is performed to ensure that x actually has the dynamic type `T`.
 
 - Parameter x: An instance to cast to type `T`.
 - Returns: The instance `x`, cast to type `T`.
 - Warning: This function trades safety for performance. Use ``unsafeDowncast(_:)`` only when you are confident that `x` is `T` always evaluates to `true`, and only after `x as! T` has proven to be a performance problem.
 */
public func unsafeDowncast<T>(_ x: AnyObject) -> T where T : AnyObject {
    unsafeDowncast(x, to: T.self)
}

public func cast<X, T>(_ x: X) -> T {
    x as! T
}

/**
 Returns the Swift runtime type of an object that may be bridged to Objective-C.

 Unlike `type(of:)`, this function attempts to recover the original Swift type for values that are bridged into Objective-C and appear as `__SwiftValue` at runtime.

 This is primarily useful when working with `AnyObject` values originating from Swift types (such as value types) that have been bridged through Objective-C APIs.

 - Parameter value: An object that may represent a bridged Swift value.
 - Returns: The Swift runtime type of the value if it can be determined; otherwise, the dynamic Objective-C type of the object.
 
 - Note: This function only recovers the Swift type for values boxed as `__SwiftValue`. Foundation-bridged types (such as `String` → `NSString`) are already converted to Objective-C objects and cannot be unbridged.
 */
public func unbridgedType(of value: Any) -> Any.Type {
    var type: Any.Type = type(of: value)
    if type == NSClassFromString("__SwiftValue"), let value = value as? NSObject {
        let selector: Selector = NSSelectorFromString("_swiftTypeMetadata")
        let methodIMP: IMP! = value.method(for: selector)
        let metadataPtr = unsafeBitCast(methodIMP, to:(@convention(c)(Any?,Selector)->OpaquePointer).self)(value,selector)
        withUnsafeMutablePointer(to: &type) {
            let unsafePtr = UnsafeMutablePointer<OpaquePointer>.allocate(capacity: 1)
            unsafePtr.pointee = metadataPtr
            $0.update(from: UnsafePointer<Any.Type>(OpaquePointer(unsafePtr)), count: 1)
        }
    }
    return type
}
