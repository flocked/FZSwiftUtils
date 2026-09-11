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
    /// A Swift array literal containing the compact Swift code representation of each element.
    public var swiftCode: String {
        "[" + map { $0.swiftCodeCompact }.joined(separator: ", ") + "]"
    }
}

extension Dictionary: SwiftCodeRepresentable where Key: SwiftCodeRepresentable, Value: SwiftCodeRepresentable {
    /// A Swift dictionary literal containing the compact Swift code representation of each key and value.
    public var swiftCode: String {
        let pairs = map { element in
            (key: element.key.swiftCodeCompact, value: element.value.swiftCodeCompact)
        }
        let sortedPairs = pairs.sorted {
            $0.key == $1.key ? $0.value < $1.value : $0.key < $1.key
        }
        let values = sortedPairs.map { "\($0.key): \($0.value)" }
        return "[" + values.joined(separator: ", ") + "]"
    }
}

extension Set: SwiftCodeRepresentable where Element: SwiftCodeRepresentable {
    /// A Swift set initializer containing the compact Swift code representation of each element.
    public var swiftCode: String {
        "Set(\(swiftCodeCompact))"
    }
    
    /// A Swift array literal containing the compact Swift code representation of each set element.
    public var swiftCodeCompact: String {
        "[" + map { $0.swiftCodeCompact }.sorted().joined(separator: ", ") + "]"
    }
}

extension Optional: SwiftCodeRepresentable where Wrapped: SwiftCodeRepresentable {
    /// The wrapped value's explicit Swift code representation, or `nil`.
    public var swiftCode: String {
        optional?.swiftCode ?? "nil"
    }
    
    /// The wrapped value's compact Swift code representation, or `nil`.
    public var swiftCodeCompact: String {
        optional?.swiftCodeCompact ?? "nil"
    }
}

extension String: SwiftCodeRepresentable {
    /// A Swift string literal containing the escaped contents of the string.
    public var swiftCode: String {
        let escaped = unicodeScalars.map { scalar in
            switch scalar {
            case "\\":
                return "\\\\"
            case "\"":
                return "\\\""
            case "\n":
                return "\\n"
            case "\r":
                return "\\r"
            case "\t":
                return "\\t"
            case "\0":
                return "\\0"
            case _ where scalar.value < 0x20:
                return "\\u{\(String(scalar.value, radix: 16))}"
            default:
                return String(scalar)
            }
        }.joined()
        return "\"\(escaped)\""
    }
}

extension Character: SwiftCodeRepresentable {
    /// A Swift character initializer containing the escaped character.
    public var swiftCode: String {
        "Character(\(String(self).swiftCode))"
    }
    
    /// A Swift string literal containing the escaped character.
    public var swiftCodeCompact: String {
        String(self).swiftCode
    }
}

// MARK: - Booleans

extension Bool: SwiftCodeRepresentable {
    /// A Swift boolean literal representing the Boolean value.
    public var swiftCode: String {
        self ? "true" : "false"
    }
}

extension Int: SwiftCodeRepresentable {
    /// A Swift integer literal representing the integer value.
    public var swiftCode: String { String(self) }
}

extension Int8: SwiftCodeRepresentable {
    /// A Swift integer literal representing the 8-bit integer value.
    public var swiftCode: String { String(self) }
}

extension Int16: SwiftCodeRepresentable {
    /// A Swift integer literal representing the 16-bit integer value.
    public var swiftCode: String { String(self) }
}

extension Int32: SwiftCodeRepresentable {
    /// A Swift integer literal representing the 32-bit integer value.
    public var swiftCode: String { String(self) }
}

extension Int64: SwiftCodeRepresentable {
    /// A Swift integer literal representing the 64-bit integer value.
    public var swiftCode: String { String(self) }
}

extension UInt: SwiftCodeRepresentable {
    /// A Swift unsigned integer literal representing the unsigned integer value.
    public var swiftCode: String { String(self) }
}

