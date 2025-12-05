//
//  CFDictionary+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

public extension CFDictionary {
    /// `NSDictionary` representation of the dictionary.
    var nsDictionary: NSDictionary {
        self as NSDictionary
    }
}
