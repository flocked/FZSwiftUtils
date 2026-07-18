//
//  ObjCType.swift
//
//
//  Created by p-x9 on 2024/06/21
//
//

import Foundation

/// Represents an Objective-C type, including primitive, pointer, object, struct, union, and modified types.
public struct ObjCType: Sendable, Hashable, Codable {
    
    /// The structural kind of the Objective-C type.
    public let kind: Kind
    /// The modifiers that qualify this Objective-C type.
    public let modifiers: [Modifier]
    /// The Objective-C runtime type encoding for this type.
    public let typeEncoding: String
    
    public indirect enum Kind: Sendable, Hashable, Codable {
        /// Objective-C class.
        case `class`
        /// Objective-C selector (`SEL`).
        case selector
        
        /// Signed char (`char`).
        case char
        /// Unsigned char (`unsigned char`).
        case uchar
        
        /// Signed short (`short`).
        case short
        /// Unsigned short (`unsigned short`).
        case ushort
        
        /// Signed integer (`int`).
        case int
        /// Unsigned integer (`unsigned int`).
        case uint
        
        /// Signed long (`long`).
        case long
        /// Unsigned long (`unsigned long`).
        case ulong
        
        /// Signed long long (`long long`).
        case longLong
        /// Unsigned long long (`unsigned long long`).
        case ulongLong
        
        /// 128-bit signed integer.
        case int128
        /// 128-bit unsigned integer.
        case uint128
        
        /// Float.
        case float
        /// Double.
        case double
        /// Long double.
        case longDouble
        
        /// Boolean (`BOOL`/`bool`).
        case bool
        /// Void.
        case void
        /// Unknown type.
        case unknown
        
        /// Pointer to char (`char *`).
        case charPtr
        /// Pointer to another type.
        case pointer(type: ObjCType)
        /// Function pointer.
        case functionPointer
        
        /// Atomic type.
        case atom
        
        /// Objective-C object.
        case object(name: String?)
        /// Block.
        case block(return: ObjCType?, args: [ObjCType]?)
        
        /// Array.
        case array(type: ObjCType, size: Int?)
        
        /// Bitfield with specified width.
        case bitField(width: Int)
        
        /// Union.
        case union(name: String?, fields: [ObjCField]?)
        /// Struct.
        case `struct`(name: String?, fields: [ObjCField]?)
        
        /// Any other type.
        case other(String)
    }

    /// Creates a new instance from the specified kind and modifiers.
    public init(kind: Kind, modifiers: [Modifier] = []) {
        self.kind = kind
        self.modifiers = modifiers
        if kind == .void, modifiers == [.const] {
            typeEncoding = "1"
        } else if kind == .void, modifiers == [.in] {
            typeEncoding = "2"
        } else {
            typeEncoding = modifiers.map(\.rawValue).joined() + kind.typeEncoding
        }
    }

    /// Creates a new instance from the specified type encoding.
    public init?(_ typeEncoding: String) {
        if let type = Self.cache[typeEncoding] {
            self = type
        } else if let type = Self.decode(typeEncoding)?.decoded {
            self = type
            Self.cache[typeEncoding] = type
        } else {
            return nil
        }
    }

    static var cache: [String: Self] = [:]
}

private extension ObjCType.Kind {
    var typeEncoding: String {
        switch self {
        case .class: return "#"
        case .selector: return ":"
        case .char: return "c"
        case .uchar: return "C"
        case .short: return "s"
        case .ushort: return "S"
        case .int: return "i"
        case .uint: return "I"
        case .long: return "l"
        case .ulong: return "L"
        case .longLong: return "q"
        case .ulongLong: return "Q"
        case .int128: return "t"
        case .uint128: return "T"
        case .float: return "f"
        case .double: return "d"
        case .longDouble: return "D"
        case .bool: return "B"
        case .void: return "v"
        case .unknown: return "?"
        case .charPtr: return "*"
        case .functionPointer: return "^?"
        case .atom: return "%"
        case .object(let name):
            if let name { return "@\"\(name)\"" }
            return "@"
        case .block(let returnType, let args):
            guard let returnType, let args else { return "@?" }
            return "@?<\(returnType.typeEncoding)@?\(args.map(\.typeEncoding).joined())>"
        case .array(let type, let size):
            return "[\(size?.string ?? "")\(type.typeEncoding)]"
        case .pointer(let type):
            return "^\(type.typeEncoding)"
        case .bitField(let width):
            return "b\(width)"
        case .union(let name, let fields):
            guard let fields else { return "(\(name ?? ""))" }
            return "(\(name ?? "?")=\(fields.map({ $0.encoded() }).joined()))"
        case .struct(let name, let fields):
            guard let fields else { return "{\(name ?? "")}" }
            return "{\(name ?? "?")=\(fields.map({ $0.encoded() }).joined())}"
        case .other(let string):
            return string
        }
    }
}

