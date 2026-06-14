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
    public func swiftExtensionString(for class: AnyClass, includeUnknownArgumentTypes: Bool = false, isThrowing: Bool = true) -> String? {
        guard let string = _swiftExtensionString(for: `class`, includeUnknownArgumentTypes: includeUnknownArgumentTypes, isThrowing: isThrowing) else { return nil }
        return FZSwiftUtils.swiftExtensionString(for: NSStringFromClass(`class`), string: string)
    }
    
    fileprivate func _swiftExtensionString(for class: AnyClass, includeUnknownArgumentTypes: Bool = false, isThrowing: Bool = true) -> String? {
        guard let swiftReturnType = returnType.resolvedSwiftType ?? (includeUnknownArgumentTypes ? "<#T##Any#>" : nil) else { return nil }
        let swiftArguments = argumentTypes.compactMap({ $0.resolvedSwiftType ?? (includeUnknownArgumentTypes ? "<#T##Any#>" : nil) })
        guard swiftArguments.count == argumentTypes.count else { return nil }
        let selectorParts = name.split(separator: ":").map(String.init)
        let methodBaseName = selectorParts.first.map(swiftIdentifier(for:)) ?? swiftIdentifier(for: name)
        let parameterNames = parameterNames(selectorParts: selectorParts)
        let parameterClauses = parameterClauses(selectorParts: selectorParts, parameterNames: parameterNames, swiftTypes: swiftArguments)
        let className = NSStringFromClass(`class`)
        let receiverType = isClassMethod ? "\(className).Type" : className
        let receiverValue = isClassMethod ? "self" : "self"
        let methodLookup = isClassMethod ? "class_getClassMethod(self, selector)" : "class_getInstanceMethod(type(of: self), selector)"
        let functionKeyword = isClassMethod ? "class func" : "func"
        let signatureSuffix = swiftReturnType == "Void" ? (isThrowing ? " throws" : "") : (isThrowing ? " throws -> \(swiftReturnType)" : " -> \(swiftReturnType)?")
        let invocationArguments = parameterNames.isEmpty ? "" : ", \(parameterNames.joined(separator: ", "))"
        let returnStatement = swiftReturnType == "Void" ? "" : "return "
        let functionTypeArguments = ([receiverType, "Selector"] + swiftArguments).joined(separator: ", ")
        let noSelectorReturn = isThrowing ? "throw RuntimeError(\"Method \\(selector) not found on \(className)\")" : "return nil"
        return """
        \(functionKeyword) \(methodBaseName)\(parameterClauses)\(signatureSuffix) {
            let selector = NSSelectorFromString("\(name)")
            typealias Function = @convention(c) (\(functionTypeArguments)) -> \(swiftReturnType)
            guard let method = \(methodLookup) else {
                \(noSelectorReturn)
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

    private func parameterNames(selectorParts: [String]) -> [String] {
        var takenNames: Set<String> = []
        return argumentTypes.indices.map { index in
            let headerName = signature.arguments[index + 2].name.flatMap { $0.isEmpty ? nil : $0 }
            if let headerName {
                let identifier = swiftIdentifier(for: headerName)
                if takenNames.insert(identifier).inserted {
                    return identifier
                }
            }
            let selectorPart = selectorParts.indices.contains(index) ? selectorParts[index] : "arg"
            return swiftIdentifier(for: NamingIntelligent.parameterName(from: selectorPart, takenNames: &takenNames))
        }
    }

    private func parameterClauses(selectorParts: [String], parameterNames: [String], swiftTypes: [String]) -> String {
        guard !swiftTypes.isEmpty else { return "()" }
        return zip(swiftTypes.indices, swiftTypes).map { index, swiftType in
            let parameterName = parameterNames[index]
            let label: String
            if index == 0 {
                label = "_"
            } else {
                label = index < selectorParts.count ? swiftIdentifier(for: selectorParts[index]) : "_"
            }
            let parameter: String
            if index > 0, label == parameterName {
                parameter = "\(label): \(swiftType)"
            } else {
                parameter = "\(label) \(parameterName): \(swiftType)"
            }
            return "\(index == 0 ? "(" : ", ")\(parameter)"
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
    public func swiftExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        guard let string = _swiftExtensionString(for: `class`, handleUnknownType: handleUnknownType) else { return nil }
        return FZSwiftUtils.swiftExtensionString(for: NSStringFromClass(`class`), string: string)
    }

    @available(*, deprecated, renamed: "swiftExtensionString(for:handleUnknownType:)")
    public func classExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        swiftExtensionString(for: `class`, handleUnknownType: handleUnknownType)
    }
    
    fileprivate func _swiftExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        guard let baseType = type.resolvedSwiftType ?? (handleUnknownType ? "<#T##Any#>" : nil) else { return nil }
        let propertyName = swiftIdentifier(for: name)
        let isOptional = type.isObjectLike
        let propertyType = isOptional ? "\(baseType)?" : baseType
        let declarationKeyword = isClassProperty ? "class var" : "var"
        let getter = getterString(propertyType: baseType, isOptional: isOptional, readOnly: isReadOnly)

        if isReadOnly {
            return """
        \(declarationKeyword) \(propertyName): \(propertyType) {
        \(getter)
        }
        """
        }
        return """
        \(declarationKeyword) \(propertyName): \(propertyType) {
        \(getter)
            set { setValue(safely: newValue, forKey: "\(name)") }
        }
        """
    }
    
    func getterString(propertyType: String, isOptional: Bool, readOnly: Bool) -> String {
        readOnly ?  getterStringReadOnly(propertyType: propertyType, isOptional: isOptional) : getterString(propertyType: propertyType, isOptional: isOptional)
    }

    private func getterString(propertyType: String, isOptional: Bool) -> String {
        if isOptional {
            return "    get { value(forKey: \"\(name)\") }"
        }
        return """
            get {
                guard let value: \(propertyType) = value(forKey: "\(name)") else {
                    fatalError("Failed to read property \(name)")
                }
                return value
            }
        """
    }
    
    private func getterStringReadOnly(propertyType: String, isOptional: Bool) -> String {
        if isOptional {
            return "    value(forKey: \"\(name)\")"
        }
        return """
            guard let value: \(propertyType) = value(forKey: "\(name)") else {
                fatalError("Failed to read property \(name)")
            }
            return value
        """
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
    public func swiftExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        guard let string = _swiftExtensionString(for: `class`, handleUnknownType: handleUnknownType) else { return nil }
        return FZSwiftUtils.swiftExtensionString(for: NSStringFromClass(`class`), string: string)
    }

    @available(*, deprecated, renamed: "swiftExtensionString(for:handleUnknownType:)")
    public func classExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
        swiftExtensionString(for: `class`, handleUnknownType: handleUnknownType)
    }
    
    fileprivate func _swiftExtensionString(for class: AnyClass, handleUnknownType: Bool = false) -> String? {
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
    public func swiftExtensionString(forMethods methods: Set<String> = [], classMethods: Set<String> = [], properties: Set<String> = [], classProperties: Set<String> = [], ivars: Set<String> = [], handleUnknownTypes: Bool = false) -> String? {
        guard let cls: AnyClass = NSClassFromString(name) else { return nil }
        
        var strings = self.properties.filter({properties.contains($0.name)}).compactMap({$0._swiftExtensionString(for: cls, handleUnknownType: handleUnknownTypes)})
        strings += self.classProperties.filter({classProperties.contains($0.name)}).compactMap({$0._swiftExtensionString(for: cls, handleUnknownType: handleUnknownTypes)})
        strings += self.methods.filter({methods.contains($0.name)}).compactMap({$0._swiftExtensionString(for: cls, includeUnknownArgumentTypes: handleUnknownTypes)})
        strings += self.classMethods.filter({classMethods.contains($0.name)}).compactMap({$0._swiftExtensionString(for: cls, includeUnknownArgumentTypes: handleUnknownTypes)})
        strings += self.ivars.filter({ivars.contains($0.name)}).compactMap({$0._swiftExtensionString(for: cls, handleUnknownType: handleUnknownTypes)})
        guard !strings.isEmpty else { return nil }
        return FZSwiftUtils.swiftExtensionString(for: NSStringFromClass(cls), string: strings.joined(separator: "\n\n"))
    }

    /// Returns Swift source code for an Objective-C protocol containing the selected methods and properties.
    public func swiftProtocolString(forMethods methods: Set<String> = [], classMethods: Set<String> = [], properties: Set<String> = [], classProperties: Set<String> = [], handleUnknownTypes: Bool = false) -> String? {
        let publicMembers = publicHeaderMemberNames
        let selectedProperties = self.properties.filter {
            properties.contains($0.name) && !publicMembers.properties.contains($0.name)
        }
        let selectedClassProperties = self.classProperties.filter {
            classProperties.contains($0.name) && !publicMembers.classProperties.contains($0.name)
        }
        let propertyAccessorNames = Set((selectedProperties + selectedClassProperties).flatMap { property in
            [property.getterName, property.setterName].compactMap { $0 }
        })

        var propertyRequirements = selectedProperties.compactMap { $0._swiftProtocolRequirement(handleUnknownType: handleUnknownTypes) }
        propertyRequirements += selectedClassProperties.compactMap { $0._swiftProtocolRequirement(handleUnknownType: handleUnknownTypes) }
        var methodRequirements = self.methods
            .filter {
                methods.contains($0.name)
                    && !publicMembers.methods.contains($0.name)
                    && !publicMembers.propertyAccessors.contains($0.name)
                    && !propertyAccessorNames.contains($0.name)
            }
            .compactMap { $0._swiftProtocolRequirement(handleUnknownTypes: handleUnknownTypes) }
        methodRequirements += self.classMethods
            .filter {
                classMethods.contains($0.name)
                    && !publicMembers.classMethods.contains($0.name)
                    && !publicMembers.classPropertyAccessors.contains($0.name)
                    && !propertyAccessorNames.contains($0.name)
            }
            .compactMap { $0._swiftProtocolRequirement(handleUnknownTypes: handleUnknownTypes) }
        guard !propertyRequirements.isEmpty || !methodRequirements.isEmpty else { return nil }

        let protocolName = swiftIdentifier(for: "\(name)Protocol")
        let groups = [propertyRequirements, methodRequirements]
            .filter { !$0.isEmpty }
            .map { $0.map { $0.indented(by: 1) }.joined(separator: "\n") }
        let body = groups.joined(separator: "\n\n")
        return """
        @objc protocol \(protocolName): NSObjectProtocol {
        \(body)
        }

        if let cls = NSClassFromString("\(name)") {
            class_addProtocol(cls, \(protocolName).self)
        }
        """
    }

    private var publicHeaderMemberNames: (
        properties: Set<String>,
        classProperties: Set<String>,
        methods: Set<String>,
        classMethods: Set<String>,
        propertyAccessors: Set<String>,
        classPropertyAccessors: Set<String>
    ) {
        guard let header = ObjCHeader.getClass(named: name) else {
            return ([], [], [], [], [], [])
        }

        func accessorNames(for properties: [ObjCHeader.Property]) -> Set<String> {
            Set(properties.flatMap { property -> [String] in
                let getter = property.attributes
                    .first { $0.hasPrefix("getter=") }?
                    .dropFirst("getter=".count)
                    .description ?? property.name
                guard !property.attributes.contains("readonly") else { return [getter] }
                let setter = property.attributes
                    .first { $0.hasPrefix("setter=") }?
                    .dropFirst("setter=".count)
                    .description ?? "set\(property.name.uppercasedFirst()):"
                return [getter, setter]
            })
        }

        return (
            Set(header.properties.map(\.name)),
            Set(header.classProperties.map(\.name)),
            Set(header.methods.map(\.name)),
            Set(header.classMethods.map(\.name)),
            accessorNames(for: header.properties),
            accessorNames(for: header.classProperties)
        )
    }
}

extension ObjCProtocolInfo {
    /// Returns Swift source code for an Objective-C protocol containing the selected requirements.
    public func swiftProtocolString(forMethods methods: Set<String> = [], classMethods: Set<String> = [], properties: Set<String> = [], classProperties: Set<String> = [], handleUnknownTypes: Bool = false) -> String? {
        let requiredProperties = self.properties.filter { properties.contains($0.name) }
        let requiredClassProperties = self.classProperties.filter { classProperties.contains($0.name) }
        let optionalProperties = self.optionalProperties.filter { properties.contains($0.name) }
        let optionalClassProperties = self.optionalClassProperties.filter { classProperties.contains($0.name) }
        let selectedProperties = requiredProperties + requiredClassProperties + optionalProperties + optionalClassProperties
        let propertyAccessorNames = Set(selectedProperties.flatMap { [$0.getterName, $0.setterName].compactMap { $0 } })

        var propertyRequirements = requiredProperties.compactMap { $0._swiftProtocolRequirement(handleUnknownType: handleUnknownTypes) }
        propertyRequirements += requiredClassProperties.compactMap { $0._swiftProtocolRequirement(handleUnknownType: handleUnknownTypes) }
        propertyRequirements += optionalProperties.compactMap { $0._swiftProtocolRequirement(handleUnknownType: handleUnknownTypes, isOptional: true) }
        propertyRequirements += optionalClassProperties.compactMap { $0._swiftProtocolRequirement(handleUnknownType: handleUnknownTypes, isOptional: true) }

        var methodRequirements = self.methods
            .filter { methods.contains($0.name) && !propertyAccessorNames.contains($0.name) }
            .compactMap { $0._swiftProtocolRequirement(handleUnknownTypes: handleUnknownTypes) }
        methodRequirements += self.classMethods
            .filter { classMethods.contains($0.name) && !propertyAccessorNames.contains($0.name) }
            .compactMap { $0._swiftProtocolRequirement(handleUnknownTypes: handleUnknownTypes) }
        methodRequirements += optionalMethods
            .filter { methods.contains($0.name) && !propertyAccessorNames.contains($0.name) }
            .compactMap { $0._swiftProtocolRequirement(handleUnknownTypes: handleUnknownTypes, isOptional: true) }
        methodRequirements += optionalClassMethods
            .filter { classMethods.contains($0.name) && !propertyAccessorNames.contains($0.name) }
            .compactMap { $0._swiftProtocolRequirement(handleUnknownTypes: handleUnknownTypes, isOptional: true) }
        guard !propertyRequirements.isEmpty || !methodRequirements.isEmpty else { return nil }

        let protocolName = swiftIdentifier(for: "\(name)Protocol")
        let groups = [propertyRequirements, methodRequirements]
            .filter { !$0.isEmpty }
            .map { $0.map { $0.indented(by: 1) }.joined(separator: "\n") }
        return """
        @objc protocol \(protocolName): NSObjectProtocol {
        \(groups.joined(separator: "\n\n"))
        }
        """
    }
}

private extension ObjCPropertyInfo {
    func _swiftProtocolRequirement(handleUnknownType: Bool, isOptional: Bool = false) -> String? {
        guard let baseType = type.resolvedSwiftType ?? (handleUnknownType ? "<#T##Any#>" : nil) else { return nil }
        let propertyType = type.isObjectLike ? "\(baseType)?" : baseType
        let declaration = isClassProperty ? "static var" : "var"
        let accessors = isReadOnly ? "get" : "get set"
        return "\(isOptional ? "@objc optional " : "")\(declaration) \(swiftIdentifier(for: name)): \(propertyType) { \(accessors) }"
    }
}

private extension ObjCMethodInfo {
    func _swiftProtocolRequirement(handleUnknownTypes: Bool, isOptional: Bool = false) -> String? {
        let fallback = handleUnknownTypes ? "<#T##Any#>" : nil
        guard let resolvedReturnType = returnType.resolvedSwiftType ?? fallback else { return nil }
        let swiftTypes = argumentTypes.compactMap { $0.resolvedSwiftType ?? fallback }
        guard swiftTypes.count == argumentTypes.count else { return nil }

        let selectorParts = name.split(separator: ":").map(String.init)
        let methodName = swiftIdentifier(for: selectorParts.first ?? name)
        var takenNames = Set<String>()
        let parameters = swiftTypes.indices.map { index -> String in
            let headerName = signature.arguments[index + 2].name.flatMap { $0.isEmpty ? nil : $0 }
            let parameterName: String
            if let headerName {
                let identifier = swiftIdentifier(for: headerName)
                parameterName = takenNames.insert(identifier).inserted
                    ? identifier
                    : swiftIdentifier(for: NamingIntelligent.parameterName(from: selectorParts.indices.contains(index) ? selectorParts[index] : "arg", takenNames: &takenNames))
            } else {
                parameterName = swiftIdentifier(for: NamingIntelligent.parameterName(from: selectorParts.indices.contains(index) ? selectorParts[index] : "arg", takenNames: &takenNames))
            }
            let label = index == 0 ? "_" : swiftIdentifier(for: selectorParts.indices.contains(index) ? selectorParts[index] : "_")
            return label == parameterName ? "\(label): \(swiftTypes[index])" : "\(label) \(parameterName): \(swiftTypes[index])"
        }
        let parameterString = parameters.joined(separator: ", ")
        let declaration = isClassMethod ? "static func" : "func"
        let returnClause = resolvedReturnType == "Void" ? "" : " -> \(resolvedReturnType)"
        return "@objc(\(name)) \(isOptional ? "optional " : "")\(declaration) \(methodName)(\(parameterString))\(returnClause)"
    }
}

fileprivate func swiftExtensionString(for className: String, string: String) -> String {
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

extension ObjCType {
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
        case .void: return "Void"
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
