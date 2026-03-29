//
//  ObjCHeader.swift
//
//
//  Created by Florian Zand on 28.03.26.
//

import Foundation

enum ObjCHeader {
    static let frameworksFolder = URL.file("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks")
    static var publicHeaderURLs = frameworksFolder.iterateFiles().includingPackageContents.extensions("h").recursive.collect()

    static var protocolsByName: [String: ProtocolInfo] = [:]
    static var classesByName: [String: Class] = [:]
    static var categoriesByName: [String: Category] = [:]
    static var categoriesByClass: [String: [Category]] = [:]
    static var didCollect = false
    
    public static func collectAll() {
        guard !didCollect else { return }
        didCollect = true
        for file in publicHeaderURLs {
            guard let header = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let info = parse(header)
            info.classes.forEach({
                classesByName[$0.name] = $0
            })
            info.protocols.forEach({ protocolsByName[$0.name] = $0 })
            info.categories.forEach({
                categoriesByName[$0.name] = $0
                categoriesByClass[$0.className, default: []] += $0
            })
        }
    }
    
    static func parseClassNames(_ header: String) -> [String] {
        let lines = header._objcHeaderLines()
        var classNames: [String] = []
        var seen = Set<String>()

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard line.hasPrefix("@interface "),
                  let declaration = Declaration.parseInterface(line) else { continue }
            guard case .class = declaration.kind else { continue }
            if seen.insert(declaration.name).inserted {
                classNames.append(declaration.name)
            }
        }
        return classNames
    }
    
    public static func parse(_ header: String) -> HeaderInfo {
        let lines = header._objcHeaderLines()
        var headerInfo = HeaderInfo()
        var classIndices: [String: Int] = [:]
        var protocolIndices: [String: Int] = [:]
        var categoryIndices: [CategoryKey: Int] = [:]

        var currentContext: ParseContext?
        var ivarBlockDepth = 0

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if line.hasPrefix("@interface "),
               let declaration = Declaration.parseInterface(line) {
                ivarBlockDepth = line._countOccurrences(of: "{") - line._countOccurrences(of: "}")
                switch declaration.kind {
                case .class:
                    let index = classIndices[declaration.name] ?? {
                        let index = headerInfo.classes.count
                        headerInfo.classes.append(.init(name: declaration.name))
                        classIndices[declaration.name] = index
                        return index
                    }()
                    if !declaration.protocols.isEmpty {
                        headerInfo.classes[index].protocols.append(contentsOf: declaration.protocols.filter({ !headerInfo.classes[index].protocols.contains($0) }))
                    }
                    currentContext = .class(index)
                case .category(let className, let categoryName):
                    let key = CategoryKey(className: className, name: categoryName)
                    let index = categoryIndices[key] ?? {
                        let index = headerInfo.categories.count
                        headerInfo.categories.append(.init(name: categoryName, className: className))
                        categoryIndices[key] = index
                        return index
                    }()
                    if !declaration.protocols.isEmpty {
                        headerInfo.categories[index].protocols.append(contentsOf: declaration.protocols.filter({ !headerInfo.categories[index].protocols.contains($0) }))
                    }
                    currentContext = .category(index)
                }
                continue
            }

            if line.hasPrefix("@protocol "),
               let declaration = Declaration.parseProtocol(line) {
                let index = protocolIndices[declaration.name] ?? {
                    let index = headerInfo.protocols.count
                    headerInfo.protocols.append(.init(name: declaration.name))
                    protocolIndices[declaration.name] = index
                    return index
                }()
                if !declaration.protocols.isEmpty {
                    headerInfo.protocols[index].protocols.append(contentsOf: declaration.protocols.filter({ !headerInfo.protocols[index].protocols.contains($0) }))
                }
                currentContext = .protocol(index, isOptional: false)
                continue
            }

            if line == "@end" {
                currentContext = nil
                ivarBlockDepth = 0
                continue
            }

            if line == "@optional" {
                if case .protocol(let index, _) = currentContext {
                    currentContext = .protocol(index, isOptional: true)
                }
                continue
            }

            if line == "@required" {
                if case .protocol(let index, _) = currentContext {
                    currentContext = .protocol(index, isOptional: false)
                }
                continue
            }

            guard let currentContext else { continue }

            ivarBlockDepth += line._countOccurrences(of: "{")
            ivarBlockDepth -= line._countOccurrences(of: "}")
            if ivarBlockDepth > 0 {
                continue
            }

            if line.hasPrefix("@property"),
               let property = Property.parse(line) {
                switch currentContext {
                case .class(let index):
                    if property.isClassProperty {
                        headerInfo.classes[index].classProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: true))
                    } else {
                        headerInfo.classes[index].properties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: false))
                    }
                case .category(let index):
                    if property.isClassProperty {
                        headerInfo.categories[index].classProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: true))
                    } else {
                        headerInfo.categories[index].properties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: false))
                    }
                case .protocol(let index, let isOptional):
                    if property.isClassProperty {
                        if isOptional {
                            headerInfo.protocols[index].optionalClassProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: true))
                        } else {
                            headerInfo.protocols[index].classProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: true))
                        }
                    } else {
                        if isOptional {
                            headerInfo.protocols[index].optionalProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: false))
                        } else {
                            headerInfo.protocols[index].properties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, isClassProperty: false))
                        }
                    }
                }
                continue
            }

            if let method = Method.parse(line) {
                switch currentContext {
                case .class(let index):
                    if method.isClassMethod {
                        headerInfo.classes[index].classMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: true))
                    } else {
                        headerInfo.classes[index].methods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: false))
                    }
                case .category(let index):
                    if method.isClassMethod {
                        headerInfo.categories[index].classMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: true))
                    } else {
                        headerInfo.categories[index].methods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: false))
                    }
                case .protocol(let index, let isOptional):
                    if method.isClassMethod {
                        if isOptional {
                            headerInfo.protocols[index].optionalClassMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: true))
                        } else {
                            headerInfo.protocols[index].classMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: true))
                        }
                    } else {
                        if isOptional {
                            headerInfo.protocols[index].optionalMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: false))
                        } else {
                            headerInfo.protocols[index].methods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, isClassMethod: false))
                        }
                    }
                }
            }
        }

        return headerInfo
    }
    
   public struct HeaderInfo {
       public var classes: [Class] = []
       public var protocols: [ProtocolInfo] = []
       public var categories: [Category] = []
    }
    
    public struct Property {
        public let name: String
        public let type: String
        public let attributes: [String]
        public let typeModifiers: [String]
        fileprivate let isClassProperty: Bool
     }
    
    public struct Method {
         public let name: String
         public let argumentTypes: [Argument]
         public let returnType: Argument
         fileprivate let isClassMethod: Bool
        
        public struct Argument {
            public let type: String
            public let modifiers: [String]
        }
     }
     
    public struct Class {
        public let name: String
        public var protocols: [String] = []
        public var classProperties: [Property] = []
        public var properties: [Property] = []
        public var classMethods: [Method] = []
        public var methods: [Method] = []
     }
     
    public struct Category {
        public let name: String
        public let className: String
        public var protocols: [String] = []
        public var classProperties: [Property] = []
        public var properties: [Property] = []
        public var classMethods: [Method] = []
        public var methods: [Method] = []
     }
     
    public struct ProtocolInfo {
        public let name: String
        public var protocols: [String] = []
        public var classProperties: [Property] = []
        public var properties: [Property] = []
        public var classMethods: [Method] = []
        public var methods: [Method] = []
        public var optionalClassProperties: [Property] = []
        public var optionalProperties: [Property] = []
        public var optionalClassMethods: [Method] = []
        public var optionalMethods: [Method] = []
     }
}

