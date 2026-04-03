//
//  ObjCClassInfo+Header.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 03.04.26.
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/*
extension ObjCClassInfo {
    /// Returns a string representing the class in a Objective-C header.
    public var headerString: String {
        headerString()
    }
    
    /// Returns a string representing the class in a Objective-C header.
    public func headerString(options: HeaderStringOptions = [.groupByOrigin, .includeMethodsFromOtherImages, .includeCategoryMethods, .addPropertyAttributesComments]) -> String {
        var stripProperties: Set<String> = []
        var stripClassProperties: Set<String> = []
        var stripMethods: Set<String> = []
        var stripClassMethods: Set<String> = []
        
        if options.contains(.stripCtorMethod) {
            stripMethods.insert(".cxx_construct")
        }
        if options.contains(.stripDtorMethod){
            stripMethods.insert(".cxx_destruct")
        }
        if options.contains(.stripPublic), let info = ObjCHeader.getClass(named: name) {
            stripMethods += info.methods.map({$0.name})
            stripClassMethods += info.classMethods.map({$0.name})
            stripProperties += info.properties.map({$0.name})
            stripClassProperties += info.classProperties.map({$0.name})
        }
        if options.contains(.stripOverrides) {
            var superclass = superclass
            while let info = superclass {
                superclass = info.superclass
                stripMethods += info.methods.map({$0.name})
                stripClassMethods += info.classMethods.map({$0.name})
                stripProperties += info.properties.map({$0.name})
                stripClassProperties += info.classProperties.map({$0.name})
                
                stripMethods += info.properties.flatMap({ $0.methodNames })
                stripClassMethods += info.classProperties.flatMap({ $0.methodNames })
            }
        }
        if options.contains(.stripSynthesizedMethods) {
            stripMethods += properties.flatMap({ $0.methodNames })
            stripClassMethods += classProperties.flatMap({ $0.methodNames })
        }
        if options.contains(.stripProtocolConformance) {
            for info in allProtocols {
                stripMethods += info.methods.map({$0.name})
                stripClassMethods += info.classMethods.map({$0.name})
                stripProperties += info.properties.map({$0.name})
                stripClassProperties += info.classProperties.map({$0.name})
                
                stripMethods += info.optionalMethods.map({$0.name})
                stripClassMethods += info.optionalClassMethods.map({$0.name})
                stripProperties += info.optionalProperties.map({$0.name})
                stripClassProperties += info.optionalClassProperties.map({$0.name})
                
                stripMethods += info.properties.flatMap({ $0.methodNames })
                stripClassMethods += info.classProperties.flatMap({ $0.methodNames })
                stripMethods += info.optionalProperties.flatMap({ $0.methodNames })
                stripClassMethods += info.optionalClassProperties.flatMap({ $0.methodNames })
            }
        }
        
        var ivars = ivars
        if options.contains(.stripSynthesizedIvars) {
            let stripIvars: Set<String> = .init(properties.compactMap({$0.ivarName}))
            ivars = ivars.filter({ !stripIvars.contains($0.name) })
        }
        let properties = properties.filter({ !stripProperties.contains($0.name)})
        let classProperties = classProperties.filter({ !stripClassProperties.contains($0.name)})
        let methods = methods.filter({ !stripMethods.contains($0.name)})
        let classMethods = classMethods.filter({ !stripClassMethods.contains($0.name)})

        var decl = "@interface \(name)"
        if options.contains(.groupByOrigin), let imagePath = imagePath {
            decl = "// Image: \(imagePath)\n\n" + decl
        }
        
        if let _superclass {
            decl += " : \(NSStringFromClass(_superclass))"
        }
        if !protocols.isEmpty {
            decl += " <\(protocols.map(\.name).joined(separator: ", "))>"
        }

        var lines = [decl]
        if !ivars.isEmpty {
            lines[0] += " {"
            lines += ivars.map { $0.headerString.components(separatedBy: .newlines).map { "    \($0)" }.joined(separator: "\n") }
            lines += "}"
        }
        if !classProperties.isEmpty {
            lines += "" + classProperties.map({$0.headerString(includeDefaultAttributes: options.contains(.addImplicitPropertyAttributes), includeComments: options.contains(.addPropertyAttributesComments))})
        }
        if !properties.isEmpty {
            lines += "" + properties.map({$0.headerString(includeDefaultAttributes: options.contains(.addImplicitPropertyAttributes), includeComments: options.contains(.addPropertyAttributesComments))})
        }
        lines += methodHeaderLines(for: methods, classMethods: classMethods, options: options)
        lines += ["", "@end"]
        return lines.joined(separator: "\n")
    }
    
    /**
    Returns an attributed string representing the class in a Objective-C header.
          
     - Parameters:
        - options: The header string options.
        - font: The font of the attributed string, or `nil` to use the default font.
     */
    public func attributedHeaderString(options: HeaderStringOptions = [], font: NSUIFont? = nil) -> NSAttributedString {
        let headerString = headerString(options: options)
        let attributed = NSMutableAttributedString(
            attributedString: .objCHeader(for: headerString, protocols: protocols.map(\.name), font: font)
        )
        let propertyOptions = options.contains(.addImplicitPropertyAttributes)
        let propertyComments = options.contains(.addPropertyAttributesComments)
        let methodTypeEncodings = options.contains(.addMethodTypeEncodingComments)
        var declarations: [(line: String, key: NSAttributedString.Key, value: String)] = []
        declarations += ivars.map({ ($0.headerString, .objcIvar, $0.name) })
        declarations += classProperties.map({
            ($0.headerString(includeDefaultAttributes: propertyOptions, includeComments: propertyComments), .objcClassProperty, $0.name)
        })
        declarations += properties.map({
            ($0.headerString(includeDefaultAttributes: propertyOptions, includeComments: propertyComments), .objcProperty, $0.name)
        })
        declarations += classMethods.map({
            ($0.headerString(includeTypeEncoding: methodTypeEncodings), .objcClassMethod, $0.name)
        })
        declarations += methods.map({
            ($0.headerString(includeTypeEncoding: methodTypeEncodings), .objcMethod, $0.name)
        })
        attributed.addObjCDeclarationAttributes(declarations)
        return attributed
    }
    
}

