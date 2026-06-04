//
//  SwiftCodeRepresentable.swift
//  
//
//  Created by Florian Zand on 04.06.26.
//

import Foundation

/// A type that can generate a Swift source code representation of its value.
public protocol SwiftCodeRepresentable {
    /// A fully explicit Swift source code representation of the receiver.
    var swiftCode: String { get }
    /// A concise Swift source code representation of the receiver that may rely on type inference.
    var swiftCodeCompact: String { get }
}

public extension SwiftCodeRepresentable {
    var swiftCodeCompact: String { swiftCode }
}

extension Array: SwiftCodeRepresentable where Element: SwiftCodeRepresentable {
    public var swiftCode: String {
        "[" + map { $0.swiftCodeCompact }.joined(separator: ", ") + "]"
    }
}

extension Dictionary: SwiftCodeRepresentable where Key: SwiftCodeRepresentable, Value: SwiftCodeRepresentable {
    public var swiftCode: String {
        "[" + map { "\($0.key.swiftCodeCompact): \($0.value.swiftCodeCompact)" }
            .joined(separator: ", ") + "]"
    }
}

extension Set: SwiftCodeRepresentable where Element: SwiftCodeRepresentable {
    public var swiftCode: String {
        "Set(\(Array(self).swiftCode))"
    }
    
    public var swiftCodeCompact: String {
        Array(self).swiftCode
    }
}

extension Optional: SwiftCodeRepresentable where Wrapped: SwiftCodeRepresentable {
    public var swiftCode: String {
        optional?.swiftCode ?? "nil"
    }
    
    public var swiftCodeCompact: String {
        optional?.swiftCodeCompact ?? "nil"
    }
}

extension String: SwiftCodeRepresentable {
    public var swiftCode: String {
        let escaped = self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }
}

extension Character: SwiftCodeRepresentable {
    public var swiftCode: String {
        String(self).swiftCode
    }
}

// MARK: - Booleans

extension Bool: SwiftCodeRepresentable {
    public var swiftCode: String {
        self ? "true" : "false"
    }
}

extension Int: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension Int8: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension Int16: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension Int32: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension Int64: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension UInt: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension UInt8: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension UInt16: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension UInt32: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension UInt64: SwiftCodeRepresentable {
    public var swiftCode: String { String(self) }
}

extension Float: SwiftCodeRepresentable {
    public var swiftCode: String {
        if isNaN { return "Float.nan" }
        if self == .infinity { return "Float.infinity" }
        if self == -.infinity { return "-Float.infinity" }
        return String(self)
    }
}

extension Double: SwiftCodeRepresentable {
    public var swiftCode: String {
        if isNaN { return ".nan" }
        if self == .infinity { return ".infinity" }
        if self == -.infinity { return "-.infinity" }
        return String(self)
    }
}

extension CGFloat: SwiftCodeRepresentable {
    public var swiftCode: String {
        Double(self).swiftCode
    }
}

extension URL: SwiftCodeRepresentable {
    public var swiftCode: String {
        isFileURL ? "URL(fileURLWithPath: \(path.swiftCode))" : "URL(string: \(absoluteString.swiftCode))!"
    }
}

extension UUID: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "UUID(uuidString: \(uuidString.swiftCode))!"
    }
}

extension Data: SwiftCodeRepresentable {
    public var swiftCode: String {
        "Data([\(map { String($0) }.joined(separator: ", "))])"
    }
    
    public var swiftCodeCompact: String {
        "[\(map { String($0) }.joined(separator: ", "))]"
    }
}

extension Date: SwiftCodeRepresentable {
    public var swiftCode: String {
        "Date(timeIntervalSinceReferenceDate: \(timeIntervalSinceReferenceDate.swiftCode))"
    }
}

extension Decimal: SwiftCodeRepresentable {
    public var swiftCode: String {
        description.swiftCode
    }
}

extension IndexPath: SwiftCodeRepresentable {
    public var swiftCode: String {
        "IndexPath(indexes: \(map { $0 }.swiftCode))"
    }
}

extension CGPoint: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "CGPoint(x: \(x.swiftCode), y: \(y.swiftCode))"
    }
}

extension CGSize: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "CGSize(width: \(width.swiftCode), height: \(height.swiftCode))"
    }
}

extension CGRect: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "CGRect(x: \(origin.x.swiftCode), y: \(origin.y.swiftCode), width: \(size.width.swiftCode), height: \(size.height.swiftCode))"
    }
}

extension CGVector: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "CGVector(dx: \(dx.swiftCode), dy: \(dy.swiftCode))"
    }
}

extension CGAffineTransform: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "CGAffineTransform(a: \(a.swiftCode), b: \(b.swiftCode), c: \(c.swiftCode), d: \(d.swiftCode), tx: \(tx.swiftCode), ty: \(ty.swiftCode))"
    }
}

extension NSRange: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "NSRange(location: \(location.swiftCode), length: \(length.swiftCode))"
    }
}

extension ClosedRange: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    public var swiftCode: String {
        "\(lowerBound.swiftCode)...\(upperBound.swiftCode)"
    }
}

extension Range: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    public var swiftCode: String {
        "\(lowerBound.swiftCode)..<\(upperBound.swiftCode)"
    }
}

extension PartialRangeFrom: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    public var swiftCode: String {
        "\(lowerBound.swiftCode)..."
    }
}

extension PartialRangeThrough: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    public var swiftCode: String {
        "...\(upperBound.swiftCode)"
    }
}

extension PartialRangeUpTo: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    public var swiftCode: String {
        "..<\(upperBound.swiftCode)"
    }
}

extension NSDirectionalEdgeInsets: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "NSDirectionalEdgeInsets(top: \(top.swiftCode), leading: \(leading.swiftCode), bottom: \(bottom.swiftCode), trailing: \(trailing.swiftCode))"
    }
}

#if canImport(AppKit)
import AppKit

extension NSEdgeInsets: SwiftCodeRepresentable {
    public var swiftCode: String {
        "NSEdgeInsets(top: \(top.swiftCode), left: \(left.swiftCode), bottom: \(bottom.swiftCode), right: \(right.swiftCode))"
    }
}
#elseif canImport(UIKit)
import UIKit

extension UIEdgeInsets: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "UIEdgeInsets(top: \(top.swiftCode), left: \(left.swiftCode), bottom: \(bottom.swiftCode), right: \(right.swiftCode))"
    }
}

extension UIOffset: SwiftCodeRepresentable {
    public var swiftCode: String {
        return "UIOffset(horizontal: \(horizontal.swiftCode), vertical: \(vertical.swiftCode))"
    }
}

extension UIRectEdge: SwiftCodeRepresentable {
    public var swiftCode: String {
        if isEmpty { return "[]" }
        var values: [String] = []
        if contains(.top) { values.append(".top") }
        if contains(.left) { values.append(".left") }
        if contains(.bottom) { values.append(".bottom") }
        if contains(.right) { values.append(".right") }
        return "[\(values.joined(separator: ", "))]"
    }
}

extension NSDirectionalRectEdge: SwiftCodeRepresentable {
    public var swiftCode: String {
        if isEmpty { return "[]" }
        var values: [String] = []
        if contains(.top) { values.append(".top") }
        if contains(.leading) { values.append(".leading") }
        if contains(.bottom) { values.append(".bottom") }
        if contains(.trailing) { values.append(".trailing") }
        return "[\(values.joined(separator: ", "))]"
    }
}
#endif
