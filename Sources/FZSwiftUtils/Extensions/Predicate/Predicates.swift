//
//  Predicates.swift
//  
//
//  Created by Florian Zand on 07.05.22.
//

import Foundation

// Equal
public func == <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: Equatable {
    { block($0) == value }
}

// Not equal
public func != <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: Equatable {
    { block($0) != value }
}

// Smaller
public func < <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: Comparable {
    { block($0) < value }
}

// Smaller?
public func < <Root, Value>(block: @escaping (Root) -> Value?, value: Value) -> (Root) -> Bool where Value: Comparable {
    return { if let val = block($0) {
        return val < value
    } else {
        return false
    }
    }
}

// Larger
public func > <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: Comparable {
    { block($0) > value }
}

// Larger?
public func > <Root, Value>(block: @escaping (Root) -> Value?, value: Value) -> (Root) -> Bool where Value: Comparable {
    return {
        if let val = block($0) {
            return val > value
        } else {
            return false
        }
    }
}

// Less or equal
public func <= <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: Comparable {
    { block($0) <= value }
}

// Less or equal?
public func <= <Root, Value>(block: @escaping (Root) -> Value?, value: Value) -> (Root) -> Bool where Value: Comparable {
    return {
        if let val = block($0) {
            return val <= value
        } else {
            return false
        }
    }
}

// Greater or equal
public func >= <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: Comparable {
    { block($0) >= value }
}

// Greater or equal?
public func >= <Root, Value>(block: @escaping (Root) -> Value?, value: Value) -> (Root) -> Bool where Value: Comparable {
    return {
        if let val = block($0) {
            return val >= value
        } else {
            return false
        }
    }
}

// Not
public prefix func ! <Root>(block: @escaping (Root) -> Bool) -> (Root) -> Bool {
    { !block($0) }
}

// And
public func && <Root>(lhs: @escaping @autoclosure () -> Bool, rhs: @escaping (Root) -> Bool) -> (Root) -> Bool {
    { lhs() && rhs($0) }
}

// Or
public func || <Root>(lhs: @escaping @autoclosure () -> Bool, rhs: @escaping (Root) -> Bool) -> (Root) -> Bool {
    { lhs() || rhs($0) }
}

// And
public func && <Root>(lhs: @escaping (Root) -> Bool, rhs: @escaping @autoclosure () -> Bool) -> (Root) -> Bool {
    { lhs($0) && rhs() }
}

// Or
public func || <Root>(lhs: @escaping (Root) -> Bool, rhs: @escaping @autoclosure () -> Bool) -> (Root) -> Bool {
    { lhs($0) || rhs() }
}

// And
public func && <Root>(lhs: @escaping (Root) -> Bool, rhs: @escaping (Root) -> Bool) -> (Root) -> Bool {
    { lhs($0) && rhs($0) }
}

// Or
public func || <Root>(lhs: @escaping (Root) -> Bool, rhs: @escaping (Root) -> Bool) -> (Root) -> Bool {
    { lhs($0) || rhs($0) }
}

// MARK: - Range

// In Range
public func << <Root, Value>(block: @escaping (Root) -> Value, value: ClosedRange<Value>) -> (Root) -> Bool where Value: Comparable {
    { value.contains(block($0)) }
}

// In Range?
public func << <Root, Value>(block: @escaping (Root) -> Value?, value: ClosedRange<Value>) -> (Root) -> Bool where Value: Comparable {
    return { if let block = block($0) {
        return value.contains(block)
    } else {
        return false
    }}
}

// In PartialRangeFrom
public func << <Root, Value>(block: @escaping (Root) -> Value, value: PartialRangeFrom<Value>) -> (Root) -> Bool where Value: Comparable {
    { value.contains(block($0)) }
}

// In PartialRangeFrom?
public func << <Root, Value>(block: @escaping (Root) -> Value?, value: PartialRangeFrom<Value>) -> (Root) -> Bool where Value: Comparable {
    return { if let block = block($0) {
        return value.contains(block)
    } else {
        return false
    }}
}

// In PartialRangeUpTo
public func << <Root, Value>(block: @escaping (Root) -> Value, value: PartialRangeUpTo<Value>) -> (Root) -> Bool where Value: Comparable {
    { value.contains(block($0)) }
}

// In PartialRangeUpTo?
public func << <Root, Value>(block: @escaping (Root) -> Value?, value: PartialRangeUpTo<Value>) -> (Root) -> Bool where Value: Comparable {
    return { if let block = block($0) {
        return value.contains(block)
    } else {
        return false
    }}
}

