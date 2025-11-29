//
//  AnyCodingKey.swift
//
//
//  Created by Florian Zand on 25.11.25.
//

import Foundation

/// A type that can be used as a key for encoding and decoding.
public enum AnyCodingKey: CodingKey, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    case key(String)
    case index(Int)
    
    public init(stringLiteral value: String) {
        self = .key(value)
    }
    
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
    
    public init<Key: CodingKey>(_ key: Key) {
        if let intValue = key.intValue {
            self = .index(intValue)
        } else {
            self = .key(key.stringValue)
        }
    }
    
    public var stringValue: String {
        switch self {
        case .key(let key): return key
        case .index(let index): return "[\(index)]"
        }
    }
    
    public var intValue: Int? {
        switch self {
        case .index(let index): return index
        case .key: return nil
        }
    }
    
    public init?(intValue: Int) {
        self = .index(intValue)
    }
    
    public init?(stringValue: String) {
        self = .key(stringValue)
    }
    
   public var description: String {
        stringValue
    }
}
