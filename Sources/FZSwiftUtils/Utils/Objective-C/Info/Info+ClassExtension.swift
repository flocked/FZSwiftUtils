//
//  Info+ClassExtension.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 28.03.26.
//

import Foundation

extension ObjCMethodInfo {
    /**
     Returns a string that can be used to extend the specified class with this Objective-C method.

     The generated method resolves the runtime selector, looks up the underlying Objective-C method implementation, and invokes it using a typed function cast.
     It returns `nil` when the Objective-C return type can't be represented safely as a Swift type string, or when an argument type can't be represented safely and `includeUnknownArgumentTypes` is `false`.

     - Parameters:
       - class: The Swift class that should be extended in the generated string.
       - includeUnknownArgumentTypes: A Boolean value that indicates whether unresolved argument and return types should be emitted as Xcode placeholders so the generated code can be edited manually.
     - Returns: Swift source code for extending the class with this method, or `nil` if code generation isn't possible for this method signature.
     */
    public func classExtensionString(for class: AnyClass, includeUnknownArgumentTypes: Bool = false) -> String? {
        guard let string = _classExtensionString(for: `class`, includeUnknownArgumentTypes: includeUnknownArgumentTypes) else { return nil }
        return FZSwiftUtils.classExtensionString(for: NSStringFromClass(`class`), string: string)
    }
    
    fileprivate func _classExtensionString(for class: AnyClass, includeUnknownArgumentTypes: Bool = false) -> String? {
        guard let swiftReturnType = returnType.resolvedSwiftType ?? (includeUnknownArgumentTypes ? "<#T##Any#>" : nil) else { return nil }
        let swiftArguments = argumentTypes.compactMap({ $0.resolvedSwiftType ?? (includeUnknownArgumentTypes ? "<#T##Any#>" : nil) })
        guard swiftArguments.count == argumentTypes.count else { return nil }
        let selectorParts = name.split(separator: ":").map(String.init)
        let methodBaseName = selectorParts.first.map(swiftIdentifier(for:)) ?? swiftIdentifier(for: name)
        let parameterClauses = parameterClauses(selectorParts: selectorParts, swiftTypes: swiftArguments)
        let parameterNames = (0..<swiftArguments.count).map({ "arg\($0)" }).joined(separator: ", ")
        let className = NSStringFromClass(`class`)
        let receiverType = isClassMethod ? "\(className).Type" : className
        let receiverValue = isClassMethod ? "self" : "self"
        let methodLookup = isClassMethod ? "class_getClassMethod(self, selector)" : "class_getInstanceMethod(type(of: self), selector)"
        let functionKeyword = isClassMethod ? "class func" : "func"
        let signatureSuffix = swiftReturnType == "Void" ? " throws" : " throws -> \(swiftReturnType)"
        let invocationArguments = parameterNames.isEmpty ? "" : ", \(parameterNames)"
        let returnStatement = swiftReturnType == "Void" ? "" : "return "
        let functionTypeArguments = ([receiverType, "Selector"] + swiftArguments).joined(separator: ", ")

        return """
        \(functionKeyword) \(methodBaseName)\(parameterClauses)\(signatureSuffix) {
            let selector = NSSelectorFromString("\(name)")
            typealias Function = @convention(c) (\(functionTypeArguments)) -> \(swiftReturnType)
            guard let method = \(methodLookup) else {
                throw RuntimeError("Method \\(selector) not found on \(className)")
            }
            let imp = method_getImplementation(method)
            let function = unsafeBitCast(imp, to: Function.self)
            \(returnStatement)function(\(receiverValue), selector\(invocationArguments))
        }
        """
    }
    
