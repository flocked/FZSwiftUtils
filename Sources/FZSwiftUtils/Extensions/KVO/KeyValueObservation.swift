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
        observer = Observer(object, keyPath: keyPath) { change in
            guard let new = change.newValue else { return }
            if let old = change.oldValue {
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
        if sendInitalValue {
            let value = object[keyPath: keyPath]
            handler(value, value)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) where Value: Equatable {
        #if os(macOS)
        let keyPathString = keyPath.stringValue
        if keyPathString == "inLiveScroll" || keyPathString == "inLiveMagnify", object is NSScrollView {
            _ = object[keyPath: keyPath]
        }
        switch (keyPathString, object) {
        case ("keyWindow", let object as NSWindow) where Value.self is Bool.Type:
            self.observer = NotificationObserver(object: object, keyPath: "keyWindow") {
                [.init(NSWindow.didBecomeKeyNotification, object: $0) { _ in handler(false as! Value, true as! Value)
                }, .init(NSWindow.didResignKeyNotification, object: $0) { _ in handler(true as! Value, false as! Value)  }] }
        case ("mainWindow", let object as NSWindow) where Value.self is Bool.Type:
            self.observer = NotificationObserver(object: object, keyPath: "mainWindow") {
                [.init(NSWindow.didBecomeMainNotification, object: $0) { _ in handler(false as! Value, true as! Value)
                }, .init(NSWindow.didResignMainNotification, object: $0) { _ in handler(true as! Value, false as! Value)  }] }
        case ("inLiveResize", let object as NSWindow) where Value.self is Bool.Type:
            self.observer = NotificationObserver(object: object, keyPath: "inLiveResize") {
                [.init(NSWindow.willStartLiveResizeNotification, object: $0) { _ in handler(false as! Value, true as! Value)
                }, .init(NSWindow.didEndLiveResizeNotification, object: $0) { _ in handler(true as! Value, false as! Value)  }] }
        case ("inLiveResize", let object as NSView) where Value.self is Bool.Type:
            do {
                self.observer = HookObserver(object: object, keyPath: keyPathString, hooks: [try object.hookAfter(#selector(NSView.viewWillStartLiveResize)) {
                    handler(false as! Value, true as! Value)
                }, try object.hookAfter(#selector(NSView.viewDidEndLiveResize)) { handler(true as! Value, false as! Value) }])
            } catch {
                return nil
            }
        case ("backgroundStyle", let obj as NSControl) where obj.cell != nil && Value.self is NSView.BackgroundStyle.Type:
            guard let hook = obj.cell!.hookBackgroundStyle(uniqueValues, handler) else { return nil }
            observer = HookObserver(object: object, keyPath: keyPathString, hooks: [hook])
        case ("backgroundStyle", let obj as NSCell) where Value.self is NSView.BackgroundStyle.Type:
            guard let hook = obj.hookBackgroundStyle(uniqueValues, handler) else { return nil }
            observer = HookObserver(object: object, keyPath: keyPathString, hooks: [hook])
        case ("subviews", let object as NSView) where Value.self is [NSView].Type:
            do {
                let id = UUID().uuidString
                self.observer = HookObserver(object: object, keyPath: keyPathString, hooks: [
                    try object.hookAfter(set: \.subviews) { view, oldSubviews, subviews in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                        guard !uniqueValues || oldSubviews != subviews else { return }
                        handler(oldSubviews as! Value, subviews as! Value)
                    }, try object.hookAfter(#selector(NSView.didAddSubview(_:))) { view, _ in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                    }, try object.hookAfter(#selector(NSView.willRemoveSubview(_:)), closure: { view, _, removed in
                        let newSubviews = view.subviews.filter({ $0 !== removed })
                        view.setSubviewIDs(newSubviews.map({ ObjectIdentifier($0) }), id: id)
                        guard !uniqueValues || newSubviews != view.subviews else { return }
                        handler(view.subviews as! Value, newSubviews as! Value)
                    } as @convention(block) (NSView, Selector, NSView) -> Void), try object.hookAfter(#selector(NSView.addSubview(_:positioned:relativeTo:))) { view,_ in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                    }, try object.hookAfter(#selector(NSView.addSubview(_:positioned:relativeTo:))) { view,_ in
                        view.setSubviewIDs(view.subviews.map({ ObjectIdentifier($0) }), id: id)
                    }])
                object.setSubviewIDs(object.subviews.map({ ObjectIdentifier($0) }), id: id)
            } catch {
                Swift.print(error)
                return nil
            }
        default:
            guard keyPath.kvcStringValue != nil else { return nil }
            observer = Observer(object, keyPath: keyPath) { change in
                guard let new = change.newValue else { return }
                if let old = change.oldValue {
                    if !uniqueValues || old != new {
                        handler(old, new)
                    }
                } else {
                    handler(new, new)
                }
            }
        }
        #else
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = Observer(object, keyPath: keyPath) { change in
            guard let new = change.newValue else { return }
            if let old = change.oldValue {
                if !uniqueValues || old != new {
                    handler(old, new)
                }
            } else {
                handler(new, new)
            }
        }
        #endif
        if sendInitalValue {
            let value = object[keyPath: keyPath]
            handler(value, value)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = Observer(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue else { return }
            handler(oldValue)
        }
    }
    
    init<Object: NSObject, Value>(_ object: Object, keyPath: String, initial: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        observer = TypedObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let newValue = change.newValue as? Value else { return }
            handler(change.oldValue as? Value ?? newValue, newValue)
        }
    }
    
    init<Object: NSObject, Value: Equatable>(_ object: Object, keyPath: String, initial: Bool = false, uniqueValues: Bool = true, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        observer = TypedObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let new = change.newValue as? Value else { return }
            if let old = change.oldValue as? Value {
                if !uniqueValues || old != new {
                    handler(old, new)
                }
            } else {
                handler(new, new)
            }
        }
    }
    
    init<Object: NSObject, Value>(_ object: Object, keyPath: String, willChange: @escaping (_ oldValue: Value)->()) {
        observer = TypedObserver(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue as? Value else { return }
            willChange(oldValue)
        }
    }
}

private extension KeyValueObservation {
    class Observer<Object: NSObject, Value>: NSObject, KVObserver {
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
    class TypedObserver: NSObject, KVObserver {
        weak var object: NSObject?
        let keyPath: String
        var keyPathString: String { keyPath }
        let options: NSKeyValueObservingOptions
        let handler: ([NSKeyValueChangeKey: Any])->()
        
        init(_ object: NSObject, keyPath: String, options: NSKeyValueObservingOptions, handler: @escaping ([NSKeyValueChangeKey: Any])->()) {
            self.object = object
            self.keyPath = keyPath
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
                    object.addObserver(self, forKeyPath: keyPath, options: options, context: nil)
                } else {
                    object.removeObserver(self, forKeyPath: keyPath)
                }
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
            guard object != nil, keyPath != nil, let change = change else { return }
            handler(change)
        }
    }
    
    class HookObserver<Object: NSObject>: NSObject, KVObserver {
        weak var object: Object?
        let keyPathString: String
        var hooks: [Hook] = []
        
        var isActive: Bool {
            get { hooks.first?.isActive ?? false }
            set { hooks.forEach({ $0.isActive = newValue }) }
        }
        
        deinit {
            isActive = false
        }
        
        init(object: Object, keyPath: String, hooks: [Hook]) {
            self.object = object
            self.keyPathString = keyPath
            self.hooks = hooks
        }
        
        init<Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, willChange: Bool = false, closure: @escaping (_ oldValue: Value, _ newValue: Value)->()) throws {
            self.object = object
            self.keyPathString = keyPath.stringValue
            if willChange {
                self.hooks += try object.hookBefore(set: keyPath) { object, value in
                    closure(object[keyPath: keyPath], value)
                }
            } else {
                self.hooks += try object.hook(set: keyPath) { object, value, original in
                    let current = object[keyPath: keyPath]
                    original(value)
                    closure(current, value)
                }
            }
        }
        
        init<Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, willChange: Bool = false, uniqueValues: Bool, closure: @escaping (_ oldValue: Value, _ newValue: Value)->()) throws where Value: Equatable {
            self.object = object
            if uniqueValues {
                if willChange {
                    self.hooks += try object.hookBefore(set: keyPath) { object, value in
                        let oldValue = object[keyPath: keyPath]
                        guard value != oldValue else { return }
                        closure(oldValue, value)
                    }
                } else {
                    self.hooks += try object.hook(set: keyPath) { object, value, original in
                        let current = object[keyPath: keyPath]
                        original(value)
                        guard current != value else { return }
                        closure(current, value)
                    }
                }
            } else {
                if willChange {
                    self.hooks += try object.hookBefore(set: keyPath) { object, value in
                        closure(object[keyPath: keyPath], value)
                    }
                } else {
                    self.hooks += try object.hook(set: keyPath) { object, value, original in
                        let current = object[keyPath: keyPath]
                        original(value)
                        closure(current, value)
                    }
                }
            }
            self.keyPathString = keyPath.stringValue
        }
    }
    
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
    }
}

fileprivate protocol KVObserver: NSObject {
    var isActive: Bool { get set }
    var keyPathString: String { get }
}

fileprivate extension KVObserver {
    var keyPathString: String { "" }
}

#if os(macOS)
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
#endif
