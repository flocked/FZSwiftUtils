//
//  ByteCountFormatter+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation

public extension ByteCountFormatter {
    /**
     Initializes a `ByteCountFormatter` instance with the specified allowed units and count style.

     - Parameter allowedUnits: The allowed units for formatting byte counts.
     - Parameter countStyle: The count style for formatting byte counts. Default value is `.file`.
     */
    convenience init(allowedUnits: Units, countStyle: CountStyle = .file) {
        self.init()
        self.allowedUnits = allowedUnits
        self.countStyle = countStyle
    }
    
    /// Specify the units that can be used in the output.
    @discardableResult
    func allowedUnits(_ units: Units) -> Self {
        allowedUnits = units
        return self
    }
    
    /// Sets the number of bytes to be used for kilobytes.
    @discardableResult
    func countStyle(_ style: CountStyle) -> Self {
        countStyle = style
        return self
    }
    
    /// Sets the Boolean value indicating whether to allow more natural display of some values.
    @discardableResult
    func allowsNonnumericFormatting(_ allows: Bool) -> Self {
        allowsNonnumericFormatting = allows
        return self
    }
    
    /// Sets the Boolean value indicating whether to include the number of bytes after the formatted string.
    @discardableResult
    func includesActualByteCount(_ includes: Bool) -> Self {
        includesActualByteCount = includes
        return self
    }
    
    /// Sets the Boolean value indicating the display style of the size representation.
    @discardableResult
    func isAdaptive(_ isAdaptive: Bool) -> Self {
        self.isAdaptive = isAdaptive
        return self
    }
    
    /// Sets the Boolean value indicating whether to include the count in the resulting formatted string.
    @discardableResult
    func includesCount(_ includes: Bool) -> Self {
        includesCount = includes
        return self
    }
    
    /// Sets the Boolean value indicating whether to include the units in the resulting formatted string.
    @discardableResult
    func includesUnit(_ includes: Bool) -> Self {
        includesUnit = includes
        return self
    }
    
    /// Sets the Boolean value indicating whether to zero pad fraction digits so a consistent number of characters is displayed in a representation.
    @discardableResult
    func zeroPadsFractionDigits(_ zeroPadsFractionDigits: Bool) -> Self {
        self.zeroPadsFractionDigits = zeroPadsFractionDigits
        return self
    }
    
    /**
     The locale of the formatter.
     
     The default value is `current`.
     */
    var locale: Locale {
        get { getAssociatedValue("locale") ?? .current }
        set {
            guard newValue != locale else { return }
            setAssociatedValue(newValue, key: "locale")
            swizzle(!(locale == .current && unitStyle == .short))
        }
    }
    
    /**
     Sets the locale of the formatter.
     
     The default value is `current`.
     */
    @discardableResult
    func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /**
     The unit style.
     
     The default value is `short`.
     */
    var unitStyle: Formatter.UnitStyle {
        get { getAssociatedValue("unitStyle") ?? .short }
        set {
            guard newValue != unitStyle else { return }
            setAssociatedValue(newValue, key: "unitStyle")
            swizzle(!(locale == .current && unitStyle == .short))
        }
    }
    
    /**
     Sets the unit style.
     
     The default value is `short`.
     */
    @discardableResult
    func unitStyle(_ style: Formatter.UnitStyle) -> Self {
        unitStyle = style
        return self
    }
}

