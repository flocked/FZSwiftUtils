//
//  Hook+Closure.swift
//  FZSwiftUtils
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
    static func closure<Object: NSObject, Value>(for closure: @escaping (_ object: Object,_ value: Value, _ apply:(Value)->())->()) -> Any {
        switch Value.self {
        case _ where Value.self == Bool.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Bool) -> Void, AnyObject, Selector, Bool) -> Void
        case _ where Value.self == Int.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void
        case _ where Value.self == Int8.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int8) -> Void, AnyObject, Selector, Int8) -> Void
        case _ where Value.self == Int16.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int16) -> Void, AnyObject, Selector, Int16) -> Void
        case _ where Value.self == Int32.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int32) -> Void, AnyObject, Selector, Int32) -> Void
        case _ where Value.self == Int64.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Int64) -> Void, AnyObject, Selector, Int64) -> Void
        case _ where Value.self == UInt.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt) -> Void, AnyObject, Selector, UInt) -> Void
        case _ where Value.self == UInt8.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt8) -> Void, AnyObject, Selector, UInt8) -> Void
        case _ where Value.self == UInt16.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt16) -> Void, AnyObject, Selector, UInt16) -> Void
        case _ where Value.self == UInt32.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt32) -> Void, AnyObject, Selector, UInt32) -> Void
        case _ where Value.self == UInt64.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, UInt64) -> Void, AnyObject, Selector, UInt64) -> Void
        case _ where Value.self == Double.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Double) -> Void, AnyObject, Selector, Double) -> Void
        case _ where Value.self == Float.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Float) -> Void, AnyObject, Selector, Float) -> Void
        case _ where Value.self == Decimal.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Decimal) -> Void, AnyObject, Selector, Decimal) -> Void
        case _ where Value.self == CGFloat.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGFloat) -> Void, AnyObject, Selector, CGFloat) -> Void
        case _ where Value.self == Date.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Date) -> Void, AnyObject, Selector, Date) -> Void
        case _ where Value.self == Data.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Data) -> Void, AnyObject, Selector, Data) -> Void
        case _ where Value.self == URL.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, URL) -> Void, AnyObject, Selector, URL) -> Void
        case _ where Value.self == CGSize.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGSize) -> Void, AnyObject, Selector, CGSize) -> Void
        case _ where Value.self == CGPoint.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGPoint) -> Void, AnyObject, Selector, CGPoint) -> Void
        case _ where Value.self == CGRect.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGRect) -> Void, AnyObject, Selector, CGRect) -> Void
        case _ where Value.self == CGColor.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGColor) -> Void, AnyObject, Selector, CGColor) -> Void
        case _ where Value.self == CGImage.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGImage) -> Void, AnyObject, Selector, CGImage) -> Void
        case _ where Value.self == CGVector.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGVector) -> Void, AnyObject, Selector, CGVector) -> Void
        case _ where Value.self == CGAffineTransform.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CGAffineTransform) -> Void, AnyObject, Selector, CGAffineTransform) -> Void
        case _ where Value.self == IndexSet.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, IndexSet) -> Void, AnyObject, Selector, IndexSet) -> Void
        case _ where Value.self == IndexPath.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, IndexPath) -> Void, AnyObject, Selector, IndexPath) -> Void
        case _ where Value.self == NSRange.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, NSRange) -> Void, AnyObject, Selector, NSRange) -> Void
        case _ where Value.self == CATransform3D.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CATransform3D) -> Void, AnyObject, Selector, CATransform3D) -> Void
        case _ where Value.self == CMTime.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CMTime) -> Void, AnyObject, Selector, CMTime) -> Void
        case _ where Value.self == CMTimeRange.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, CMTimeRange) -> Void, AnyObject, Selector, CMTimeRange) -> Void
        case _ where Value.self == UnsafeRawPointer.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, UnsafeRawPointer) -> Void, AnyObject, Selector, UnsafeRawPointer) -> Void
        case _ where Value.self == Optional<UnsafeRawPointer>.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, Optional<UnsafeRawPointer>) -> Void, AnyObject, Selector, Optional<UnsafeRawPointer>) -> Void
        case _ where Value.self == NSUIEdgeInsets.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, NSUIEdgeInsets) -> Void, AnyObject, Selector, NSUIEdgeInsets) -> Void
        case _ where Value.self == NSDirectionalRectEdge.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((AnyObject, Selector, NSDirectionalRectEdge) -> Void, AnyObject, Selector, NSDirectionalRectEdge) -> Void
        case _ where Value.self == (() -> ()).self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((@convention(block) (AnyObject, Selector, @escaping () -> ()) -> Void), AnyObject, Selector, @escaping () -> ()) -> Void
        case _ where Value.self == Optional<(() -> ())>.self:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
            } as @convention(block) ((@convention(block) (AnyObject, Selector, (@convention(block) () -> Void)?) -> Void), AnyObject, Selector, (@convention(block) () -> Void)?) -> Void
        case _ where Value.self == UUID.self:
            return { original, object, selector, value in
            closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
        } as @convention(block) ((AnyObject, Selector, UUID) -> Void, AnyObject, Selector, UUID) -> Void
        case _ where Value.self == AffineTransform.self:
            return { original, object, selector, value in
            closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, unsafeBitCast($0)) })
        } as @convention(block) ((AnyObject, Selector, AffineTransform) -> Void, AnyObject, Selector, AffineTransform) -> Void
        default:
            return { original, object, selector, value in
                closure(unsafeBitCast(object), unsafeBitCast(value), { original(object, selector, $0 as Any) })
            } as @convention(block) ((AnyObject, Selector, Any) -> Void, AnyObject, Selector, Any) -> Void
        }
    }
    
    static func beforeAfterClosure<Object: NSObject, Value>(for closure: @escaping (_ object: Object,_ value: Value)->()) -> Any {
        switch Value.self {
        case _ where Value.self == Bool.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Bool) -> Void
        case _ where Value.self == Int.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Int) -> Void
        case _ where Value.self == Int8.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Int8) -> Void
        case _ where Value.self == Int16.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Int16) -> Void
        case _ where Value.self == Int32.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Int32) -> Void
        case _ where Value.self == Int64.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Int64) -> Void
        case _ where Value.self == UInt.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, UInt) -> Void
        case _ where Value.self == UInt8.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, UInt8) -> Void
        case _ where Value.self == UInt16.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, UInt16) -> Void
        case _ where Value.self == UInt32.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, UInt32) -> Void
        case _ where Value.self == UInt64.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, UInt64) -> Void
        case _ where Value.self == Double.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Double) -> Void
        case _ where Value.self == Float.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Float) -> Void
        case _ where Value.self == Decimal.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Decimal) -> Void
        case _ where Value.self == CGFloat.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGFloat) -> Void
        case _ where Value.self == Date.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Date) -> Void
        case _ where Value.self == Data.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Data) -> Void
        case _ where Value.self == URL.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, URL) -> Void
        case _ where Value.self == CGSize.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGSize) -> Void
        case _ where Value.self == CGPoint.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGPoint) -> Void
        case _ where Value.self == CGRect.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGRect) -> Void
        case _ where Value.self == CGColor.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGColor) -> Void
        case _ where Value.self == CGImage.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGImage) -> Void
        case _ where Value.self == CGVector.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGVector) -> Void
        case _ where Value.self == CGAffineTransform.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CGAffineTransform) -> Void
        case _ where Value.self == IndexSet.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, IndexSet) -> Void
        case _ where Value.self == IndexPath.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, IndexPath) -> Void
        case _ where Value.self == NSRange.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, NSRange) -> Void
        case _ where Value.self == CATransform3D.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CATransform3D) -> Void
        case _ where Value.self == CMTime.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CMTime) -> Void
        case _ where Value.self == CMTimeRange.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, CMTimeRange) -> Void
        case _ where Value.self == UnsafeRawPointer.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, UnsafeRawPointer) -> Void
        case _ where Value.self == Optional<UnsafeRawPointer>.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Optional<UnsafeRawPointer>) -> Void
        case _ where Value.self == NSUIEdgeInsets.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, NSUIEdgeInsets) -> Void
        case _ where Value.self == NSDirectionalRectEdge.self:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, NSDirectionalRectEdge) -> Void
        case _ where Value.self == (()->()).self:
            return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, @escaping () -> ()) -> Void
        case _ where Value.self == Optional<(() ->())>.self:
            return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, (() -> ())?) -> Void
        case _ where Value.self == UUID.self:
            return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, (() -> ())?) -> Void
        case _ where Value.self == AffineTransform.self:
            return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, (() -> ())?) -> Void
        default:
         return { closure(unsafeBitCast($0), unsafeBitCast($2)) } as @convention(block) (AnyObject, Selector, Any) -> Void
        }
    }
    
    static func rawClosure<Object: NSObject, Value: RawRepresentable>(for closure: @escaping (_ object: Object,_ value: Value)->()) -> (Object, Value.RawValue)->() {
        { object, rawValue in
            guard let value = Value(rawValue: rawValue) else { return }
            closure(object, value)
        }
    }
}

#endif
