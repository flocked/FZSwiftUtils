//
//  NSObject+SelectorName.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation

extension PartialKeyPath {
    func getterName() throws -> String where Root: NSObject {
        guard let getterName = _kvcKeyPathString else {
            throw HookError.nonObjcProperty
        }
        return getterName
    }
    
    func setterName() throws -> String where Root: NSObject {
        guard let setterName = Root.setterName(for: try getterName()) else {
            throw HookError.nonObjcProperty
        }
        return setterName
    }
    
    func getterName<T>() throws -> String where Root == T.Type, T: NSObject {
        guard let getterName = _kvcKeyPathString else {
            throw HookError.nonObjcProperty
        }
        return getterName
    }
    
    func setterName<T>() throws -> String where Root == T.Type, T: NSObject {
        guard let setterName = T.setterName(for: try getterName(), isInstance: false) else {
            throw HookError.nonObjcProperty
        }
        return setterName
    }
}

fileprivate extension NSObject {
    static func setterName(for getterName: String, isInstance: Bool = true) -> String? {
        let lookupClass: AnyClass = isInstance ? self : object_getClass(self) ?? self
        if let setterName = NSObject.setterNames[lookupClass, default: [:]][getterName] {
            return setterName
        }
        func check(_ name: String) -> String? {
            let hasUnderscore = name.hasPrefix("_")
            let searchName = hasUnderscore ? String(name.dropFirst()) : name
            let prefix = hasUnderscore ? "_set" : "set"
            var names = ["\(prefix)\(searchName.uppercasedFirst()):"]
            if searchName.hasPrefix("is") { names += "\(prefix)\(searchName.dropFirst(2).uppercasedFirst()):" }
            else if searchName.hasPrefix("get") { names += "\(prefix)\(searchName.dropFirst(3).uppercasedFirst()):" }
            guard let name = names.first(where: {
                isInstance ? lookupClass.instancesRespond(to: Selector($0)) : lookupClass.responds(to: Selector($0))
            }) else { return nil }
            NSObject.setterNames[lookupClass, default: [:]][getterName] = name
            return name
        }
        if let name = check(getterName) {
            return name
        }
        var currentClass: AnyClass? = lookupClass
        while let cls = currentClass {
            currentClass = cls.superclass()
            var count: UInt32 = 0
            guard let properties = class_copyPropertyList(cls, &count) else { continue }
            defer { free(properties) }
            for property in properties.buffer(count: count) {
                let name = property_getName(property).string
                guard getterName == property.attribute(for: "G") ?? name else { continue }
                if property.attribute(for: "R") != nil {
                    setterNames[lookupClass, default: [:]][getterName] = nil
                    return nil
                }
                if let setterName = property.attribute(for: "S") {
                    NSObject.setterNames[lookupClass, default: [:]][getterName] = setterName
                    return setterName
                }
                return check(getterName)
            }
        }
        NSObject.setterNames[lookupClass, default: [:]][getterName] = nil
        return nil
    }
    
    static var setterNames: SynchronizedDictionary<ObjectIdentifier, [String: String?]> {
        get { getAssociatedValue("setterNames", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "setterNames") }
    }
}

fileprivate extension objc_property_t {
    func attribute(for key: String) -> String? {
        property_copyAttributeValue(self, key)?.stringAndFree()
    }
}
