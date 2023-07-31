//
//  Number+String.swift
//  
//
//  Created by Florian Zand on 31.07.23.
//

import Foundation

public extension IntegerLiteralType {
    var string: String {
        String(self)
    }
}

public extension FloatLiteralType {
    var string: String {
        String(self)
    }
}

public extension CGFloat {
    var string: String {
        String(Float(self))
    }
}
