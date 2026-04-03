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
        headerString(includeTypeEncoding: false)
    }
    
    /// Returns a string representing the method in a Objective-C header.
    public func headerString(includeTypeEncoding: Bool) -> String {
        let prefix = isClassMethod ? "+" : "-"
        let returnType = returnType.decodedStringForArgument
        let nameAndLabels = name.split(separator: ":")

        var result = "\(prefix) (\(returnType))"
        if argumentTypes.isEmpty {
            result += name
        } else {
            result += zip(nameAndLabels, argumentTypes.map(\.decodedStringForArgument))
                .enumerated()
                .map { "\($1.0):(\($1.1))arg\($0)" }
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
