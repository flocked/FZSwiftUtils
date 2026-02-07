//
//  KeyValueObservation.swift
//
//
//  Created by Florian Zand on 22.02.25.
//

import Foundation
#if os(macOS)
import AppKit
#endif

/**
 An object that observes the value of a key-value compatible property,
  
 To observe the value of a `NSObject` property that is key-value compatible, use `observeChanges(for:)`.
 
 Exanple usage:
 
 ```swift
 let observation = textField.observeChanges(for: \.stringValue) {
    oldValue, newValue in
    // handle changes
 }
 ```
 
 When the object is deinited or invalidated, it will stop observing.
 */
public class KeyValueObservation: NSObject {

    /// Invalidates the observation.
    public func invalidate() {
        observer.isActive = false
    }
    
    /// The keypath of the observed property.
    public var keyPath: String {
        observer.keyPathString
    }
    
    ///  A Boolean value indicating whether the observation is active.
    public var isObserving: Bool {
        get { observer.isActive }
        set { observer.isActive = newValue }
    }
    
    fileprivate let observer: KVObserver
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = KeyPathObserver(object, keyPath: keyPath) { change in
            guard let new = change.newValue else { return }
            if let old = change.oldValue {
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
        guard sendInitalValue else { return }
        let value = object[keyPath: keyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) where Value: Equatable {
        var observer: KVObserver?
        #if os(macOS)
        let keyPathString = keyPath.stringValue
        if ((keyPathString == "inLiveScroll" || keyPathString == "inLiveMagnify") && object is NSScrollView) || (keyPathString == "isFullscreen" && object is NSWindow) {
            _ = object[keyPath: keyPath]
        }
        switch (keyPathString, object) {
        case ("occlusionState", let object as NSApplication) where Value.self is NSApplication.OcclusionState.Type:
            object._occlusionState = object.occlusionState
            observer = NotificationObserver(object: object, keyPath: "occlusionState") {
                [.init(NSApplication.didChangeOcclusionStateNotification, object: $0) {_ in
                    guard object.occlusionState != object._occlusionState else { return }
                    handler(object._occlusionState as! Value, object.occlusionState as! Value)
                    object._occlusionState = object.occlusionState } ] }
        case ("hidden", let object as NSApplication) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "hidden", NSApplication.didHideNotification, NSApplication.didUnhideNotification, handler)
        case ("keyWindow", let object as NSWindow) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "keyWindow", NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification, handler)
        case ("mainWindow", let object as NSWindow) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "mainWindow", NSWindow.didBecomeMainNotification, NSWindow.didResignMainNotification, handler)
        case ("inLiveResize", let object as NSWindow) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "inLiveResize", NSWindow.willStartLiveResizeNotification, NSWindow.didEndLiveResizeNotification, handler)
        case ("isOnActiveSpace", let object as NSWindow) where Value.self is Bool.Type:
            object._isOnActiveSpace = object.isOnActiveSpace
            observer = NotificationObserver(object: object, keyPath: "isOnActiveSpace") {
                [.init(NSWorkspace.activeSpaceDidChangeNotification, object: $0) {_ in
                    guard object.isOnActiveSpace != object._isOnActiveSpace else { return }
                    handler(object._isOnActiveSpace as! Value, object.isOnActiveSpace as! Value)
                    object._isOnActiveSpace = object.isOnActiveSpace } ] }
        case ("inLiveResize", let object as NSView) where Value.self is Bool.Type:
            do {
                observer = HookObserver(keyPath: keyPathString, hooks: [try object.hookAfter(#selector(NSView.viewWillStartLiveResize)) {
                    handler(false as! Value, true as! Value)
                }, try object.hookAfter(#selector(NSView.viewDidEndLiveResize)) { handler(true as! Value, false as! Value) }])
            } catch {
                return nil
            }
        case ("backgroundStyle", let obj as NSControl) where obj.cell != nil && Value.self is NSView.BackgroundStyle.Type:
            guard let hook = obj.cell!.hookBackgroundStyle(uniqueValues, handler) else { return nil }
            observer = HookObserver(keyPath: keyPathString, hooks: [hook])
        case ("backgroundStyle", let obj as NSCell) where Value.self is NSView.BackgroundStyle.Type:
            guard let hook = obj.hookBackgroundStyle(uniqueValues, handler) else { return nil }
            observer = HookObserver(keyPath: keyPathString, hooks: [hook])
        case ("subviews", let object as NSView) where Value.self is [NSView].Type:
            do {
                let id = UUID().uuidString
                try observer = HookObserver(keyPath: keyPathString, hooks: [
                    object.hookAfter(set: \.subviews) { view, oldSubviews, subviews in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                        guard !uniqueValues || oldSubviews != subviews else { return }
                        handler(oldSubviews as! Value, subviews as! Value)
                    }, object.hookAfter(#selector(NSView.didAddSubview(_:))) { view, _ in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                    }, object.hookAfter(#selector(NSView.willRemoveSubview(_:)), closure: { view, _, removed in
                        let newSubviews = view.subviews.filter({ $0 !== removed })
                        view.setSubviewIDs(newSubviews.map({ ObjectIdentifier($0) }), id: id)
                        guard !uniqueValues || newSubviews != view.subviews else { return }
                        handler(view.subviews as! Value, newSubviews as! Value)
                    } as @convention(block) (NSView, Selector, NSView) -> Void), try object.hookAfter(#selector(NSView.addSubview(_:positioned:relativeTo:))) { view,_ in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                    }, object.hookAfter(#selector(NSView.addSubview(_:positioned:relativeTo:))) { view,_ in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                    }])
                object.setSubviewIDs(object.subviews.map({ ObjectIdentifier($0) }), id: id)
            } catch {
                Swift.print(error)
                return nil
            }
        default: break
        }
        #endif
        if observer == nil, keyPath.kvcStringValue == nil {
            return nil
        }
        self.observer = observer ?? KeyPathObserver(object, keyPath: keyPath) { change in
            guard let new = change.newValue else { return }
            if let old = change.oldValue {
                guard !uniqueValues || old != new else { return }
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
        guard sendInitalValue else { return }
        let value = object[keyPath: keyPath]
        handler(value, value)
    }
    
    #if os(macOS) || os(iOS)
    init?<Object: NSObject, Value>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let observer = HookObserver(object: object, keyPath: writableKeyPath, handler: handler) else { return nil }
        self.observer = observer
        guard sendInitalValue else { return }
        let value = object[keyPath: writableKeyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let observer = HookObserver(object: object, keyPath: writableKeyPath, uniqueValues: uniqueValues, handler: handler) else { return nil }
        self.observer = observer
        guard sendInitalValue else { return }
        let value = object[keyPath: writableKeyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value) -> Void) {
        guard let observer = HookObserver(object: object, keyPath: writableKeyPath, willChange: willChange) else { return nil }
        self.observer = observer
    }
    
    init?<Object: NSObject, Value>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value, Value) -> Void) {
        guard let observer = HookObserver(object: object, keyPath: writableKeyPath, willChange: willChange) else { return nil }
        self.observer = observer
    }
    #endif
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, willChange: @escaping ((_ oldValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = KeyPathObserver(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue else { return }
            willChange(oldValue)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, initial: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        guard object.isObservable(keyPath, Value.self) else { return nil }
        observer = KeyPathStringObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let newValue = change.newValue as? Value else { return }
            handler(change.oldValue as? Value ?? newValue, newValue)
        }
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object, keyPath: String, initial: Bool = false, uniqueValues: Bool = true, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        guard object.isObservable(keyPath, Value.self) else { return nil }
        observer = KeyPathStringObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let new = change.newValue as? Value else { return }
            if let old = change.oldValue as? Value {
                guard !uniqueValues || old != new else { return }
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, willChange: @escaping (_ oldValue: Value)->()) {
        guard object.isObservable(keyPath, Value.self) else { return nil }
        guard Object.classInfo().propertyType(at: keyPath) != nil else { return nil }
        observer = KeyPathStringObserver(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue as? Value else { return }
            willChange(oldValue)
        }
    }
}

private extension KeyValueObservation {
    /// Observes a property at a specific key path.
    class KeyPathObserver<Object: NSObject, Value>: NSObject, KVObserver {
        weak var object: Object?
        let keyPath: KeyPath<Object, Value>
        var keyPathString: String { keyPath._kvcKeyPathString ?? "" }
        var observation: NSKeyValueObservation?
        let handler: ((NSKeyValueObservedChange<Value>) -> Void)
        let options: NSKeyValueObservingOptions

        var isActive: Bool {
            get { object != nil && observation != nil }
            set {
                guard let object = object else { return }
                if newValue {
                    observation = object.observe(keyPath, options: options) { [ weak self] _, change in
                        guard let self = self else { return }
                        self.handler(change)
                    }
                } else {
                    observation?.invalidate()
                    observation = nil
                }
            }
        }
        
        init(_ object: Object, keyPath: KeyPath<Object, Value>, options: NSKeyValueObservingOptions = [.old, .new], handler: @escaping ((NSKeyValueObservedChange<Value>) -> Void)) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.handler = handler
            super.init()
            self.isActive = true
        }
        
        deinit {
            isActive = false
        }
    }
    
    /// Observes a property at a specific key path.
    class KeyPathStringObserver: NSObject, KVObserver {
        weak var object: NSObject?
        var keyPathString: String
        let options: NSKeyValueObservingOptions
        let handler: ([NSKeyValueChangeKey: Any])->()
        var context = 0
        
        init(_ object: NSObject, keyPath: String, options: NSKeyValueObservingOptions, handler: @escaping ([NSKeyValueChangeKey: Any])->()) {
            self.object = object
            self.keyPathString = keyPath
            self.options = options
            self.handler = handler
            super.init()
            isActive = true
        }
        
        var _isActive = false
        var isActive: Bool {
            get { object != nil && _isActive }
            set {
                guard newValue != isActive, let object = object else { return }
                _isActive = newValue
                if newValue {
                    object.addObserver(self, forKeyPath: keyPathString, options: options, context: &context)
                } else {
                    object.removeObserver(self, forKeyPath: keyPathString, context: &context)
                }
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard context == &self.context, object != nil, keyPath != nil, let change = change else { return }
            handler(change)
        }
        
        deinit {
            isActive = false
        }
    }
    
    #if os(macOS) || os(iOS)
    /// Hooks a property and observes changes to it.
    class HookObserver: NSObject, KVObserver {
        let keyPathString: String
        let hooks: [Hook]
        
        var isActive: Bool {
            get { hooks.first?.isActive ?? false }
            set { hooks.forEach({ $0.isActive = newValue }) }
        }
        
        deinit {
            isActive = false
        }
        
        init(keyPath: String, hooks: [Hook]) {
            self.keyPathString = keyPath
            self.hooks = hooks
        }
        
        init?<Object: NSObject, Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, handler: @escaping (Value, Value) -> Void) {
            do {
                let hook = try object.hookAfter(set: keyPath) { handler($1, $2) }
                hooks = [hook]
                keyPathString = hook.selector.string
            } catch {
                Swift.print(error)
                return nil
            }
        }
        
        init?<Object: NSObject, Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, uniqueValues: Bool = true, handler: @escaping (Value, Value) -> Void) where Value: Equatable {
            do {
                let hook = try object.hookAfter(set: keyPath, uniqueValues: uniqueValues) {
                   handler($1, $2)
                }
                hooks = [hook]
                keyPathString = hook.selector.string
            } catch {
                Swift.print(error)
                return nil
            }
        }
        
        init?<Object: NSObject, Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value) -> Void) {
            do {
                let hook = try object.hookBefore(set: keyPath) { willChange($1) }
                hooks = [hook]
                keyPathString = hook.selector.string
            } catch {
                Swift.print(error)
                return nil
            }
        }
        
        init?<Object: NSObject, Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value, Value) -> Void) {
            do {
                let hook = try object.hookBefore(set: keyPath) { willChange($1, $2) }
                hooks = [hook]
                keyPathString = hook.selector.string
            } catch {
                Swift.print(error)
                return nil
            }
        }
    }
    #endif
    
    /// Observes a notidication.
    class NotificationObserver<Object: NSObject>: NSObject, KVObserver {
        weak var object: Object?
        let handler: (Object)->([NotificationToken])
        var tokens: [NotificationToken]
        let keyPathString: String

        var isActive: Bool {
            get { !tokens.isEmpty }
            set {
                guard newValue != isActive, let object = object else { return }
                tokens = newValue ? handler(object) : []
            }
        }
        
        deinit {
            isActive = false
        }
        
        init(object: Object, keyPath: String, handler: @escaping (Object) -> [NotificationToken]) {
            self.object = object
            self.handler = handler
            self.tokens = handler(object)
            self.keyPathString = keyPath
        }
        
       convenience init<V>(object: Object, keyPath: String,  _ name1: Notification.Name, _ name2: Notification.Name, _ handler: @escaping (V, V)->()) {
           self.init(object: object, keyPath: keyPath) { [.init(name1, object: $0) { _ in handler(false as! V, true as! V) }, .init(name2, object: $0) { _ in handler(true as! V, false as! V) }] }
        }
    }
}