public extension ObjCType {
    /// An Objective-C class type.
    static let `class` = ObjCType(kind: .class)
    /// An Objective-C selector type.
    static let selector = ObjCType(kind: .selector)
    /// A signed char type.
    static let char = ObjCType(kind: .char)
    /// An unsigned char type.
    static let uchar = ObjCType(kind: .uchar)
    /// A signed short type.
    static let short = ObjCType(kind: .short)
    /// An unsigned short type.
    static let ushort = ObjCType(kind: .ushort)
    /// A signed integer type.
    static let int = ObjCType(kind: .int)
    /// An unsigned integer type.
    static let uint = ObjCType(kind: .uint)
    /// A signed long type.
    static let long = ObjCType(kind: .long)
    /// An unsigned long type.
    static let ulong = ObjCType(kind: .ulong)
    /// A signed long long type.
    static let longLong = ObjCType(kind: .longLong)
    /// An unsigned long long type.
    static let ulongLong = ObjCType(kind: .ulongLong)
    /// A 128-bit signed integer type.
    static let int128 = ObjCType(kind: .int128)
    /// A 128-bit unsigned integer type.
    static let uint128 = ObjCType(kind: .uint128)
    /// A float type.
    static let float = ObjCType(kind: .float)
    /// A double type.
    static let double = ObjCType(kind: .double)
    /// A long double type.
    static let longDouble = ObjCType(kind: .longDouble)
    /// A Boolean type.
    static let bool = ObjCType(kind: .bool)
    /// A void type.
    static let void = ObjCType(kind: .void)
    /// An unknown type.
    static let unknown = ObjCType(kind: .unknown)
    /// A C string pointer type.
    static let charPtr = ObjCType(kind: .charPtr)
    /// A function pointer type.
    static let functionPointer = ObjCType(kind: .functionPointer)
    /// An atomic type.
    static let atom = ObjCType(kind: .atom)

    /// Creates an Objective-C object type with an optional runtime class or protocol name.
    static func object(name: String?) -> ObjCType {
        ObjCType(kind: .object(name: name))
    }

    /// Creates a pointer type to another Objective-C type.
    static func pointer(type: ObjCType) -> ObjCType {
        ObjCType(kind: .pointer(type: type))
    }

    /// Creates a block type with optional return and argument types.
    static func block(return returnType: ObjCType?, args: [ObjCType]?) -> ObjCType {
        ObjCType(kind: .block(return: returnType, args: args))
    }

    /// Creates an array type with an optional fixed size.
    static func array(type: ObjCType, size: Int?) -> ObjCType {
        ObjCType(kind: .array(type: type, size: size))
    }

    /// Creates a bitfield type with the specified width.
    static func bitField(width: Int) -> ObjCType {
        ObjCType(kind: .bitField(width: width))
    }

    /// Creates a union type with an optional name and fields.
    static func union(name: String?, fields: [ObjCField]?) -> ObjCType {
        ObjCType(kind: .union(name: name, fields: fields))
    }

    /// Creates a struct type with an optional name and fields.
    static func `struct`(name: String?, fields: [ObjCField]?) -> ObjCType {
        ObjCType(kind: .struct(name: name, fields: fields))
    }

    /// Creates an Objective-C type for an unsupported or custom encoding string.
    static func other(_ string: String) -> ObjCType {
        ObjCType(kind: .other(string))
    }
}


