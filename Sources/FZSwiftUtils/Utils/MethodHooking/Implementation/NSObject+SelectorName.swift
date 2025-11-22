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
        guard let setterName = NSObject.setterName(for: try getterName(), _class: Root.self) else {
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
        guard let setterName = NSObject.setterName(for: try getterName(), _class: T.self) else {
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
    
    static func setterName(for getterName: String, _class: AnyClass, isInstance: Bool = true) -> String? {
        let lookupClass: AnyClass = isInstance ? _class : object_getClass(_class) ?? _class
        
        if let setterName = setterNames[lookupClass, default: [:]][getterName] {
            return setterName
        }
        
        if !class_respondsToSelector(lookupClass, Selector(getterName)) {
            return nil
        }
        
        var names = ["set\(getterName.uppercasedFirst()):"]
        if getterName.hasPrefix("is") {
            names += "set\(getterName.dropFirst(2).uppercasedFirst()):"
        } else if getterName.hasPrefix("get") {
            names += "set\(getterName.dropFirst(3).uppercasedFirst()):"
        }
        if let name = names.first(where: { class_respondsToSelector(lookupClass, Selector($0)) }) {
            setterNames[lookupClass, default: [:]][getterName] = name
            return name
        }
       
        let getterSelector = Selector(getterName)
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
                
                guard getterSelector == Selector(property.attribute(for: "G") ?? name) else { continue }
                if let explicitSetter = property.attribute(for: "S") {
                    setterNames[lookupClass, default: [:]][getterName] = explicitSetter
                    return explicitSetter
                }
                var names = ["set\(name.uppercasedFirst()):"]
                if name.hasPrefix("is") {
                    names += "set\(name.dropFirst(2).uppercasedFirst()):"
                } else if name.hasPrefix("get") {
                    names += "set\(name.dropFirst(3).uppercasedFirst()):"
                }
                if let name = names.first(where: { class_respondsToSelector(c, Selector($0)) }) {
                    setterNames[lookupClass, default: [:]][getterName] = name
                    return name
                }
                return nil
            }
            currentClass = class_getSuperclass(c)
        }
        return nil
    }
}

fileprivate extension objc_property_t {
    func attribute(for key: String) -> String? {
        var count: UInt32 = 0
        guard let attrs = property_copyAttributeList(self, &count) else { return nil }
        defer { free(attrs) }
        for i in 0..<count {
            let attr = attrs[Int(i)]
            if String(cString: attr.name) == key {
                return String(cString: attr.value)
            }
        }
        return nil
    }
}
