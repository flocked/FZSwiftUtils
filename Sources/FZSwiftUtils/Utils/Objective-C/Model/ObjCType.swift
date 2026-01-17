//
//  ObjCType.swift
//
//
//  Created by p-x9 on 2024/06/21
//
//

import Foundation

/// Represents an Objective-C type, including primitive, pointer, object, struct, union, and modified types.
public indirect enum ObjCType: Sendable, Equatable, Codable {
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
    /// Const void.
    case voidConst
    /// Void parameter marked as `in`.
    case voidIn
    /// Unknown type.
    case unknown

    /// Pointer to char (`char *`).
    case charPtr

    /// Atomic type.
    case atom

    /// Objective-C object.
    case object(name: String?)
    /// Block.
    case block(return: ObjCType?, args: [ObjCType]?)
    /// Function pointer.
    case functionPointer

    /// Array.
    case array(type: ObjCType, size: Int?)
    /// Pointer to another type.
    case pointer(type: ObjCType)

    /// Bitfield with specified width.
    case bitField(width: Int)

    /// Union.
    case union(name: String?, fields: [ObjCField]?)
    /// Struct.
    case `struct`(name: String?, fields: [ObjCField]?)

    /// A modified Objective-C type.
    case modified(_ modifier: Modifier, type: ObjCType)

    /// Any other type.
    case other(String)
    
    /// Creates a new instance from the specified type encoding.
    public init?(_ typeEncoding: String) {
        guard let type = Self._decode(typeEncoding)?.decoded else { return nil }
        self = type
    }
}

extension ObjCType: CustomStringConvertible {
    public func decoded(tab: String = "    ") -> String {
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
        case .void, .voidIn, .voidConst: return "void"
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
            return "\(ret.decoded(tab: tab)) (^)(\(args.map({ $0.decoded(tab: tab) }).joined(separator: ", ")))"
        case .functionPointer:
            return "void * /* function pointer */"
        case .array(let type, let size):
            return "\(type.decoded(tab: tab))[\(size?.string ?? "")]"
        case .pointer(let type):
            return "\(type.decoded(tab: tab)) *"
        case .bitField(let width):
            return "int x : \(width)"
        case .union(let name, let fields), .struct(let name, let fields):
            let type = typeKind.rawValue
            guard let fields, !fields.isEmpty else {
                return "\(type) \(name ?? "{}")"
            }
            let name = name != nil ? " \(name!) " : " "
            return """
            \(type)\(name){
            \(fields.decoded(tab: tab))
            }
            """
        case .modified(let modifier, let type):
            return "\(modifier.decoded(tab: tab)) \(type.decoded(tab: tab))"
        case .other(let string):
            return string
        }
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
        case .voidConst: return "1"
        case .voidIn: return "2"
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
        case .modified(let modifier, let type):
            return "\(modifier.encoded())\(type.encoded())"
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
        case .void, .voidConst, .voidIn: return "Void"
        case .unknown: return "unknown"
        case .charPtr: return "UnsafePointer<CChar>"
        case .atom: return "Int" // assuming atomic integer type
        case .object(let name): return name ?? "AnyObject"
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
}