fileprivate extension ObjCClassInfo {
    func methodHeaderLines(for methods: [ObjCMethodInfo], classMethods: [ObjCMethodInfo], options: HeaderStringOptions) -> [String] {
        var lines: [String] = []
        let addMethodTypeEncodingComments = options.contains(.addMethodTypeEncodingComments)
        guard options.contains(.groupByOrigin) || !options.contains(.includeCategoryMethods) || !options.contains(.includeMethodsFromOtherImages), var sections = methodHeaderSections(for: methods, classMethods) else {
            if !classMethods.isEmpty {
                lines += "" + classMethods.map({$0.headerString(includeTypeEncoding: addMethodTypeEncodingComments)})
            }
            if !methods.isEmpty {
                lines += "" + methods.map({$0.headerString(includeTypeEncoding: addMethodTypeEncodingComments)})
            }
            return lines
        }
        
        sections = options.contains(.includeMethodsFromOtherImages) ? sections : sections.filter({ $0.imagePath == self.imagePath ?? "" })
        sections = options.contains(.includeCategoryMethods) ? sections : sections.filter({ $0.categoryName.isEmpty })
        
        if !options.contains(.groupByOrigin) {
            let classMethods = sections.flatMap({$0.classMethods}).sorted(by: \.name)
            if !classMethods.isEmpty {
                lines += "" + classMethods.map({$0.headerString(includeTypeEncoding: addMethodTypeEncodingComments)})
            }
            let instanceMethods = sections.flatMap({$0.instanceMethods}).sorted(by: \.name)
            if !instanceMethods.isEmpty {
                lines += "" + instanceMethods.map({$0.headerString(includeTypeEncoding: addMethodTypeEncodingComments)})
            }
            return lines
        }
        
        let hasMethodsFromMoreThanOneImage: Bool = {
            guard let firstImagePath = sections.first?.imagePath else { return false }
            return sections.contains { $0.imagePath != firstImagePath }
        }()
        var imagePath: String?
        for (index, section) in sections.enumerated() {
            if index > 0 {
                lines += ""
            }
            if hasMethodsFromMoreThanOneImage, imagePath != section.imagePath {
                imagePath = section.imagePath
                lines += "// Image: \(section.imagePath)"
                lines += ""
            }
            if !section.categoryName.isEmpty {
                lines += "// \(name) (\(section.categoryName))"
                lines += ""
            }
            lines += section.classMethods.map({$0.headerString(includeTypeEncoding: addMethodTypeEncodingComments)})
            if !section.classMethods.isEmpty && !section.instanceMethods.isEmpty {
                lines += ""
            }
            lines += section.instanceMethods.map({$0.headerString(includeTypeEncoding: addMethodTypeEncodingComments)})
        }
        return !lines.isEmpty ? "" + lines : lines
    }
    
    func methodHeaderSections(for methods: [ObjCMethodInfo], _ classMethods: [ObjCMethodInfo]) -> [HeaderSection]? {
        guard let objcClass = ObjCClass(name) else { return nil }
        
        var bucketsByImage: [String: [String: CategoryBucket]] = .init(
            minimumCapacity: classMethods.count + methods.count)
        
        func append(_ method: Method, isClassMethod: Bool) {
            guard let info = ObjCMethodInfo(method, isClassMethod: isClassMethod) else { return }
            let origin = ObjCRuntime.origin(of: method)
            let keyPath: WritableKeyPath<CategoryBucket, [ObjCMethodInfo]> = isClassMethod ? \.classMethods : \.instanceMethods
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()][keyPath: keyPath] += info
        }
        /*
        for method in objcClass.classMethods() {
            append(method, isClassMethod: true)
        }
        for method in objcClass.methods() {
            append(method, isClassMethod: false)
        }
         */
        
        var sortedImagePaths = bucketsByImage.sorted(by: \.key)
        let imagePath = imagePath ?? ""
        if let index = sortedImagePaths.firstIndex(where: { $0.key == imagePath }) {
            sortedImagePaths.insert(sortedImagePaths.remove(at: index), at: 0)
        }
        let headerSections = sortedImagePaths.flatMap({ element in
            element.value.sorted(by: \.key).map({ $0.value.headerSeaction(imagePath: element.key, categoryName: $0.key) })
        })
        return headerSections
    }
    var methodHeaderSections: [HeaderSection]? {
        if let cached = Self.cachedHeaderSections[name] {
            return cached
        }
        guard let objcClass = ObjCClass(name) else { return nil }
        
        var bucketsByImage: [String: [String: CategoryBucket]] = .init(
            minimumCapacity: classMethods.count + methods.count)
        
        func append(_ method: Method, isClassMethod: Bool) {
            guard let info = ObjCMethodInfo(method, isClassMethod: isClassMethod) else { return }
            let origin = ObjCRuntime.origin(of: method)
            let keyPath: WritableKeyPath<CategoryBucket, [ObjCMethodInfo]> = isClassMethod ? \.classMethods : \.instanceMethods
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()][keyPath: keyPath] += info
        }
        /*
        for method in objcClass.classMethods() {
            append(method, isClassMethod: true)
        }
        for method in objcClass.methods() {
            append(method, isClassMethod: false)
        }
         */
        
        var sortedImagePaths = bucketsByImage.sorted(by: \.key)
        let imagePath = imagePath ?? ""
        if let index = sortedImagePaths.firstIndex(where: { $0.key == imagePath }) {
            sortedImagePaths.insert(sortedImagePaths.remove(at: index), at: 0)
        }
        let headerSections = sortedImagePaths.flatMap({ element in
            element.value.sorted(by: \.key).map({ $0.value.headerSeaction(imagePath: element.key, categoryName: $0.key) })
        })
        Self.cachedHeaderSections[name] = headerSections
        return headerSections
    }
    
    static var cachedHeaderSections: [String: [HeaderSection]] = [:]
    
    struct CategoryBucket {
        var classMethods: [ObjCMethodInfo] = []
        var instanceMethods: [ObjCMethodInfo] = []
        
        func headerSeaction(imagePath: String, categoryName: String) -> HeaderSection {
            .init(imagePath: imagePath, categoryName: categoryName, classMethods: classMethods, instanceMethods: instanceMethods)
        }
    }
    
    struct HeaderSection {
        let imagePath: String
        let categoryName: String
        var classMethods: [ObjCMethodInfo]
        var instanceMethods: [ObjCMethodInfo]
        
        func filter(_ names: [String]) -> HeaderSection? {
            var section = self
            section.classMethods = section.classMethods.filter({ !names.contains($0.name) })
            section.instanceMethods = section.instanceMethods.filter({ !names.contains($0.name) })
            return !section.classMethods.isEmpty && !section.instanceMethods.isEmpty ? section : nil
        }
        
        struct HeaderMethod: Comparable {
            let name: String
            let headerString: String
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.name == rhs.name
            }
            static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.name < rhs.name
            }
        }
    }
}

