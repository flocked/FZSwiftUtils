//
//  ObjCMethodInfo.swift
//
//
//  Created by p-x9 on 2024/06/23
//  
//

import Foundation

extension ObjCPropertyInfo {
    
}

/// Represents information about an Objective-C method.
public struct ObjCMethodInfo: Sendable, Equatable, Codable, Hashable {
    /// The name of the method.
    public let name: String
    /// The type information for the arguments and return value of the method.
    public let signature: ObjCMethodSignature
    /// A Boolean value indicating whatever the method is a class method.
    public let isClassMethod: Bool
    
    /*
    var className: String?
    
    static var originCache: [String: (imagePath: String?, categoryName: String?, symbolName: String?)] = [:]
    
    var origin: (imagePath: String?, categoryName: String?, symbolName: String?) {
        guard let clsName = className else { return (nil,nil,nil)  }
        let key = clsName+name
        if let cache = Self.originCache[key] {
            return cache
        } else if let cls = NSClassFromString(clsName), let method = (isClassMethod ? class_getClassMethod(cls, .string(name)) : class_getInstanceMethod(cls, .string(name))) {
            let origin = ObjCRuntime.origin(of: method)
            Self.originCache[key] = origin
            return origin
        }
        Self.originCache[key] = (nil, nil, nil)
        return (nil, nil, nil)
    }
     */
        
    /**
     Initializes a new instance of `ObjCMethodInfo`.

     - Parameters:
       - name: The name of the method.
       - typeEncoding: The type information for the return value and parameters of the method.
       - isClassMethod: A Boolean value that indicates whether the method is a class method.
     */
    public init(name: String, typeEncoding: String, isClassMethod: Bool) {
        self.name = name
        self.signature = ObjCMethodSignature(typeEncoding)
        self.isClassMethod = isClassMethod
    }

    /**
     Initializes a new instance of `ObjCMethodInfo` for the specified method.

     - Parameters:
       - method: The method of the target for which information is to be obtained.
       - isClassMethod: A Boolean value that indicates whether the method is a class method.
     */
    public init?(_ method: Method, isClassMethod: Bool = false) {
        guard let typeEncoding = method_getTypeEncoding(method)?.string else { return nil }
        self.init(name: NSStringFromSelector(method_getName(method)), typeEncoding: typeEncoding, isClassMethod: isClassMethod)
    }
    
    /**
     Initializes a new instance of `ObjCMethodInfo` for the specified method description.

     - Parameters:
       - description: The method description of the target for which information is to be obtained.
       - isClassMethod: A Boolean value that indicates whether the method is a class method.
     */
    public init?(_ description: objc_method_description, isClassMethod: Bool) {
        guard let name = description.name, let _typeEncoding = description.types else { return nil }
        self.init(name: NSStringFromSelector(name), typeEncoding: String(cString: _typeEncoding), isClassMethod: isClassMethod)
    }
}

extension ObjCMethodInfo {
    /// The argument types of the method.
    public var argumentTypes: [ObjCType] {
        signature.arguments.dropFirst(2).map({ $0.type })
    }
    
    /// The return type of the object.
    public var returnType: ObjCType {
        signature.returnValue.type
    }
}

extension ObjCMethodInfo: CustomStringConvertible {
    /// Returns a string representing the method in a Objective-C header.
    public var headerString: String {
        headerString(includeTypeEncoding: false, renameArguments: false)
    }
    
    /// Returns a string representing the method in a Objective-C header.
    public func headerString(includeTypeEncoding: Bool, renameArguments: Bool) -> String {
        let prefix = isClassMethod ? "+" : "-"
        let returnType = returnType.decodedStringForArgument
        let nameAndLabels = name.split(separator: ":")

        var result = "\(prefix) (\(returnType))"
        if argumentTypes.isEmpty {
            result += name
        } else {
            result += zip(nameAndLabels, argumentTypes.map(\.decodedStringForArgument))
                .enumerated()
                .map { "\($1.0):(\($1.1))\(renameArguments ? NamingIntelligent.parameterName(from: String($1.0)) : "arg\($0)")" }
                .joined(separator: " ")
        }
        result += ";"
        if includeTypeEncoding {
            result += " // \(signature.encoded)"
        }
        return result
    }
    
    public var description: String { headerString }
    
