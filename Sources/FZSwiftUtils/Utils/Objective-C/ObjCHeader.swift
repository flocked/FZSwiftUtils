//
//  ObjCHeader.swift
//
//
//  Created by Florian Zand on 28.03.26.
//

import Foundation

public enum ObjCHeader {
    public struct ParseOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let classes = Self(rawValue: 1 << 0)
        public static let categories = Self(rawValue: 1 << 1)
        public static let protocols = Self(rawValue: 1 << 2)
        public static let enums = Self(rawValue: 1 << 3)
        public static let optionSets = Self(rawValue: 1 << 4)
        public static let bridgedTypedefs = Self(rawValue: 1 << 5)
        public static let exportedConstants = Self(rawValue: 1 << 6)
        public static let structTypedefs = Self(rawValue: 1 << 7)
        public static let blockTypedefs = Self(rawValue: 1 << 8)
        public static let apiDeprecations = Self(rawValue: 1 << 9)
        public static let apiAvailabilities = Self(rawValue: 1 << 10)

        public static let `default`: Self = [.classes, .categories, .protocols, .enums, .optionSets, .structTypedefs, .blockTypedefs]

        public static let all: Self = [.classes, .categories, .protocols, .enums, .optionSets, .bridgedTypedefs, .exportedConstants, .structTypedefs, .blockTypedefs, .apiDeprecations, .apiAvailabilities]
    }

    static let frameworksFolder = URL.file("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks")
    static var publicHeaderURLs = frameworksFolder.iterateFiles().includingPackageContents.extensions("h").recursive.collect()

    public static var protocolsByName: [String: ProtocolInfo] = [:]
    public static var classesByName: [String: Class] = [:]
    public static var categoriesByName: [String: Category] = [:]
    public static var categoriesByClass: [String: [Category]] = [:]
    public static var enumsByName: [String: EnumInfo] = [:]
    public static var optionSetsByName: [String: OptionSetInfo] = [:]
    public static var structTypedefsByName: [String: StructTypedef] = [:]
    public static var bridgedTypedefsByName: [String: BridgedTypedef] = [:]
    public static var didCollect = false
    
    public static func getClass(named name: String) -> Class? {
        if didCollect {
            return classesByName[name]
        } else if let file = publicHeaderURLs.removeFirst(where: { $0.nameExludingExtension == name }) {
                return parse(file)?.classes.first(where: { $0.name == name })
        }
        collectAll()
        return classesByName[name]
    }
    
    public static func collectAll(options: ParseOptions = .all) {
        if options == .all {
            guard !didCollect else { return }
            didCollect = true
        }
        for file in publicHeaderURLs {
           parse(file, options: options)
        }
    }
    
    @discardableResult
    public static func parse(_ file: URL, options: ParseOptions = .all) -> HeaderInfo? {
        guard let header = try? String(contentsOf: file, encoding: .utf8) else { return nil }
        let info = parse(header, options: options)
        info.classes.forEach({ classesByName[$0.name] = $0 })
        info.protocols.forEach({ protocolsByName[$0.name] = $0 })
        info.categories.forEach({
            categoriesByName[$0.name] = $0
            categoriesByClass[$0.className, default: []] += $0
        })
        info.enums.forEach({ enumsByName[$0.name] = $0 })
        info.optionSets.forEach({ optionSetsByName[$0.name] = $0 })
        info.structTypedefs.forEach({ structTypedefsByName[$0.name] = $0 })
        info.bridgedTypedefs.forEach({ bridgedTypedefsByName[$0.name] = $0 })
        return info
    }
    
    public static func parseClassNames(_ header: String) -> [String] {
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
    
    public static func parse(_ header: String, options: ParseOptions = .all) -> HeaderInfo {
        let lines = header._objcHeaderLines()
        var headerInfo = HeaderInfo()
        var classIndices: [String: Int] = [:]
        var protocolIndices: [String: Int] = [:]
        var categoryIndices: [CategoryKey: Int] = [:]

        var currentContext: ParseContext?
        var ivarBlockDepth = 0
        var enumBuilder: EnumBuilder?
        var topLevelStatement: TopLevelStatementBuilder?

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if var builder = topLevelStatement {
                builder.consume(line)
                if builder.isComplete {
                    builder.appendParsedResults(to: &headerInfo, options: options)
                    topLevelStatement = nil
                } else {
                    topLevelStatement = builder
                }
                continue
            }

            if var builder = enumBuilder {
                builder.consume(line)
                if builder.isComplete {
                    switch builder.kind {
                    case .enum where options.contains(.enums):
                        headerInfo.enums.append(builder.makeEnumInfo())
                    case .optionSet where options.contains(.optionSets):
                        headerInfo.optionSets.append(builder.makeOptionSetInfo())
                    default:
                        break
                    }
                    enumBuilder = nil
                } else {
                    enumBuilder = builder
                }
                continue
            }

            if currentContext == nil, let declaration = EnumDeclaration.parse(line) {
                var builder = EnumBuilder(declaration: declaration)
                builder.consume(line)
                if builder.isComplete {
                    switch builder.kind {
                    case .enum where options.contains(.enums):
                        headerInfo.enums.append(builder.makeEnumInfo())
                    case .optionSet where options.contains(.optionSets):
                        headerInfo.optionSets.append(builder.makeOptionSetInfo())
                    default:
                        break
                    }
                } else {
                    enumBuilder = builder
                }
                continue
            }

            if currentContext == nil, let statementBuilder = TopLevelStatementBuilder.starting(with: line, options: options) {
                if statementBuilder.isComplete {
                    var builder = statementBuilder
                    builder.appendParsedResults(to: &headerInfo, options: options)
                } else {
                    topLevelStatement = statementBuilder
                }
                continue
            }

            if (options.contains(.classes) || options.contains(.categories)),
               line.hasPrefix("@interface "),
               let declaration = Declaration.parseInterface(line) {
                ivarBlockDepth = line._countOccurrences(of: "{") - line._countOccurrences(of: "}")
                switch declaration.kind {
                case .class:
                    guard options.contains(.classes) else { continue }
                    let index = classIndices[declaration.name] ?? {
                        let index = headerInfo.classes.count
                        headerInfo.classes.append(.init(name: declaration.name))
                        classIndices[declaration.name] = index
                        return index
                    }()
                    headerInfo.classes[index].superclass = declaration.superclass
                    if options.contains(.apiDeprecations) {
                        headerInfo.classes[index].apiDeprecated = declaration.apiDeprecated
                    }
                    if options.contains(.apiAvailabilities) {
                        headerInfo.classes[index].apiAvailable = declaration.apiAvailable
                    }
                    if !declaration.protocols.isEmpty {
                        headerInfo.classes[index].protocols.append(contentsOf: declaration.protocols.filter({ !headerInfo.classes[index].protocols.contains($0) }))
                    }
                    currentContext = .class(index)
                case .category(let className, let categoryName):
                    guard options.contains(.categories) else { continue }
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
                    if options.contains(.apiDeprecations) {
                        headerInfo.categories[index].apiDeprecated = declaration.apiDeprecated
                    }
                    if options.contains(.apiAvailabilities) {
                        headerInfo.categories[index].apiAvailable = declaration.apiAvailable
                    }
                    currentContext = .category(index)
                }
                continue
            }

            if options.contains(.protocols),
               line.hasPrefix("@protocol "),
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
                if options.contains(.apiDeprecations) {
                    headerInfo.protocols[index].apiDeprecated = declaration.apiDeprecated
                }
                if options.contains(.apiAvailabilities) {
                    headerInfo.protocols[index].apiAvailable = declaration.apiAvailable
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
               let property = Property.parse(line, parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                switch currentContext {
                case .class(let index):
                    if property.isClassProperty {
                        headerInfo.classes[index].classProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: true))
                    } else {
                        headerInfo.classes[index].properties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: false))
                    }
                case .category(let index):
                    if property.isClassProperty {
                        headerInfo.categories[index].classProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: true))
                    } else {
                        headerInfo.categories[index].properties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: false))
                    }
                case .protocol(let index, let isOptional):
                    if property.isClassProperty {
                        if isOptional {
                            headerInfo.protocols[index].optionalClassProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: true))
                        } else {
                            headerInfo.protocols[index].classProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: true))
                        }
                    } else {
                        if isOptional {
                            headerInfo.protocols[index].optionalProperties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: false))
                        } else {
                            headerInfo.protocols[index].properties.append(.init(name: property.name, type: property.type, attributes: property.attributes, typeModifiers: property.typeModifiers, apiDeprecated: property.apiDeprecated, apiAvailable: property.apiAvailable, isClassProperty: false))
                        }
                    }
                }
                continue
            }

            if let method = Method.parse(line, parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                switch currentContext {
                case .class(let index):
                    if method.isClassMethod {
                        headerInfo.classes[index].classMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: true))
                    } else {
                        headerInfo.classes[index].methods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: false))
                    }
                case .category(let index):
                    if method.isClassMethod {
                        headerInfo.categories[index].classMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: true))
                    } else {
                        headerInfo.categories[index].methods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: false))
                    }
                case .protocol(let index, let isOptional):
                    if method.isClassMethod {
                        if isOptional {
                            headerInfo.protocols[index].optionalClassMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: true))
                        } else {
                            headerInfo.protocols[index].classMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: true))
                        }
                    } else {
                        if isOptional {
                            headerInfo.protocols[index].optionalMethods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: false))
                        } else {
                            headerInfo.protocols[index].methods.append(.init(name: method.name, argumentTypes: method.argumentTypes, returnType: method.returnType, apiDeprecated: method.apiDeprecated, apiAvailable: method.apiAvailable, isClassMethod: false))
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
       public var enums: [EnumInfo] = []
       public var optionSets: [OptionSetInfo] = []
       public var bridgedTypedefs: [BridgedTypedef] = []
       public var exportedConstants: [ExportedConstant] = []
       public var structTypedefs: [StructTypedef] = []
       public var opaqueStructTypedefs: [OpaqueStructTypedef] = []
       public var opaqueStructPointerTypedefs: [OpaqueStructPointerTypedef] = []
       public var blockTypedefs: [BlockTypedef] = []
    }
    
    public struct Property {
        public let name: String
        public let type: String
        public let attributes: [String]
        public let typeModifiers: [String]
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?
        fileprivate let isClassProperty: Bool

        init(name: String, type: String, attributes: [String], typeModifiers: [String], apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?, isClassProperty: Bool) {
            self.name = name
            self.type = type
            self.attributes = attributes
            self.typeModifiers = typeModifiers
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
            self.isClassProperty = isClassProperty
        }
     }
    
    public struct Method {
         public let name: String
         public let argumentTypes: [Argument]
         public let returnType: Argument
         public let apiDeprecated: APIDeprecation?
         public let apiAvailable: APIAvailability?
         fileprivate let isClassMethod: Bool

         init(name: String, argumentTypes: [Argument], returnType: Argument, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?, isClassMethod: Bool) {
            self.name = name
            self.argumentTypes = argumentTypes
            self.returnType = returnType
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
            self.isClassMethod = isClassMethod
         }
        
        public struct Argument {
            public let type: String
            public let typeModifiers: [String]
            public let name: String?

            public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
                let typeString = _objcTypeString(type: type, modifiers: typeModifiers)
                if let name, !name.isEmpty, typeString.contains("(^)") {
                    return typeString.replacingOccurrences(of: "(^)", with: "(^\(name))")
                }
                guard let name, !name.isEmpty else { return typeString }
                return "\(typeString) \(name)"
            }
         }
     }

    public struct EnumInfo {
        public let name: String
        public let rawType: String?
        public let declarationStyle: DeclarationStyle
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?
        public var cases: [EnumCase] = []

        init(name: String, rawType: String?, declarationStyle: DeclarationStyle, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?, cases: [EnumCase]) {
            self.name = name
            self.rawType = rawType
            self.declarationStyle = declarationStyle
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
            self.cases = cases
        }

        public enum DeclarationStyle {
            case nsEnum
            case cfEnum
            case typedefEnum
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let casesString = cases.map({ "    " + $0.headerString(includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) }).joined(separator: ",\n")
            let body = casesString.isEmpty ? "" : "\n\(casesString)\n"
            let declaration: String
            switch declarationStyle {
            case .nsEnum:
                declaration = "typedef NS_ENUM(\(rawType ?? "NSInteger"), \(name)) {\(body)}"
            case .cfEnum:
                declaration = "typedef CF_ENUM(\(rawType ?? "CFIndex"), \(name)) {\(body)}"
            case .typedefEnum:
                let raw = rawType.map({ " \($0)" }) ?? ""
                declaration = "typedef enum\(raw) {\(body)} \(name)"
            }
            return declaration + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }

    public struct OptionSetInfo {
        public let name: String
        public let rawType: String?
        public let declarationStyle: DeclarationStyle
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?
        public var cases: [EnumCase] = []

        init(name: String, rawType: String?, declarationStyle: DeclarationStyle, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?, cases: [EnumCase]) {
            self.name = name
            self.rawType = rawType
            self.declarationStyle = declarationStyle
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
            self.cases = cases
        }

        public enum DeclarationStyle {
            case nsOptions
            case cfOptions
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let casesString = cases.map({ "    " + $0.headerString(includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) }).joined(separator: ",\n")
            let body = casesString.isEmpty ? "" : "\n\(casesString)\n"
            let declaration: String
            switch declarationStyle {
            case .nsOptions:
                declaration = "typedef NS_OPTIONS(\(rawType ?? "NSUInteger"), \(name)) {\(body)}"
            case .cfOptions:
                declaration = "typedef CF_OPTIONS(\(rawType ?? "CFOptionFlags"), \(name)) {\(body)}"
            }
            return declaration + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }

    public struct EnumCase {
        public let name: String
        public let rawValue: String?
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?

        init(name: String, rawValue: String?, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?) {
            self.name = name
            self.rawValue = rawValue
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let declaration = rawValue.map({ "\(name) = \($0)" }) ?? name
            return declaration + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated)
        }
    }

    public struct APIDeprecation {
        public let message: String?
        public let replacement: String?
        public let platform: String?
        public let introducedVersion: String?
        public let deprecatedVersion: String?
        public let rawMacro: String

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            rawMacro
        }
    }

    public struct APIAvailability {
        public let platforms: [Platform]
        public let rawMacro: String

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            rawMacro
        }

        public struct Platform {
            public let name: String
            public let introducedVersion: String?
        }
    }

    public struct BridgedTypedef {
        public let name: String
        public let underlyingType: String
        public let kind: Kind
        public let attributes: [String]
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?

        init(name: String, underlyingType: String, kind: Kind, attributes: [String], apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?) {
            self.name = name
            self.underlyingType = underlyingType
            self.kind = kind
            self.attributes = attributes
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
        }

        public enum Kind {
            case typedEnum
            case extensibleTypedEnum
            case swiftBridged
            case closedEnum
            case other
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let attributesString = attributes.joined(separator: " ")
            let suffix = [
                attributesString,
                includeAPIDeprecated ? apiDeprecated?.headerString() : nil,
                includeAPIAvailable ? apiAvailable?.headerString() : nil
            ]
                .compactMap({ value -> String? in
                    guard let value, !value.isEmpty else { return nil }
                    return value
                })
                .joined(separator: " ")
            if suffix.isEmpty {
                return "typedef \(underlyingType) \(name);"
            }
            return "typedef \(underlyingType) \(name) \(suffix);"
        }
    }

    public struct ExportedConstant {
        public let name: String
        public let type: String
        public let typeModifiers: [String]
        public let declarationSpecifier: String
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?

        init(name: String, type: String, typeModifiers: [String], declarationSpecifier: String, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?) {
            self.name = name
            self.type = type
            self.typeModifiers = typeModifiers
            self.declarationSpecifier = declarationSpecifier
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let declaration = "\(declarationSpecifier) \(_objcTypeString(type: type, modifiers: typeModifiers)) \(name)"
            return declaration + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }

    public struct StructTypedef {
        public let name: String
        public let tagName: String?
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?
        public let fields: [Field]

        init(name: String, tagName: String?, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?, fields: [Field]) {
            self.name = name
            self.tagName = tagName
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
            self.fields = fields
        }

        public struct Field {
            public let name: String
            public let type: String
            public let typeModifiers: [String]

            public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
                "\(_objcTypeString(type: type, modifiers: typeModifiers)) \(name);"
            }
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let tag = tagName.map({ " \($0)" }) ?? ""
            let fieldsString = fields
                .map({ "    \(_objcTypeString(type: $0.type, modifiers: $0.typeModifiers)) \($0.name);" })
                .joined(separator: "\n")
            let body = fieldsString.isEmpty ? "" : "\n\(fieldsString)\n"
            return "typedef struct\(tag) {\(body)} \(name)" + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }

    public struct OpaqueStructTypedef {
        public let name: String
        public let tagName: String?
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?

        init(name: String, tagName: String?, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?) {
            self.name = name
            self.tagName = tagName
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let tag = tagName ?? name
            return "typedef struct \(tag) \(name)" + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }

    public struct OpaqueStructPointerTypedef {
        public let name: String
        public let tagName: String?
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?

        init(name: String, tagName: String?, apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?) {
            self.name = name
            self.tagName = tagName
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let tag = tagName ?? name
            return "typedef struct \(tag) *\(name)" + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }

    public struct BlockTypedef {
        public let name: String
        public let returnType: Method.Argument
        public let argumentTypes: [Method.Argument]
        public let apiDeprecated: APIDeprecation?
        public let apiAvailable: APIAvailability?

        init(name: String, returnType: Method.Argument, argumentTypes: [Method.Argument], apiDeprecated: APIDeprecation?, apiAvailable: APIAvailability?) {
            self.name = name
            self.returnType = returnType
            self.argumentTypes = argumentTypes
            self.apiDeprecated = apiDeprecated
            self.apiAvailable = apiAvailable
        }

        public func headerString(includeAPIAvailable: Bool = true, includeAPIDeprecated: Bool = true) -> String {
            let argumentsString = argumentTypes.isEmpty ? "void" : argumentTypes.map({ $0.headerString(includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) }).joined(separator: ", ")
            let declaration = "typedef \(returnType.headerString(includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated)) (^\(name))(\(argumentsString))"
            return declaration + _declarationMacroSuffix(apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, includeAPIAvailable: includeAPIAvailable, includeAPIDeprecated: includeAPIDeprecated) + ";"
        }
    }
     
    public struct Class {
        public let name: String
        public var superclass: String?
        public var apiDeprecated: APIDeprecation? = nil
        public var apiAvailable: APIAvailability? = nil
        public var protocols: [String] = []
        public var classProperties: [Property] = []
        public var properties: [Property] = []
        public var classMethods: [Method] = []
        public var methods: [Method] = []
     }
     
    public struct Category {
        public let name: String
        public let className: String
        public var apiDeprecated: APIDeprecation? = nil
        public var apiAvailable: APIAvailability? = nil
        public var protocols: [String] = []
        public var classProperties: [Property] = []
        public var properties: [Property] = []
        public var classMethods: [Method] = []
        public var methods: [Method] = []
     }
     
    public struct ProtocolInfo {
        public let name: String
        public var apiDeprecated: APIDeprecation? = nil
        public var apiAvailable: APIAvailability? = nil
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

fileprivate func _objcTypeString(type: String, modifiers: [String]) -> String {
    let modifiersString = modifiers.joined(separator: " ")
    if modifiersString.isEmpty {
        return type
    }
    return "\(modifiersString) \(type)"
}

fileprivate func _declarationMacroSuffix(apiDeprecated: ObjCHeader.APIDeprecation?, apiAvailable: ObjCHeader.APIAvailability?, includeAPIAvailable: Bool, includeAPIDeprecated: Bool) -> String {
    let components = [includeAPIDeprecated ? apiDeprecated?.headerString() : nil, includeAPIAvailable ? apiAvailable?.headerString() : nil].nonNil.filter({!$0.isEmpty})
    guard !components.isEmpty else { return "" }
    return " " + components.joined(separator: " ")
}

fileprivate extension ObjCHeader.Property {
    static func parse(_ line: String, parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> Self? {
        guard let semicolonIndex = line.firstIndex(of: ";") else { return nil }
        let declaration = String(line[..<semicolonIndex])
        let propertyBody = declaration._removingTrailingAttributeClauses()._removingPropertyAttributes().trimmingCharacters(in: .whitespacesAndNewlines)
        let apiDeprecated = parseAPIDeprecation ? declaration._parsedAPIDeprecation() : nil
        let apiAvailable = parseAPIAvailability ? declaration._parsedAPIAvailability() : nil
        if let blockProperty = propertyBody._parsedBlockProperty() {
            return .init(name: blockProperty.name, type: blockProperty.type, attributes: declaration._propertyAttributes(), typeModifiers: blockProperty.typeModifiers, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, isClassProperty: declaration._propertyAttributes().contains("class"))
        }
        guard let (type, name) = propertyBody._splitTrailingIdentifier() else { return nil }
        let attributes = declaration._propertyAttributes()
        let parsedType = type._parsedObjCType()
        return .init(name: name, type: parsedType.type, attributes: attributes, typeModifiers: parsedType.typeModifiers, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, isClassProperty: attributes.contains("class"))
    }
}

fileprivate extension ObjCHeader.Method {
    static func parse(_ line: String, parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> Self? {
        guard let prefix = line.first, prefix == "-" || prefix == "+" else { return nil }
        let apiDeprecated = parseAPIDeprecation ? line._parsedAPIDeprecation() : nil
        let apiAvailable = parseAPIAvailability ? line._parsedAPIAvailability() : nil
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
                line._skipWhitespace(from: &index)
                let argumentName = line._readIdentifier(from: &index)
                argumentTypes.append(.init(type: parsedArgumentType.type, typeModifiers: parsedArgumentType.typeModifiers, name: argumentName))
                line._skipWhitespace(from: &index)
                continue
            }

            if !sawColon {
                selector = token
            }
            break
        }

        guard !selector.isEmpty else { return nil }
        return .init(name: selector, argumentTypes: argumentTypes, returnType: .init(type: parsedReturnType.type, typeModifiers: parsedReturnType.typeModifiers, name: nil), apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, isClassMethod: prefix == "+")
    }
}

fileprivate extension ObjCHeader {
    enum EnumKind {
        case `enum`
        case optionSet
    }

    enum ParseContext {
        case `class`(Int)
        case category(Int)
        case `protocol`(Int, isOptional: Bool)
    }

    struct CategoryKey: Hashable {
        let className: String
        let name: String
    }

    struct EnumDeclaration {
        let kind: EnumKind
        let name: String
        let rawType: String?
        let declarationStyle: DeclarationStyle
        let apiDeprecated: APIDeprecation?
        let apiAvailable: APIAvailability?

        enum DeclarationStyle {
            case nsEnum
            case cfEnum
            case typedefEnum
            case nsOptions
            case cfOptions
        }

        static func parse(_ line: String) -> Self? {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("typedef") else { return nil }

            if let declaration = parseMacro(trimmed, macro: "NS_OPTIONS", kind: .optionSet, declarationStyle: .nsOptions)
                ?? parseMacro(trimmed, macro: "CF_OPTIONS", kind: .optionSet, declarationStyle: .cfOptions)
                ?? parseMacro(trimmed, macro: "NS_ENUM", kind: .enum, declarationStyle: .nsEnum)
                ?? parseMacro(trimmed, macro: "CF_ENUM", kind: .enum, declarationStyle: .cfEnum) {
                return declaration
            }

            return parseTypedefEnum(trimmed)
        }

        private static func parseMacro(_ line: String, macro: String, kind: EnumKind, declarationStyle: DeclarationStyle) -> Self? {
            guard let macroRange = line.range(of: macro + "(") else { return nil }
            let argumentsStart = macroRange.upperBound
            guard let closeParen = line[argumentsStart...].firstIndex(of: ")") else { return nil }
            let arguments = line[argumentsStart..<closeParen]
                .split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
                .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            guard arguments.count == 2, !arguments[1].isEmpty else { return nil }
            return .init(kind: kind, name: arguments[1], rawType: arguments[0].isEmpty ? nil : arguments[0], declarationStyle: declarationStyle, apiDeprecated: line._parsedAPIDeprecation(), apiAvailable: line._parsedAPIAvailability())
        }

        private static func parseTypedefEnum(_ line: String) -> Self? {
            guard line.hasPrefix("typedef enum") else { return nil }

            let afterEnum = line.dropFirst("typedef enum".count).trimmingCharacters(in: .whitespacesAndNewlines)
            let beforeBrace = String(afterEnum.prefix(while: { $0 != "{" })).trimmingCharacters(in: .whitespacesAndNewlines)
            let rawType = beforeBrace.isEmpty ? nil : beforeBrace

            if let openBrace = line.firstIndex(of: "{") {
                let tail = line[line.index(after: openBrace)...]
                let name = tail.prefix { !$0.isWhitespace && $0 != ";" }
                if !name.isEmpty {
                    return .init(kind: .enum, name: String(name), rawType: rawType, declarationStyle: .typedefEnum, apiDeprecated: line._parsedAPIDeprecation(), apiAvailable: line._parsedAPIAvailability())
                }
            }

            return .init(kind: .enum, name: "", rawType: rawType, declarationStyle: .typedefEnum, apiDeprecated: line._parsedAPIDeprecation(), apiAvailable: line._parsedAPIAvailability())
        }
    }

    struct EnumBuilder {
        let kind: EnumKind
        private(set) var name: String
        let rawType: String?
        let declarationStyle: EnumDeclaration.DeclarationStyle
        private(set) var apiDeprecated: APIDeprecation?
        private(set) var apiAvailable: APIAvailability?
        private(set) var cases: [EnumCase] = []
        private(set) var braceDepth: Int = 0
        private(set) var didEnterBody = false
        private(set) var isComplete = false

        init(declaration: EnumDeclaration) {
            kind = declaration.kind
            name = declaration.name
            rawType = declaration.rawType
            declarationStyle = declaration.declarationStyle
            apiDeprecated = declaration.apiDeprecated
            apiAvailable = declaration.apiAvailable
        }

        mutating func consume(_ line: String) {
            guard !isComplete else { return }

            if let openBrace = line.firstIndex(of: "{") {
                didEnterBody = true
                braceDepth += line._countOccurrences(of: "{")
                braceDepth -= line._countOccurrences(of: "}")

                let afterBrace = String(line[line.index(after: openBrace)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !afterBrace.isEmpty {
                    consumeBody(afterBrace)
                }
            } else if didEnterBody {
                braceDepth += line._countOccurrences(of: "{")
                braceDepth -= line._countOccurrences(of: "}")
                consumeBody(line)
            } else {
                return
            }

            if didEnterBody, braceDepth <= 0 {
                apiDeprecated = apiDeprecated ?? line._parsedAPIDeprecation()
                apiAvailable = apiAvailable ?? line._parsedAPIAvailability()
                if name.isEmpty {
                    name = line._enumTrailingName() ?? name
                }
                isComplete = !name.isEmpty
            }
        }

        private mutating func consumeBody(_ line: String) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            if let closeBrace = trimmed.firstIndex(of: "}") {
                let beforeBrace = String(trimmed[..<closeBrace]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !beforeBrace.isEmpty {
                    parseCases(from: beforeBrace)
                }
                if name.isEmpty {
                    let trailing = String(trimmed[trimmed.index(after: closeBrace)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trailing.isEmpty {
                        let candidateName = trailing._splitTopLevel(separator: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        if !candidateName.isEmpty {
                            name = candidateName
                        }
                    }
                }
                return
            }

            parseCases(from: trimmed)
        }

        private mutating func parseCases(from text: String) {
            for segment in text._splitTopLevel(separator: ",") {
                let candidate = segment.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !candidate.isEmpty else { continue }
                guard let parsedCase = candidate._parsedEnumCase() else { continue }
                cases.append(parsedCase)
            }
        }

        func makeEnumInfo() -> EnumInfo {
            .init(name: name, rawType: rawType, declarationStyle: declarationStyle == .cfEnum ? .cfEnum : declarationStyle == .nsEnum ? .nsEnum : .typedefEnum, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, cases: cases)
        }

        func makeOptionSetInfo() -> OptionSetInfo {
            .init(name: name, rawType: rawType, declarationStyle: declarationStyle == .cfOptions ? .cfOptions : .nsOptions, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, cases: cases)
        }
    }

    struct TopLevelStatementBuilder {
        private(set) var text: String
        private(set) var braceDepth: Int

        var isComplete: Bool {
            braceDepth <= 0 && text.contains(";")
        }

        init(text: String) {
            self.text = text
            self.braceDepth = text._countOccurrences(of: "{") - text._countOccurrences(of: "}")
        }

        static func starting(with line: String, options: ParseOptions) -> Self? {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard currentContextEligibleLine(trimmed, options: options) else { return nil }
            return .init(text: trimmed)
        }

        mutating func consume(_ line: String) {
            text += " " + line.trimmingCharacters(in: .whitespacesAndNewlines)
            braceDepth += line._countOccurrences(of: "{") - line._countOccurrences(of: "}")
        }

        mutating func appendParsedResults(to headerInfo: inout HeaderInfo, options: ParseOptions) {
            let statement = text.trimmingCharacters(in: .whitespacesAndNewlines)

            if options.contains(.blockTypedefs), let blockTypedef = statement._parsedBlockTypedef(parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                headerInfo.blockTypedefs.append(blockTypedef)
                return
            }

            if options.contains(.structTypedefs), let structTypedef = statement._parsedStructTypedef(parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                headerInfo.structTypedefs.append(structTypedef)
                return
            }

            if options.contains(.structTypedefs), let opaqueStructTypedef = statement._parsedOpaqueStructTypedef(parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                headerInfo.opaqueStructTypedefs.append(opaqueStructTypedef)
                return
            }

            if options.contains(.structTypedefs), let opaqueStructPointerTypedef = statement._parsedOpaqueStructPointerTypedef(parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                headerInfo.opaqueStructPointerTypedefs.append(opaqueStructPointerTypedef)
                return
            }

            if options.contains(.bridgedTypedefs), let bridgedTypedef = statement._parsedBridgedTypedef(parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                headerInfo.bridgedTypedefs.append(bridgedTypedef)
                return
            }

            if options.contains(.exportedConstants), let exportedConstant = statement._parsedExportedConstant(parseAPIDeprecation: options.contains(.apiDeprecations), parseAPIAvailability: options.contains(.apiAvailabilities)) {
                headerInfo.exportedConstants.append(exportedConstant)
            }
        }

        private static func currentContextEligibleLine(_ line: String, options: ParseOptions) -> Bool {
            if line.hasPrefix("typedef "), (options.contains(.bridgedTypedefs) || options.contains(.structTypedefs) || options.contains(.blockTypedefs)) {
                return true
            }
            if options.contains(.exportedConstants), line._hasExportedConstantPrefix {
                return true
            }
            return false
        }
    }

    struct Declaration {
        enum Kind {
            case `class`
            case category(className: String, categoryName: String)
        }

        let kind: Kind
        let name: String
        let superclass: String?
        let apiDeprecated: APIDeprecation?
        let apiAvailable: APIAvailability?
        let protocols: [String]

        static func parseInterface(_ line: String) -> Self? {
            let declaration = line.dropFirst("@interface ".count).drop { $0.isWhitespace }
            guard let nameEnd = declaration.firstIndex(where: { $0.isWhitespace || $0 == "(" || $0 == "<" || $0 == ":" || $0 == "{" }) else {
                let className = String(declaration)
                return .init(kind: .class, name: className, superclass: nil, apiDeprecated: line._parsedAPIDeprecation(), apiAvailable: line._parsedAPIAvailability(), protocols: [])
            }

            let className = String(declaration[..<nameEnd])
            guard !className.isEmpty else { return nil }
            let remainder = String(declaration[nameEnd...])._droppingLeadingGenericClause().trimmingCharacters(in: .whitespacesAndNewlines)
            let protocols = remainder._protocolNames()
            let superclass = remainder._objcSuperclassName()
            let apiDeprecated = line._parsedAPIDeprecation()
            let apiAvailable = line._parsedAPIAvailability()

            if remainder.first == "(",
               let closeParenIndex = remainder.firstIndex(of: ")") {
                let categoryName = remainder[remainder.index(after: remainder.startIndex)..<closeParenIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                return .init(kind: .category(className: className, categoryName: categoryName), name: className, superclass: nil, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, protocols: protocols)
            }

            return .init(kind: .class, name: className, superclass: superclass, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable, protocols: protocols)
        }

        static func parseProtocol(_ line: String) -> Self? {
            let declaration = line.dropFirst("@protocol ".count).drop { $0.isWhitespace }
            let name = declaration.prefix { !$0.isWhitespace && $0 != "<" }
            guard !name.isEmpty else { return nil }
            return .init(kind: .class, name: String(name), superclass: nil, apiDeprecated: line._parsedAPIDeprecation(), apiAvailable: line._parsedAPIAvailability(), protocols: String(declaration[name.endIndex...])._protocolNames())
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

    var _hasExportedConstantPrefix: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("APPKIT_EXTERN ")
            || trimmed.hasPrefix("FOUNDATION_EXPORT ")
            || trimmed.hasPrefix("OBJC_EXPORT ")
            || trimmed.hasPrefix("CF_EXPORT ")
            || trimmed.hasPrefix("extern ")
    }

    func _parsedBlockProperty() -> (name: String, type: String, typeModifiers: [String])? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let markerRange = trimmed.range(of: "(^") else { return nil }
        let returnTypeString = String(trimmed[..<markerRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !returnTypeString.isEmpty else { return nil }

        let nameStart = markerRange.upperBound
        guard let closeNameParen = trimmed[nameStart...].firstIndex(of: ")") else { return nil }
        let name = String(trimmed[nameStart..<closeNameParen]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }

        let argumentsStart = trimmed.index(after: closeNameParen)
        let arguments = String(trimmed[argumentsStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedReturnType = returnTypeString._parsedObjCType()
        return (name, "\(parsedReturnType.type) (^)\(arguments)", parsedReturnType.typeModifiers)
    }

    func _splitTopLevel(separator: Character) -> [String] {
        var result: [String] = []
        var current = ""
        var parenthesesDepth = 0
        var braceDepth = 0
        var bracketDepth = 0

        for character in self {
            switch character {
            case "(":
                parenthesesDepth += 1
            case ")":
                parenthesesDepth = max(0, parenthesesDepth - 1)
            case "{":
                braceDepth += 1
            case "}":
                braceDepth = max(0, braceDepth - 1)
            case "[":
                bracketDepth += 1
            case "]":
                bracketDepth = max(0, bracketDepth - 1)
            default:
                break
            }

            if character == separator, parenthesesDepth == 0, braceDepth == 0, bracketDepth == 0 {
                result.append(current)
                current.removeAll(keepingCapacity: true)
            } else {
                current.append(character)
            }
        }

        result.append(current)
        return result
    }

    func _enumTrailingName() -> String? {
        guard let closeBrace = firstIndex(of: "}") else { return nil }
        let trailing = self[index(after: closeBrace)...]
            .prefix { !$0.isWhitespace && $0 != ";" }
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trailing.isEmpty ? nil : trailing
    }

    func _parsedEnumCase() -> ObjCHeader.EnumCase? {
        let withoutSemicolon = _splitTopLevel(separator: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? trimmingCharacters(in: .whitespacesAndNewlines)
        guard !withoutSemicolon.isEmpty else { return nil }
        let apiDeprecated = withoutSemicolon._parsedAPIDeprecation()
        let apiAvailable = withoutSemicolon._parsedAPIAvailability()
        let cleaned = withoutSemicolon._removingTrailingAttributeClauses()

        if let equalsIndex = cleaned.firstIndex(of: "=") {
            let namePart = String(cleaned[..<equalsIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            let rawValue = String(cleaned[cleaned.index(after: equalsIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let name = namePart._readLeadingIdentifier(), !name.isEmpty else { return nil }
            return .init(name: name, rawValue: rawValue.isEmpty ? nil : rawValue, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable)
        } else {
            guard let name = cleaned._readLeadingIdentifier(), !name.isEmpty else { return nil }
            return .init(name: name, rawValue: nil, apiDeprecated: apiDeprecated, apiAvailable: apiAvailable)
        }
    }

    func _parsedObjCType() -> (type: String, typeModifiers: [String]) {
        var typeModifiers: [String] = []
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
                    typeModifiers.appendIfNeeded(token)
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
        return (normalizedType, typeModifiers)
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

    func _objcSuperclassName() -> String? {
        guard let colon = firstIndex(of: ":") else { return nil }
        let tail = self[index(after: colon)...].trimmingCharacters(in: .whitespacesAndNewlines)
        let superclass = tail.prefix { !$0.isWhitespace && $0 != "<" && $0 != "{" }
        return superclass.isEmpty ? nil : String(superclass)
    }

    func _parsedBridgedTypedef(parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> ObjCHeader.BridgedTypedef? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("typedef "), trimmed.contains(";") else { return nil }
        let body = String(trimmed.dropFirst("typedef ".count))
            .split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true).first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let knownAttributes = ["NS_TYPED_EXTENSIBLE_ENUM", "NS_TYPED_ENUM", "NS_SWIFT_BRIDGED_TYPEDEF", "NS_CLOSED_ENUM"]
        guard knownAttributes.contains(where: { body.contains($0) }) else { return nil }
        var declaration = body._removingTrailingAttributeClauses()
        let attributes = knownAttributes.filter({ body.contains($0) })
        attributes.forEach { declaration = declaration.replacingOccurrences(of: $0, with: "") }
        declaration = declaration.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let (underlyingType, name) = declaration._splitTrailingIdentifier() else { return nil }

        let kind: ObjCHeader.BridgedTypedef.Kind
        if attributes.contains("NS_TYPED_EXTENSIBLE_ENUM") {
            kind = .extensibleTypedEnum
        } else if attributes.contains("NS_TYPED_ENUM") {
            kind = .typedEnum
        } else if attributes.contains("NS_SWIFT_BRIDGED_TYPEDEF") {
            kind = .swiftBridged
        } else if attributes.contains("NS_CLOSED_ENUM") {
            kind = .closedEnum
        } else {
            kind = .other
        }

        return .init(name: name, underlyingType: underlyingType._normalizingObjCTypeWhitespace(), kind: kind, attributes: attributes, apiDeprecated: parseAPIDeprecation ? trimmed._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmed._parsedAPIAvailability() : nil)
    }

    func _parsedExportedConstant(parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> ObjCHeader.ExportedConstant? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed._hasExportedConstantPrefix, trimmed.contains(" const ") || trimmed.hasPrefix("extern const ") else { return nil }

        let prefixes = ["APPKIT_EXTERN", "FOUNDATION_EXPORT", "OBJC_EXPORT", "CF_EXPORT", "extern"]
        guard let prefix = prefixes.first(where: { trimmed.hasPrefix($0 + " ") }) else { return nil }
        let declaration = String(trimmed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        let stripped = declaration._removingTrailingAttributeClauses().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let (typeString, name) = stripped._splitTrailingIdentifier() else { return nil }
        let parsedType = typeString._parsedObjCType()
        return .init(name: name, type: parsedType.type, typeModifiers: parsedType.typeModifiers, declarationSpecifier: prefix, apiDeprecated: parseAPIDeprecation ? trimmed._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmed._parsedAPIAvailability() : nil)
    }

    func _parsedStructTypedef(parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> ObjCHeader.StructTypedef? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("typedef struct ") else { return nil }
        let body = String(trimmed.dropFirst("typedef ".count))
            .split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true).first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if let openBrace = body.firstIndex(of: "{"), let closeBrace = body.lastIndex(of: "}") {
            let head = String(body[..<openBrace]).trimmingCharacters(in: .whitespacesAndNewlines)
            let rawTagName = head.replacingOccurrences(of: "struct", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            let tagName = rawTagName.isEmpty ? nil : rawTagName
            let fieldsBody = String(body[body.index(after: openBrace)..<closeBrace])
            let trailing = String(body[body.index(after: closeBrace)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            let name = trailing._splitTrailingIdentifier()?.name ?? trailing
            guard !name.isEmpty else { return nil }
            let fields = fieldsBody._splitTopLevel(separator: ";").compactMap({ fieldDecl -> ObjCHeader.StructTypedef.Field? in
                let field = fieldDecl.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !field.isEmpty, let (type, fieldName) = field._splitTrailingIdentifier() else { return nil }
                let parsedType = type._parsedObjCType()
                return .init(name: fieldName, type: parsedType.type, typeModifiers: parsedType.typeModifiers)
            })
            return .init(name: name, tagName: tagName, apiDeprecated: parseAPIDeprecation ? trimmed._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmed._parsedAPIAvailability() : nil, fields: fields)
        }
        return nil
    }

    func _parsedOpaqueStructPointerTypedef(parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> ObjCHeader.OpaqueStructPointerTypedef? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("typedef struct ") else { return nil }
        let body = String(trimmed.dropFirst("typedef ".count))
            .split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true).first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !body.contains("{") else { return nil }
        guard let pointerNameRange = body.range(of: "*", options: .backwards) else { return nil }
        let tail = String(body[pointerNameRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        let head = String(body[..<pointerNameRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let rawTagName = head.replacingOccurrences(of: "struct", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let tagName = rawTagName.isEmpty ? nil : rawTagName
        return .init(name: tail, tagName: tagName, apiDeprecated: parseAPIDeprecation ? trimmed._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmed._parsedAPIAvailability() : nil)
    }

    func _parsedOpaqueStructTypedef(parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> ObjCHeader.OpaqueStructTypedef? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("typedef struct ") else { return nil }
        let body = String(trimmed.dropFirst("typedef ".count))
            .split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true).first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !body.contains("{"), !body.contains("*") else { return nil }

        let remainder = body.replacingOccurrences(of: "struct", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let components = remainder.split(whereSeparator: \.isWhitespace).map(String.init)
        guard !components.isEmpty else { return nil }

        if components.count == 1 {
            return .init(name: components[0], tagName: components[0], apiDeprecated: parseAPIDeprecation ? trimmed._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmed._parsedAPIAvailability() : nil)
        } else {
            return .init(name: components.last ?? components[0], tagName: components.first, apiDeprecated: parseAPIDeprecation ? trimmed._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmed._parsedAPIAvailability() : nil)
        }
    }

    func _parsedBlockTypedef(parseAPIDeprecation: Bool, parseAPIAvailability: Bool) -> ObjCHeader.BlockTypedef? {
        let trimmed = _removingTrailingAttributeClauses().trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("typedef "), let markerRange = trimmed.range(of: "(^") else { return nil }
        let start = trimmed.index(trimmed.startIndex, offsetBy: "typedef ".count)
        let beforeMarker = String(trimmed[start..<markerRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let nameStart = markerRange.upperBound
        guard let closeNameParen = trimmed[nameStart...].firstIndex(of: ")") else { return nil }
        let name = String(trimmed[nameStart..<closeNameParen]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        let argumentsStart = trimmed.index(after: closeNameParen)
        var index = argumentsStart
        guard let rawArguments = trimmed._readParenthesizedContent(from: &index) else { return nil }
        let parsedReturnType = beforeMarker._parsedObjCType()
        let argumentTypes = rawArguments._parsedFunctionArguments()
        return .init(name: name, returnType: .init(type: parsedReturnType.type, typeModifiers: parsedReturnType.typeModifiers, name: nil), argumentTypes: argumentTypes, apiDeprecated: parseAPIDeprecation ? trimmingCharacters(in: .whitespacesAndNewlines)._parsedAPIDeprecation() : nil, apiAvailable: parseAPIAvailability ? trimmingCharacters(in: .whitespacesAndNewlines)._parsedAPIAvailability() : nil)
    }

    func _splitTrailingAttributes() -> (declaration: String, attributes: [String])? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        var declaration = trimmed
        var attributes: [String] = []

        while let (updatedDeclaration, attribute) = declaration._removingLastAttributeClause() {
            declaration = updatedDeclaration.trimmingCharacters(in: .whitespacesAndNewlines)
            attributes.insert(attribute, at: 0)
        }
        return (declaration, attributes)
    }

    func _removingTrailingAttributeClauses() -> String {
        var declaration = trimmingCharacters(in: .whitespacesAndNewlines)
        while let (updated, _) = declaration._removingLastAttributeClause() {
            declaration = updated.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return declaration
    }

    func _removingLastAttributeClause() -> (String, String)? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasSuffix(")") else { return nil }

        var index = trimmed.index(before: trimmed.endIndex)
        var depth = 0
        while true {
            let character = trimmed[index]
            if character == ")" {
                depth += 1
            } else if character == "(" {
                depth -= 1
                if depth == 0 {
                    let nameEnd = index
                    var nameStart = nameEnd
                    while nameStart > trimmed.startIndex {
                        let previous = trimmed.index(before: nameStart)
                        let char = trimmed[previous]
                        if char == "_" || char.isLetter || char.isNumber {
                            nameStart = previous
                        } else {
                            break
                        }
                    }
                    let attribute = String(trimmed[nameStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let declaration = String(trimmed[..<nameStart]).trimmingCharacters(in: .whitespacesAndNewlines)
                    guard attribute.contains("("), !declaration.isEmpty else { return nil }
                    return (declaration, attribute)
                }
            }

            guard index > trimmed.startIndex else { break }
            index = trimmed.index(before: index)
        }
        return nil
    }

    func _parsedAPIDeprecation() -> ObjCHeader.APIDeprecation? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if let macroRange = trimmed.range(of: "API_DEPRECATED_WITH_REPLACEMENT("),
           let content = trimmed._macroContent(for: "API_DEPRECATED_WITH_REPLACEMENT", in: macroRange) {
            let parts = content.content._splitTopLevel(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            return .init(
                message: nil,
                replacement: parts[safe: 0]?._strippingQuotedString(),
                platform: parts[safe: 1],
                introducedVersion: parts[safe: 2],
                deprecatedVersion: parts[safe: 3],
                rawMacro: content.raw
            )
        }

        if let macroRange = trimmed.range(of: "API_DEPRECATED("),
           let content = trimmed._macroContent(for: "API_DEPRECATED", in: macroRange) {
            let parts = content.content._splitTopLevel(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            return .init(
                message: parts[safe: 0]?._strippingQuotedString(),
                replacement: nil,
                platform: parts[safe: 1],
                introducedVersion: parts[safe: 2],
                deprecatedVersion: parts[safe: 3],
                rawMacro: content.raw
            )
        }

        return nil
    }

    func _parsedAPIAvailability() -> ObjCHeader.APIAvailability? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let macroRange = trimmed.range(of: "API_AVAILABLE("),
              let content = trimmed._macroContent(for: "API_AVAILABLE", in: macroRange) else { return nil }

        let platforms = content.content._splitTopLevel(separator: ",").compactMap { segment -> ObjCHeader.APIAvailability.Platform? in
            let trimmedSegment = segment.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedSegment.isEmpty else { return nil }
            if let openParen = trimmedSegment.firstIndex(of: "("),
               let closeParen = trimmedSegment.lastIndex(of: ")"),
               openParen < closeParen {
                let platform = String(trimmedSegment[..<openParen]).trimmingCharacters(in: .whitespacesAndNewlines)
                let version = String(trimmedSegment[trimmedSegment.index(after: openParen)..<closeParen]).trimmingCharacters(in: .whitespacesAndNewlines)
                guard !platform.isEmpty else { return nil }
                return .init(name: platform, introducedVersion: version.isEmpty ? nil : version)
            } else {
                return .init(name: trimmedSegment, introducedVersion: nil)
            }
        }

        guard !platforms.isEmpty else { return nil }
        return .init(platforms: platforms, rawMacro: content.raw)
    }

    func _macroContent(for macro: String, in range: Range<String.Index>) -> (raw: String, content: String)? {
        let openParen = range.upperBound
        var index = openParen
        var depth = 1

        while index < endIndex {
            let character = self[index]
            if character == "(" {
                depth += 1
            } else if character == ")" {
                depth -= 1
                if depth == 0 {
                    let content = String(self[openParen..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let raw = String(self[range.lowerBound...index])
                    return (raw, content)
                }
            }
            index = self.index(after: index)
        }
        return nil
    }

    func _strippingQuotedString() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2, trimmed.first == "\"", trimmed.last == "\"" else { return trimmed }
        return String(trimmed.dropFirst().dropLast())
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

    func _readLeadingIdentifier() -> String? {
        var index = startIndex
        _skipWhitespace(from: &index)
        return _readIdentifier(from: &index)
    }

    func _parsedFunctionArguments() -> [ObjCHeader.Method.Argument] {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "void" else { return [] }
        return _splitTopLevel(separator: ",").compactMap { argument in
            let candidate = argument.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !candidate.isEmpty else { return nil }

            if let blockProperty = candidate._parsedBlockProperty() {
                return .init(type: blockProperty.type, typeModifiers: blockProperty.typeModifiers, name: blockProperty.name)
            }

            if let (type, _) = candidate._splitTrailingIdentifier() {
                let parsedType = type._parsedObjCType()
                let name = candidate._splitTrailingIdentifier()?.name
                return .init(type: parsedType.type, typeModifiers: parsedType.typeModifiers, name: name)
            }

            let parsedType = candidate._parsedObjCType()
            return .init(type: parsedType.type, typeModifiers: parsedType.typeModifiers, name: nil)
        }
    }
}

fileprivate extension Array where Element == String {
    mutating func appendIfNeeded(_ element: String) {
        guard !contains(element) else { return }
        append(element)
    }
}