fileprivate extension ObjCHeader.Property {
    static func parse(_ line: String) -> Self? {
        guard let semicolonIndex = line.firstIndex(of: ";") else { return nil }
        let declaration = String(line[..<semicolonIndex])
        let propertyBody = declaration._removingPropertyAttributes().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let (type, name) = propertyBody._splitTrailingIdentifier() else { return nil }
        let attributes = declaration._propertyAttributes()
        let parsedType = type._parsedObjCType()
        return .init(name: name, type: parsedType.type, attributes: attributes, typeModifiers: parsedType.modifiers, isClassProperty: attributes.contains("class"))
    }
}

fileprivate extension ObjCHeader.Method {
    static func parse(_ line: String) -> Self? {
        guard let prefix = line.first, prefix == "-" || prefix == "+" else { return nil }
        var index = line.index(after: line.startIndex)
        line._skipWhitespace(from: &index)
        guard index < line.endIndex, line[index] == "(" else { return nil }
        guard let rawReturnType = line._readParenthesizedContent(from: &index) else { return nil }
        let parsedReturnType = rawReturnType._parsedObjCType()

        var selector = ""
        var argumentTypes: [Argument] = []
        var sawColon = false

        while true {
            line._skipWhitespace(from: &index)
            guard let token = line._readIdentifier(from: &index) else { break }
            line._skipWhitespace(from: &index)

            if index < line.endIndex, line[index] == ":" {
                sawColon = true
                selector += token + ":"
                index = line.index(after: index)
                line._skipWhitespace(from: &index)
                guard let rawArgumentType = line._readParenthesizedContent(from: &index) else { return nil }
                let parsedArgumentType = rawArgumentType._parsedObjCType()
                argumentTypes.append(.init(type: parsedArgumentType.type, modifiers: parsedArgumentType.modifiers))
                line._skipWhitespace(from: &index)
                _ = line._readIdentifier(from: &index)
                continue
            }

            if !sawColon {
                selector = token
            }
            break
        }

        guard !selector.isEmpty else { return nil }
        return .init(name: selector, argumentTypes: argumentTypes, returnType: .init(type: parsedReturnType.type, modifiers: parsedReturnType.modifiers), isClassMethod: prefix == "+")
    }
}