extension ObjCClassInfo {
    public func attributedHeaderStringAlt(
        options: HeaderStringOptions = [
            .groupByOrigin,
            .includeMethodsFromOtherImages,
            .includeCategoryMethods,
            .addPropertyAttributesComments
        ], font: NSUIFont? = nil
    ) -> NSAttributedString {
        let font = font ?? NSUIFont(name: "SF Mono Regular", size: 13) ?? NSUIFont(name: "Menlo Regular", size: 13) ?? .monospacedSystemFont(ofSize: 13.0, weight: .regular)
        let attributes: [NSAttributedString.Key : Any] = [.font: font]
        let result = NSMutableAttributedString()
        
        func append(_ string: String) {
            result.append(NSAttributedString(string: string, attributes: attributes))
        }

        func appendLine(_ string: String = "") {
            result.append(NSAttributedString(string: string + "\n", attributes: attributes))
        }

        func appendAttributedLine(
            _ string: String,
            key: NSAttributedString.Key,
            value: Any
        ) {
            let start = result.length
            result.append(NSAttributedString(string: string, attributes: attributes))
            let range = NSRange(location: start, length: (string as NSString).length)
            result.addAttribute(key, value: value, range: range)
            result.append(NSAttributedString(string: "\n", attributes: attributes))
        }

        if options.contains(.groupByOrigin), let imagePath = imagePath {
            appendLine("// Image: \(imagePath)")
            appendLine()
        }

        var decl = "@interface \(name)"
        if let _superclass {
            decl += " : \(NSStringFromClass(_superclass))"
        }
        if !protocols.isEmpty {
            decl += " <\(protocols.map(\.name).joined(separator: ", "))>"
        }

        if !ivars.isEmpty {
            appendLine(decl + " {")
            for ivar in ivars {
                let indented = ivar.headerString
                    .components(separatedBy: .newlines)
                    .map { "    \($0)" }
                    .joined(separator: "\n")
                appendAttributedLine(indented, key: .objcIvar, value: ivar.name)
            }
            appendLine("}")
        } else {
            appendLine(decl)
        }

        if !classProperties.isEmpty {
            appendLine()
            for property in classProperties {
                appendAttributedLine(
                    property.headerString(
                        includeDefaultAttributes: options.contains(.addImplicitPropertyAttributes),
                        includeComments: options.contains(.addPropertyAttributesComments)
                    ),
                    key: .objcClassProperty,
                    value: property.name
                )
            }
        }

        if !properties.isEmpty {
            appendLine()
            for property in properties {
                appendAttributedLine(
                    property.headerString(
                        includeDefaultAttributes: options.contains(.addImplicitPropertyAttributes),
                        includeComments: options.contains(.addPropertyAttributesComments)
                    ),
                    key: .objcProperty,
                    value: property.name
                )
            }
        }
        
        result.append(methodHeaderAttributedString(options: options, attributes: attributes))

        appendLine()
        append("@end")
        NSAttributedString.updateObjCHeader(result, protocols: protocols.map(\.name), font: font)

        return result
    }

