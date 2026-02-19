//
//  NSObject+SelectorName.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation

extension PartialKeyPath {
    func getterName() throws -> String where Root: AnyObject {
        guard let getterName = _kvcKeyPathString else {
            throw HookError.nonObjcProperty
        }
        return getterName
    }
    
    func setterName() throws -> String where Root: AnyObject {
        guard let setterName = NSObject.setterName(for: Root.self, getterName: try getterName()) else {
            throw HookError.nonObjcProperty
        }
        return setterName
    }
    
    func getterName<T>() throws -> String where Root == T.Type, T: AnyObject {
        guard let getterName = _kvcKeyPathString else {
            throw HookError.nonObjcProperty
        }
        return getterName
    }
    
    func setterName<T>() throws -> String where Root == T.Type, T: AnyObject {
        guard let setterName = NSObject.setterName(for: T.self, getterName: try getterName(), isInstance: false) else {
            throw HookError.nonObjcProperty
        }
        return setterName
    }
}

extension NSObject {
    static var setterNames: [ObjectIdentifier: [String: String?]] {
        get { getAssociatedValue("setterNames") ?? [:] }
        set { setAssociatedValue(newValue, key: "setterNames") }
    }
    
    static func setterName(for cls: AnyClass, getterName: String, isInstance: Bool = true) -> String? {
        let lookupClass: AnyClass = isInstance ? cls : object_getClass(cls) ?? cls
        if let setterName = setterNames[lookupClass, default: [:]][getterName] {
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
            setterNames[lookupClass, default: [:]][getterName] = name
            return name
        }
        if let name = check(getterName) {
            return name
        }
        var currentClass: AnyClass? = lookupClass
        while let c = currentClass {
            var propertyCount: UInt32 = 0
            guard let properties = class_copyPropertyList(c, &propertyCount) else {
                currentClass = class_getSuperclass(c)
                continue
            }
            defer { free(properties) }
            for i in 0..<propertyCount {
                let property = properties[Int(i)]
                let name = String(cString: property_getName(property))
                guard getterName == property.attribute(for: "G") ?? name else { continue }
                if let explicitSetter = property.attribute(for: "S") {
                    setterNames[lookupClass, default: [:]][getterName] = explicitSetter
                    return explicitSetter
                }
                return check(getterName)
            }
            currentClass = class_getSuperclass(c)
        }
        return nil
    }
}

fileprivate extension objc_property_t {
    func attribute(for key: String) -> String? {
        guard let pointer = property_copyAttributeValue(self, key) else { return nil }
        defer { free(pointer) }
        return String(cString: pointer)
    }
}