    /**
     Returns Swift source code for an extension on the specified class that adds a throwing helper returning a Swift closure for this Objective-C method.

     The generated helper performs the runtime selector lookup once, converts the Objective-C implementation pointer into a typed C function, and returns a Swift closure that takes the receiver and method arguments while handling the selector internally.
     Returns `nil` when the Objective-C return type can't be represented safely as a Swift type string, or when an argument type can't be represented safely and `includeUnknownArgumentTypes` is `false`.

     - Parameters:
       - class: The Swift class the generated extension should target.
       - includeUnknownArgumentTypes: A Boolean value that indicates whether unresolved argument and return types should be emitted as Xcode placeholders so the generated code can be edited manually.
     - Returns: Swift source code for the closure-producing helper, or `nil` if code generation isn't possible for this method signature.
     */
    public func functionString(for class: AnyClass, includeUnknownArgumentTypes: Bool = false) -> String? {
        guard let swiftReturnType = returnType.resolvedSwiftType ?? (includeUnknownArgumentTypes ? "<#T##Any#>" : nil) else { return nil }
        let swiftArguments = argumentTypes.compactMap({ $0.resolvedSwiftType ?? (includeUnknownArgumentTypes ? "<#T##Any#>" : nil) })
        guard swiftArguments.count == argumentTypes.count else { return nil }
        let className = NSStringFromClass(`class`)
        let methodBaseName = swiftIdentifier(for: name.split(separator: ":").first.map(String.init) ?? name)
        let receiverType = isClassMethod ? "\(className).Type" : className
        let functionTypeArguments = ([receiverType, "Selector"] + swiftArguments).joined(separator: ", ")
        let closureTypeArguments = ([receiverType] + swiftArguments).joined(separator: ", ")
        let methodLookup = isClassMethod ? "class_getClassMethod(self, selector)" : "class_getInstanceMethod(self, selector)"
        let functionKeyword = isClassMethod ? "class func" : "static func"
        let closureParameters = closureParameters(receiverType: receiverType, swiftTypes: swiftArguments)
        let invocationArguments = closureInvocationArguments(argumentCount: swiftArguments.count)

        return """
        extension \(className) {
            \(functionKeyword) \(methodBaseName)Function() throws -> (\(closureTypeArguments)) -> \(swiftReturnType) {
                let selector = NSSelectorFromString("\(name)")
                typealias Function = @convention(c) (\(functionTypeArguments)) -> \(swiftReturnType)
                guard let method = \(methodLookup) else {
                    throw RuntimeError("Method \\(selector) not found on \(className)")
                }
                let imp = method_getImplementation(method)
                let function = unsafeBitCast(imp, to: Function.self)
                return { \(closureParameters) in
                    function(\(invocationArguments))
                }
            }
        }
        """
    }

    private func parameterClauses(selectorParts: [String], swiftTypes: [String]) -> String {
        guard !swiftTypes.isEmpty else { return "()" }
        return zip(swiftTypes.indices, swiftTypes).map { index, swiftType in
            let parameterName = "arg\(index)"
            let label: String
            if index == 0 {
                label = "_"
            } else {
                label = index < selectorParts.count ? swiftIdentifier(for: selectorParts[index]) : "_"
            }
            return "\(index == 0 ? "(" : ", ")\(label) \(parameterName): \(swiftType)"
        }.joined() + ")"
    }

    private func closureParameters(receiverType: String, swiftTypes: [String]) -> String {
        let parameters = [("object", receiverType)] + swiftTypes.enumerated().map { ("arg\($0.offset)", $0.element) }
        return parameters.map({ "\($0.0): \($0.1)" }).joined(separator: ", ")
    }

    private func closureInvocationArguments(argumentCount: Int) -> String {
        let arguments = ["object", "selector"] + (0..<argumentCount).map({ "arg\($0)" })
        return arguments.joined(separator: ", ")
    }
}

extension ObjCPropertyInfo {
    /**
     Returns Swift source code for an extension on the specified class that exposes this Objective-C property as a computed Swift property.

     The generated property uses `value(forKey:)` for reading and `setValue(safely:forKey:)` for writing, so custom Objective-C accessor behavior is preserved.
     Object-like properties are emitted as optional properties. Scalar properties are emitted as non-optional properties with a guarded getter.

     - Parameters:
       - class: The Swift class the generated extension should target.
       - handleUnknownType: A Boolean value that indicates whether unresolved property types should be emitted as Xcode placeholders so the generated code can be edited manually.
     - Returns: Swift source code for the computed property, or `nil` if code generation isn't possible for this property.
     */
    public func classExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        guard let string = _classExtensionString(for: `class`, handleUnknownType: handleUnknownType) else { return nil }
        return FZSwiftUtils.classExtensionString(for: NSStringFromClass(`class`), string: string)
    }
    
