//
//  NSObject+SelectorName.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

extension PartialKeyPath {
    func getterName() throws -> String where Root: NSObject {
        guard let getterName = _kvcKeyPathString else {
            throw HookError.noKVOKeyPath
        }
        return getterName
    }
    
    func setterName() throws -> String where Root: NSObject {
        guard let setterName = NSObject.setterName(for: try getterName(), _class: Root.self) else {
            throw HookError.noKVOKeyPath
        }
        return setterName
    }
    
    func getterName<T>() throws -> String where Root == T.Type, T: NSObject {
        guard let getterName = _kvcKeyPathString else {
            throw HookError.noKVOKeyPath
        }
        return getterName
    }
    
    func setterName<T>() throws -> String where Root == T.Type, T: NSObject {
        guard let setterName = NSObject.setterName(for: try getterName(), _class: T.self) else {
            throw HookError.noKVOKeyPath
        }
        return setterName
    }
}

fileprivate extension NSObject {
    static func setterName(for getterName: String, _class: AnyClass) -> String? {
        let getterSelector = Selector(getterName)
        
        var currentClass: AnyClass? = _class
        while let c = currentClass {
            var propertyCount: UInt32 = 0
            guard let properties = class_copyPropertyList(c, &propertyCount) else {
                currentClass = class_getSuperclass(c)
                continue
            }
            defer { free(properties) }
            
            for i in 0..<propertyCount {
                let property = properties[Int(i)]
                let nameCStr = property_getName(property)
                let propName = String(cString: nameCStr)
                
                // Check if this property has a custom getter
                let getterSel: Selector
                if let getterAttr = getPropertyAttribute(property, key: "G") {
                    getterSel = Selector(getterAttr)
                } else {
                    getterSel = Selector(propName)
                }
                
                if getterSel == getterSelector {
                    if let setterAttr = getPropertyAttribute(property, key: "S") {
                        return setterAttr
                    } else {
                        let capitalized = propName.prefix(1).uppercased() + propName.dropFirst()
                        return "set\(capitalized):"
                    }
                }
            }
            currentClass = class_getSuperclass(c)
        }
        return nil
    }
    
    static func getPropertyAttribute(_ property: objc_property_t, key: String) -> String? {
        var count: UInt32 = 0
        guard let attrs = property_copyAttributeList(property, &count) else { return nil }
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
#endif
