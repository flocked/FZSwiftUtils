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
    /// The value as `String`.
    var string: String {
        String(self)
    }
}

public extension CGFloat {
    /// The value as `String`.
    var string: String {
        String(Float(self))
    }
}

public extension NSNumber {
    /// The value as Integer `String`.
    var intString: String {
        String(Int(truncating: self))
    }
    
    /// The value as Float `String`.
    var string: String {
        String(Float(truncating: self))
    }
}
