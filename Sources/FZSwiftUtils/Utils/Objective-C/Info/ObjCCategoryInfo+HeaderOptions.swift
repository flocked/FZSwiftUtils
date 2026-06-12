//
//  ObjCCategoryInfo+HeaderOptions.swift
//  FZSwiftUtils
//

import Foundation

extension ObjCCategoryInfo {
    /// Options for the category header string.
    public struct HeaderStringOptions: OptionSet {
        /**
         Properties include attributes that are normally implicit.

         This adds `readwrite` for writable properties and `atomic` for
         properties that are not `nonatomic`.
         */
        public static let addImplicitPropertyAttributes = Self(rawValue: 1 << 0)

        /// Includes inline comments for properties declared as `@dynamic` or `@synthesize`.
        public static let addPropertyAttributesComments = Self(rawValue: 1 << 1)

        /// Adds type encoding comments to methods.
        public static let addMethodTypeEncodingComments = Self(rawValue: 1 << 2)

        /// Renames method arguments based on the method name.
        public static let renameMethodArguments = Self(rawValue: 1 << 3)

        /// Includes the fields of structures and unions.
        public static let includeStructAndUnionFields = Self(rawValue: 1 << 4)

        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}
