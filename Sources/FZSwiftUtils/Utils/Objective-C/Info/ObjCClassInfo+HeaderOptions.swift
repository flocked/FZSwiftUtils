//
//  ObjCClassInfo+HeaderOptions.swift
//
//
//  Created by Florian Zand on 03.04.26.
//

import Foundation

extension ObjCClassInfo {
    /// Options for the header string.
    public struct HeaderStringOptions: OptionSet {
        /**
         Properties include attributes that are normally implicit.
                  
         This adds attributes that Objective-C omits by default:
         - `readwrite` for writable properties
         - `atomic` for properties that are not `nonatomic`
         
         For example:
         
         ```objc
         @property(readWrite, atomic) CGSize itemSize;
         ```
         */
        public static let addImplicitPropertyAttributes = Self(rawValue: 1 << 0)
        
        /**
         Include inline comments for properties implemented using `@dynamic` and/or `@synthesize`.
                  
         For example:

         ```objc
         @property BOOL usesAutomaticRowHeights; // @dynamic usesAutomaticRowHeights
         ```
         */
        public static let addPropertyAttributesComments = Self(rawValue: 1 << 1)
        
        /// Adds type encoding comments to methods.
        public static let addMethodTypeEncodingComments = Self(rawValue: 1 << 5)
        
        /// Groups methods by library and category and add comments for each.
        public static let groupByOrigin = Self(rawValue: 1 << 2)
        
        /**
         Includes methods and properties defined in images other than the class's primary image.
         
         This exposes methods and properties implemented in linked frameworks or libraries.
         */
        public static let includeMethodsFromOtherImages = Self(rawValue: 1 << 3)
        
        /// Includes methods declared in Objective-C categories.
        public static let includeCategoryMethods = Self(rawValue: 1 << 4)
        
        /// Strips methods from the header that are synthesized from properties.
        public static let stripSynthesizedMethods = Self(rawValue: 1 << 6)
        
        /// Strips Ivars from the header that are synthesized from properties.
        public static let stripSynthesizedIvars = Self(rawValue: 1 << 10)
        
        /// Strips methods and properties from the header that are overrides from the superclass.
        public static let stripOverrides = Self(rawValue: 1 << 11)
        
        /// Strips methods and properties from the header that correspond to conforming protocols.
        public static let stripProtocolConformance = Self(rawValue: 1 << 9)
        
        /// Strips methods and properties from the are public.
        public static let stripPublic = Self(rawValue: 1 << 7)
        
        /// Strips Dtor method from the header string.
        public static let stripDtorMethod = Self(rawValue: 1 << 12)
        
        /// Strips CTor method from the header string.
        public static let stripCtorMethod = Self(rawValue: 1 << 13)

        /// Renames method arguments based on the method name.
        public static let renameMethodArguments = Self(rawValue: 1 << 14)

                

        /*
        /// Include instance variables of the class.
        public static let includeIvars = Self(rawValue: 1 << 6)
        /// Include protocols to which the class conforms.
        public static let includeProtocols = Self(rawValue: 1 << 7)
       /// Include class properties of the class.
        public static let includeClassProperties = Self(rawValue: 1 << 8)
        /// Include instance properties of the class.
        public static let includeInstanceProperties = Self(rawValue: 1 << 9)
        /// Include class and instance properties of the class.
        public static let includeProperties: Self = [.includeClassProperties, .includeInstanceProperties]
        /// Include class methods of the class.
        public static let includeClassMethods = Self(rawValue: 1 << 10)
        /// Include instance methods of the class.
        public static let includeInstanceMethods = Self(rawValue: 1 << 11)
        /// Include class and instance methods of the class.
        public static let includeMethods: Self = [.includeClassMethods, .includeInstanceMethods]
        */
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}