fileprivate protocol KVObserver: NSObject {
    var isActive: Bool { get set }
    var keyPathString: String { get }
}

#if os(macOS)
fileprivate extension NSWindow {
    var _isOnActiveSpace: Bool {
        get { getAssociatedValue("isOnActiveSpace", initialValue: isOnActiveSpace) }
        set { setAssociatedValue(newValue, key: "isOnActiveSpace") }
    }
}

fileprivate extension NSApplication {
    var _occlusionState: OcclusionState {
        get { getAssociatedValue("_occlusionState", initialValue: occlusionState) }
        set { setAssociatedValue(newValue, key: "_occlusionState") }
    }
}

fileprivate extension NSCell {
    func hookBackgroundStyle<Value>(_ uniqueValues: Bool, _ handler: @escaping (Value, Value)->()) -> Hook? {
        try? hook("setBackgroundStyle:", closure: { original, object, selector, style in
            let oldValue = object[keyPath: \.backgroundStyle]
            original(object, selector, style)
            guard !uniqueValues || oldValue != style else { return }
            handler(oldValue as! Value, style as! Value)
        } as @convention(block) ((NSCell, Selector, NSView.BackgroundStyle) -> Void, NSCell, Selector, NSView.BackgroundStyle) -> Void)
    }
}
fileprivate extension NSView {
    @discardableResult
    func setSubviewIDs(_ ids: [ObjectIdentifier], id: String) -> Bool {
        guard ids != getAssociatedValue("subviewIDs_\(id)", initialValue: [ObjectIdentifier]()) else { return false }
        setAssociatedValue(ids, key: "subviewIDs_\(id)")
        return true
    }
}

fileprivate extension NSObject {
    func isObservable<Value>(_ keyPath: String, _ type: Value.Type) -> Bool {
        guard let type = Self.classInfo().propertyType(at: keyPath) else { return false }
        guard type.matches(Value.self) ?? true else { return false }
        let object = NSObject()
        var context = 0
        do {
            return try ObjCRuntime.catchException {
                addObserver(object, forKeyPath: keyPath, context: &context)
                removeObserver(object, forKeyPath: keyPath, context: &context)
                return true
            }
        } catch {
            return false
        }
    }
}
#endif
