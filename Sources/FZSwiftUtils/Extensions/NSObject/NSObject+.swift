//
//  File.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

public extension NSKeyedUnarchiver {
    enum Errors: Error {
        case unpackingError
    }
}

public extension NSCoding where Self: NSObject {
    func archiveBasedCopy() throws -> Self {
        let o = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        guard let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: o) else { throw NSKeyedUnarchiver.Errors.unpackingError }
        return object
    }
}

public extension NSObject {
    func removeObserver<Value>(_ observer: NSObject, for keypath: KeyPath<NSObject, Value>) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        self.removeObserver(observer, forKeyPath: keypathString)
    }
    
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
}