extension UInt8: SwiftCodeRepresentable {
    /// A Swift unsigned integer literal representing the 8-bit unsigned integer value.
    public var swiftCode: String { String(self) }
}

extension UInt16: SwiftCodeRepresentable {
    /// A Swift unsigned integer literal representing the 16-bit unsigned integer value.
    public var swiftCode: String { String(self) }
}

extension UInt32: SwiftCodeRepresentable {
    /// A Swift unsigned integer literal representing the 32-bit unsigned integer value.
    public var swiftCode: String { String(self) }
}

extension UInt64: SwiftCodeRepresentable {
    /// A Swift unsigned integer literal representing the 64-bit unsigned integer value.
    public var swiftCode: String { String(self) }
}

extension Float: SwiftCodeRepresentable {
    /// An explicit Swift floating-point representation of the single-precision value.
    public var swiftCode: String {
        if isNaN { return "Float.nan" }
        if self == .infinity { return "Float.infinity" }
        if self == -.infinity { return "-Float.infinity" }
        return "Float(\(String(self)))"
    }
    
    /// A compact Swift floating-point literal for the single-precision value.
    public var swiftCodeCompact: String {
        if isNaN { return ".nan" }
        if self == .infinity { return ".infinity" }
        if self == -.infinity { return "-.infinity" }
        return String(self)
    }
}

extension Double: SwiftCodeRepresentable {
    /// An explicit Swift floating-point representation of the double-precision value.
    public var swiftCode: String {
        if isNaN { return "Double.nan" }
        if self == .infinity { return "Double.infinity" }
        if self == -.infinity { return "-Double.infinity" }
        return String(self)
    }
    
    /// A compact Swift floating-point literal for the double-precision value.
    public var swiftCodeCompact: String {
        if isNaN { return ".nan" }
        if self == .infinity { return ".infinity" }
        if self == -.infinity { return "-.infinity" }
        return String(self)
    }
}

extension CGFloat: SwiftCodeRepresentable {
    /// An explicit Swift initializer representing the Core Graphics floating-point value.
    public var swiftCode: String {
        "CGFloat(\(Double(self).swiftCode))"
    }
    
    /// A compact Swift floating-point literal for the Core Graphics floating-point value.
    public var swiftCodeCompact: String {
        Double(self).swiftCodeCompact
    }
}

extension URL: SwiftCodeRepresentable {
    /// A Swift URL initializer representing the URL.
    public var swiftCode: String {
        isFileURL ? "URL(filePath: \(path.swiftCode))" : "URL(string: \(absoluteString.swiftCode))!"
    }
}

extension UUID: SwiftCodeRepresentable {
    /// A Swift UUID initializer representing the UUID.
    public var swiftCode: String {
        return "UUID(uuidString: \(uuidString.swiftCode))!"
    }
}

extension Data: SwiftCodeRepresentable {
    /// A Swift data initializer containing the bytes of the data value.
    public var swiftCode: String {
        "Data([\(map { String($0) }.joined(separator: ", "))])"
    }
    
    /// A Swift byte array literal containing the bytes of the data value.
    public var swiftCodeCompact: String {
        "[\(map { String($0) }.joined(separator: ", "))]"
    }
}

extension Date: SwiftCodeRepresentable {
    /// A Swift date initializer preserving the date's reference-date interval.
    public var swiftCode: String {
        "Date(timeIntervalSinceReferenceDate: \(timeIntervalSinceReferenceDate.swiftCode))"
    }
}

extension Decimal: SwiftCodeRepresentable {
    /// A Swift decimal initializer preserving the decimal value's textual representation.
    public var swiftCode: String {
        "Decimal(string: \(description.swiftCode))!"
    }
}

