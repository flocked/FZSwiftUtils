//
//  Mirror+.swift
//
//
//  Created by Florian Zand on 08.01.25.
//

extension Mirror {
    /**
     Prints the details of the object, such as labels, values, types, and depth of nested properties,
     based on the provided `PrintOptions` and `maxLevel`.

     - Parameters:
        - options: A  value that specifies the details to be printed for each child (`label`, `valueType` and `value`).
        - maxLevel: An optional integer specifying the maximum depth for recursion when printing nested properties. If not provided, recursion will be unlimited.
        - maxChildren: An optional integer specifying the maximum amount of children to display.
    */
    public func print(_ options: PrintOptions = .all, maxLevel: Int? = nil, maxChildren: Int? = nil) {
        Swift.print("Mirror<\(subjectType)>(")
        Swift.print(strings(level: 1, maxLevel: maxLevel, maxChildren: maxChildren, options: options).joined(separator: "\n"))
        Swift.print(")")
    }
    
    /// Options for printing the mirror.
    public struct PrintOptions: OptionSet, Codable {
        /// Include child label.
        public static let label = PrintOptions(rawValue: 1 << 0)
        /// Include child value type.
        public static let valueType = PrintOptions(rawValue: 1 << 1)
        /// Include child value.
        public static let value = PrintOptions(rawValue: 1 << 2)
        /// Include children of the subject’s superclass, if one exists.
        public static let superclass = PrintOptions(rawValue: 1 << 3)
        /// Child Label, value type and value & superclass children.
        public static let all: PrintOptions = [.label, .valueType, .value, .superclass]
        
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
    }
    
    func strings(level: Int, maxLevel: Int? = nil, maxChildren: Int? = nil, options: PrintOptions = .all) -> [String] {
        var strings: [String] = []
        let indentation = String(repeating: "  ", count: level)
        if options.contains(.superclass), let superclassMirror = superclassMirror {
            strings.append("\(indentation)Superclass<\(superclassMirror.subjectType)>(")
            strings += superclassMirror.strings(level: level + 1, maxLevel: maxLevel, maxChildren: maxChildren, options: options)
            strings.append("\(indentation))")
        }
        let includeLabel = options.contains(.label)
        let includeType = options.contains(.valueType)
        let includeValue = options.contains(.value)
        var children = Array(children)
        if let maxChildren = maxChildren {
            children = children[safe: 0..<maxChildren]
        }
        for child in children {
            let value = options.contains(.value) ? " = \(child.value)" : ""
            if includeLabel, let label = child.label {
                if includeType {
                    strings += "\(indentation)\(label): \(type(of: child.value))\(value)"
                } else {
                    strings += "\(indentation)\(label)\(value)"
                }
            } else {
                if includeType {
                    strings += "\(indentation)\(type(of: child.value))\(value)"
                } else {
                    if includeValue {
                        strings += "\(indentation)\(child.value)"
                    }
                }
            }
            if level - 1 < maxLevel ?? .max {
                strings += Mirror(reflecting: child.value).strings(level: level + 1, maxLevel: maxLevel, maxChildren: maxChildren, options: options)
            }
        }
        return strings
    }
    
    /**
     Returns a string representation of the subject.
     
     - Parameters:
        - includeType: A Boolean value indicating whether to include the subject type.
        - includePropertyNames: A Boolean value indicating whether to include the property names.
     */
    public func prettyDescription(includeType: Bool = true, includePropertyNames: Bool = true) -> String {
        let name = includeType ? String(describing: subjectType) : ""
        let props = children.prettyDescription(includeLabels: includePropertyNames)
        return "\(name)(\(props))"
    }
}

extension Mirror.Children {
    /**
     Returns a string representation of the children.
     
     - Parameter includeLabels: A Boolean value indicating whether to include the labels.
     */
    public func prettyDescription(includeLabels: Bool = true) -> String {
        if includeLabels {
            return map { "\($0.label ?? "_"): \(String(cleanDescribing: $0.value))" }.joined(separator: ", ")
        } else {
            return map { "\(String(cleanDescribing: $0.value))" }.joined(separator: ", ")
        }
    }
}
