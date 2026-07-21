//
//  ObjCHeaderSimple.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 20.07.26.
//

import Foundation

public enum ObjCHeaderSimple {
    static func _parse(_ file: URL, framework: String) {
        parse(file, framework: framework)
    }

    private static var didCollect = false
    public private(set) static var isCollecting = false

    public static var classesByName: [String: ClassInfo] = [:]
    public static var protocolsByName: [String: ProtocolInfo] = [:]
    public static var categoriesByName: [String: CategoryInfo] = [:]
    public static var categoriesByClass: [String: [CategoryInfo]] = [:]

    static let frameworksFolder = URL(fileURLWithPath: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks")
    static var publicHeadersByFramework: [String: [URL]] = collectPublicHeadersByFramework()

    public static func collectAll(completion: (() -> Void)? = nil) {
        guard !isCollecting, !didCollect else { return }
        isCollecting = true
        defer {
            didCollect = true
            isCollecting = false
            completion?()
        }
        for framework in publicHeadersByFramework.keys.sorted() {
            for file in publicHeadersByFramework[framework] ?? [] {
                parse(file, framework: framework)
            }
        }
    }

    static func parse(_ file: URL, framework: String) {
        guard let header = try? String(contentsOf: file, encoding: .utf8) else {
            return
        }
        var parser = Parser(header: header, headerName: file.deletingPathExtension().lastPathComponent, framework: framework)
        parser.parse()
    }

    public static func `class`(named name: String, collectAllIfNeeded: Bool = true) -> ClassInfo? {
        if didCollect {
            return classesByName[name]
        }
        if let info = classesByName[name] {
            return info
        }
        guard collectAllIfNeeded else { return nil }
        collectAll()
        return classesByName[name]
    }

    public static func `protocol`(named name: String, collectAllIfNeeded: Bool = true) -> ProtocolInfo? {
        if let info = protocolsByName[name] {
            return info
        }
        guard collectAllIfNeeded else { return nil }
        collectAll()
        return protocolsByName[name]
    }

    private static func collectPublicHeadersByFramework() -> [String: [URL]] {
        Dictionary(uniqueKeysWithValues: frameworksFolder
            .iterateFolders().includingPackageContents.map {
                (
                    $0.deletingPathExtension().lastPathComponent,
                    Array($0
                        .iterateFiles()
                        .extensions("h")
                        .recursive
                        .filter { !$0.pathComponents.contains("__impl") })
                ) })
    }

    public struct ClassInfo {
        let name: String
        let framework: String
        let header: String
        var protocols: [String] = []
        var ivars: [String] = []
        var methods: [String] = []
        var classMethods: [String] = []
        var properties: [String] = []
        var classProperties: [String] = []
    }

    public struct ProtocolInfo {
        public let header: String
        public let framework: String
        public let name: String
        public var protocols: [String] = []
        public var properties: [String] = []
        public var classProperties: [String] = []
        public var optionalProperties: [String] = []
        public var optionalClassProperties: [String] = []
        public var methods: [String] = []
        public var classMethods: [String] = []
        public var optionalMethods: [String] = []
        public var optionalClassMethods: [String] = []
    }

    public struct CategoryInfo {
        public let name: String
        public let className: String
        public let header: String
        public let framework: String
        public var protocols: [String]
        public var classProperties: [String] = []
        public var properties: [String] = []
        public var classMethods: [String] = []
        public var methods: [String] = []
    }
}

private extension ObjCHeaderSimple {
    struct InterfaceDeclaration {
        enum Kind {
            case `class`
            case category(className: String, categoryName: String)
        }

        var kind: Kind
        var name: String
        var protocols: [String]
    }

    struct Parser {
        let header: String
        let headerName: String
        let framework: String
        var classInfo: ClassInfo?
        var categoryInfo: CategoryInfo?
        var protocolInfo: ProtocolInfo?
        var isOptional = false
        var ivarBlockDepth = 0
        
        struct InfoCollection {
            let header: String
            let framework: String
            let name: String
            var className: String?
            var protocols: [String] = []
            var ivars: [String] = []
            var methods: [String] = []
            var classMethods: [String] = []
            var properties: [String] = []
            var classProperties: [String] = []
            var optionalProperties: [String] = []
            var optionalClassProperties: [String] = []
            var optionalMethods: [String] = []
            var optionalClassMethods: [String] = []
            var isOptional = false
        }

        init(header: String, headerName: String, framework: String) {
            self.header = header
            self.headerName = headerName
            self.framework = framework
        }

        mutating func parse() {
            for line in header.logicalLines {
                parse(line)
            }
            finishCurrentDeclaration()
        }