extension URLComponents: SwiftCodeRepresentable {
    /// A Swift URL components initializer or construction closure representing the URL components.
    public var swiftCode: String {
        if let string {
            return "URLComponents(string: \(string.swiftCode))!"
        }
        var assignments: [String] = []
        if let scheme { assignments.append("components.scheme = \(scheme.swiftCode)") }
        if let user { assignments.append("components.user = \(user.swiftCode)") }
        if let password { assignments.append("components.password = \(password.swiftCode)") }
        if let host { assignments.append("components.host = \(host.swiftCode)") }
        if let port { assignments.append("components.port = \(port.swiftCode)") }
        if !path.isEmpty { assignments.append("components.path = \(path.swiftCode)") }
        if let query { assignments.append("components.query = \(query.swiftCode)") }
        if let fragment { assignments.append("components.fragment = \(fragment.swiftCode)") }
        return "({ var components = URLComponents(); \(assignments.joined(separator: "; ")); return components })()"
    }
}

extension TimeZone: SwiftCodeRepresentable {
    /// A Swift time zone initializer representing the time zone.
    public var swiftCode: String {
        if TimeZone(identifier: identifier) == self {
            return "TimeZone(identifier: \(identifier.swiftCode))!"
        }
        return "TimeZone(secondsFromGMT: \(secondsFromGMT().swiftCode))!"
    }
}

extension Locale: SwiftCodeRepresentable {
    /// A Swift locale initializer representing the locale.
    public var swiftCode: String {
        "Locale(identifier: \(identifier.swiftCode))"
    }
}

extension Calendar.Identifier: SwiftCodeRepresentable {
    /// A Swift calendar identifier case representing the calendar identifier.
    public var swiftCode: String {
        switch self {
        case .gregorian: return ".gregorian"
        case .buddhist: return ".buddhist"
        case .chinese: return ".chinese"
        case .coptic: return ".coptic"
        case .ethiopicAmeteMihret: return ".ethiopicAmeteMihret"
        case .ethiopicAmeteAlem: return ".ethiopicAmeteAlem"
        case .hebrew: return ".hebrew"
        case .iso8601: return ".iso8601"
        case .indian: return ".indian"
        case .islamic: return ".islamic"
        case .islamicCivil: return ".islamicCivil"
        case .japanese: return ".japanese"
        case .persian: return ".persian"
        case .republicOfChina: return ".republicOfChina"
        case .islamicTabular: return ".islamicTabular"
        case .islamicUmmAlQura: return ".islamicUmmAlQura"
        case .bangla: return ".bangla"
        case .gujarati: return ".gujarati"
        case .kannada: return ".kannada"
        case .malayalam: return ".malayalam"
        case .marathi: return ".marathi"
        case .odia: return ".odia"
        case .tamil: return ".tamil"
        case .telugu: return ".telugu"
        case .vikram: return ".vikram"
        case .dangi: return ".dangi"
        case .vietnamese: return ".vietnamese"
        @unknown default: return ".gregorian /* unknown calendar identifier: \(String(describing: self)) */"
        }
    }
}

extension Calendar: SwiftCodeRepresentable {
    /// A Swift construction closure representing the calendar and its configurable properties.
    public var swiftCode: String {
        var assignments: [String] = []
        if let locale { assignments.append("calendar.locale = \(locale.swiftCode)") }
        assignments.append("calendar.timeZone = \(timeZone.swiftCode)")
        assignments.append("calendar.firstWeekday = \(firstWeekday.swiftCode)")
        assignments.append("calendar.minimumDaysInFirstWeek = \(minimumDaysInFirstWeek.swiftCode)")
        return "({ var calendar = Calendar(identifier: \(identifier.swiftCode)); \(assignments.joined(separator: "; ")); return calendar })()"
    }
}

