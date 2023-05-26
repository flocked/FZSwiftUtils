//
//  NSNumber+.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension NSNumber {
    convenience init(_ value: Bool) { self.init(value: value) }
    convenience init(_ value: CChar) { self.init(value: value) }
    convenience init(_ value: Double) { self.init(value: value) }
    convenience init(_ value: Float) { self.init(value: value) }
    convenience init(_ value: Int) { self.init(value: value) }
    convenience init(_ value: Int16) { self.init(value: value) }
    convenience init(_ value: Int32) { self.init(value: value) }
    convenience init(_ value: Int64) { self.init(value: value) }
    convenience init(_ value: UInt) { self.init(value: value) }
    convenience init(_ value: UInt16) { self.init(value: value) }
    convenience init(_ value: UInt32) { self.init(value: value) }
    convenience init(_ value: UInt64) { self.init(value: value) }
    convenience init?(_ string: String) {
        let formatter = NumberFormatter()
        if let value: Float = formatter.value(from: string) {
            self.init(value)
        } else if let value: Int = formatter.value(from: string) {
            self.init(value)
        } else if let value: Bool = formatter.value(from: string) {
            self.init(value)
        } else {
            return nil
        }
    }
}
