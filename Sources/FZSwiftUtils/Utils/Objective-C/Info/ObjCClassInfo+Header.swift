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

extension ObjCClassInfo {
    /// Returns a string representing the class in a Objective-C header.
    public var headerString: String {
        headerString()
    }
    
    /// Returns a string representing the class in a Objective-C header.
    public func headerString(options: HeaderStringOptions = [.groupByOrigin, .includeCategoryMethods, .addPropertyAttributesComments]) -> String {
        _headerString(options: options).string
    }
    
    /**
    Returns an attributed string representing the class in a Objective-C header.
          
     - Parameters:
        - options: The header string options.
        - font: The font of the attributed string, or `nil` to use the default font.
     */
    public func attributedHeaderString(options: HeaderStringOptions = [.groupByOrigin, .includeCategoryMethods, .addPropertyAttributesComments], font: NSUIFont? = nil) -> NSAttributedString {
        let val = _headerString(options: options)
        let attributed = NSMutableAttributedString(
            attributedString: .objCHeader(for: val.string, font: font)
        )
        attributed.addObjCDeclarationAttributes(val.declarations)
        return attributed
    }
    
    /// Returns a string representing the class in a Objective-C header.
   private func _headerString(options: HeaderStringOptions = [.groupByOrigin, .includeCategoryMethods, .addPropertyAttributesComments]) -> (string: String, declarations: [(line: String, key: NSAttributedString.Key, value: Any)]) {
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
       if options.contains(.stripPublic), let info = ObjCHeader.getClass(named: name) {
           stripMethods += info.methods.map({$0.name})
           stripClassMethods += info.classMethods.map({$0.name})
           stripProperties += info.properties.map({$0.name})
           stripClassProperties += info.classProperties.map({$0.name})
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
            let includeFields = options.contains(.includeStructAndUnionFields)
            lines += ivars.map({ ivar in
                let line = ivar.headerString(includeFields: includeFields).components(separatedBy: .newlines).map { "    \($0)" }.joined(separator: "\n")
                declarations += (line, .objcIvar, value: ivar.name)
                return line
            })
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
        let renameArguments = options.contains(.renameMethodArguments)
        let includeFields = options.contains(.includeStructAndUnionFields)
        guard options.contains(.groupByOrigin) || !options.contains(.includeCategoryMethods), var sections = allHeaderSections() else {
            let classProperties = classProperties.filter({ !stripClassProperties.contains($0.name)})
            let properties = properties.filter({ !stripProperties.contains($0.name)})
            let classMethods = classMethods.filter({ !stripClassMethods.contains($0.name)})
            let methods = methods.filter({ !stripMethods.contains($0.name)})
            return lines(for: classProperties, properties, classMethods, methods, propertyOptions: propertyOptions, propertyComments: propertyComments, methodTypeEncodings: methodTypeEncodings, renameArguments: renameArguments, includeFields: includeFields, declarations: &declarations)
        }
        
        let includeCategories = options.contains(.includeCategoryMethods)
        sections = sections.compactMap({$0.filtered(with: stripProperties, stripClassProperties, stripMethods, stripClassMethods, includeCategories: includeCategories)})

        if !options.contains(.groupByOrigin) {
            let classProperties = sections.flatMap(\.classProperties).sorted(by: \.name)
            let properties = sections.flatMap(\.instanceProperties).sorted(by: \.name)
            let classMethods = sections.flatMap(\.classMethods).sorted(by: \.name)
            let methods = sections.flatMap(\.instanceMethods).sorted(by: \.name)
            return lines(for: classProperties, properties, classMethods, methods, propertyOptions: propertyOptions, propertyComments: propertyComments, methodTypeEncodings: methodTypeEncodings, renameArguments: renameArguments, includeFields: includeFields, declarations: &declarations)
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
                let line = "// \(section.imagePath.imageName) (\(section.imagePath))"
                lines += line
                lines += ""
                declarations += (section.imagePath, .objcImageName, section.imagePath)
            }
            if !section.categoryName.isEmpty {
                lines += "// \(name) (\(section.categoryName))"
                lines += ""
            }
            let newLines = self.lines(for: section.classProperties, section.instanceProperties, section.classMethods, section.instanceMethods, propertyOptions: propertyOptions, propertyComments: propertyComments, methodTypeEncodings: methodTypeEncodings, renameArguments: renameArguments, includeFields: includeFields, declarations: &declarations)
            if !newLines.isEmpty {
                lines += newLines.dropFirst()
            }
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
    
    func lines(for classProperties: [ObjCPropertyInfo], _ properties: [ObjCPropertyInfo], _ classMethods: [ObjCMethodInfo], _ methods: [ObjCMethodInfo], propertyOptions: Bool, propertyComments: Bool, methodTypeEncodings: Bool, renameArguments: Bool, includeFields: Bool, declarations: inout [(line: String, key: NSAttributedString.Key, value: Any)]) -> [String] {
        var lines: [String] = []
        if !classProperties.isEmpty {
            lines += "" + classProperties.map({
                let line = $0.headerString(includeFields: includeFields, includeDefaultAttributes: propertyOptions, includeComments: propertyComments)
                declarations += (line, .objcClassProperty, $0.name)
                return line
            })
        }
        if !properties.isEmpty {
            lines += "" + properties.map({
                let line = $0.headerString(includeFields: includeFields, includeDefaultAttributes: propertyOptions, includeComments: propertyComments)
                declarations += (line, .objcProperty, $0.name)
                return line
            })
        }
        if !classMethods.isEmpty {
            lines += "" + classMethods.map({
                let line = $0.headerString(includeArgumentFields: includeFields, includeTypeEncoding: methodTypeEncodings, renameArguments: renameArguments)
                declarations += (line, .objcClassMethod, $0.name)
                return line
            })
        }
        if !methods.isEmpty {
            lines += "" + methods.map({
                let line = $0.headerString(includeArgumentFields: includeFields, includeTypeEncoding: methodTypeEncodings, renameArguments: renameArguments)
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
        let primaryImagePath = imagePath ?? ""

        var bucketsByImage: [String: [String: CategoryBucket]] = .init(
            minimumCapacity: classProperties.count + properties.count + classMethods.count + methods.count
        )
        
        func append(_ methodInfo: ObjCMethodInfo) {
            let method = methodInfo.isClassMethod ? objcClass.classMethod(for: .string(methodInfo.name)) : objcClass.method(for: .string(methodInfo.name))
            let origin: (imagePath: String?, categoryName: String?, symbolName: String?) =
                method.map(ObjCRuntime.origin(of:)) ?? (primaryImagePath, nil, nil)
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()].add(methodInfo)
        }

        func append(_ propertyInfo: ObjCPropertyInfo) {
            let method = propertyInfo.isClassProperty ? objcClass.classMethod(for: propertyInfo.getter)  : objcClass.method(for: propertyInfo.getter)
            let origin: (imagePath: String?, categoryName: String?, symbolName: String?) =
                method.map(ObjCRuntime.origin(of:)) ?? (primaryImagePath, nil, nil)
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()].add(propertyInfo)
        }

        classProperties.forEach { append($0) }
        properties.forEach { append($0) }
        classMethods.forEach { append($0) }
        methods.forEach { append($0) }
        
        var sortedImagePaths = bucketsByImage.sorted(by: \.key, options: .caseInsensitive)
        let preferredImagePath = primaryImagePath ?? ""
        if let index = sortedImagePaths.firstIndex(where: { $0.key == preferredImagePath }) {
            sortedImagePaths.insert(sortedImagePaths.remove(at: index), at: 0)
        }
        let headerSections = sortedImagePaths.flatMap { element in
            element.value.sorted(by: \.key.imageName, options: .caseInsensitive) .compactMap { $0.value.headerSection(imagePath: element.key, categoryName: $0.key) }
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
        
        mutating func add(_ info: ObjCMethodInfo) {
            info.isClassMethod ? classMethods.append(info) : instanceMethods.append(info)
        }
        mutating func add(_ info: ObjCPropertyInfo) {
            info.isClassProperty ? classProperties.append(info) : instanceProperties.append(info)
        }
        
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
                      _ stripClassMethods: Set<String>, includeCategories: Bool) -> Self? {
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
    }
}

fileprivate extension String {
    var imageName: String {
        URL(fileURLWithPath: self).lastPathComponent
    }
}
