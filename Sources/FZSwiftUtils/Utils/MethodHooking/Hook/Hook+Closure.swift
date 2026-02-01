//
//  Hook+Closure.swift
//
//
//  Created by Florian Zand on 12.08.25.
//

#if os(macOS) || os(iOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import CoreMedia

extension Hook {
    // MARK: - hook before set property, unique values
    
    static func beforeClosure<Object, Value: Equatable>(for closure: @escaping (_ object: Object,_ oldValue: Value, _ newValue: Value)->(), _ uniqueValues: Bool, _ keyPath: WritableKeyPath<Object, Value>) -> Any {
        self.closure { (object: Object, value: Value) in
            let oldValue = object[keyPath: keyPath]
            guard !uniqueValues || value != oldValue else { return }
            closure(object, oldValue, value)
        }
    }
    
    static func beforeClosure<Object, Value: Equatable>(for closure: @escaping (_ object: Object,_ oldValue: Value, _ newValue: Value)->(), _ uniqueValues: Bool, _ keyPath: WritableKeyPath<Object, Value>) -> Any where Value: RawRepresentable {
        self.closure { (object: Object, value: Value) in
            let oldValue = object[keyPath: keyPath]
            guard !uniqueValues || value != oldValue else { return }
            closure(object, oldValue, value)
        }
    }
    
    // MARK: - hook after set property, unique values