    fileprivate func _classExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        // 1. Resolve the base type or return nil/placeholder
        guard let baseType = type.resolvedSwiftType ?? (handleUnknownType ? "<#T##Any#>" : nil) else { return nil }
        
        let propertyName = swiftIdentifier(for: name)
        let isOptional = type.isObjectLike
        let propertyType = isOptional ? "\(baseType)?" : baseType
        let keyword = isClassProperty ? "class var" : "var"

        // 2. Generate the internal logic for fetching the value
        let coreLogic: String
        if isOptional {
            coreLogic = "value(forKey: \"\(name)\")"
        } else {
            coreLogic = """
                guard let value: \(baseType) = value(forKey: "\(name)") else {
                    fatalError("Failed to read property \(name)")
                }
                return value
            """
        }

        // 3. Assemble the final string
        if isReadOnly {
            return "\(keyword) \(propertyName): \(propertyType) {\n\(coreLogic)\n}"
        } else {
            return """
            \(keyword) \(propertyName): \(propertyType) {
                get { 
            \(coreLogic) 
                }
                set { setValue(safely: newValue, forKey: "\(name)") }
            }
            """
        }
    }
}

extension ObjCIvarInfo {
    /**
     Returns Swift source code for an extension on the specified class that exposes this Objective-C ivar as a computed Swift property.

     The generated property uses `ivarValue(named:)` for reading and `setIvarValue(_:named:)` for writing.
     Object-like ivars are emitted as optional properties with nil-aware setters. Scalar ivars are emitted as non-optional properties with a guarded getter.

     - Parameters:
       - class: The Swift class the generated extension should target.
       - handleUnknownType: A Boolean value that indicates whether unresolved ivar types should be emitted as Xcode placeholders so the generated code can be edited manually.
     - Returns: Swift source code for the computed property, or `nil` if code generation isn't possible for this ivar.
     */
    public func classExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        guard let string = _classExtensionString(for: `class`, handleUnknownType: handleUnknownType) else { return nil }
        return FZSwiftUtils.classExtensionString(for: NSStringFromClass(`class`), string: string)
    }
    
    fileprivate func _classExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        guard let baseType = type?.resolvedSwiftType ?? (handleUnknownType ? "<#T##Any#>" : nil) else { return nil }
        let propertyName = swiftIdentifier(for: name)
        let isOptional = type?.isObjectLike == true
        let propertyType = isOptional ? "\(baseType)?" : baseType
        let getter = getterString(propertyType: baseType, isOptional: isOptional)
        return """
        var \(propertyName): \(propertyType) {
        \(getter)
            set { setIvarValue(newValue, named: "\(name)") }
        }
        """
    }

    private func getterString(propertyType: String, isOptional: Bool) -> String {
        if isOptional {
            return "    get { ivarValue(named: \"\(name)\") }"
        }
        return """
            get { 
                guard let value: \(propertyType) = ivarValue(named: "\(name)") else {
                    fatalError("Failed to read ivar \(name)")
                }
                return value
            }
        """
    }
}

extension ObjCClassInfo {
    public func classExtensionString(forMethods methods: Set<String> = [], classMethods: Set<String> = [], properties: Set<String> = [], classProperties: Set<String> = [], ivars: Set<String> = [], handleUnknownTypes: Bool = false) -> String? {
        guard let cls: AnyClass = NSClassFromString(name) else { return nil }
        
        var strings = self.properties.filter({properties.contains($0.name)}).compactMap({$0._classExtensionString(for: cls, handleUnknownType: handleUnknownTypes)})
        strings += self.classProperties.filter({classProperties.contains($0.name)}).compactMap({$0._classExtensionString(for: cls, handleUnknownType: handleUnknownTypes)})
        strings += self.methods.filter({methods.contains($0.name)}).compactMap({$0._classExtensionString(for: cls, includeUnknownArgumentTypes: handleUnknownTypes)})
        strings += self.classMethods.filter({classMethods.contains($0.name)}).compactMap({$0._classExtensionString(for: cls, includeUnknownArgumentTypes: handleUnknownTypes)})
        strings += self.ivars.filter({ivars.contains($0.name)}).compactMap({$0._classExtensionString(for: cls, handleUnknownType: handleUnknownTypes)})
        guard !strings.isEmpty else { return nil }
        return FZSwiftUtils.classExtensionString(for: NSStringFromClass(cls), string: strings.joined(separator: "\n\n"))
    }
}