    func methodHeaderAttributedString(options: HeaderStringOptions, attributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
        let result = NSMutableAttributedString()

        func append(_ string: String) {
            result.append(NSAttributedString(string: string, attributes: attributes))
        }

        func appendLine(_ string: String = "") {
            result.append(NSAttributedString(string: string + "\n", attributes: attributes))
        }

        func appendMethodLine(
            _ string: String,
            key: NSAttributedString.Key,
            value: Any
        ) {
            let start = result.length
            result.append(NSAttributedString(string: string, attributes: attributes))
            let range = NSRange(location: start, length: (string as NSString).length)
            result.addAttribute(key, value: value, range: range)
            result.append(NSAttributedString(string: "\n", attributes: attributes))
        }

        let addMethodTypeEncodingComments = options.contains(.addMethodTypeEncodingComments)

        guard options.contains(.groupByOrigin)
                || !options.contains(.includeCategoryMethods)
                || !options.contains(.includeMethodsFromOtherImages),
              var sections = methodHeaderSections else {
            if !classMethods.isEmpty {
                appendLine()
                for method in classMethods {
                    appendMethodLine(
                        method.headerString(includeTypeEncoding: addMethodTypeEncodingComments),
                        key: .objcClassMethod,
                        value: method.name
                    )
                }
            }
            if !methods.isEmpty {
                appendLine()
                for method in methods {
                    appendMethodLine(
                        method.headerString(includeTypeEncoding: addMethodTypeEncodingComments),
                        key: .objcMethod,
                        value: method.name
                    )
                }
            }
            return result
        }

        sections = options.contains(.includeMethodsFromOtherImages)
            ? sections
            : sections.filter { $0.imagePath == self.imagePath ?? "" }

        sections = options.contains(.includeCategoryMethods)
            ? sections
            : sections.filter { $0.categoryName.isEmpty }

        if !options.contains(.groupByOrigin) {
            let classMethods = sections.flatMap(\.classMethods).sorted(by: \.name)
            if !classMethods.isEmpty {
                appendLine()
                for method in classMethods {
                    appendMethodLine(
                        method.headerString(includeTypeEncoding: addMethodTypeEncodingComments),
                        key: .objcClassMethod,
                        value: method.name
                    )
                }
            }

            let instanceMethods = sections.flatMap(\.instanceMethods).sorted(by: \.name)
            if !instanceMethods.isEmpty {
                appendLine()
                for method in instanceMethods {
                    appendMethodLine(
                        method.headerString(includeTypeEncoding: addMethodTypeEncodingComments),
                        key: .objcMethod,
                        value: method.name
                    )
                }
            }

            return result
        }

        let hasMethodsFromMoreThanOneImage: Bool = {
            guard let firstImagePath = sections.first?.imagePath else { return false }
            return sections.contains { $0.imagePath != firstImagePath }
        }()

        var currentImagePath: String?

        if !sections.isEmpty {
            appendLine()
        }

        for (index, section) in sections.enumerated() {
            if index > 0 {
                appendLine()
            }

            if hasMethodsFromMoreThanOneImage, currentImagePath != section.imagePath {
                currentImagePath = section.imagePath
                appendLine("// Image: \(section.imagePath)")
                appendLine()
            }

            if !section.categoryName.isEmpty {
                appendLine("// \(name) (\(section.categoryName))")
                appendLine()
            }

            for method in section.classMethods {
                appendMethodLine(
                    method.headerString(includeTypeEncoding: addMethodTypeEncodingComments),
                    key: .objcClassMethod,
                    value: method.name
                )
            }

            if !section.classMethods.isEmpty && !section.instanceMethods.isEmpty {
                appendLine()
            }

            for method in section.instanceMethods {
                appendMethodLine(
                    method.headerString(includeTypeEncoding: addMethodTypeEncodingComments),
                    key: .objcMethod,
                    value: method.name
                )
            }
        }

        return result
    }
}
 */

