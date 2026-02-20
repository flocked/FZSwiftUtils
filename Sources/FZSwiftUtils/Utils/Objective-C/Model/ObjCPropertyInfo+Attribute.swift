//
//  ObjCPropertyAttribute.swift
//
//
//  Created by p-x9 on 2024/06/23
//  
//

import Foundation

extension ObjCPropertyInfo {
    /// Represents an attribute of an Objective-C property.
    public enum Attribute: Sendable, Equatable, Codable {
        /// The type of the property (encoded).
        case type(ObjCType?)
        /// The property is read-only.
        case readonly
        /// The property is nonatomic.
        case nonatomic
        /// The property is declared as dynamic.
        case dynamic
        /// The property uses copy semantics.
        case copy
        /// The property uses retain semantics.
        case retain
        /// The property uses weak semantics.
        case weak
        /// A custom getter method name.
        case getter(name: String)
        /// A custom setter method name.
        case setter(name: String)
        /// The name of the backing instance variable.
        case ivar(name: String)
        /// An unrecognized or unsupported property attribute.
        case other(String)
        
        /// The type encodibg of the attribute.
        public func encoded() -> String {
            switch self {
            case .type(let type): "T" + type?.encoded()
            case .readonly: "R"
            case .nonatomic: "N"
            case .dynamic: "D"
            case .weak: "W"
            case .copy: "C"
            case .retain: "&"
            case .getter(let name): "G\(name)"
            case .setter(let name): "S\(name)"
            case .ivar(let name): "V\(name)"
            case .other(let value): value
            }
        }
        
        public var description: String {
            switch self {
            case .type(let type): return "type: \(type?.description ?? "-")"
            case .getter(let name): return "getter: \(name)"
            case .setter(let name): return "setter: \(name)"
            case .ivar(let name): return "ivar: \(name)"
            case .readonly: return "readonly"
            case .copy: return "copy"
            case .retain: return "retain"
            case .nonatomic: return "nonatomic"
            case .dynamic: return "dynamic"
            case .weak: return "weak"
            case .other(let string): return "\(string)"
            }
        }
    }
    
    /// Returns the attributes for the specified Objective-C property.
    public static func attributes(for property: objc_property_t) -> [Attribute]? {
        var count: UInt32 = 0
        guard let list = property_copyAttributeList(property, &count) else { return nil }
        defer { free(list) }
        return list.buffer(count: count).map({
            let name = String(cString: $0.name)
            let value = $0.value
            switch String(cString: $0.name) {
            case "T": return .type(ObjCType(String(cString: value)))
            case "R": return .readonly
            case "C": return .copy
            case "&": return .retain
            case "N": return .nonatomic
            case "G": return .getter(name: String(cString: value))
            case "S": return .setter(name: String(cString: value))
            case "D": return .dynamic
            case "W": return .weak
            case "V": return .ivar(name: String(cString: value))
            default: return .other(name + String(cString: value))
            }
        })
    }
}

extension ObjCPropertyInfo.Attribute {
    var type: ObjCType? {
        switch self {
        case .type(let type): return type
        default: return nil
        }
    }
    
    var size: Int? {
        guard let typeEncoding = type?.encoded() else { return nil }
        return ObjCRuntime.sizeAndAlignment(for: typeEncoding)?.size
    }
    
    var ivarName: String? {
        switch self {
        case .ivar(name: let name): return name
        default: return nil
        }
    }
    
    var getterName: String? {
        switch self {
        case .getter(name: let name): return name
        default: return nil
        }
    }
    
    var setterName: String? {
        switch self {
        case .setter(name: let name): return name
        default: return nil
        }
    }
}

/*
 /// Ownership of the property.
public  enum Ownership: String, CustomStringConvertible {
     /// Retain.
     case retain
     /// Copy.
     case copy
     /// Weak.
     case weak
     
     public var description: String { rawValue }
     
     public var encoded: String {
         switch self {
         case .retain: return "&"
         case .copy: return "C"
         case .weak: return "W"
         }
     }
 }

extension ObjCPropertyAttribute {
    var name: String {
        switch self {
        case .type(let type): return "T"
        case .readonly: return "R"
        case .nonatomic: return "N"
        case .dynamic: return "D"
        case .copy: return "C"
        case .retain: return "&"
        case .weak: return "W"
        case .getter(let name): return "G"
        case .setter(let name): return "S"
        case .ivar(let name): return "V"
        case .other(let string): return string.first.map({ String($0) }) ?? ""
        }
    }
    
    var value: String {
        switch self {
        case .type(let type):
            return type?.encoded() ?? ""
        case .getter(let name), .setter(let name), .ivar(let name):
            return name
        case .other(let string):
            return String(string.dropFirst())
        default: return ""
        }
    }
}

extension objc_property_attribute_t {
    init(_ attribute: ObjCPropertyAttribute) {
        self.init(name: attribute.name, value: attribute.value)
    }
}
*/