extension DateComponents: SwiftCodeRepresentable {
    /// A Swift construction closure representing the date components and their configured fields.
    public var swiftCode: String {
        var assignments: [String] = []
        if let calendar { assignments.append("components.calendar = \(calendar.swiftCode)") }
        if let timeZone { assignments.append("components.timeZone = \(timeZone.swiftCode)") }
        if let era { assignments.append("components.era = \(era.swiftCode)") }
        if let year { assignments.append("components.year = \(year.swiftCode)") }
        if let month { assignments.append("components.month = \(month.swiftCode)") }
        if let day { assignments.append("components.day = \(day.swiftCode)") }
        if let hour { assignments.append("components.hour = \(hour.swiftCode)") }
        if let minute { assignments.append("components.minute = \(minute.swiftCode)") }
        if let second { assignments.append("components.second = \(second.swiftCode)") }
        if let nanosecond { assignments.append("components.nanosecond = \(nanosecond.swiftCode)") }
        if let weekday { assignments.append("components.weekday = \(weekday.swiftCode)") }
        if let weekdayOrdinal { assignments.append("components.weekdayOrdinal = \(weekdayOrdinal.swiftCode)") }
        if let quarter { assignments.append("components.quarter = \(quarter.swiftCode)") }
        if let weekOfMonth { assignments.append("components.weekOfMonth = \(weekOfMonth.swiftCode)") }
        if let weekOfYear { assignments.append("components.weekOfYear = \(weekOfYear.swiftCode)") }
        if let yearForWeekOfYear { assignments.append("components.yearForWeekOfYear = \(yearForWeekOfYear.swiftCode)") }
        guard !assignments.isEmpty else { return "DateComponents()" }
        return "({ var components = DateComponents(); \(assignments.joined(separator: "; ")); return components })()"
    }
}

extension Measurement: SwiftCodeRepresentable where UnitType: SwiftCodeRepresentable {
    /// A Swift measurement initializer representing the measurement value and unit.
    public var swiftCode: String {
        "Measurement(value: \(value.swiftCode), unit: \(unit.swiftCode))"
    }
}

private extension Dimension {
    func swiftCode(typeName: String) -> String {
        if let converter = converter as? UnitConverterLinear {
            return "\(typeName)(symbol: \(symbol.swiftCode), converter: UnitConverterLinear(coefficient: \(converter.coefficient.swiftCode), constant: \(converter.constant.swiftCode)))"
        }
        return "\(typeName)(symbol: \(symbol.swiftCode), converter: UnitConverterLinear(coefficient: 1))"
    }
}

extension UnitDuration: SwiftCodeRepresentable {
    /// A Swift duration unit case or initializer representing the duration unit.
    public var swiftCode: String {
        switch self {
        case .hours: return "UnitDuration.hours"
        case .minutes: return "UnitDuration.minutes"
        case .seconds: return "UnitDuration.seconds"
        case .milliseconds: return "UnitDuration.milliseconds"
        case .microseconds: return "UnitDuration.microseconds"
        case .nanoseconds: return "UnitDuration.nanoseconds"
        case .picoseconds: return "UnitDuration.picoseconds"
        default: return swiftCode(typeName: "UnitDuration")
        }
    }
}

extension UnitLength: SwiftCodeRepresentable {
    /// A Swift length unit case or initializer representing the length unit.
    public var swiftCode: String {
        switch self {
        case .megameters: return "UnitLength.megameters"
        case .kilometers: return "UnitLength.kilometers"
        case .hectometers: return "UnitLength.hectometers"
        case .decameters: return "UnitLength.decameters"
        case .meters: return "UnitLength.meters"
        case .decimeters: return "UnitLength.decimeters"
        case .centimeters: return "UnitLength.centimeters"
        case .millimeters: return "UnitLength.millimeters"
        case .micrometers: return "UnitLength.micrometers"
        case .nanometers: return "UnitLength.nanometers"
        case .picometers: return "UnitLength.picometers"
        case .inches: return "UnitLength.inches"
        case .feet: return "UnitLength.feet"
        case .yards: return "UnitLength.yards"
        case .miles: return "UnitLength.miles"
        case .scandinavianMiles: return "UnitLength.scandinavianMiles"
        case .lightyears: return "UnitLength.lightyears"
        case .nauticalMiles: return "UnitLength.nauticalMiles"
        case .fathoms: return "UnitLength.fathoms"
        case .furlongs: return "UnitLength.furlongs"
        case .astronomicalUnits: return "UnitLength.astronomicalUnits"
        case .parsecs: return "UnitLength.parsecs"
        default: return swiftCode(typeName: "UnitLength")
        }
    }
}