        mutating func parse(_ line: String) {
            guard !line.isEmpty, !line.hasPrefix("#") else { return }

            if line == "@end" {
                finishCurrentDeclaration()
                ivarBlockDepth = 0
                return
            }

            if line == "@optional" {
                isOptional = true
                return
            }

            if line == "@required" {
                isOptional = false
                return
            }

            if line.hasPrefix("@interface "),
               let declaration = line.parseInterface()
            {
                finishCurrentDeclaration()
                switch declaration.kind {
                case .class:
                    classInfo = .init(name: declaration.name, framework: framework, header: headerName, protocols: declaration.protocols)
                case .category(let className, let categoryName):
                    categoryInfo = .init(name: categoryName, className: className, header: headerName, framework: framework, protocols: declaration.protocols)
                }
                ivarBlockDepth = line.braceDelta
                collectIvar(from: line)
                return
            }

            if line.hasPrefix("@protocol "),
               let declaration = line.parseProtocolDeclaration()
            {
                finishCurrentDeclaration()
                protocolInfo = .init(header: headerName, framework: framework, name: declaration.name, protocols: declaration.protocols)
                isOptional = false
                if !line.contains(";") {
                    ivarBlockDepth = 0
                } else {
                    finishCurrentDeclaration()
                }
                return
            }

            ivarBlockDepth += line.braceDelta
            if ivarBlockDepth > 0 || line.contains("{") || line.contains("}") {
                collectIvar(from: line)
                return
            }

            if line.hasPrefix("@property"),  let property = line.parseProperty()
            {
                appendProperty(property.name, isClassProperty: property.isClassProperty)
                return
            }

            if let method = line.parseMethod() {
                appendMethod(method.name, isClassMethod: method.isClassMethod)
            }
        }

        mutating func appendProperty(_ name: String, isClassProperty: Bool) {
            if classInfo != nil {
                if isClassProperty {
                    classInfo?.classProperties += name
                } else {
                    classInfo?.properties += name
                }
            } else if categoryInfo != nil {
                if isClassProperty {
                    categoryInfo?.classProperties += name
                } else {
                    categoryInfo?.properties += name
                }
            } else if protocolInfo != nil {
                switch (isClassProperty, isOptional) {
                case (true, true): protocolInfo?.optionalClassProperties += name
                case (true, false): protocolInfo?.classProperties += name
                case (false, true): protocolInfo?.optionalProperties += name
                case (false, false): protocolInfo?.properties += name
                }
            }
        }

        mutating func appendMethod(_ methodName: String, isClassMethod: Bool) {
            if classInfo != nil {
                if isClassMethod {
                    classInfo?.classMethods += methodName
                } else {
                    classInfo?.methods += methodName
                }
            } else if categoryInfo != nil {
                if isClassMethod {
                    categoryInfo?.classMethods += methodName
                } else {
                    categoryInfo?.methods += methodName
                }
            } else if protocolInfo != nil {
                switch (isClassMethod, isOptional) {
                case (true, true): protocolInfo?.optionalClassMethods += methodName
                case (true, false): protocolInfo?.classMethods += methodName
                case (false, true): protocolInfo?.optionalMethods += methodName
                case (false, false): protocolInfo?.methods += methodName
                }
            }
        }

        mutating func collectIvar(from line: String) {
            guard classInfo != nil else { return }
            for declaration in line.ivarDeclarations {
                guard let name = declaration.variableName else { continue }
                classInfo?.ivars.append(name)
            }
        }

        mutating func finishCurrentDeclaration() {
            if let current = classInfo {
                ObjCHeaderSimple.classesByName[current.name] = current
                classInfo = nil
            }
            if let current = protocolInfo {
                ObjCHeaderSimple.protocolsByName[current.name] = current
                protocolInfo = nil
            }
            if let current = categoryInfo {
                ObjCHeaderSimple.categoriesByName[current.name] = current
                ObjCHeaderSimple.categoriesByClass[current.className, default: []] += current
                categoryInfo = nil
            }
            isOptional = false
        }
    }
}

private extension String {
    func droppingLeadingGenericClause() -> String {
        var text = trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.hasPrefix("<"),
              let close = text.matchingAngleClose(from: text.startIndex)
        else {
            return self
        }
        text = String(text[text.index(after: close)...])
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var logicalLines: [String] {
        let stripped = strippingComments()

        var result: [String] = []
        var buffer = ""

        for rawLine in stripped.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if !buffer.isEmpty {
                buffer += " " + line

                if buffer.isCompleteBufferedLine {
                    result.append(buffer.normalizedLine)
                    buffer = ""
                }

                continue
            }

            if line.shouldBuffer, !line.isCompleteBufferedLine {
                buffer = line
            } else {
                result.append(line.normalizedLine)
            }
        }

        if !buffer.isEmpty {
            result.append(buffer.normalizedLine)
        }

        return result
    }