public extension ObjCType {
    /// A Boolean value indicating whether the type is ``void``.
    var isVoid: Bool {
        switch resolved.kind {
        case .void: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is an object.
    var isObject: Bool {
        switch resolved.kind {
        case .object: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is a block.
    var isBlock: Bool {
        switch resolved.kind {
        case .block: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is a pointer.
    var isPointer: Bool {
        switch resolved.kind {
        case .pointer, .charPtr: return true
        default: return false
        }
    }

    /// A Boolean value indicating whether the type is an array.
    var isArray: Bool {
        switch resolved.kind {
        case .array: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is an union.
    var isUnion: Bool {
        switch resolved.kind {
        case .union: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is a structure.
    var isStruct: Bool {
        switch resolved.kind {
        case .struct: return true
        default: return false
        }
    }
            
    /// A Boolean value indicating whether the type is a bit field.
    var isBitField: Bool {
        switch resolved.kind {
        case .bitField: return true
        default: return false
        }
    }
    
    /// The resolved type.
    var resolved: ObjCType {
        self
    }
}

extension ObjCType: CustomStringConvertible {
    public func decoded(tab: String = "    ", includeFields: Bool = true, includeModifiers: Bool = false) -> String {
        let decoded: String = {
            switch kind {
        case .class: return "Class"
        case .selector: return "SEL"
        case .char: return "char"
        case .uchar: return "unsigned char"
        case .short: return "short"
        case .ushort: return "unsigned short"
        case .int: return "int"
        case .uint: return "unsigned int"
        case .long: return "long"
        case .ulong: return "unsigned long"
        case .longLong: return "long long"
        case .ulongLong: return "unsigned long long"
        case .int128: return "__int128_t"
        case .uint128: return "__uint128_t"
        case .float: return "float"
        case .double: return "double"
        case .longDouble: return "long double"
        case .bool: return "BOOL"
        case .void: return "void"
        case .unknown: return "unknown"
        case .charPtr: return "char *"
        case .atom: return "atom"
        case .object(let name):
            guard let name = name else { return "id" }
            if name.first == "<" && name.last == ">" {
                return "id \(name)"
            }
            return "\(name) *"
        case .block(let ret, let args):
            guard let ret, let args else { return "id /* block */" }
            return "\(ret.decoded(tab: tab, includeFields: includeFields, includeModifiers: includeModifiers)) (^)(\(args.map({ $0.decoded(tab: tab, includeFields: includeFields, includeModifiers: includeModifiers) }).joined(separator: ", ")))"
        case .functionPointer:
            return "IMP"
        case .array(let type, let size):
            return "\(type.decoded(tab: tab, includeFields: includeFields, includeModifiers: includeModifiers))[\(size?.string ?? "")]"
        case .pointer(let type):
            return "\(type.decoded(tab: tab, includeFields: includeFields, includeModifiers: includeModifiers)) *"
        case .bitField(let width):
            return "int x : \(width)"
        case .union(let name, let fields), .struct(let name, let fields):
            if isStruct, let name = name {
                Self.structNames.insert(name)
            }
            let type = typeKind.rawValue
            guard includeFields, let fields, !fields.isEmpty else {
                if let name = name { return "\(type) \(name)" }
                return "\(type) \(name ?? "{}")"
            }
            let name = name != nil ? " \(name!) " : " "
            return """
            \(type)\(name){
            \(fields.decoded(tab: tab, includeModifiers: includeModifiers))
            }
            """
        case .other(let string):
            return string
        }
        }()
        guard includeModifiers, !modifiers.isEmpty else { return decoded }
        return "\(modifiers.map({ $0.decoded(tab: tab) }).joined(separator: " ")) \(decoded)"
    }
    
    func decodedForIvar(tab: String = "    ", includeFields: Bool, includeModifiers: Bool = false) -> String {
        switch kind {
        case .struct(name: let name, fields: let fields):
            guard let fields = fields, fields.contains(where: {$0.bitWidth != nil }) else { break }
            if let name = name {
                Self.structNames.insert(name)
            }
            let name = name != nil ? " \(name!) " : " "
            return """
            \(typeKind.rawValue)\(name){
            \(fields.decoded(tab: tab, includeModifiers: includeModifiers))
            }
            """
        default: break
        }
        return decoded(tab: tab, includeFields: includeFields, includeModifiers: includeModifiers)
    }

    public var description: String {
        switch kind {
        case .class: return "AnyClass"
        case .selector: return "Selector"
        case .char: return "Int8"
        case .uchar: return "UInt8"
        case .short: return "Int16"
        case .ushort: return "UInt16"
        case .int: return "Int32"
        case .uint: return "UInt32"
        case .long: return "Int"      // platform-native signed integer
        case .ulong: return "UInt"     // platform-native unsigned integer
        case .longLong: return "Int64"
        case .ulongLong: return "UInt64"
        case .int128: return "Int128"   // placeholder for 128-bit integer
        case .uint128: return "UInt128"  // placeholder for 128-bit unsigned integer
        case .float: return "Float"
        case .double: return "Double"
        case .longDouble: return "Float80"  // note: Intel macOS only, ARM uses Double
        case .bool: return "Bool"
        case .void: return "Void"
        case .unknown: return "unknown"
        case .charPtr: return "UnsafePointer<CChar>"
        case .atom: return "Int" // assuming atomic integer type
        case .object(let name): return swiftTypeName ?? name ?? "AnyObject"
        case .block(let returnType, let args):
            let argsString = args?.map { $0.description }.joined(separator: ", ") ?? ""
            let returnString = returnType?.description ?? "Void"
            return "(@escaping (\(argsString)) -> \(returnString))"
        case .functionPointer: return "UnsafeRawPointer"
        case .array(let type, let size):
            if let size = size {
                return "(\(type.description), count: \(size))" // fixed-size array representation
            }
            return "[\(type.description)]"
        case .pointer(let type): return "UnsafeMutablePointer<\(type.description)>"
        case .bitField(_): return "Int"
        case .union(let name, _): return name ?? "union"
        case .struct(let name, _): return name ?? "struct"
        case .other(let str): return str
        }
    }
    
    func names() -> (types: Set<String>, fields: Set<String>) {
        var typeNames: Set<String> = []
        var fieldNames: Set<String> = []
        func visit(_ type: ObjCType) {
            switch type.kind {
            case .object(name: let name):
                typeNames += name
            case .array(type: let type, size: _), .pointer(type: let type):
                visit(type)
            case .struct(name: let name, fields: let fields), .union(name: let name, fields: let fields):
                typeNames += name
                fields?.forEach({
                    fieldNames += $0.name
                    visit($0.type)
                })
            case .block(return: let returnType, args: let arguments):
                if let returnType = returnType { visit(returnType) }
                arguments?.forEach(visit)
            default: break
            }
        }
        visit(self)
        return (typeNames, fieldNames)
    }
}

extension ObjCType {
    private static func decode(_ type: String) -> (decoded: ObjCType?, trailing: String?)? {
        guard let first = type.first else { return nil }
        switch first {
            // decode `id` ref: https://github.com/gnustep/libobjc2/blob/2855d1771478e1e368fcfeb4d56aecbb4d9429ca/encoding2.c#L159
        case _ where type.starts(with: "@?"):
           return decodeBlock(type)
        case _ where type.starts(with: #"@""#):
           return decodeObject(type)
        case _ where type.starts(with: "^?"):
            return (.functionPointer, type.removingFirst(2))
        case _ where simpleTypes.keys.contains(first):
            return (simpleTypes[first], type.removingFirst())
        case "A", "j", "r", "n", "N", "o", "O", "R", "V", "+":
            return decodeModified(first, type)
        case "b":
            return decodeBitField(type)
        case "[":
            return decodeArray(type)
        case "^":
            return decodePointer(type)
        case "(":
            return decodeUnion(type)
        case "{":
            return decodeStruct(type)
        case "1":
            return (ObjCType(kind: .void, modifiers: [.const]), type.removingFirst())
        case "2":
            return (ObjCType(kind: .void, modifiers: [.in]), type.removingFirst())
        default:
            break
        }
        return nil
    }
    
    private static func decodeModified(_ first: Character, _ type: String) -> Node? {
        guard let modifier = Modifier(rawValue: String(first)),
              let content = decode(type.removingFirst()),
              let type = content.decoded else {
            return nil
        }
        return (ObjCType(kind: type.kind, modifiers: [modifier] + type.modifiers), content.trailing)
    }

    private static func decodeBitField(_ type: String) -> Node? {
        guard let _length = type.removingFirst().readInitialDigits(), let length = Int(_length) else { return nil }
        let trailing = type.trailing(after: type.index(type.startIndex, offsetBy: _length.count))
        return (.bitField(width: length), trailing)
    }
    
    private static func decodeBlock(_ type: String) -> Node? {
        let trailing = type.removingFirst(2)
        if trailing.starts(with: "<") {
            guard let (content, trailing) = trailing.firstBracket("<", ">") else { return nil }
            guard let ret = decode(content), let retType = ret.decoded, var args = ret.trailing else { return nil }
            guard args.starts(with: "@?") else { return nil }
            args.removeFirst(2)
            var argTypes: [ObjCType] = []
            while !args.isEmpty {
                guard let node = decode(args), let argType = node.decoded else { return nil }
                argTypes.append(argType)
                guard let trailing = node.trailing else { break }
                args = trailing
            }
            return (.block(return: retType, args: argTypes), trailing)
        }
        return (.block(return: nil, args: nil), trailing)
    }
    
    private static func decodeObject(_ type: String) -> Node? {
        guard let (name, trailing) = type.extractString(between: "\"", startingAt: type.index(after: type.startIndex)) else { return nil }
        return (.object(name: name), trailing)
    }

    // MARK: - Pointer ^
    private static func decodePointer(_ type: String) -> Node? {
        guard let node = decode(type.removingFirst()), let contentType = node.decoded else { return nil }
        return (.pointer(type: contentType), node.trailing)
    }

    // MARK: - Bit Field b
    private static func decodeBitField(_ type: String, name: String?) -> (field: ObjCField, trailing: String?)? {
        let content = type.removingFirst()
        guard let _length = content.readInitialDigits(), let length = Int(_length) else { return nil }
        let endInex = content.index(content.startIndex, offsetBy: _length.count)
        let trailing = type.trailing(after: endInex)
        return (.init(type: .int, name: name, bitWidth: length), trailing)
    }
    
    // MARK: - Array []
    private static func decodeArray(_ type: String) -> Node? {
        guard var bracket = type.firstBracket("[", "]") else { return nil }
        let length = bracket.content.readInitialDigits()
        if let _length = length, let length = Int(_length) {
            bracket.content.removeFirst(_length.count)
            guard let node = decode(bracket.content), let contentType = node.decoded else { return nil }
            // TODO: `node.trailing` must be empty
            return (.array(type: contentType, size: length), bracket.trailing)
        }
        guard let node = decode(bracket.content), let contentType = node.decoded else { return nil }
        // TODO: `node.trailing` must be empty
        return (.array(type: contentType, size: nil), bracket.trailing)
    }

    // MARK: - Union ()
    private static func decodeUnion(_ type: String) -> Node? {
        decodeFields(type, for: .union)
    }

    // MARK: - Struct {}
    private static func decodeStruct(_ type: String) -> Node? {
        decodeFields(type, for: .struct)
    }

    // MARK: - Union or Struct
    private enum TypeKind: String {
        case `struct`
        case union
        
        var open: Character { self == .union ? "(" : "{" }
        var close: Character { self == .union ?  ")" : "}" }
        
        func type(name: String?, fields: [ObjCField]?) -> ObjCType {
            self == .union ? .union(name: name, fields: fields) :  .struct(name: name, fields: fields)
        }
    }

    private static func decodeFields(_ type: String, for kind: TypeKind) -> Node? {
        guard let (content, trailing) = type.firstBracket(kind.open, kind.close) else { return nil }
        guard !content.isEmpty else { return nil }

        guard let equalIndex = content.firstIndex(of: "=") else {
            return (kind.type(name: content, fields: nil), trailing)
        }

        var typeName: String? = String(content[content.startIndex ..< equalIndex])
        if typeName == "?" { typeName = nil }

        var _fields = String(content[content.index(equalIndex, offsetBy: 1) ..< content.endIndex])
        var fields: [ObjCField] = []
        while !_fields.isEmpty {
            guard let (field, trailing) = decodeField(_fields) else { break }
            fields.append(field)
            guard let trailing else { break }
            _fields = trailing
        }
        return (kind.type(name: typeName, fields: fields), trailing)
    }

    private static func decodeField(_ type: String) -> (field: ObjCField, trailing: String?)? {
        guard let first = type.first else { return nil }
        switch first {
        case "b":
            return decodeBitField(type, name: nil)
        case "\"":
            guard let (name, contentType) = type.extractString(between: #"""#) else { return nil }
            if contentType.starts(with: "b"), let (field, trailing) = decodeBitField(contentType, name: name) {
                return (field, trailing)
            } else if let node = decode(contentType), let contentType = node.decoded {
                return (.init(type: contentType, name: name), node.trailing)
            } else { return nil }
        default:
            guard let node = decode(type), let decoded = node.decoded else { return nil }
            return (.init(type: decoded),  node.trailing)
        }
    }
    
    func decodedStringForArgument(includeFields: Bool = false, includeModifiers: Bool = false) -> String {
        if includeFields {
            return decoded(tab: "", includeFields: includeFields, includeModifiers: includeModifiers).components(separatedBy: .newlines).joined(separator: " ")
        }
        switch kind {
        case .struct(let name, let fields), .union(let name, let fields):
            if isStruct, let name = name {
                Self.structNames.insert(name)
            }
            if let name { return "\(typeKind.rawValue) \(name)" }
            return typeKind.type(name: nil, fields: fields).decoded(tab: "", includeModifiers: includeModifiers).components(separatedBy: .newlines).joined(separator: " ")
        // Objective-C BOOL types may be represented by signed char or by C/C++ bool types.
        // This means that the type encoding may be represented as `c` or as `B`.
        // [reference](https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc.h#L61-L86)
        case .char:
            return "BOOL"
        default:
            break
        }
        return decoded(tab: "", includeFields: includeFields, includeModifiers: includeModifiers).components(separatedBy: .newlines).joined(separator: " ")
    }
    
    private var typeKind: TypeKind {
        switch kind {
        case .union: .union
        default: .struct
        }
    }
    
    var normalized: ObjCType {
        switch kind {
        case .pointer(let t): return t.normalized
        default: return self
        }
    }
    
    /// The raw Objective-C runtime name (may be Swift-mangled)
    public var objcRuntimeName: String? {
        switch kind {
        case .object(let name): return name
        default: return nil
        }
    }

    /// A demangled, human-readable Swift type name (for UI / logging only)
    public var swiftTypeName: String? {
        guard let name = objcRuntimeName else { return nil }
        guard name.hasPrefix("_Tt"), let cls = NSClassFromString(name) else { return name }
        return String(reflecting: cls)
    }
}

extension ObjCType {
    /**
     Checks if the specified Swift type matches the Objective-C type.
     
     - Parameter swiftType: The Swift type to compare.
     - Returns: `true` if the type matches, `false` if it doesn't, or `nil` if undecidable (e.g., struct/union types).
     */
    public func matches(_ swiftType: Any.Type) -> Bool? {
        let swiftType = (swiftType.self as? any OptionalProtocol.Type)?.wrappedType ?? swiftType.self
        switch kind {
        case .char: return swiftType == Int8.self || swiftType == CChar.self
        case .uchar: return swiftType == UInt8.self || swiftType == CUnsignedChar.self
        case .short: return swiftType == Int16.self || swiftType == CShort.self
        case .ushort: return swiftType == UInt16.self || swiftType == CUnsignedShort.self
        case .int: return swiftType == Int32.self || swiftType == CInt.self
        case .uint: return swiftType == UInt32.self || swiftType == CUnsignedInt.self
        case .long: return swiftType == Int.self || swiftType == Int64.self || swiftType == CLong.self
        case .ulong: return swiftType == UInt.self || swiftType == UInt64.self || swiftType == CUnsignedLong.self
        case .longLong: return swiftType == Int64.self || swiftType == CLongLong.self || swiftType == Int.self
        case .ulongLong: return swiftType == UInt64.self || swiftType == CUnsignedLongLong.self || swiftType == UInt.self
        case .int128:
            if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) { return swiftType == Int128.self } else { return nil }
        case .uint128:
            if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) { return swiftType == UInt128.self } else { return nil }
        case .float: return swiftType == Float.self
        case .double: return swiftType == Double.self || swiftType == CGFloat.self
        case .longDouble: return swiftType == Double.self
        case .bool: return swiftType == Bool.self || swiftType == ObjCBool.self
        case .void: return swiftType == Void.self
        case .charPtr:
            return swiftType == UnsafePointer<CChar>.self || swiftType == UnsafeMutablePointer<CChar>.self || swiftType == UnsafePointer<Int8>.self || swiftType == UnsafeMutablePointer<Int8>.self
        case .pointer(let type):
            guard let pointerType = swiftType as? PointerType.Type else { return false }
            return type.matches(pointerType.pointeeType)
        case let .object(name):
            guard let cls = ObjCRuntime.objcType(for: swiftType) else { return false }
            guard let name else { return true }
            return NSClassFromString(name)?.isSubclass(of: cls) == true
        case .block:
            let swiftName = String(reflecting: swiftType)
            return swiftName.hasPrefix("(") && swiftName.contains("->")
        case .functionPointer: return nil
        case .struct(name: let name, fields: _):
            guard let name = name, let swiftName = String(reflecting: swiftType).components(separatedBy: ".").last else { return nil }
            return swiftName == name || swiftName.removingSuffix("Ref") == name
        case .union, .array, .bitField:
            return nil
        case .selector: return swiftType == Selector.self
        case .class: return swiftType is AnyClass
        case .other, .unknown, .atom: return nil
        }
    }
    
    static var structNames: SynchronizedSet<String> = []
}

fileprivate protocol PointerType {
    static var pointeeType: Any.Type { get }
}

extension UnsafePointer: PointerType {
    fileprivate static var pointeeType: Any.Type { Pointee.self }
}

extension UnsafeMutablePointer: PointerType {
    fileprivate static var pointeeType: Any.Type { Pointee.self }
}

extension UnsafeRawPointer: PointerType {
    fileprivate static var pointeeType: Any.Type { Void.self }
}

extension UnsafeMutableRawPointer: PointerType {
    fileprivate static var pointeeType: Any.Type { Void.self }
}

fileprivate let simpleTypes: [Character: ObjCType] = [
    "@": .object(name: nil),
    "#": .class,
    ":": .selector,
    "c": .char,
    "C": .uchar,
    "s": .short,
    "S": .ushort,
    "i": .int,
    "I": .uint,
    "l": .long,
    "L": .ulong,
    "q": .longLong,
    "Q": .ulongLong,
    "t": .int128,
    "T": .uint128,
    "f": .float,
    "d": .double,
    "D": .longDouble,
    "B": .bool,
    "v": .void,
    "?": .unknown,
    "*": .charPtr,
    "%": .atom // FIXME: ?????
]

fileprivate typealias Node = (decoded: ObjCType?, trailing: String?)

fileprivate extension String {
    func firstBracket(_ open: Character, _ close: Character) -> (content: String, trailing: String?)? {
        var depth = 0
        var openIndex: String.Index?
        for idx in indices {
            switch self[idx] {
            case open:
                if depth == 0 { openIndex = idx }
                depth += 1
            case close:
                depth -= 1
                if depth == 0, let openIndex = openIndex {
                    let trailingStart = index(after: idx)
                    let trailing = trailingStart < endIndex ? String(self[trailingStart...]) : nil
                    return (String(self[index(after: openIndex)..<idx]), trailing)
                }
            default: break
            }
        }
        return nil
    }
    
    func extractString(between character: Character, startingAt startIndex: Index? = nil) -> (content: String, trailing: String)? {
        let startIndex = startIndex ?? self.startIndex
        var inQuote = false
        var idx = startIndex
        while idx < endIndex {
            if self[idx] == "\"" {
                if inQuote {
                    let content = String(self[index(after: startIndex)..<idx])
                    return (content, String(self[index(after: idx)..<endIndex]))
                } else {
                    inQuote = true
                }
            }
            idx = index(after: idx)
        }
        return nil
    }

    func readInitialDigits() -> String? {
        guard !isEmpty else { return nil }
        var start = startIndex
        let hasSign = self[start] == "-"
        if hasSign {
            start = index(after: start)
            if start == endIndex { return nil } // only "-" no digits
        }
        var end = start
        while end < endIndex, self[end].isNumber {
            end = index(after: end)
        }
        if start == end { return nil }
        return String(self[(hasSign ? startIndex : start)..<end])
    }
    
    func trailing(after index: Index) -> String? {
        distance(from: index, to: endIndex) > 0 ? String(self[self.index(after: index) ..< endIndex]) : nil
    }
}