// In PartialRangeThrough
public func << <Root, Value>(block: @escaping (Root) -> Value, value: PartialRangeThrough<Value>) -> (Root) -> Bool where Value: Comparable {
    { value.contains(block($0)) }
}

// In PartialRangeThrough?
public func << <Root, Value>(block: @escaping (Root) -> Value?, value: PartialRangeThrough<Value>) -> (Root) -> Bool where Value: Comparable {
    return { if let block = block($0) {
        return value.contains(block)
    } else {
        return false
    }}
}

// Contains String
public func << <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: StringProtocol {
    { block($0).contains(value) }
}

// Contains String?
public func << <Root, Value>(block: @escaping (Root) -> Value?, value: Value) -> (Root) -> Bool where Value: StringProtocol {
    return { if let block = block($0) {
        return block.contains(value)
    } else {
        return false
    }}
}

// Contains String lowercased
infix operator <<~
func <<~ <Root, Value>(block: @escaping (Root) -> Value, value: Value) -> (Root) -> Bool where Value: StringProtocol {
    { block($0).lowercased().contains(value.lowercased()) }
}

// Contains String lowercased?
func <<~ <Root, Value>(block: @escaping (Root) -> Value?, value: Value) -> (Root) -> Bool where Value: StringProtocol {
    return { if let block = block($0) {
        return block.lowercased().contains(value.lowercased())
    } else {
        return false
    }}
}

public func <<~ <Root, S>(block: @escaping (Root) -> S.Element, value: S) -> (Root) -> Bool where S: Sequence, S.Element: StringProtocol {
    { value.compactMap { $0.lowercased() }.contains(block($0).lowercased()) }
}

public func <<~ <Root, S>(block: @escaping (Root) -> S.Element?, value: S) -> (Root) -> Bool where S: Sequence, S.Element: StringProtocol {
    return { if let block = block($0) {
        return value.compactMap { $0.lowercased() }.contains(block.lowercased())
    } else {
        return false
    }}
}

// MARK: - Sequence

public func << <Root, S>(block: @escaping (Root) -> S.Element, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    { value.contains(block($0)) }
}

public func << <Root, S>(block: @escaping (Root) -> S.Element?, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    return { if let block = block($0) {
        return value.contains(block)
    } else {
        return false
    }}
}

public func >> <Root, S>(block: @escaping (Root) -> S, value: S.Element) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    { block($0).contains(value) }
}

public func >> <Root, S>(block: @escaping (Root) -> S?, value: S.Element) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    return { if let block = block($0) {
        return block.contains(value)
    } else {
        return false
    }}
}

public func << <Root, S>(block: @escaping (Root) -> S, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    { value.contains(any: block($0)) }
}

public func << <Root, S>(block: @escaping (Root) -> S?, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    return { if let block = block($0) {
        return value.contains(any: block)
    } else {
        return false
    }}
}

infix operator <<!
public func <<! <Root, S>(block: @escaping (Root) -> S, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    { value.contains(all: block($0)) }
}

public func <<! <Root, S>(block: @escaping (Root) -> S?, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    return { if let block = block($0) {
        return value.contains(all: block)
    } else {
        return false
    }}
}

public func >> <Root, S>(block: @escaping (Root) -> S, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    { block($0).contains(any: value) }
}

public func >> <Root, S>(block: @escaping (Root) -> S?, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    return { if let block = block($0) {
        return block.contains(any: value)
    } else {
        return false
    }}
}

infix operator >>!
public func >>! <Root, S>(block: @escaping (Root) -> S, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    { block($0).contains(all: value) }
}

public func >>! <Root, S>(block: @escaping (Root) -> S?, value: S) -> (Root) -> Bool where S: Sequence, S.Element: Equatable {
    return { if let block = block($0) {
        return block.contains(all: value)
    } else {
        return false
    }}
}

public func == <Root, Value>(block: @escaping (Root) -> Value, value: (Value, Value)) -> (Root) -> Bool where Value: FloatingPoint {
    { abs(block($0) - value.0) < value.1 }
}

public func == <Root, Value>(block: @escaping (Root) -> Value?, value: (Value, Value)) -> (Root) -> Bool where Value: FloatingPoint {
    return { if let block = block($0) {
        return abs(block - value.0) < value.1
    } else {
        return false
    }}
}

infix operator ±: NilCoalescingPrecedence

public func ± <Value>(number: Value, accuracy: Value) -> (Value, Value) where Value: FloatingPoint {
    (number, accuracy)
}
