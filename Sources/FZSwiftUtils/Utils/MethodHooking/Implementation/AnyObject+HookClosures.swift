//
//  ClosuresContext.swift
//
//
//  Created by Yanni Wang on 18/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation

func hookClosures(for object: AnyObject, selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
    closuresContext(for: object)?.closures(for: selector) ?? ([], [], [])
}

func appendHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, to object: AnyObject) throws {
    var context = getAssociatedValue("closuresContext", object: object, initialValue: ClosuresContext())
    
    func append(to keyPath: WritableKeyPath<ClosuresContext, [Selector: [ObjectIdentifier: AnyObject]]>) throws {
        guard context[keyPath: keyPath][selector, default: [:]].updateValue(hookClosure, forKey: .init(hookClosure)) == nil else {
            throw HookError.duplicateHookClosure
        }
    }

    switch mode {
    case .before:
        try append(to: \.before)
    case .after:
        try append(to: \.after)
    case .instead:
        try append(to: \.instead)
    }
}

func removeHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, for object: AnyObject) throws {
    guard var context = closuresContext(for: object) else {
        throw HookError.internalError(file: #file, line: #line)
    }
    func remove(_ keyPath: WritableKeyPath<ClosuresContext, [Selector: [ObjectIdentifier: AnyObject]]>) throws {
        guard context[keyPath: keyPath][selector, default: [:]].removeValue(forKey: .init(hookClosure)) != nil else {
            throw HookError.duplicateHookClosure
        }
    }
    
    switch mode {
    case .before:
        try remove(\.before)
    case .after:
        try remove(\.after)
    case .instead:
        try remove(\.instead)
    }
}

func isHookClosuresEmpty(for object: AnyObject) -> Bool {
    closuresContext(for: object)?.isEmpty ?? true
}

fileprivate class ClosuresContext {
    var before: [Selector: [ObjectIdentifier: AnyObject]] = [:]
    var after: [Selector: [ObjectIdentifier: AnyObject]] = [:]
    var instead: [Selector: [ObjectIdentifier: AnyObject]] = [:]

    var isEmpty: Bool {
        [before, instead, after].allSatisfy { $0.values.allSatisfy(\.isEmpty) }
    }
    
    func closures(for selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
        return (Array(before[selector, default: [:]].values), Array(after[selector, default: [:]].values), Array(instead[selector, default: [:]].values))
    }
}

fileprivate func closuresContext(for object: AnyObject) -> ClosuresContext? {
    getAssociatedValue("closuresContext", object: object)
}
#endif
