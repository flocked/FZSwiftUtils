//
//  ObjCType.swift
//
//
//  Created by p-x9 on 2024/06/21
//
//

import Foundation

/// Represents an Objective-C type, including primitive, pointer, object, struct, union, and modified types.
public indirect enum ObjCType: Sendable, Hashable, Codable {
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

    /// A modified Objective-C type.
    case modified(_ modifiers: [Modifier], type: ObjCType)

    /// Any other type.
    case other(String)
    
    /// Creates a new instance from the specified type encoding.
    public init?(_ typeEncoding: String) {
        guard let type = Self.decode(typeEncoding)?.decoded else { return nil }
        self = type
    }
}

public extension ObjCType {
    /// A Boolean value indicating whether the type is ``void``.
    var isVoid: Bool {
        switch resolved {
        case .void: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is an object.
    var isObject: Bool {
        switch resolved {
        case .object: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is a block.
    var isBlock: Bool {
        switch resolved {
        case .block: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is a pointer.
    var isPointer: Bool {
        switch resolved {
        case .pointer, .charPtr: return true
        default: return false
        }
    }

    /// A Boolean value indicating whether the type is an array.
    var isArray: Bool {
        switch resolved {
        case .array: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is an union.
    var isUnion: Bool {
        switch resolved {
        case .union: return true
        default: return false
        }
    }
    
    /// A Boolean value indicating whether the type is a structure.
    var isStruct: Bool {
        switch resolved {
        case .struct: return true
        default: return false
        }
    }
            
    /// A Boolean value indicating whether the type is a bit field.
    var isBitField: Bool {
        switch resolved {
        case .bitField: return true
        default: return false
        }
    }
    
    /// The modifiers of the type.
    var modifiers: [Modifier] {
        switch self {
        case .modified(let modifiers, type: let type):
            return modifiers + type.modifiers
        default:
            return []
        }
    }
    
    /// The resolved type.
    var resolved: ObjCType {
        switch self {
        case .modified(_, type: let type): return type.resolved
        default: return self
        }
    }
}

extension ObjCType: CustomStringConvertible {
    public func decoded(tab: String = "    ", includeFields: Bool = true) -> String {
        switch self {
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
            return "\(ret.decoded(tab: tab, includeFields: includeFields)) (^)(\(args.map({ $0.decoded(tab: tab, includeFields: includeFields) }).joined(separator: ", ")))"
        case .functionPointer:
            return "IMP"
        case .array(let type, let size):
            return "\(type.decoded(tab: tab, includeFields: includeFields))[\(size?.string ?? "")]"
        case .pointer(let type):
            return "\(type.decoded(tab: tab, includeFields: includeFields)) *"
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
            \(fields.decoded(tab: tab))
            }
            """
        case .modified(let modifiers, let type):
            return "\(modifiers.map({ $0.decoded(tab: tab) }).joined(separator: " ")) \(type.decoded(tab: tab, includeFields: includeFields))"
        case .other(let string):
            return string
        }
    }
    
    func decodedForIvar(tab: String = "    ", includeFields: Bool) -> String {
        switch self {
        case .struct(name: let name, fields: let fields):
            guard let fields = fields, fields.contains(where: {$0.bitWidth != nil }) else { break }
            if let name = name {
                Self.structNames.insert(name)
            }
            let name = name != nil ? " \(name!) " : " "
            return """
            \(typeKind.rawValue)\(name){
            \(fields.decoded(tab: tab))
            }
            """
        default: break
        }
        return decoded(tab: tab, includeFields: includeFields)
    }

    /// The type encodibg of the Objective-C type.
    public func encoded() -> String {
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
        case .atom: return "%"
        case .object(let name):
            if let name { return "@\"\(name)\"" }
            return "@"
        case let .block(ret, args):
            guard let ret, let args else { return "@?" }
            return "@?<\(ret.encoded())@?\(args.map({ $0.encoded() }).joined())>"
        case .functionPointer: return "^?"
        case .array(let type, let size):
            return "[\(size?.string ?? "")\(type.encoded())]"
        case .pointer(let type):
            return "^\(type.encoded())"
        case .bitField(let width):
            return "b\(width)"
        case .union(let name, let fields):
            guard let fields else { return "(\(name ?? ""))" }
            return "(\(name ?? "?")=\(fields.map({ $0.encoded() }).joined()))"
        case .struct(let name, let fields):
            guard let fields else { return "{\(name ?? "")}" }
            return "{\(name ?? "?")=\(fields.map({ $0.encoded() }).joined())}"
        case .modified(let modifiers, let type) where type == .void && modifiers == [.const]:
            return "1"
        case .modified(let modifiers, let type) where type == .void && modifiers == [.in]:
            return "2"
        case .modified(let modifiers, let type):
            return "\(modifiers.map({ $0.encoded() }).joined())\(type.encoded())"
        case .other(let string):
            return string
        }
    }
    
    public var description: String {
        switch self {
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
        case .modified(_, let type): return type.description
        case .other(let str): return str
        }
    }
    
    func names() -> (types: Set<String>, fields: Set<String>) {
        var typeNames: Set<String> = []
        var fieldNames: Set<String> = []
        func visit(_ type: ObjCType) {
            switch type {
            case .object(name: let name):
                typeNames += name
            case .modified(_, type: let type), .array(type: let type, size: _), .pointer(type: let type):
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
            return (.modified([.const], type: .void), type.removingFirst())
        case "2":
            return (.modified([.in], type: .void), type.removingFirst())
        default:
            break
        }
        return nil
    }
    
    private static func decodeModified(_ first: Character, _ type: String) -> Node? {
        guard let modifier = Modifier(rawValue: first),
              let content = decode(type.removingFirst()),
              let type = content.decoded else {
            return nil
        }
        switch type {
        case .modified(let modifiers, let type):
            return (.modified([modifier] + modifiers, type: type), content.trailing)
        default:
            return (.modified([modifier], type: type), content.trailing)
        }
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
    
    func decodedStringForArgument(includeFields: Bool = false) -> String {
        if includeFields {
            return decoded(tab: "", includeFields: includeFields).components(separatedBy: .newlines).joined(separator: " ")
        }
        switch self {
        case .struct(let name, let fields), .union(let name, let fields):
            if isStruct, let name = name {
                Self.structNames.insert(name)
            }
            if let name { return "\(typeKind.rawValue) \(name)" }
            return typeKind.type(name: nil, fields: fields).decoded(tab: "").components(separatedBy: .newlines).joined(separator: " ")
        // Objective-C BOOL types may be represented by signed char or by C/C++ bool types.
        // This means that the type encoding may be represented as `c` or as `B`.
        // [reference](https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc.h#L61-L86)
        case .char:
            return "BOOL"
        default:
            break
        }
        return decoded(tab: "", includeFields: includeFields).components(separatedBy: .newlines).joined(separator: " ")
    }
    
    private var typeKind: TypeKind {
        switch self {
        case .union: .union
        default: .struct
        }
    }
    
    var normalized: ObjCType {
        switch self {
        case .pointer(let t), .modified(_, let t): return t.normalized
        default: return self
        }
    }
    
    /// The raw Objective-C runtime name (may be Swift-mangled)
    public var objcRuntimeName: String? {
        switch self {
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
        switch self {
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
            if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *) { return swiftType == Int128.self } else { return nil }
        case .uint128:
            if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *) { return swiftType == UInt128.self } else { return nil }
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
        case let .modified(_, type): return type.matches(swiftType)
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
