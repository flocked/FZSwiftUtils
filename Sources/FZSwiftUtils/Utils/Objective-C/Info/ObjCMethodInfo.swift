//
//  ObjCMethodInfo.swift
//
//
//  Created by p-x9 on 2024/06/23
//  
//

import Foundation

/// Represents information about an Objective-C method.
public struct ObjCMethodInfo: Sendable, Equatable, Codable {
    /// The name of the method.
    public let name: String
    /// The type information for the return value and parameters of the method.
    public let type: ObjCMethodSignature
    /// A Boolean value indicating whatever the method is a class method or not.
    public let isClassMethod: Bool
        
    /**
     Initializes a new instance of `ObjCMethodInfo`.

     - Parameters:
       - name: The name of the method.
       - typeEncoding: The type information for the return value and parameters of the method.
       - isClassMethod: A Boolean value that indicates whether the method is a class method.
     */
    public init(name: String, typeEncoding: String, isClassMethod: Bool) {
        self.name = name
        self.type = ObjCMethodSignature(typeEncoding)
        self.isClassMethod = isClassMethod
    }

    /**
     Initializes a new instance of `ObjCMethodInfo` for the specified method.

     - Parameters:
       - method: The method of the target for which information is to be obtained.
       - isClassMethod: A Boolean value that indicates whether the method is a class method.
     */
    public init?(_ method: Method, isClassMethod: Bool) {
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
        type.arguments.map({ ObjCType($0.type) ?? .unknown })
    }
    
    /// The return type of the object.
    public var returnType: ObjCType {
        ObjCType(type.returnType) ?? .unknown
    }
}

extension ObjCMethodInfo: CustomStringConvertible {
    /// Returns a string representing the method in a Objective-C header.
    public var headerString: String {
        let prefix = isClassMethod ? "+" : "-"
        let returnType = returnType.decodedStringForArgument
        let nameAndLabels = name.split(separator: ":")
        guard nameAndLabels.count > 0 else {
            return "\(prefix) (\(returnType))\(name);"
        }
        var result = "\(prefix) (\(returnType))"
        result += zip(nameAndLabels, argumentTypes.map({$0.decodedStringForArgument})).enumerated().map({  "\($1.0):(\($1.1))arg\($0)" }).joined(separator: " ")
        result += ";"
        return result
    }
    
    public var description: String { headerString }
}
