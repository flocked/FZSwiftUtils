//
//  CSSearchableItem+.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

#if canImport(CoreSpotlight) && (os(macOS) || os(iOS))
import Foundation
import CoreSpotlight
import UniformTypeIdentifiers

@available(macOS 10.11, iOS 9.0, *)
extension CSSearchableItem {
    /**
     Adds or updates the item of the sequence to the specified searchable index.
     
     - Parameters:
        - searchableIndex: The searchable index to add or update the items.
        - completionHander: The block that’s called when the data has been journaled by the index, which means that the index makes a note that it has to perform this operation. If the completion handler returns an error, it means that the data wasn’t journaled correctly and the client should retry the request.
     */
    public func index(using searchableIndex: CSSearchableIndex = .default(), completionHandler: (((any Error)?) -> Void)? = nil) {
        searchableIndex.indexSearchableItems([self], completionHandler: completionHandler)
    }
}

@available(macOS 10.11, iOS 9.0, *)
extension Sequence where Element == CSSearchableItem {
    /**
     Adds or updates the items of the sequence to the specified searchable index.
     
     - Parameters:
        - searchableIndex: The searchable index to add or update the items.
        - completionHander: The block that’s called when the data has been journaled by the index, which means that the index makes a note that it has to perform this operation. If the completion handler returns an error, it means that the data wasn’t journaled correctly and the client should retry the request.
     */
    public func index(using searchableIndex: CSSearchableIndex = .default(), completionHandler: (((any Error)?) -> Void)? = nil) {
        searchableIndex.indexSearchableItems(Array(self), completionHandler: completionHandler)
    }
}

@available(macOS 11.0, iOS 14.0, *)
extension CSSearchableItemAttributeSet {
    /**
     Creates an attribute set for the file at the specified URL.
     
     - Returns: An attribute set, or `nil` if the content type of the file couldn't be determinated.
     */
    public convenience init?(fileURL: URL) {
        guard let contentType = fileURL.contentType else { return nil }
        self.init(contentType: contentType)
        contentURL = fileURL
    }
}
#endif