extension ObjCClassInfo {
    /// Returns a string representing the class in a Objective-C header.
    public var headerString: String {
        headerString()
    }
    
    /// Returns a string representing the class in a Objective-C header.
    public func headerString(options: HeaderStringOptions = [.groupByOrigin, .includeMethodsFromOtherImages, .includeCategoryMethods, .addPropertyAttributesComments]) -> String {
        _headerString(options: options).string
    }
    
    /**
    Returns an attributed string representing the class in a Objective-C header.
          
     - Parameters:
        - options: The header string options.
        - font: The font of the attributed string, or `nil` to use the default font.
     */
    public func attributedHeaderString(options: HeaderStringOptions = [.groupByOrigin, .includeMethodsFromOtherImages, .includeCategoryMethods, .addPropertyAttributesComments], font: NSUIFont? = nil) -> NSAttributedString {
        let val = _headerString(options: options)
        let attributed = NSMutableAttributedString(
            attributedString: .objCHeader(for: val.string, protocols: protocols.map(\.name), font: font)
        )
        attributed.addObjCDeclarationAttributes(val.declarations)
        return attributed
    }
    
    /// Returns a string representing the class in a Objective-C header.
   private func _headerString(options: HeaderStringOptions = [.groupByOrigin, .includeMethodsFromOtherImages, .includeCategoryMethods, .addPropertyAttributesComments]) -> (string: String, declarations: [(line: String, key: NSAttributedString.Key, value: Any)]) {
        var stripProperties: Set<String> = []
        var stripClassProperties: Set<String> = []
        var stripMethods: Set<String> = []
        var stripClassMethods: Set<String> = []
        
        if options.contains(.stripCtorMethod) {
            stripMethods.insert(".cxx_construct")
        }
        if options.contains(.stripDtorMethod){
            stripMethods.insert(".cxx_destruct")
        }
        /*
        if options.contains(.stripPublic), let info = ObjCHeader.getClass(named: name) {
            stripMethods += info.methods.map({$0.name})
            stripClassMethods += info.classMethods.map({$0.name})
            stripProperties += info.properties.map({$0.name})
            stripClassProperties += info.classProperties.map({$0.name})
        }
         */
        if options.contains(.stripOverrides) {
            var superclass = superclass
            while let info = superclass {
                superclass = info.superclass
                stripMethods += info.methods.map({$0.name})
                stripClassMethods += info.classMethods.map({$0.name})
                stripProperties += info.properties.map({$0.name})
                stripClassProperties += info.classProperties.map({$0.name})
                
                stripMethods += info.properties.flatMap({ $0.methodNames })
                stripClassMethods += info.classProperties.flatMap({ $0.methodNames })
            }
        }
        if options.contains(.stripSynthesizedMethods) {
            stripMethods += properties.flatMap({ $0.methodNames })
            stripClassMethods += classProperties.flatMap({ $0.methodNames })
        }
        if options.contains(.stripProtocolConformance) {
            for info in allProtocols {
                stripMethods += info.methods.map({$0.name})
                stripClassMethods += info.classMethods.map({$0.name})
                stripProperties += info.properties.map({$0.name})
                stripClassProperties += info.classProperties.map({$0.name})
                
                stripMethods += info.optionalMethods.map({$0.name})
                stripClassMethods += info.optionalClassMethods.map({$0.name})
                stripProperties += info.optionalProperties.map({$0.name})
                stripClassProperties += info.optionalClassProperties.map({$0.name})
                
                stripMethods += info.properties.flatMap({ $0.methodNames })
                stripClassMethods += info.classProperties.flatMap({ $0.methodNames })
                stripMethods += info.optionalProperties.flatMap({ $0.methodNames })
                stripClassMethods += info.optionalClassProperties.flatMap({ $0.methodNames })
            }
        }
        
        var ivars = ivars
        if options.contains(.stripSynthesizedIvars) {
            let stripIvars: Set<String> = .init(properties.compactMap({$0.ivarName}))
            ivars = ivars.filter({ !stripIvars.contains($0.name) })
        }
        
        var decl = "@interface \(name)"
        if options.contains(.groupByOrigin), let imagePath = imagePath {
            decl = "// Image: \(imagePath)\n\n" + decl
        }
        
        if let _superclass {
            decl += " : \(NSStringFromClass(_superclass))"
        }
        if !protocols.isEmpty {
            decl += " <\(protocols.map(\.name).joined(separator: ", "))>"
        }

        var declarations: [(line: String, key: NSAttributedString.Key, value: Any)] = []
        var lines = [decl]
        if !ivars.isEmpty {
            lines[0] += " {"
            for ivar in ivars {
                let line = ivar.headerString
                declarations += (line, .objcIvar, value: ivar.name)
                lines += line
            }
            lines += "}"
        }
        lines += memberHeaderLines(
            for: stripProperties,
            stripClassProperties,
            stripMethods,
            stripClassMethods,
            options: options,
            declarations: &declarations
        )
        lines += ["", "@end"]
        return (lines.joined(separator: "\n"), declarations)
    }
}

