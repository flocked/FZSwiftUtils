//
//  File.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

public extension NSKeyedUnarchiver {
    enum Errors: Error {
        case unpackingErrorr
    }
}

public extension NSCoding where Self: NSObject {
    func archiveBasedCopy() throws -> Self {
        let o = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        guard let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: o) else { throw NSKeyedUnarchiver.Errors.unpackingErrorr }
        return object
    }
}

public extension NSObject {
    func setValueSafely(_ value: Any?, forKey key: String) {
        if containsProperty(named: key) {
            setValue(value, forKey: key)
        }
    }

    func value<T>(forKey key: String, type _: T.Type) -> T? {
        if containsProperty(named: key) {
            return value(forKey: key) as? T
        }
        return nil
    }

    func overrides(_ selector: Selector) -> Bool {
        var currentClass: AnyClass = type(of: self)
        let method: Method? = class_getInstanceMethod(currentClass, selector)

        while let superClass: AnyClass = class_getSuperclass(currentClass) {
            // Make sure we only check against non-nil returned instance methods.
            if class_getInstanceMethod(superClass, selector).map({ $0 != method }) ?? false { return true }
            currentClass = superClass
        }
        return false
    }

    func isSubclass(of class_: AnyClass) -> Bool {
        var currentClass: AnyClass = type(of: self)
        while let superClass: AnyClass = class_getSuperclass(currentClass) {
            if superClass == class_ {
                return true
            }
            currentClass = superClass
        }
        return false
    }
    
    func observeNew<Value>(_ keyPath: KeyPath<NSObject, Value>, changeHandler: @escaping ((NSObject, Value)->())) -> NSKeyValueObservation {
        return self.observe(keyPath, options: [.new], changeHandler: { object, value in
            if let newValue = value.newValue {
                changeHandler(object, newValue)
            }
        })
    }
}
