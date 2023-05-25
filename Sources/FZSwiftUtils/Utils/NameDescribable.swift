//
//  NameDescribable.swift
//  NameDescribable
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}


public extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}

extension NSObject: NameDescribable {}
extension Array: NameDescribable {}
extension Dictionary: NameDescribable {}
extension Set: NameDescribable {}