fileprivate extension ObjCClassInfo {
    func memberHeaderLines(for stripProperties: Set<String>,_ stripClassProperties: Set<String>, _ stripMethods: Set<String>, _ stripClassMethods: Set<String>, options: HeaderStringOptions, declarations: inout [(line: String, key: NSAttributedString.Key, value: Any)]) -> [String] {
        let propertyOptions = options.contains(.addImplicitPropertyAttributes)
        let propertyComments = options.contains(.addPropertyAttributesComments)
        let methodTypeEncodings = options.contains(.addMethodTypeEncodingComments)
        guard options.contains(.groupByOrigin) || !options.contains(.includeCategoryMethods) || !options.contains(.includeMethodsFromOtherImages), var sections = allHeaderSections() else {
            let classProperties = classProperties.filter({ !stripClassProperties.contains($0.name)})
            let properties = properties.filter({ !stripProperties.contains($0.name)})
            let classMethods = classMethods.filter({ !stripClassMethods.contains($0.name)})
            let methods = methods.filter({ !stripMethods.contains($0.name)})
            return lines(for: classProperties, properties, classMethods, methods, propertyOptions: propertyOptions, propertyComments: propertyComments, methodTypeEncodings: methodTypeEncodings, declarations: &declarations)
        }
        
        let includeCategories = options.contains(.includeCategoryMethods)
        let requiredImagePath = !options.contains(.includeMethodsFromOtherImages) ? imagePath ?? "" : nil
        sections = sections.compactMap({$0.filtered(with: stripProperties, stripClassProperties, stripMethods, stripClassMethods, includeCategories: includeCategories, requiredImagePath: requiredImagePath)})

        if !options.contains(.groupByOrigin) {
            let classProperties = sections.flatMap(\.classProperties).sorted(by: \.name)
            let properties = sections.flatMap(\.instanceProperties).sorted(by: \.name)
            let classMethods = sections.flatMap(\.classMethods).sorted(by: \.name)
            let methods = sections.flatMap(\.instanceMethods).sorted(by: \.name)
            return lines(for: classProperties, properties, classMethods, methods, propertyOptions: propertyOptions, propertyComments: propertyComments, methodTypeEncodings: methodTypeEncodings, declarations: &declarations)
        }

        let hasMembersFromMoreThanOneImage = Set(sections.map(\.imagePath)).count > 1
        var currentImagePath = imagePath ?? ""
        var lines: [String] = []
        for (index, section) in sections.enumerated() {
            if index > 0 {
                lines += ""
            }
            if hasMembersFromMoreThanOneImage, currentImagePath != section.imagePath {
                currentImagePath = section.imagePath
                lines += "// Image: \(section.imagePath)"
                lines += ""
            }
            if !section.categoryName.isEmpty {
                lines += "// \(name) (\(section.categoryName))"
                lines += ""
            }
            lines += self.lines(for: section.classProperties, section.instanceProperties, section.classMethods, section.instanceMethods, propertyOptions: propertyOptions, propertyComments: propertyComments, methodTypeEncodings: methodTypeEncodings, declarations: &declarations)
            /*
            lines += section.headerLines(
                propertyOptions: propertyOptions,
                propertyComments: propertyComments,
                methodTypeEncodings: methodTypeEncodings
            )
             */
        }
        return !lines.isEmpty ? "" + lines : lines
    }
    
    func lines(for classProperties: [ObjCPropertyInfo], _ properties: [ObjCPropertyInfo], _ classMethods: [ObjCMethodInfo], _ methods: [ObjCMethodInfo], propertyOptions: Bool, propertyComments: Bool, methodTypeEncodings: Bool, declarations: inout [(line: String, key: NSAttributedString.Key, value: Any)]) -> [String] {
        var lines: [String] = []
        if !classProperties.isEmpty {
            lines += "" + classProperties.map({
                let line = $0.headerString(includeDefaultAttributes: propertyOptions, includeComments: propertyComments)
                declarations += (line, .objcClassProperty, $0.name)
                return line
            })
        }
        if !properties.isEmpty {
            lines += "" + properties.map({
                let line = $0.headerString(includeDefaultAttributes: propertyOptions, includeComments: propertyComments)
                declarations += (line, .objcProperty, $0.name)
                return line
            })
        }
        if !classMethods.isEmpty {
            lines += "" + classMethods.map({
                let line = $0.headerString(includeTypeEncoding: methodTypeEncodings)
                declarations += (line, .objcClassMethod, $0.name)
                return line
            })
        }
        if !methods.isEmpty {
            lines += "" + methods.map({
                let line = $0.headerString(includeTypeEncoding: methodTypeEncodings)
                declarations += (line, .objcMethod, $0.name)
                return line
            })
        }
        return lines
    }

    func allHeaderSections() -> [HeaderSection]? {
        if let cache = Self.cachedHeaerSectionsByClass[name] {
            return cache
        }
        guard let objcClass = ObjCClass(name) else { return nil }
        let primaryImagePath = self.imagePath

        var bucketsByImage: [String: [String: CategoryBucket]] = .init(
            minimumCapacity: classProperties.count + properties.count + classMethods.count + methods.count
        )
        
        var methodsByName: [String: Method] = [:]
        var classMethodsByName: [String: Method] = [:]
        for method in objcClass.methods() {
            methodsByName[method_getName(method).string] = method
        }
        for method in objcClass.classMethods() {
            classMethodsByName[method_getName(method).string] = method
        }

        func append(_ methodInfo: ObjCMethodInfo, isClassMethod: Bool) {
            let method = isClassMethod ? classMethodsByName[methodInfo.name] : methodsByName[methodInfo.name]
            let origin: (imagePath: String?, categoryName: String?, symbolName: String?) =
                method.map(ObjCRuntime.origin(of:)) ?? (imagePath: primaryImagePath, categoryName: nil, symbolName: nil)
            let keyPath: WritableKeyPath<CategoryBucket, [ObjCMethodInfo]> = isClassMethod ? \.classMethods : \.instanceMethods
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()][keyPath: keyPath].append(methodInfo)
        }

        func append(_ propertyInfo: ObjCPropertyInfo, isClassProperty: Bool) {
            let selector = propertyInfo.getter
            var method = isClassProperty ? classMethodsByName[propertyInfo.getterName] : methodsByName[propertyInfo.getterName]
            method = method ?? (isClassProperty
                ? objcClass.classMethod(for: selector)
                : objcClass.method(for: selector))
            let origin: (imagePath: String?, categoryName: String?, symbolName: String?) =
                method.map(ObjCRuntime.origin(of:)) ?? (imagePath: primaryImagePath, categoryName: nil, symbolName: nil)
            let keyPath: WritableKeyPath<CategoryBucket, [ObjCPropertyInfo]> = isClassProperty ? \.classProperties : \.instanceProperties
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()][keyPath: keyPath].append(propertyInfo)
        }

        classProperties.forEach { append($0, isClassProperty: true) }
        properties.forEach { append($0, isClassProperty: false) }
        classMethods.forEach { append($0, isClassMethod: true) }
        methods.forEach { append($0, isClassMethod: false) }
        
        var sortedImagePaths = bucketsByImage.sorted(by: \.key)
        let preferredImagePath = primaryImagePath ?? ""
        if let index = sortedImagePaths.firstIndex(where: { $0.key == preferredImagePath }) {
            sortedImagePaths.insert(sortedImagePaths.remove(at: index), at: 0)
        }
        let headerSections = sortedImagePaths.flatMap { element in
            element.value.sorted(by: \.key) .compactMap { $0.value.headerSection(imagePath: element.key, categoryName: $0.key) }
        }
        Self.cachedHeaerSectionsByClass[name] = headerSections
        return headerSections
    }
    
    static var cachedHeaerSectionsByClass: [String: [HeaderSection]] = [:]
}