private extension ByteCountFormatter {
    func swizzle(_ shouldSwizzle: Bool) {
        let isReplaced = isMethodHooked(#selector(ByteCountFormatter.string(fromByteCount:countStyle:)))
        if shouldSwizzle, !isReplaced {
            do {
                #if os(macOS) || os(iOS)
                try hook(#selector(ByteCountFormatter.string(for:)), closure: { original, object, sel, obj in
                    (object as? ByteCountFormatter)?.localizedString(for: obj) ?? original(object, sel, obj)
                } as @convention(block) (
                    (AnyObject, Selector, Any?) -> String?,
                    AnyObject, Selector, Any?) -> String?)
                try hook(#selector(ByteCountFormatter.string(fromByteCount:)), closure: { original, object, sel, byteCount in
                    (object as? ByteCountFormatter)?.localizedString(fromByteCount: byteCount) ?? original(object, sel, byteCount)
                } as @convention(block) (
                    (AnyObject, Selector, Int64) -> String,
                    AnyObject, Selector, Int64) -> String)
                try hook(#selector(ByteCountFormatter.string(from:)), closure: { original, object, sel, measurement in
                    (object as? ByteCountFormatter)?.localizedString(from: measurement) ?? original(object, sel, measurement)
                } as @convention(block) (
                    (AnyObject, Selector, Measurement<UnitInformationStorage>) -> String,
                    AnyObject, Selector, Measurement<UnitInformationStorage>) -> String)
                #else
                try hook(#selector(ByteCountFormatter.string(for:)),
                     methodSignature: (@convention(c)  (AnyObject, Selector, Any?) -> (String?)).self,
                     hookSignature: (@convention(block)  (AnyObject, Any?) -> (String?)).self) { store in {
                         object, obj in
                         (object as? ByteCountFormatter)?.localizedString(for: obj) ?? store.original(object, #selector(ByteCountFormatter.string(for:)), obj)
                     } }
                 try hook(#selector(ByteCountFormatter.string(fromByteCount:)),
                     methodSignature: (@convention(c)  (AnyObject, Selector, Int64) -> (String)).self,
                     hookSignature: (@convention(block)  (AnyObject, Int64) -> (String)).self) { store in {
                         object, byteCount in
                         (object as? ByteCountFormatter)?.localizedString(fromByteCount: byteCount) ?? store.original(object, #selector(ByteCountFormatter.string(fromByteCount:)), byteCount)
                     } }
                 try hook(#selector(ByteCountFormatter.string(from:)),
                     methodSignature: (@convention(c)  (AnyObject, Selector, Measurement<UnitInformationStorage>) -> (String)).self,
                     hookSignature: (@convention(block)  (AnyObject, Measurement<UnitInformationStorage>) -> (String)).self) { store in {
                         object, measurement in
                         (object as? ByteCountFormatter)?.localizedString(from: measurement) ??  store.original(object, #selector(ByteCountFormatter.string(from:)), measurement)
                     } }
                #endif
            } catch {
                debugPrint(error)
            }
        } else if isReplaced {
            revertHooks(for: #selector(ByteCountFormatter.string(for:)))
            revertHooks(for: #selector(ByteCountFormatter.string(fromByteCount:)))
            revertHooks(for: #selector(ByteCountFormatter.string(from:)))
        }
    }
    
    func localizedString(fromByteCount count: Int64) -> String? {
        guard needsLocalized else { return nil }
        let split = split { self.string(fromByteCount: count)  }!
        if let unit = split.unit.storageUnit?.localized(to: locale, unitStyle: unitStyle) {
            return "\(split.count) \(unit)"
        }
        return nil
    }
    
    func localizedString(for obj: Any?) -> String? {
        guard needsLocalized, let split = split(handler: { self.string(for: obj) }), let unit = split.unit.storageUnit?.localized(to: locale, unitStyle: unitStyle) else { return nil }
        return "\(split.count) \(unit)"
    }

    func localizedString(from measurement: Measurement<UnitInformationStorage>) -> String? {
        guard needsLocalized else { return nil }
        let split = split { self.string(from: measurement) }!
        if let unit = split.unit.storageUnit?.localized(to: locale, unitStyle: unitStyle) {
            return "\(split.count) \(unit)"
        }
        return nil
    }

    var needsLocalized: Bool {
       !isFetching && includesUnit && (locale != .current || unitStyle != .short)
    }
    
    var isFetching: Bool {
        get { getAssociatedValue("isFetching") ?? false }
        set { setAssociatedValue(newValue, key: "isFetching") }
    }
    
    func split(handler: @escaping (()->(String?))) -> (count: String, unit: String)? {
        isFetching = true
        let previous = (includesCount, includesUnit)
        includesCount = true
        includesUnit = false
        let _count = handler()
        includesCount = false
        includesUnit = true
        let unit = handler()
        includesCount = previous.0
        includesUnit = previous.1
        isFetching = false
        guard let _count = _count, let unit = unit else { return nil }
        return (_count, unit)
    }
}

public extension ByteCountFormatter.CountStyle {
    var factor: Int {
        self == .binary ? 1024 : 1000
    }
}

fileprivate extension String {
    var storageUnit: UnitInformationStorage? {
        switch self {
        case "bytes", "B": return .bytes
        case "KB": return .kilobytes
        case "MB": return .megabytes
        case "GB": return .gigabytes
        case "TB": return .terabytes
        case "PB": return .petabytes
        case "EB": return .exabytes
        case "ZB": return .zettabytes
        case "YB": return .yottabytes
        default: return nil
        }
    }
}