    var shouldBuffer: Bool {
        hasPrefix("@interface ")
            || hasPrefix("@protocol ")
            || hasPrefix("@property")
            || hasPrefix("-")
            || hasPrefix("+")
    }

    var isCompleteBufferedLine: Bool {
        if hasPrefix("@interface ") {
            return contains("{") || !contains("<") || contains(">")
        }

        if hasPrefix("@protocol ") {
            return contains(";") || !contains("<") || contains(">")
        }

        return contains(";")
    }

    var normalizedLine: String {
        replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func strippingComments() -> String {
        var result = ""
        var index = startIndex
        var isInBlockComment = false
        var isInString = false
        var stringDelimiter: Character?

        while index < endIndex {
            let character = self[index]
            let nextIndex = self.index(after: index)
            let next = nextIndex < endIndex ? self[nextIndex] : nil

            if isInBlockComment {
                if character == "\n" {
                    result.append("\n")
                }

                if character == "*", next == "/" {
                    isInBlockComment = false
                    index = self.index(after: nextIndex)
                } else {
                    index = nextIndex
                }

                continue
            }

            if isInString {
                result.append(character)

                if character == stringDelimiter {
                    isInString = false
                    stringDelimiter = nil
                } else if character == "\\", nextIndex < endIndex {
                    result.append(self[nextIndex])
                    index = self.index(after: nextIndex)
                    continue
                }

                index = nextIndex
                continue
            }

            if character == "\"" || character == "'" {
                isInString = true
                stringDelimiter = character
                result.append(character)
                index = nextIndex
                continue
            }

            if character == "/", next == "*" {
                isInBlockComment = true
                index = self.index(after: nextIndex)
                continue
            }

            if character == "/", next == "/" {
                while index < endIndex, self[index] != "\n" {
                    index = self.index(after: index)
                }

                continue
            }

            result.append(character)
            index = nextIndex
        }

        return result
    }

    // MARK: - Interface declarations

    func parseInterface() -> ObjCHeaderSimple.InterfaceDeclaration? {
        let declaration = String(dropFirst("@interface ".count))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let className = declaration.identifierAtStart else {
            return nil
        }

        let remainderStart = declaration.index(
            declaration.startIndex,
            offsetBy: className.count
        )

        let remainder = String(declaration[remainderStart...])
            .droppingLeadingGenericClause()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let protocols = remainder.protocolNames

        if remainder.hasPrefix("("),
           let closeIndex = remainder.firstIndex(of: ")")
        {
            let name = remainder[
                remainder.index(after: remainder.startIndex)..<closeIndex
            ]
            .trimmingCharacters(in: .whitespacesAndNewlines)

            guard name.isEmpty || name.isObjCIdentifier else {
                return nil
            }

            return .init(
                kind: .category(
                    className: className,
                    categoryName: name
                ),
                name: className,
                protocols: protocols
            )
        }

        return .init(
            kind: .class,
            name: className,
            protocols: protocols
        )
    }

    func parseProtocolDeclaration() -> (
        name: String,
        protocols: [String]
    )? {
        let declaration = String(dropFirst("@protocol ".count))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let name = declaration.identifierAtStart else {
            return nil
        }

        let remainderStart = declaration.index(
            declaration.startIndex,
            offsetBy: name.count
        )

        let remainder = String(declaration[remainderStart...])

        return (
            name,
            remainder.protocolNames
        )
    }

    // MARK: - Properties and methods

    func parseProperty() -> (
        name: String,
        isClassProperty: Bool
    )? {
        guard let semicolon = firstIndex(of: ";") else {
            return nil
        }

        var declaration = String(self[..<semicolon])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        declaration = String(
            declaration.dropFirst("@property".count)
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)

        var isClassProperty = false

        if declaration.hasPrefix("("),
           let end = declaration.matchingCloseParen(
               from: declaration.startIndex
           )
        {
            let attributes = String(
                declaration[
                    declaration.index(after: declaration.startIndex)..<end
                ]
            )

            isClassProperty = attributes
                .split(separator: ",")
                .contains {
                    $0.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) == "class"
                }

            declaration = String(
                declaration[declaration.index(after: end)...]
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return declaration.variableName.map {
            ($0, isClassProperty)
        }
    }

    func parseMethod() -> (
        name: String,
        isClassMethod: Bool
    )? {
        guard let prefix = first,
              prefix == "-" || prefix == "+"
        else {
            return nil
        }

        var index = self.index(after: startIndex)
        skipWhitespace(from: &index)

        guard index < endIndex,
              self[index] == "(",
              let closeReturn = matchingCloseParen(from: index)
        else {
            return nil
        }

        index = self.index(after: closeReturn)

        var selector = ""
        var sawColon = false

        while index < endIndex {
            skipWhitespace(from: &index)

            guard let token = readIdentifier(from: &index) else {
                break
            }

            skipWhitespace(from: &index)

            if index < endIndex, self[index] == ":" {
                sawColon = true
                selector += token + ":"
                index = self.index(after: index)

                skipWhitespace(from: &index)

                if index < endIndex,
                   self[index] == "(",
                   let closeArgument = matchingCloseParen(from: index)
                {
                    index = self.index(after: closeArgument)
                }

                _ = readIdentifier(from: &index)
                continue
            }

            if !sawColon {
                selector = token
            }

            break
        }

        guard !selector.isEmpty else {
            return nil
        }

        return (
            selector,
            prefix == "+"
        )
    }

    // MARK: - Instance variables

    var ivarDeclarations: [String] {
        var body = self

        if let open = body.firstIndex(of: "{") {
            body = String(body[body.index(after: open)...])
        }

        if let close = body.firstIndex(of: "}") {
            body = String(body[..<close])
        }

        return body
            .split(separator: ";")
            .map(String.init)
    }

    var variableName: String? {
        let trimmed = trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        .trimmingCharacters(
            in: CharacterSet(charactersIn: ";")
        )
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty,
              !trimmed.hasPrefix("@"),
              !trimmed.hasPrefix("#")
        else {
            return nil
        }

        if let blockMarker = trimmed.range(of: "(^") {
            let start = blockMarker.upperBound
            let name = trimmed[start...].prefix {
                $0.isObjCIdentifierCharacter
            }

            if !name.isEmpty {
                return String(name)
            }
        }

        var end = trimmed.endIndex

        while end > trimmed.startIndex {
            let previous = trimmed.index(before: end)

            guard !trimmed[previous].isObjCIdentifierCharacter else {
                break
            }

            end = previous
        }

        guard end > trimmed.startIndex else {
            return nil
        }

        var start = end

        while start > trimmed.startIndex {
            let previous = trimmed.index(before: start)

            guard trimmed[previous].isObjCIdentifierCharacter else {
                break
            }

            start = previous
        }

        let name = String(trimmed[start..<end])
        return name.isObjCIdentifier ? name : nil
    }

    // MARK: - Protocols

    var protocolNames: [String] {
        guard let open = firstIndex(of: "<"),
              let close = matchingAngleClose(from: open)
        else {
            return []
        }

        return self[index(after: open)..<close]
            .split(separator: ",")
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter(\.isObjCIdentifier)
    }

    // MARK: - Identifiers

    var identifierAtStart: String? {
        let name = prefix {
            $0.isObjCIdentifierCharacter
        }

        guard !name.isEmpty else {
            return nil
        }

        let result = String(name)
        return result.isObjCIdentifier ? result : nil
    }

    func readIdentifier(
        from index: inout String.Index
    ) -> String? {
        guard index < endIndex,
              self[index].isObjCIdentifierStart
        else {
            return nil
        }

        let start = index
        index = self.index(after: index)

        while index < endIndex,
              self[index].isObjCIdentifierCharacter
        {
            index = self.index(after: index)
        }

        return String(self[start..<index])
    }

    var isObjCIdentifier: Bool {
        guard let first,
              first.isObjCIdentifierStart
        else {
            return false
        }

        return dropFirst().allSatisfy(
            \.isObjCIdentifierCharacter
        )
    }

    // MARK: - Whitespace

    func skipWhitespace(
        from index: inout String.Index
    ) {
        while index < endIndex,
              self[index].isWhitespace
        {
            index = self.index(after: index)
        }
    }

    // MARK: - Delimiters

    var braceDelta: Int {
        reduce(into: 0) { result, character in
            if character == "{" {
                result += 1
            } else if character == "}" {
                result -= 1
            }
        }
    }

    func matchingCloseParen(
        from open: String.Index
    ) -> String.Index? {
        matchingClose(
            from: open,
            open: "(",
            close: ")"
        )
    }

    func matchingAngleClose(
        from open: String.Index
    ) -> String.Index? {
        matchingClose(
            from: open,
            open: "<",
            close: ">"
        )
    }

    func matchingClose(
        from openIndex: String.Index,
        open: Character,
        close: Character
    ) -> String.Index? {
        var depth = 0
        var index = openIndex

        while index < endIndex {
            if self[index] == open {
                depth += 1
            } else if self[index] == close {
                depth -= 1

                if depth == 0 {
                    return index
                }
            }

            index = self.index(after: index)
        }

        return nil
    }
}

private extension Character {
    var isObjCIdentifierStart: Bool {
        self == "_" || isLetter
    }

    var isObjCIdentifierCharacter: Bool {
        isObjCIdentifierStart || isNumber
    }
}
