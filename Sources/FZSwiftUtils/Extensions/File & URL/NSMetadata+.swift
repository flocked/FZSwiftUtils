//
//  NSMetadata+.swift
//
//
//  Created by Florian Zand on 28.08.22.
//

import Foundation

public extension NSMetadataItem {
    /**
     Returns the value of the specified attribute.

     - Parameter attribute: The name of a metadata attribute. See the “Constants” section for a list of possible keys.
     - Returns: Returns the value of the attribute or nil if the attribute couldn't be found.
     */
    func value<T>(for attribute: String) -> T? {
        value(forAttribute: attribute) as? T
    }
}

public extension NSMetadataQuery {
    /**
     Returns the values for the specified attribute names at the index in the results specified by `index`.

     - Parameters:
        - attributes: The attributes of the result object at index being inquired about. The attributes must be specified in valueListAttributes, as a sorting key in a specified sort descriptor, or as one of the grouping attributes specified set for the query.
        - index: The index of the desired return object in the query results array.

     - Returns: Values for the attributes in the result object at index in the query result array.
     */
    func values(of attributes: [String], forResultsAt index: Int) -> [String: Any] {
        var values = [String: Any]()
        attributes.forEach { values[$0] = value(ofAttribute: $0, forResultAt: index) }
        return values
    }
}