fileprivate func classExtensionString(for className: String, string: String) -> String {
    """
    extension \(className) {
    \(string.lines.map({ "\t" + $0 }).joined(separator: "\n"))
    }
    """
}

fileprivate let swiftKeywords: Set<String> = [
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
    "func", "import", "init", "inout", "internal", "let", "open", "operator",
    "private", "precedencegroup", "protocol", "public", "rethrows", "static",
    "struct", "subscript", "typealias", "var", "break", "case", "catch",
    "continue", "default", "defer", "do", "else", "fallthrough", "for",
    "guard", "if", "in", "repeat", "return", "throw", "switch", "where",
    "while", "as", "Any", "false", "is", "nil", "self", "Self", "super",
    "throws", "true", "try"
]

fileprivate func swiftIdentifier(for string: String) -> String {
    let cleanedScalars = string.unicodeScalars.map { scalar -> Character in
        if CharacterSet.alphanumerics.contains(scalar) || scalar == "_" {
            return Character(scalar)
        }
        return "_"
    }
    var identifier = String(cleanedScalars)
    if identifier.isEmpty { identifier = "_" }
    if identifier.first?.isNumber == true {
        identifier = "_" + identifier
    }
    if swiftKeywords.contains(identifier) {
        identifier = "`\(identifier)`"
    }
    return identifier
}

fileprivate extension ObjCType {
    var isObjectLike: Bool {
        isObject || self == .class || self == .selector || isBlock
    }
    
    var resolvedSwiftType: String? {
        switch self {
        case .class: return "AnyClass"
        case .selector: return "Selector"
        case .char: return "Int8"
        case .uchar: return "UInt8"
        case .short: return "Int16"
        case .ushort: return "UInt16"
        case .int: return "Int32"
        case .uint: return "UInt32"
        case .long: return "Int"
        case .ulong: return "UInt"
        case .longLong: return "Int64"
        case .ulongLong: return "UInt64"
        case .int128: return "Int128"
        case .uint128: return "UInt128"
        case .float: return "Float"
        case .double: return "Double"
        case .longDouble: return "Float80"
        case .bool: return "Bool"
        case .void, .voidConst, .voidIn: return "Void"
        case .charPtr:
            return modifiers.contains(.const) ? "UnsafePointer<CChar>" : "UnsafeMutablePointer<CChar>"
        case .object(let name):
            return swiftTypeName ?? name ?? "AnyObject"
        case .block(let returnType, let args):
            let argsString = args?.compactMap(\.resolvedSwiftType).joined(separator: ", ") ?? ""
            let returnString = returnType?.resolvedSwiftType ?? "Void"
            return "(@escaping (\(argsString)) -> \(returnString))"
        case .functionPointer: return "UnsafeRawPointer"
        case .pointer(let type): 
            return type.resolvedSwiftType.map { "UnsafeMutablePointer<\($0)>" }
        case .struct(let name, _):
            return name
        case .atom, .unknown, .other, .union, .bitField, .array:
            return nil
        case .modified(_, type: _):
            let resolved = resolved
            return resolved != .charPtr ? resolved.resolvedSwiftType : modifiers.contains(.const) ? "UnsafePointer<CChar>" : "UnsafeMutablePointer<CChar>"
        }
    }
}

fileprivate extension String {
    func indented(by count: Int) -> String {
        indented(by: Array(repeating: "\t", count: count.clamped(min: 0)).joined())
    }
    func indented(by indentation: String) -> String {
        lines.map({ indentation + $0 }).joined(separator: "\n")
    }
}