    static func afterClosure<Object, Value: Equatable>(for closure: @escaping (_ object: Object,_ oldValue: Value, _ newValue: Value)->(), _ uniqueValues: Bool, _ keyPath: WritableKeyPath<Object, Value>) -> Any {
        self.setterClosure { (object: Object, value: Value, apply: (Value)->()) in
            let oldValue = object[keyPath: keyPath]
            apply(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
    }
    
    static func afterClosure<Object, Value: Equatable>(for closure: @escaping (_ object: Object,_ oldValue: Value, _ newValue: Value)->(), _ uniqueValues: Bool, _ keyPath: WritableKeyPath<Object, Value>) -> Any where Value: RawRepresentable {
        self.setterClosure { (object: Object, value: Value, apply: (Value)->()) in
            let oldValue = object[keyPath: keyPath]
            apply(value)
            guard !uniqueValues || oldValue != value else { return }
            closure(object, oldValue, value)
        }
    }
    
    // MARK: - hook after set property
    
    static func afterClosure<Object, Value>(for closure: @escaping (_ object: Object,_ oldValue: Value, _ newValue: Value)->(), keyPath: WritableKeyPath<Object, Value>) -> Any {
        self.setterClosure { (object: Object, value: Value, apply: (Value)->()) in
            let oldValue = object[keyPath: keyPath]
            apply(value)
            closure(object, oldValue, value)
        }
    }
    
    static func afterClosure<Object, Value>(for closure: @escaping (_ object: Object,_ oldValue: Value, _ newValue: Value)->(), keyPath: WritableKeyPath<Object, Value>) -> Any where Value: RawRepresentable {
        self.setterClosure { (object: Object, value: Value, apply: (Value)->()) in
            let oldValue = object[keyPath: keyPath]
            apply(value)
            closure(object, oldValue, value)
        }
    }
    
    // MARK: - hook get property

    static func getterClosure<Object, Value>(
        for closure: @escaping ((_ object: Object, _ value: Value) -> Value)
    ) -> Any {
        switch Value.self {
        case _ where Value.self == Bool.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Bool, AnyObject, Selector) -> Bool
        case _ where Value.self == Int.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Int, AnyObject, Selector) -> Int
        case _ where Value.self == Int8.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Int8, AnyObject, Selector) -> Int8
        case _ where Value.self == Int16.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Int16, AnyObject, Selector) -> Int16
        case _ where Value.self == Int32.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Int32, AnyObject, Selector) -> Int32
        case _ where Value.self == Int64.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Int64, AnyObject, Selector) -> Int64
        case _ where Value.self == UInt.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UInt, AnyObject, Selector) -> UInt
        case _ where Value.self == UInt8.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UInt8, AnyObject, Selector) -> UInt8
        case _ where Value.self == UInt16.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UInt16, AnyObject, Selector) -> UInt16
        case _ where Value.self == UInt32.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UInt32, AnyObject, Selector) -> UInt32
        case _ where Value.self == UInt64.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UInt64, AnyObject, Selector) -> UInt64
        case _ where Value.self == Double.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Double, AnyObject, Selector) -> Double
        case _ where Value.self == Float.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Float, AnyObject, Selector) -> Float
        case _ where Value.self == Decimal.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Decimal, AnyObject, Selector) -> Decimal
        case _ where Value.self == CGFloat.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGFloat, AnyObject, Selector) -> CGFloat
        case _ where Value.self == Date.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Date, AnyObject, Selector) -> Date
        case _ where Value.self == Data.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Data, AnyObject, Selector) -> Data
        case _ where Value.self == URL.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> URL, AnyObject, Selector) -> URL
        case _ where Value.self == CGSize.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGSize, AnyObject, Selector) -> CGSize
        case _ where Value.self == CGPoint.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGPoint, AnyObject, Selector) -> CGPoint
        case _ where Value.self == CGRect.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGRect, AnyObject, Selector) -> CGRect
        case _ where Value.self == CGColor.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGColor, AnyObject, Selector) -> CGColor
        case _ where Value.self == CGImage.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGImage, AnyObject, Selector) -> CGImage
        case _ where Value.self == CGVector.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGVector, AnyObject, Selector) -> CGVector
        case _ where Value.self == CGAffineTransform.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CGAffineTransform, AnyObject, Selector) -> CGAffineTransform
        case _ where Value.self == IndexSet.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> IndexSet, AnyObject, Selector) -> IndexSet
        case _ where Value.self == IndexPath.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> IndexPath, AnyObject, Selector) -> IndexPath
        case _ where Value.self == NSRange.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> NSRange, AnyObject, Selector) -> NSRange
        case _ where Value.self == CATransform3D.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CATransform3D, AnyObject, Selector) -> CATransform3D
        case _ where Value.self == CMTime.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CMTime, AnyObject, Selector) -> CMTime
        case _ where Value.self == CMTimeRange.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> CMTimeRange, AnyObject, Selector) -> CMTimeRange
        case _ where Value.self == UnsafeRawPointer.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UnsafeRawPointer, AnyObject, Selector) -> UnsafeRawPointer
        case _ where Value.self == Optional<UnsafeRawPointer>.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Optional<UnsafeRawPointer>, AnyObject, Selector) -> Optional<UnsafeRawPointer>
        case _ where Value.self == NSUIEdgeInsets.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> NSUIEdgeInsets, AnyObject, Selector) -> NSUIEdgeInsets
        case _ where Value.self == NSDirectionalRectEdge.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> NSDirectionalRectEdge, AnyObject, Selector) -> NSDirectionalRectEdge
        case _ where Value.self == (() -> ()).self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> (@convention(block) () -> Void), AnyObject, Selector) -> (@convention(block) () -> Void)
        case _ where Value.self == Optional<(() -> ())>.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> ((@convention(block) () -> Void)?), AnyObject, Selector) -> ((@convention(block) () -> Void)?)
        case _ where Value.self == UUID.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> UUID, AnyObject, Selector) -> UUID
        #if os(macOS)
        case _ where Value.self == AffineTransform.self:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> AffineTransform, AnyObject, Selector) -> AffineTransform
        #endif
        default:
            return { original, object, selector in
                cast(closure(cast(object), cast(original(object, selector))))
            } as @convention(block) ((AnyObject, Selector) -> Any, AnyObject, Selector) -> Any
        }
    }
    
    static func getterClosure<Object, Value>(for closure: @escaping ((_ object: Object, _ value: Value)->Value)) -> Any where Value: RawRepresentable {
        let rawClosure:  ((_ object: Object, _ value: Value.RawValue)->Value.RawValue) = { object, rawValue in
            closure(object, Value(rawValue: rawValue)!).rawValue
        }
        return self.getterClosure(for: rawClosure)
    }
    
    // MARK: - hook set property
    
    static func setterClosure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value, _ apply:(Value)->())->()) -> Any {
        switch Value.self {
        case _ where Value.self == Bool.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Bool) -> Void, AnyObject, Selector, Bool) -> Void
        case _ where Value.self == Int.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void
        case _ where Value.self == Int8.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int8) -> Void, AnyObject, Selector, Int8) -> Void
        case _ where Value.self == Int16.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int16) -> Void, AnyObject, Selector, Int16) -> Void
        case _ where Value.self == Int32.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int32) -> Void, AnyObject, Selector, Int32) -> Void
        case _ where Value.self == Int64.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int64) -> Void, AnyObject, Selector, Int64) -> Void
        case _ where Value.self == UInt.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt) -> Void, AnyObject, Selector, UInt) -> Void
        case _ where Value.self == UInt8.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt8) -> Void, AnyObject, Selector, UInt8) -> Void
        case _ where Value.self == UInt16.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt16) -> Void, AnyObject, Selector, UInt16) -> Void
        case _ where Value.self == UInt32.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt32) -> Void, AnyObject, Selector, UInt32) -> Void
        case _ where Value.self == UInt64.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt64) -> Void, AnyObject, Selector, UInt64) -> Void
        case _ where Value.self == Double.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Double) -> Void, AnyObject, Selector, Double) -> Void
        case _ where Value.self == Float.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Float) -> Void, AnyObject, Selector, Float) -> Void
        case _ where Value.self == Decimal.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Decimal) -> Void, AnyObject, Selector, Decimal) -> Void
        case _ where Value.self == CGFloat.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGFloat) -> Void, AnyObject, Selector, CGFloat) -> Void
        case _ where Value.self == Date.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Date) -> Void, AnyObject, Selector, Date) -> Void
        case _ where Value.self == Data.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Data) -> Void, AnyObject, Selector, Data) -> Void
        case _ where Value.self == URL.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, URL) -> Void, AnyObject, Selector, URL) -> Void
        case _ where Value.self == CGSize.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGSize) -> Void, AnyObject, Selector, CGSize) -> Void
        case _ where Value.self == CGPoint.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGPoint) -> Void, AnyObject, Selector, CGPoint) -> Void
        case _ where Value.self == CGRect.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGRect) -> Void, AnyObject, Selector, CGRect) -> Void
        case _ where Value.self == CGColor.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGColor) -> Void, AnyObject, Selector, CGColor) -> Void
        case _ where Value.self == CGImage.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGImage) -> Void, AnyObject, Selector, CGImage) -> Void
        case _ where Value.self == CGVector.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGVector) -> Void, AnyObject, Selector, CGVector) -> Void
        case _ where Value.self == CGAffineTransform.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGAffineTransform) -> Void, AnyObject, Selector, CGAffineTransform) -> Void
        case _ where Value.self == IndexSet.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, IndexSet) -> Void, AnyObject, Selector, IndexSet) -> Void
        case _ where Value.self == IndexPath.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, IndexPath) -> Void, AnyObject, Selector, IndexPath) -> Void
        case _ where Value.self == NSRange.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, NSRange) -> Void, AnyObject, Selector, NSRange) -> Void
        case _ where Value.self == CATransform3D.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CATransform3D) -> Void, AnyObject, Selector, CATransform3D) -> Void
        case _ where Value.self == CMTime.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CMTime) -> Void, AnyObject, Selector, CMTime) -> Void
        case _ where Value.self == CMTimeRange.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, CMTimeRange) -> Void, AnyObject, Selector, CMTimeRange) -> Void
        case _ where Value.self == UnsafeRawPointer.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, UnsafeRawPointer) -> Void, AnyObject, Selector, UnsafeRawPointer) -> Void
        case _ where Value.self == Optional<UnsafeRawPointer>.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, Optional<UnsafeRawPointer>) -> Void, AnyObject, Selector, Optional<UnsafeRawPointer>) -> Void
        case _ where Value.self == NSUIEdgeInsets.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, NSUIEdgeInsets) -> Void, AnyObject, Selector, NSUIEdgeInsets) -> Void
        case _ where Value.self == NSDirectionalRectEdge.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((AnyObject, Selector, NSDirectionalRectEdge) -> Void, AnyObject, Selector, NSDirectionalRectEdge) -> Void
        case _ where Value.self == (() -> ()).self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((@convention(block) (AnyObject, Selector, @escaping () -> ()) -> Void), AnyObject, Selector, @escaping () -> ()) -> Void
        case _ where Value.self == Optional<(() -> ())>.self:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, cast($0)) })
            } as @convention(block) ((@convention(block) (AnyObject, Selector, (@convention(block) () -> Void)?) -> Void), AnyObject, Selector, (@convention(block) () -> Void)?) -> Void
        case _ where Value.self == UUID.self:
            return { original, object, selector, value in
            closure(cast(object), cast(value), { original(object, selector, cast($0)) })
        } as @convention(block) ((AnyObject, Selector, UUID) -> Void, AnyObject, Selector, UUID) -> Void
        #if os(macOS)
        case _ where Value.self == AffineTransform.self:
            return { original, object, selector, value in
            closure(cast(object), cast(value), { original(object, selector, cast($0)) })
        } as @convention(block) ((AnyObject, Selector, AffineTransform) -> Void, AnyObject, Selector, AffineTransform) -> Void
        #endif
        default:
            return { original, object, selector, value in
                closure(cast(object), cast(value), { original(object, selector, $0 as Any) })
            } as @convention(block) ((AnyObject, Selector, Any) -> Void, AnyObject, Selector, Any) -> Void
        }
    }
    
    static func setterClosure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value, _ apply: (Value)->())->()) -> Any where Value: RawRepresentable {
        let rawClosure: (Object, Value.RawValue, (Value.RawValue)->())->() = { object, rawValue, original in
            guard let newValue = Value(rawValue: rawValue) else { return }
            let newOriginal: ((Value)->()) = { original($0.rawValue) }
            closure(object, newValue, newOriginal)
        }
        return self.setterClosure(for: rawClosure)
    }
    
    // MARK: - hook before/after set property
    
    static func closure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value)->()) -> Any {
        switch Value.self {
        case _ where Value.self == Bool.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Bool) -> Void
        case _ where Value.self == Int.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Int) -> Void
        case _ where Value.self == Int8.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Int8) -> Void
        case _ where Value.self == Int16.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Int16) -> Void
        case _ where Value.self == Int32.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Int32) -> Void
        case _ where Value.self == Int64.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Int64) -> Void
        case _ where Value.self == UInt.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, UInt) -> Void
        case _ where Value.self == UInt8.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, UInt8) -> Void
        case _ where Value.self == UInt16.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, UInt16) -> Void
        case _ where Value.self == UInt32.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, UInt32) -> Void
        case _ where Value.self == UInt64.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, UInt64) -> Void
        case _ where Value.self == Double.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Double) -> Void
        case _ where Value.self == Float.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Float) -> Void
        case _ where Value.self == Decimal.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Decimal) -> Void
        case _ where Value.self == CGFloat.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGFloat) -> Void
        case _ where Value.self == Date.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Date) -> Void
        case _ where Value.self == Data.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Data) -> Void
        case _ where Value.self == URL.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, URL) -> Void
        case _ where Value.self == CGSize.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGSize) -> Void
        case _ where Value.self == CGPoint.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGPoint) -> Void
        case _ where Value.self == CGRect.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGRect) -> Void
        case _ where Value.self == CGColor.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGColor) -> Void
        case _ where Value.self == CGImage.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGImage) -> Void
        case _ where Value.self == CGVector.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGVector) -> Void
        case _ where Value.self == CGAffineTransform.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CGAffineTransform) -> Void
        case _ where Value.self == IndexSet.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, IndexSet) -> Void
        case _ where Value.self == IndexPath.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, IndexPath) -> Void
        case _ where Value.self == NSRange.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, NSRange) -> Void
        case _ where Value.self == CATransform3D.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CATransform3D) -> Void
        case _ where Value.self == CMTime.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CMTime) -> Void
        case _ where Value.self == CMTimeRange.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, CMTimeRange) -> Void
        case _ where Value.self == UnsafeRawPointer.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, UnsafeRawPointer) -> Void
        case _ where Value.self == Optional<UnsafeRawPointer>.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Optional<UnsafeRawPointer>) -> Void
        case _ where Value.self == NSUIEdgeInsets.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, NSUIEdgeInsets) -> Void
        case _ where Value.self == NSDirectionalRectEdge.self:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, NSDirectionalRectEdge) -> Void
        case _ where Value.self == (()->()).self:
            return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, @escaping () -> ()) -> Void
        case _ where Value.self == Optional<(() ->())>.self:
            return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, (() -> ())?) -> Void
        case _ where Value.self == UUID.self:
            return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, (() -> ())?) -> Void
        #if os(macOS)
        case _ where Value.self == AffineTransform.self:
            return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, (() -> ())?) -> Void
        #endif
        default:
         return { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Any) -> Void
        }
    }
    
    static func closure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value)->()) -> Any where Value:RawRepresentable {
        let rawClosure: (_ object: Object,_ value: Value.RawValue)->() = { object, rawValue in
            closure(object, Value(rawValue: rawValue)!)
        }
        return self.closure(for: rawClosure)
    }
}

#endif
