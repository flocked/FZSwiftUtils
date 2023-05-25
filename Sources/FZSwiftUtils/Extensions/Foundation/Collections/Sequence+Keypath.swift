//
//  File.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

import Foundation

public extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        return compactMap { $0[keyPath: keyPath] }
    }

    func compactMap<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return compactMap { $0[keyPath: keyPath] }
    }

    func flatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S>) -> [T] {
        return flatMap { $0[keyPath: keyPath] }
    }

    func contains<T>(_ keyPath: KeyPath<Element, T?>) -> Bool {
        return contains(where: { $0[keyPath: keyPath] != nil })
    }

    func first<T>(_ keyPath: KeyPath<Element, T?>) -> T? {
        return first(where: { $0[keyPath: keyPath] != nil })?[keyPath: keyPath]
    }

    func count<T>(of keyPath: KeyPath<Element, T?>) -> Int {
        return filter { $0[keyPath: keyPath] != nil }.count
    }

    func indexes<T>(of keyPath: KeyPath<Element, T?>) -> IndexSet {
        indexes(where: { $0[keyPath: keyPath] != nil })
    }
}