extension UnitMass: SwiftCodeRepresentable {
    /// A Swift mass unit case or initializer representing the mass unit.
    public var swiftCode: String {
        switch self {
        case .kilograms: return "UnitMass.kilograms"
        case .grams: return "UnitMass.grams"
        case .decigrams: return "UnitMass.decigrams"
        case .centigrams: return "UnitMass.centigrams"
        case .milligrams: return "UnitMass.milligrams"
        case .micrograms: return "UnitMass.micrograms"
        case .nanograms: return "UnitMass.nanograms"
        case .picograms: return "UnitMass.picograms"
        case .ounces: return "UnitMass.ounces"
        case .pounds: return "UnitMass.pounds"
        case .stones: return "UnitMass.stones"
        case .metricTons: return "UnitMass.metricTons"
        case .shortTons: return "UnitMass.shortTons"
        case .carats: return "UnitMass.carats"
        case .ouncesTroy: return "UnitMass.ouncesTroy"
        case .slugs: return "UnitMass.slugs"
        default: return swiftCode(typeName: "UnitMass")
        }
    }
}

extension UnitTemperature: SwiftCodeRepresentable {
    /// A Swift temperature unit case or initializer representing the temperature unit.
    public var swiftCode: String {
        switch self {
        case .kelvin: return "UnitTemperature.kelvin"
        case .celsius: return "UnitTemperature.celsius"
        case .fahrenheit: return "UnitTemperature.fahrenheit"
        default: return swiftCode(typeName: "UnitTemperature")
        }
    }
}

extension IndexPath: SwiftCodeRepresentable {
    /// A Swift index path initializer containing the indexes of the index path.
    public var swiftCode: String {
        "IndexPath(indexes: \(map { $0 }.swiftCode))"
    }
}

extension CGPoint: SwiftCodeRepresentable {
    /// A Swift point initializer representing the point's coordinates.
    public var swiftCode: String {
        return "CGPoint(x: \(x.swiftCode), y: \(y.swiftCode))"
    }
}

extension CGSize: SwiftCodeRepresentable {
    /// A Swift size initializer representing the size's dimensions.
    public var swiftCode: String {
        return "CGSize(width: \(width.swiftCode), height: \(height.swiftCode))"
    }
}

extension CGRect: SwiftCodeRepresentable {
    /// A Swift rectangle initializer representing the rectangle's origin and size.
    public var swiftCode: String {
        return "CGRect(x: \(origin.x.swiftCode), y: \(origin.y.swiftCode), width: \(size.width.swiftCode), height: \(size.height.swiftCode))"
    }
}

extension CGVector: SwiftCodeRepresentable {
    /// A Swift vector initializer representing the vector's horizontal and vertical components.
    public var swiftCode: String {
        return "CGVector(dx: \(dx.swiftCode), dy: \(dy.swiftCode))"
    }
}

extension CGAffineTransform: SwiftCodeRepresentable {
    /// A Swift affine transform initializer representing the transform matrix.
    public var swiftCode: String {
        return "CGAffineTransform(a: \(a.swiftCode), b: \(b.swiftCode), c: \(c.swiftCode), d: \(d.swiftCode), tx: \(tx.swiftCode), ty: \(ty.swiftCode))"
    }
}

extension AffineTransform: SwiftCodeRepresentable {
    /// A Swift affine transform initializer representing the transform matrix.
    public var swiftCode: String {
        "AffineTransform(m11: \(m11.swiftCode), m12: \(m12.swiftCode), m21: \(m21.swiftCode), m22: \(m22.swiftCode), tX: \(tX.swiftCode), tY: \(tY.swiftCode))"
    }
}