extension ObjCType {
    static func _decode(_ type: String) -> (decoded: ObjCType?, trailing: String?)? {
        guard let first = type.first else { return nil }
        switch first {
            // decode `id` ref: https://github.com/gnustep/libobjc2/blob/2855d1771478e1e368fcfeb4d56aecbb4d9429ca/encoding2.c#L159
        case _ where type.starts(with: "@?"):
           return _decodeBlock(type)
        case _ where type.starts(with: #"@""#):
           return _decodeObject(type)
        case _ where type.starts(with: "^?"):
            return (.functionPointer, type.removingFirst(2))
        case _ where simpleTypes.keys.contains(first):
            return (simpleTypes[first], type.removingFirst())
        case "A", "j", "r", "n", "N", "o", "O", "R", "V", "+":
            return _decodeModified(first, type)
        case "b":
            return _decodeBitField(type)
        case "[":
            return _decodeArray(type)
        case "^":
            return _decodePointer(type)
        case "(":
            return _decodeUnion(type)
        case "{":
            return _decodeStruct(type)
        case "1":
            return (.voidConst, type.removingFirst())
            //  return (decoded: .modified(.const, type: .void), trailing: type.removingFirst())
        case "2":
            return (.voidIn, type.removingFirst())
            /*
            if let decoded = _decode(type.removingFirst()), let next = decoded.decoded {
                switch next {
                case .pointer, .charPtr, .array, .block, .functionPointer:
                    return (.modified(.out, type: next), type.removingFirst())
                default:
                    return (.modified(.in, type: next), type.removingFirst())
                }
            }
            return (decoded: .modified(.in, type: .void), trailing: type.removingFirst())
             */
        default:
            break
        }
        return nil
    }
    
    private static func _decodeModified(_ first: Character, _ type: String) -> Node? {
        guard let modifier = Modifier(rawValue: first), let content = _decode(type.removingFirst()), let rype = content.decoded else {
            return nil
        }
        return (.modified(modifier, type: rype), content.trailing)
    }

    private static func _decodeBitField(_ type: String) -> Node? {
        guard let _length = type.removingFirst().readInitialDigits(), let length = Int(_length) else { return nil }
        let trailing = type.trailing(after: type.index(type.startIndex, offsetBy: _length.count))
        return (.bitField(width: length), trailing)
    }
    
    private static func _decodeBlock(_ type: String) -> Node? {
        let trailing = type.removingFirst(2)
        if trailing.starts(with: "<") {
            guard let (content, trailing) = trailing.firstBracket("<", ">") else { return nil }
            guard let ret = _decode(content), let retType = ret.decoded, var args = ret.trailing else { return nil }
            guard args.starts(with: "@?") else { return nil }
            args.removeFirst(2)
            var argTypes: [ObjCType] = []
            while !args.isEmpty {
                guard let node = _decode(args), let argType = node.decoded else { return nil }
                argTypes.append(argType)
                guard let trailing = node.trailing else { break }
                args = trailing
            }
            return (.block(return: retType, args: argTypes), trailing)
        }
        return (.block(return: nil, args: nil), trailing)
    }
    
    private static func _decodeObject(_ type: String) -> Node? {
        guard let (name, trailing) = type.extractString(between: "\"", startingAt: type.index(after: type.startIndex)) else { return nil }
        return (.object(name: name), trailing)
    }

    // MARK: - Pointer ^
    private static func _decodePointer(_ type: String) -> Node? {
        let content = type.removingFirst()
        guard let node = _decode(content), let contentType = node.decoded else { return nil }
        return (.pointer(type: contentType), node.trailing)
    }

    // MARK: - Bit Field b
    private static func _decodeBitField(_ type: String, name: String?) -> (field: ObjCField, trailing: String?)? {
        let content = type.removingFirst()
        guard let _length = content.readInitialDigits(), let length = Int(_length) else { return nil }
        let endInex = content.index(content.startIndex, offsetBy: _length.count)
        let trailing = type.trailing(after: endInex)
        return (.init(type: .int, name: name, bitWidth: length), trailing)
    }
    
    // MARK: - Array []
    private static func _decodeArray(_ type: String) -> Node? {
        guard var bracket = type.firstBracket("[", "]") else { return nil }
        let length = bracket.content.readInitialDigits()
        if let _length = length, let length = Int(_length) {
            bracket.content.removeFirst(_length.count)
            guard let node = _decode(bracket.content), let contentType = node.decoded else { return nil }
            // TODO: `node.trailing` must be empty
            return (.array(type: contentType, size: length), bracket.trailing)
        }
        guard let node = _decode(bracket.content), let contentType = node.decoded else { return nil }
        // TODO: `node.trailing` must be empty
        return (.array(type: contentType, size: nil), bracket.trailing)
    }

    // MARK: - Union ()
    private static func _decodeUnion(_ type: String) -> Node? {
        _decodeFields(type, for: .union)
    }

    // MARK: - Struct {}
    private static func _decodeStruct(_ type: String) -> Node? {
        _decodeFields(type, for: .struct)
    }

    // MARK: - Union or Struct
    enum _TypeKind: String {
        case `struct`
        case union
        
        var open: Character { self == .union ? "(" : "{" }
        var close: Character { self == .union ?  ")" : "}" }
        
        func type(name: String?, fields: [ObjCField]?) -> ObjCType {
            self == .union ? .union(name: name, fields: fields) :  .struct(name: name, fields: fields)
        }
    }

    private static func _decodeFields(_ type: String, for kind: _TypeKind) -> Node? {
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
            guard let (field, trailing) = _decodeField(_fields) else { break }
            fields.append(field)
            guard let trailing else { break }
            _fields = trailing
        }
        return (kind.type(name: content, fields: fields), trailing)
    }

    private static func _decodeField(_ type: String) -> (field: ObjCField, trailing: String?)? {
        guard let first = type.first else { return nil }
        switch first {
        case "b":
            return _decodeBitField(type, name: nil)
        case "\"":
            guard let (name, contentType) = type.extractString(between: #"""#) else { return nil }
            if contentType.starts(with: "b"), let (field, trailing) = _decodeBitField(contentType, name: name) {
                return (field, trailing)
            } else if let node = _decode(contentType), let contentType = node.decoded {
                return (.init(type: contentType, name: name), node.trailing)
            } else { return nil }
        default:
            guard let node = _decode(type), let decoded = node.decoded else { return nil }
            return (.init(type: decoded),  node.trailing)
        }
    }
    
    var decodedStringForArgument: String {
        switch self {
        case .struct(let name, let fields), .union(let name, let fields):
            if let name { return name }
            return typeKind.type(name: nil, fields: fields).decoded(tab: "").components(separatedBy: .newlines).joined(separator: " ")
        // Objective-C BOOL types may be represented by signed char or by C/C++ bool types.
        // This means that the type encoding may be represented as `c` or as `B`.
        // [reference](https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc.h#L61-L86)
        case .char:
            return "BOOL"
        default:
            break
        }
        return decoded(tab: "").components(separatedBy: .newlines).joined(separator: " ")
    }
    
    private var typeKind: _TypeKind {
        switch self {
        case .union: return .union
        default: return .struct
        }
    }
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

typealias Node = (decoded: ObjCType?, trailing: String?)

/*
extension ObjCType {
    var modifier: ObjCModifier? {
        switch self {
        case .modified(let modifier, type: _): return modifier
        default: return nil
        }
    }
    
    var value: ObjCType {
        switch self {
        case .modified(_, type: let type): return type
        default: return self
        }
    }
}
*/