fileprivate extension ObjCClassInfo {
    struct CategoryBucket {
        var classProperties: [ObjCPropertyInfo] = []
        var instanceProperties: [ObjCPropertyInfo] = []
        var classMethods: [ObjCMethodInfo] = []
        var instanceMethods: [ObjCMethodInfo] = []
        
        func headerSection(imagePath: String, categoryName: String) -> HeaderSection? {
            let section = HeaderSection(
                imagePath: imagePath,
                categoryName: categoryName,
                classProperties: classProperties,
                instanceProperties: instanceProperties,
                classMethods: classMethods,
                instanceMethods: instanceMethods
            )
            return section.hasMembers ? section : nil
        }
    }
    
    struct HeaderSection {
        let imagePath: String
        let categoryName: String
        var classProperties: [ObjCPropertyInfo]
        var instanceProperties: [ObjCPropertyInfo]
        var classMethods: [ObjCMethodInfo]
        var instanceMethods: [ObjCMethodInfo]
        
        func filtered(with stripProperties: Set<String>,
                    _ stripClassProperties: Set<String>,
                    _ stripMethods: Set<String>,
                      _ stripClassMethods: Set<String>, includeCategories: Bool, requiredImagePath: String?) -> Self? {
            if let requiredImagePath = requiredImagePath, imagePath != requiredImagePath { return nil }
            if !includeCategories, !categoryName.isEmpty { return nil }
            var section = self
            section.instanceProperties = instanceProperties.filter({ !stripProperties.contains($0.name)})
            section.classProperties = classProperties.filter({ !stripClassProperties.contains($0.name)})
            section.instanceMethods = instanceMethods.filter({ !stripMethods.contains($0.name)})
            section.classMethods = classMethods.filter({ !stripClassMethods.contains($0.name)})
            return section.hasMembers ? section : nil
        }

        var hasMembers: Bool {
            !classProperties.isEmpty || !instanceProperties.isEmpty || !classMethods.isEmpty || !instanceMethods.isEmpty
        }

        func headerLines(
            propertyOptions: Bool,
            propertyComments: Bool,
            methodTypeEncodings: Bool
        ) -> [String] {
            var lines: [String] = []
            if !classProperties.isEmpty {
                lines += classProperties.map({
                    $0.headerString(includeDefaultAttributes: propertyOptions, includeComments: propertyComments)
                })
            }
            if !instanceProperties.isEmpty {
                if !lines.isEmpty {
                    lines += ""
                }
                lines += instanceProperties.map({
                    $0.headerString(includeDefaultAttributes: propertyOptions, includeComments: propertyComments)
                })
            }
            if !classMethods.isEmpty {
                if !lines.isEmpty {
                    lines += ""
                }
                lines += classMethods.map({ $0.headerString(includeTypeEncoding: methodTypeEncodings) })
            }
            if !instanceMethods.isEmpty {
                if !lines.isEmpty {
                    lines += ""
                }
                lines += instanceMethods.map({ $0.headerString(includeTypeEncoding: methodTypeEncodings) })
            }
            return lines
        }
    }
}
