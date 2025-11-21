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
    static func closure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value, _ apply:(Value)->())->()) -> Any {
        { original, object, selector, value in
            closure(cast(object), cast(value), { original(object, selector, cast($0)) })
        } as @convention(block) ((AnyObject, Selector, Any) -> Void, AnyObject, Selector, Any) -> Void
    }
    
    static func closure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value, _ apply: (Value)->())->()) -> Any where Value: RawRepresentable {
        let rawClosure: (Object, Value.RawValue, (Value.RawValue)->())->() = { object, rawValue, original in
            guard let newValue = Value(rawValue: rawValue) else { return }
            let newOriginal: ((Value)->()) = { original($0.rawValue) }
            closure(object, newValue, newOriginal)
        }
        return self.closure(for: rawClosure)
    }
    
    static func closure<Object, Value>(for closure: @escaping ((_ object: Object, _ value: Value)->Value)) -> Any {
        { original, object, selector in
            cast(closure(cast(object), cast(original(object, selector))))
        } as @convention(block) ((AnyObject, Selector) -> Any, AnyObject, Selector) -> Any
    }
    
    static func closure<Object, Value>(for closure: @escaping ((_ object: Object, _ value: Value)->Value)) -> Any where Value: RawRepresentable {
        let rawClosure:  ((_ object: Object, _ value: Value.RawValue)->Value.RawValue) = { object, rawValue in
            closure(object, Value(rawValue: rawValue)!).rawValue
        }
        return self.closure(for: rawClosure)
    }
    
    static func closure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value)->()) -> Any {
        { closure(cast($0), cast($2)) } as @convention(block) (AnyObject, Selector, Bool) -> Void
    }
    
    static func closure<Object, Value>(for closure: @escaping (_ object: Object,_ value: Value)->()) -> Any where Value:RawRepresentable {
        let rawClosure: (_ object: Object,_ value: Value.RawValue)->() = { object, rawValue in
            closure(object, Value(rawValue: rawValue)!)
        }
        return self.closure(for: rawClosure)
    }
}

#endif
