//
//  NSKeyValueObservingOptions+.swift
//
//
//  Created by Florian Zand on 28.02.26.
//

import Foundation

extension NSKeyValueObservingOptions: CustomStringConvertible {
    public var description: String {
        "[\(elements().map({$0.string}).joined(separator: ", "))]"
    }
    
    private var string: String {
        switch self {
        case .initial: return "initial"
        case .new: return "new"
        case .old: return "old"
        case .prior: return "prior"
        default: return "\(rawValue)"
        }
    }
}
