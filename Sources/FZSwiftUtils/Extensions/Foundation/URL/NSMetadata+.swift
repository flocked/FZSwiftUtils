//
//  File.swift
//
//
//  Created by Florian Zand on 28.08.22.
//

import Foundation

extension NSMetadataItem {
    func value<T>(_ attribute: String, type _: T.Type) -> T? {
        return value(forAttribute: attribute) as? T
    }
}

public extension NSMetadataQuery {
    func values(of attributes: [String], forResultsAt index: Int) -> [String: Any] {
        var values = [String: Any]()
        attributes.forEach { values[$0] = value(ofAttribute: $0, forResultAt: index) }
        return values
    }
}
