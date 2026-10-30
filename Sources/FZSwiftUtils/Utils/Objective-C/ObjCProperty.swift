//
//  ObjCProperty.swift
//
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

/// An Objective-C property.
public struct ObjCProperty {
    /// The property.
    public let property: objc_property_t
    
    public init(_ property: objc_property_t) {
        self.property = property
    }
    
    /// The name of the property.
    public var name: String {
        property_getName(property).string
    }
    
    /// The attributes of the property.
    public var attributes: [Attribute] {
        BufferCollection{ property_copyAttributeList(property, $0) }.map(Attribute.init)
    }

    /// An attribute of an Objective-C property.
    public struct Attribute: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
        /// The name of the attribute.
        public let name: Name

        /// The value of the attribute.
        public let value: String

        /// An attribute indicating that the property is read-only.
        public static let readOnly = Self(name: .readOnly)
        /// An attribute indicating that the property uses copy semantics.
        public static let copy = Self(name: .copy)
        /// An attribute indicating that the property uses retain semantics.
        public static let retain = Self(name: .retain)
        /// An attribute indicating that the property is nonatomic.
        public static let nonatomic = Self(name: .nonatomic)
        /// An attribute indicating that the property is dynamic.
        public static let dynamic = Self(name: .dynamic)
        /// An attribute indicating that the property uses weak semantics.
        public static let weak = Self(name: .weak)
        /// An attribute indicating that the property is eligible for garbage collection.
        public static let garbageCollectable = Self(name: .garbageCollectable)
        /// Returns an attribute with the specified getter name.
        public static func getter(_ getterName: String) -> Self {
            Self(name: .getter, value: getterName)
        }
        /// Returns an attribute with the specified setter name.
        public static func setter(_ setterName: String) -> Self {
            Self(name: .setter, value: setterName)
        }
        /// Returns an attribute with the specified instance variable name.
        public static func ivar(_ ivarName: String) -> Self {
            Self(name: .ivar, value: ivarName)
        }
        /// Returns an attribute with the specified type encoding.
        public static func typeEncoding(_ typeEncoding: String) -> Self {
            Self(name: .typeEncoding, value: typeEncoding)
        }
        
        /// Creates an attribute from the specified Objective-C runtime property attribute.
        public init(_ attribute: objc_property_attribute_t) {
            self.init(name: attribute.name.string, value: attribute.value.string)
        }
        
        /// Creates an attribute with the specified name and value.
        @_disfavoredOverload
        public init(name: Name, value: String) {
            self.name = name
            self.value = value
        }

        /// Creates an attribute with the specified raw name and value.
        public init(name: String, value: String) {
            self.name = Name(rawValue: name)
            self.value = value
        }
        
        /// Creates an attribute with the specified name.
        @_disfavoredOverload
        public init(name: Name) {
            self.init(name: name, value: "")
        }
        
        /// Creates an attribute with the specified name.
        public init(name: String) {
            self.init(name: name, value: "")
        }
        
        public var description: String {
            value.isEmpty ? "\(name)" : "(\(name), \(value))"
        }

        public var debugDescription: String {
            value.isEmpty ? name.rawValue : "(\(name.rawValue), \(value))"
        }

        /// The name of a property attribute.
        public struct Name: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible, CustomDebugStringConvertible {
            /// The type encoding of the property.
            public static let typeEncoding: Self = "T"
            /// The property is read-only.
            public static let readOnly: Self = "R"
            /// The property uses copy semantics.
            public static let copy: Self = "C"
            /// The property uses retain semantics.
            public static let retain: Self = "&"
            /// The property is nonatomic.
            public static let nonatomic: Self = "N"
            /// The property has a custom getter.
            public static let getter: Self = "G"
            /// The property has a custom setter.
            public static let setter: Self = "S"
            /// The property is dynamic.
            public static let dynamic: Self = "D"
            /// The property uses weak semantics.
            public static let weak: Self = "W"
            /// The property is eligible for garbage collection.
            public static let garbageCollectable: Self = "P"
            /// The old-style type encoding of the property.
            public static let oldTypeEncoding: Self = "t"
            /// The backing instance variable of the property.
            public static let ivar: Self = "V"

            /// The raw Objective-C runtime attribute name.
            public let rawValue: String
            
            /// Creates an attribute name with the specified raw value.
            public init(rawValue: String) {
                self.rawValue = rawValue
            }

            /// Creates an attribute name from a string literal.
            public init(stringLiteral value: String) {
                self.init(rawValue: value)
            }

            public var description: String {
                Self.descriptions[rawValue] ?? rawValue
            }

            public var debugDescription: String {
                rawValue
            }

            private static let descriptions = ["T": ".type", "R": ".readOnly", "C": ".copy", "&": ".retain", "N": ".nonatomic", "G": ".getter", "S": ".setter", "D": ".dynamic", "W": ".weak", "P": ".garbageCollectable", "t": ".oldType", "V": ".ivar"]
        }
    }
    
    /// Returns the attribute value for the attribute with the specified name.
    public func attributeValue(for name: String) -> String? {
        property_copyAttributeValue(property, name)?.stringAndFree()
    }
    
    /// Returns a Boolean value indicating whether the property has an attribute with the specified name.
    @_disfavoredOverload
    public func attributeValue(for name: Attribute.Name) -> String? {
        attributeValue(for: name.rawValue)
    }

    /// Returns a Boolean value indicating whether the property has an attribute with the specified name.
    public func hasAttribute(named name: String) -> Bool {
        attributeValue(for: name) != nil
    }
    
    /// Returns a Boolean value indicating whether the property has an attribute with the specified name.
    @_disfavoredOverload
    public func hasAttribute(named name: Attribute.Name) -> Bool {
        hasAttribute(named: name.rawValue)
    }

    /// The property's type encoding.
    public var typeEncoding: String? {
        attributeValue(for: "T")
    }

    /// A Boolean value indicating whether the property is read-only.
    public var isReadOnly: Bool {
        hasAttribute(named: "R")
    }

    /// A Boolean value indicating whether the property uses copy semantics.
    public var isCopy: Bool {
        hasAttribute(named: "C")
    }

    /// A Boolean value indicating whether the property uses strong or retain semantics.
    public var isStrong: Bool {
        hasAttribute(named: "&")
    }

    /// A Boolean value indicating whether the property is nonatomic.
    public var isNonatomic: Bool {
        hasAttribute(named: "N")
    }

    /// A Boolean value indicating whether the property is dynamic.
    public var isDynamic: Bool {
        hasAttribute(named: "D")
    }

    /// A Boolean value indicating whether the property uses weak semantics.
    public var isWeak: Bool {
        hasAttribute(named: "W")
    }

    /// A Boolean value indicating whether the property is eligible for garbage collection.
    public var isGarbageCollectable: Bool {
        hasAttribute(named: "P")
    }

    /// The property's old-style type encoding.
    public var oldTypeEncoding: String? {
        attributeValue(for: "t")
    }

    /// The name of the property's backing instance variable.
    public var ivarName: String? {
        attributeValue(for: "V")
    }

    /// The name of the getter method.
    public var getterName: String {
        attributeValue(for: "G") ?? name
    }

    /// The name of the setter method, or `nil` if the property is read-only.
    public var setterName: String? {
        guard !isReadOnly else { return nil }
        return attributeValue(for: "S") ?? "set\(name.uppercasedFirst()):"
    }
}
