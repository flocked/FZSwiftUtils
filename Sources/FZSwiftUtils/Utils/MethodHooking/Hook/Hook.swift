//
//  Hook.swift
//
//
//  Created by Florian Zand on 05.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

/// Hooking mode.
public enum HookMode: String, Hashable {
    /// Before.
    case before
    /// After.
    case after
    /// Instead.
    case instead
}

/// A hook that interposes a method on a object, class or all instances of a class.
public class Hook: Hashable {

    private let id = UUID()
    
    let hookClosure: AnyObject
 
    /// The class of the hooked method.
    public let `class`: AnyClass
    
    /// The selector of the method being interposed.
    public let selector: Selector
    
    /// The hooking mode.
    public let mode: HookMode
    
    /// A Boolean value indicating whether the hook is active.
    public var isActive: Bool = false
    
    /// Applies the hook by interposing the method implementation.
    public func apply() throws { }
    
    /// Reverts the hook, restoring the original method implementation.
    public func revert() throws {
        try revert(remove: true)
    }
    
    func revert(remove: Bool) throws { }
    
    func apply(_ shouldApply: Bool) throws -> Hook {
        try apply()
        if !shouldApply {
            _ = try revert()
        }
        return self
    }
    
    init(selector: Selector, hookClosure: AnyObject, mode: HookMode, class_: AnyClass) {
        self.selector = selector
        self.hookClosure = hookClosure
        self.mode = mode
        self.class = class_
    }
        
    public static func == (lhs: Hook, rhs: Hook) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
#endif
