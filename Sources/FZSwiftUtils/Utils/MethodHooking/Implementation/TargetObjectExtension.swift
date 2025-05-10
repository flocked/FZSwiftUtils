//
//  AssociatedHookClosure.swift
//
//
//  Created by Yanni Wang on 18/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation

private class ClosuresContext {
    var before: [Selector: [AnyObject]] = [:]
    var after: [Selector: [AnyObject]] = [:]
    var instead: [Selector: [AnyObject]] = [:]
    var add: [Selector: [AnyObject]] = [:]

    var isEmpty: Bool {
        [before, instead, after, add].allSatisfy { $0.values.allSatisfy(\.isEmpty) }
    }
    
    func closures(for selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
        (before[selector] ?? [], after[selector] ?? [], instead[selector] ?? [])
    }
}

func hookClosures(for object: AnyObject, selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
    closuresContext(for: object)?.closures(for: selector) ?? ([], [], [])
}

func appendHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, to object: AnyObject) throws {
    var context = getAssociatedValue("closuresContext", object: object, initialValue: ClosuresContext())
    
    func append(to keyPath: WritableKeyPath<ClosuresContext, [Selector: [AnyObject]]>) throws {
        var closures = context[keyPath: keyPath][selector] ?? []
        guard !closures.contains(where: { hookClosure === $0 }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.append(hookClosure)
        context[keyPath: keyPath][selector] = closures
    }

    switch mode {
    case .before:
        try append(to: \.before)
    case .after:
        try append(to: \.after)
    case .instead:
        try append(to: \.instead)
    case .add:
        try append(to: \.add)
    }
}

func removeHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, for object: AnyObject) throws {
    guard var context = closuresContext(for: object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    
    func remove(_ keyPath: WritableKeyPath<ClosuresContext, [Selector: [AnyObject]]>) throws {
        var closures = context[keyPath: keyPath][selector] ?? []
        guard closures.contains(where: { hookClosure === $0 }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.removeAll(where: { hookClosure === $0 })
        context[keyPath: keyPath][selector] = closures
    }
    
    switch mode {
    case .before:
        try remove(\.before)
    case .after:
        try remove(\.after)
    case .instead:
        try remove(\.instead)
    case .add:
        try remove(\.add)
    }
}

func isHookClosuresEmpty(for object: AnyObject) -> Bool {
    closuresContext(for: object)?.isEmpty ?? true
}

fileprivate func closuresContext(for object: AnyObject) -> ClosuresContext? {
    getAssociatedValue("closuresContext", object: object)
}
#endif