fileprivate extension ObjCHeader {
    enum ParseContext {
        case `class`(Int)
        case category(Int)
        case `protocol`(Int, isOptional: Bool)
    }

    struct CategoryKey: Hashable {
        let className: String
        let name: String
    }

    struct Declaration {
        enum Kind {
            case `class`
            case category(className: String, categoryName: String)
        }

        let kind: Kind
        let name: String
        let protocols: [String]

        static func parseInterface(_ line: String) -> Self? {
            let declaration = line.dropFirst("@interface ".count).drop { $0.isWhitespace }
            guard let nameEnd = declaration.firstIndex(where: { $0.isWhitespace || $0 == "(" || $0 == "<" || $0 == ":" || $0 == "{" }) else {
                let className = String(declaration)
                return .init(kind: .class, name: className, protocols: [])
            }

            let className = String(declaration[..<nameEnd])
            guard !className.isEmpty else { return nil }
            let remainder = String(declaration[nameEnd...])._droppingLeadingGenericClause().trimmingCharacters(in: .whitespacesAndNewlines)
            let protocols = remainder._protocolNames()

            if remainder.first == "(",
               let closeParenIndex = remainder.firstIndex(of: ")") {
                let categoryName = remainder[remainder.index(after: remainder.startIndex)..<closeParenIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                return .init(kind: .category(className: className, categoryName: categoryName), name: className, protocols: protocols)
            }

            return .init(kind: .class, name: className, protocols: protocols)
        }

        static func parseProtocol(_ line: String) -> Self? {
            let declaration = line.dropFirst("@protocol ".count).drop { $0.isWhitespace }
            let name = declaration.prefix { !$0.isWhitespace && $0 != "<" }
            guard !name.isEmpty else { return nil }
            return .init(kind: .class, name: String(name), protocols: String(declaration[name.endIndex...])._protocolNames())
        }
    }
}

fileprivate extension String {
    private static let objcTypeModifierTokens: Set<String> = [
        "nullable", "nonnull", "null_unspecified",
        "_Nullable", "_Nonnull", "_Null_unspecified",
        "__nullable", "__nonnull", "__null_unspecified",
        "__kindof",
        "__strong", "__weak", "__unsafe_unretained", "__autoreleasing",
        "const", "volatile", "restrict", "__restrict",
        "in", "out", "inout", "bycopy", "byref", "oneway",
        "NS_NOESCAPE", "NS_REFINED_FOR_SWIFT", "NS_SWIFT_UI_ACTOR"
    ]

    func _objcHeaderLines() -> [String] {
        var lines: [String] = []
        lines.reserveCapacity(components(separatedBy: .newlines).count)

        var current = ""
        current.reserveCapacity(256)
        var index = startIndex
        var isInLineComment = false
        var isInBlockComment = false

        while index < endIndex {
            let char = self[index]
            let nextIndex = self.index(after: index)
            let nextChar = nextIndex < endIndex ? self[nextIndex] : nil

            if isInLineComment {
                if char == "\n" {
                    lines.append(current)
                    current.removeAll(keepingCapacity: true)
                    isInLineComment = false
                }
                index = nextIndex
                continue
            }

            if isInBlockComment {
                if char == "*" && nextChar == "/" {
                    isInBlockComment = false
                    index = self.index(after: nextIndex)
                    continue
                }
                if char == "\n" {
                    lines.append(current)
                    current.removeAll(keepingCapacity: true)
                }
                index = nextIndex
                continue
            }

            if char == "/" && nextChar == "/" {
                isInLineComment = true
                index = self.index(after: nextIndex)
                continue
            }

            if char == "/" && nextChar == "*" {
                isInBlockComment = true
                index = self.index(after: nextIndex)
                continue
            }

            if char == "\n" {
                lines.append(current)
                current.removeAll(keepingCapacity: true)
            } else if char != "\r" {
                current.append(char)
            }
            index = nextIndex
        }

        if !current.isEmpty {
            lines.append(current)
        }
        return lines
    }

    func _countOccurrences(of character: Character) -> Int {
        reduce(into: 0) { result, next in
            if next == character {
                result += 1
            }
        }
    }

    func _propertyAttributes() -> [String] {
        guard let openParen = firstIndex(of: "("),
              let closeParen = self[openParen...].firstIndex(of: ")") else { return [] }
        return self[index(after: openParen)..<closeParen]
            .split(separator: ",")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    }

    func _removingPropertyAttributes() -> String {
        guard let propertyRange = range(of: "@property") else { return self }
        var result = self[propertyRange.upperBound...]
        if let openParen = result.firstIndex(of: "("),
           let closeParen = result[openParen...].firstIndex(of: ")"),
           result[..<openParen].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = result[result.index(after: closeParen)...]
        }
        return String(result)
    }

    func _splitTrailingIdentifier() -> (type: String, name: String)? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var end = trimmed.endIndex
        while end > trimmed.startIndex, trimmed[trimmed.index(before: end)].isWhitespace {
            end = trimmed.index(before: end)
        }

        var start = end
        while start > trimmed.startIndex {
            let previous = trimmed.index(before: start)
            let scalar = trimmed[previous]
            if scalar.isLetter || scalar.isNumber || scalar == "_" {
                start = previous
            } else {
                break
            }
        }

        guard start < end else { return nil }
        let name = String(trimmed[start..<end])
        let type = trimmed[..<start].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !type.isEmpty else { return nil }
        return (type, name)
    }

    func _parsedObjCType() -> (type: String, modifiers: [String]) {
        var modifiers: [String] = []
        var rebuilt = ""
        rebuilt.reserveCapacity(count)

        var index = startIndex
        while index < endIndex {
            let character = self[index]
            if character == "_" || character.isLetter {
                let tokenStart = index
                index = self.index(after: index)
                while index < endIndex, self[index] == "_" || self[index].isLetter || self[index].isNumber {
                    index = self.index(after: index)
                }
                let token = String(self[tokenStart..<index])
                if Self.objcTypeModifierTokens.contains(token) {
                    modifiers.appendIfNeeded(token)
                    if rebuilt.last == " " {
                        rebuilt.removeLast()
                    }
                } else {
                    rebuilt += token
                }
                continue
            }

            rebuilt.append(character)
            index = self.index(after: index)
        }

        let normalizedType = rebuilt._normalizingObjCTypeWhitespace()
        return (normalizedType, modifiers)
    }

    func _protocolNames() -> [String] {
        guard let open = firstIndex(of: "<"),
              let close = self[open...].firstIndex(of: ">") else { return [] }
        return self[index(after: open)..<close]
            .split(separator: ",")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ !$0.isEmpty })
    }

    func _droppingLeadingGenericClause() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.first == "<" else { return trimmed }
        var index = trimmed.startIndex
        var depth = 0

        while index < trimmed.endIndex {
            let character = trimmed[index]
            if character == "<" {
                depth += 1
            } else if character == ">" {
                depth -= 1
                if depth == 0 {
                    let next = trimmed.index(after: index)
                    return String(trimmed[next...])
                }
            }
            index = trimmed.index(after: index)
        }
        return trimmed
    }

    func _normalizingObjCTypeWhitespace() -> String {
        var normalized = ""
        normalized.reserveCapacity(count)
        var previousWasWhitespace = false

        for character in self {
            if character.isWhitespace {
                if !previousWasWhitespace {
                    normalized.append(" ")
                }
                previousWasWhitespace = true
            } else {
                if character == "*", normalized.last == " " {
                    normalized.removeLast()
                }
                normalized.append(character)
                previousWasWhitespace = false
            }
        }
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func _skipWhitespace(from index: inout Index) {
        while index < endIndex, self[index].isWhitespace {
            index = self.index(after: index)
        }
    }

    func _readParenthesizedContent(from index: inout Index) -> String? {
        guard index < endIndex, self[index] == "(" else { return nil }
        index = self.index(after: index)
        let start = index
        var depth = 1

        while index < endIndex {
            let character = self[index]
            if character == "(" {
                depth += 1
            } else if character == ")" {
                depth -= 1
                if depth == 0 {
                    let content = self[start..<index].trimmingCharacters(in: .whitespacesAndNewlines)
                    index = self.index(after: index)
                    return String(content)
                }
            }
            index = self.index(after: index)
        }
        return nil
    }

    func _readIdentifier(from index: inout Index) -> String? {
        guard index < endIndex else { return nil }
        let start = index
        guard self[start] == "_" || self[start].isLetter else { return nil }
        index = self.index(after: start)
        while index < endIndex, self[index] == "_" || self[index].isLetter || self[index].isNumber {
            index = self.index(after: index)
        }
        return String(self[start..<index])
    }
}

fileprivate extension Array where Element == String {
    mutating func appendIfNeeded(_ element: String) {
        guard !contains(element) else { return }
        append(element)
    }
}