    func typeNames() -> (types: Set<String>, fields: Set<String>) {
        var typeNames: Set<String> = []
        var fieldNames: Set<String> = []
        var names = returnType.names()
        typeNames.insert(names.types)
        fieldNames.insert(names.fields)
        argumentTypes.forEach({
           names = $0.names()
            typeNames.insert(names.types)
            fieldNames.insert(names.fields)
        })
        return (typeNames, fieldNames)
    }
}

private enum NamingIntelligent {
    /// Common prepositions used in Objective-C method names (lowercase).
    /// Ordered by length (longest first) to match longer prepositions before shorter ones.
    private static let prepositions: [String] = [
        "withcontentsof",
        "byappending",
        "byreplacing",
        "fromstring",
        "tostring",
        "containing",
        "including",
        "excluding",
        "replacing",
        "returning",
        "matching",
        "starting",
        "between",
        "through",
        "without",
        "within",
        "during",
        "before",
        "behind",
        "except",
        "under",
        "using",
        "after",
        "about",
        "above",
        "along",
        "among",
        "below",
        "named",
        "called",
        "having",
        "where",
        "until",
        "since",
        "with",
        "from",
        "into",
        "onto",
        "upon",
        "over",
        "like",
        "near",
        "past",
        "for",
        "and",
        "but",
        "nor",
        "yet",
        "via",
        "per",
        "at",
        "by",
        "in",
        "of",
        "on",
        "to",
        "as",
    ]

    /// Prefixes that should be stripped before looking for prepositions.
    private static let prefixes: [String] = [
        "_set",
        "_get",
        "set",
        "get",
    ]

    /// Guesses a parameter name from an Objective-C method label.
    ///
    /// - Parameter label: The method label (e.g., "initWithTitle", "objectForKey")
    /// - Returns: The guessed parameter name (e.g., "title", "key")
    static func parameterName(from label: String) -> String {
        guard !label.isEmpty else { return "arg" }

        var workingLabel = label
        let lowercasedLabel = label.lowercased()

        // First, strip known prefixes like set/get
        for prefix in prefixes {
            if lowercasedLabel.hasPrefix(prefix) && label.count > prefix.count {
                let afterPrefix = label.index(label.startIndex, offsetBy: prefix.count)
                // Make sure the next character is uppercase (word boundary)
                if label[afterPrefix].isUppercase {
                    workingLabel = String(label[afterPrefix...])
                    break
                }
            }
        }

        // Now search for prepositions from the beginning, find the LAST match
        let lowercasedWorking = workingLabel.lowercased()
        var lastMatchEnd: String.Index?

        for preposition in prepositions {
            // Search for all occurrences from the beginning
            var searchStart = lowercasedWorking.startIndex
            while let range = lowercasedWorking.range(of: preposition, range: searchStart ..< lowercasedWorking.endIndex) {
                // Calculate the corresponding range in the working label
                let startDistance = lowercasedWorking.distance(from: lowercasedWorking.startIndex, to: range.lowerBound)
                let endDistance = lowercasedWorking.distance(from: lowercasedWorking.startIndex, to: range.upperBound)
                let originalStart = workingLabel.index(workingLabel.startIndex, offsetBy: startDistance)
                let originalEnd = workingLabel.index(workingLabel.startIndex, offsetBy: endDistance)

                // Check word boundary for camelCase:
                // 1. The preposition must start with uppercase (e.g., "With" in "initWithTitle")
                // 2. After: must be uppercase letter (the next word starts)
                let prepositionStartChar = workingLabel[originalStart]
                let startsWithUppercase = prepositionStartChar.isUppercase

                let hasValidEnd: Bool
                if originalEnd >= workingLabel.endIndex {
                    // Preposition at the end of the label is not valid
                    hasValidEnd = false
                } else {
                    let nextChar = workingLabel[originalEnd]
                    hasValidEnd = nextChar.isUppercase
                }

                if startsWithUppercase && hasValidEnd || (hasValidEnd && originalStart == workingLabel.startIndex) {
                    // Use the last (rightmost) preposition match
                    if lastMatchEnd == nil || originalEnd > lastMatchEnd! {
                        lastMatchEnd = originalEnd
                    }
                }

                // Move search start forward
                searchStart = range.upperBound
            }
        }

        // Extract the part after the last preposition
        if let end = lastMatchEnd {
            let afterPreposition = String(workingLabel[end...])
            if !afterPreposition.isEmpty {
                return afterPreposition.lowercasedFirst()
            }
        }

        // No preposition found, use the working label
        return workingLabel.lowercasedFirst()
    }
}
