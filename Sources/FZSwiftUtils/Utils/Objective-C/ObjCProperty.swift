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
        var count: UInt32 = 0
        guard let list = property_copyAttributeList(property, &count) else { return [] }
        defer { free(list) }
        return list.buffer(count: count).map({ Attribute(name: $0.name.string, value: $0.value.string) })
    }
    
    /// An attribute of a property.
    public struct Attribute {
        /// The name of the attribute.
        public let name: String
        /// The value of the attribute.
        public let value: String
    }
}
