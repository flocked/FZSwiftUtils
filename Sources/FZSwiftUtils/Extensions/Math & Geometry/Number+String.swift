//
//  Number+String.swift
//  
//
//  Created by Florian Zand on 31.07.23.
//

import Foundation

public extension IntegerLiteralType {
    /// The string value.
    var string: String {
        String(self)
    }
}

public extension FloatLiteralType {
    /// The string value.
    var string: String {
        String(self)
    }
}

public extension CGFloat {
    /// The string value.
    var string: String {
        String(Float(self))
    }
}

public extension NSNumber {
    /// The integer string value.
    var intString: String {
        String(Int(truncating: self))
    }
    
    /// The string value.
    var string: String {
        String(Float(truncating: self))
    }
}