extension SIMD2: SwiftCodeRepresentable where Scalar: SwiftCodeRepresentable {
    /// A Swift two-component SIMD initializer representing the vector.
    public var swiftCode: String {
        "SIMD2(\(x.swiftCodeCompact), \(y.swiftCodeCompact))"
    }
}

extension SIMD3: SwiftCodeRepresentable where Scalar: SwiftCodeRepresentable {
    /// A Swift three-component SIMD initializer representing the vector.
    public var swiftCode: String {
        "SIMD3(\(x.swiftCodeCompact), \(y.swiftCodeCompact), \(z.swiftCodeCompact))"
    }
}

extension SIMD4: SwiftCodeRepresentable where Scalar: SwiftCodeRepresentable {
    /// A Swift four-component SIMD initializer representing the vector.
    public var swiftCode: String {
        "SIMD4(\(x.swiftCodeCompact), \(y.swiftCodeCompact), \(z.swiftCodeCompact), \(w.swiftCodeCompact))"
    }
}

extension NSRange: SwiftCodeRepresentable {
    /// A Swift range initializer representing the range's location and length.
    public var swiftCode: String {
        return "NSRange(location: \(location.swiftCode), length: \(length.swiftCode))"
    }
}

extension ClosedRange: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    /// A Swift closed range expression representing the range bounds.
    public var swiftCode: String {
        "\(lowerBound.swiftCode)...\(upperBound.swiftCode)"
    }
}

extension Range: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    /// A Swift half-open range expression representing the range bounds.
    public var swiftCode: String {
        "\(lowerBound.swiftCode)..<\(upperBound.swiftCode)"
    }
}

extension PartialRangeFrom: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    /// A Swift one-sided range expression starting from the lower bound.
    public var swiftCode: String {
        "\(lowerBound.swiftCode)..."
    }
}

extension PartialRangeThrough: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    /// A Swift one-sided closed range expression ending at the upper bound.
    public var swiftCode: String {
        "...\(upperBound.swiftCode)"
    }
}

extension PartialRangeUpTo: SwiftCodeRepresentable where Bound: SwiftCodeRepresentable {
    /// A Swift one-sided half-open range expression ending before the upper bound.
    public var swiftCode: String {
        "..<\(upperBound.swiftCode)"
    }
}

extension NSDirectionalEdgeInsets: SwiftCodeRepresentable {
    /// A Swift directional edge insets initializer representing the inset values.
    public var swiftCode: String {
        return "NSDirectionalEdgeInsets(top: \(top.swiftCode), leading: \(leading.swiftCode), bottom: \(bottom.swiftCode), trailing: \(trailing.swiftCode))"
    }
}

#if canImport(AppKit)
import AppKit

extension NSEdgeInsets: SwiftCodeRepresentable {
    /// A Swift edge insets initializer representing the AppKit inset values.
    public var swiftCode: String {
        "NSEdgeInsets(top: \(top.swiftCode), left: \(left.swiftCode), bottom: \(bottom.swiftCode), right: \(right.swiftCode))"
    }
}

extension NSColor {
    func sdsd() {
        
    }
}
#elseif canImport(UIKit)
import UIKit

extension UIEdgeInsets: SwiftCodeRepresentable {
    /// A Swift edge insets initializer representing the UIKit inset values.
    public var swiftCode: String {
        return "UIEdgeInsets(top: \(top.swiftCode), left: \(left.swiftCode), bottom: \(bottom.swiftCode), right: \(right.swiftCode))"
    }
}

extension UIOffset: SwiftCodeRepresentable {
    /// A Swift offset initializer representing the UIKit horizontal and vertical offsets.
    public var swiftCode: String {
        return "UIOffset(horizontal: \(horizontal.swiftCode), vertical: \(vertical.swiftCode))"
    }
}

extension UIRectEdge: SwiftCodeRepresentable {
    /// A Swift option set literal representing the UIKit rectangle edges.
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
    /// A Swift option set literal representing the directional rectangle edges.
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
