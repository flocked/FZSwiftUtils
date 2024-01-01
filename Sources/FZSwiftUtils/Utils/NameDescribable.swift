//
//  NameDescribable.swift
//  
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
    /// The name of this type.
    var typeName: String {
        return String(describing: type(of: self))
    }

    /// The name of this type.
    static var typeName: String {
        return String(describing: self)
    }
}

extension Array {
    /// The name of this type.
    var typeName: String {
        return String(describing: type(of: self))
    }

    /// The name of this type.
    static var typeName: String {
        return String(describing: self)
    }
}

extension Dictionary {
    /// The name of this type.
    var typeName: String {
        return String(describing: type(of: self))
    }

    /// The name of this type.
    static var typeName: String {
        return String(describing: self)
    }
}

extension Set {
    /// The name of this type.
    var typeName: String {
        return String(describing: type(of: self))
    }

    /// The name of this type.
    static var typeName: String {
        return String(describing: self)
    }
}
