//
//  NameDescribable.swift
//  NameDescribable
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public protocol NameDescribable {
    /// The name of this type.
    var typeName: String { get }
    /// The name of this type.
    static var typeName: String { get }
}

public extension NameDescribable {
    /// The name of this type.
    var typeName: String {
        return String(describing: type(of: self))
    }

    /// The name of this type.
    static var typeName: String {
        return String(describing: self)
    }
}

extension NSObject: NameDescribable {}
extension Array: NameDescribable {}
extension Dictionary: NameDescribable {}
extension Set: NameDescribable {}
