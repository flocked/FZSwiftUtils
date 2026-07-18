//
//  KeyValueObservation.swift
//
//
//  Created by Florian Zand on 22.02.25.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
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
    
    func setObject(_ object: NSObject?, activate: Bool = false) {
        observer.setObject(object, activate: activate)
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitialValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let obs = KeyPathObserver(object, keyPath: keyPath, handler: handler) else { return nil }
        observer = obs
        guard sendInitialValue else { return }
        let value = object[keyPath: keyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object?, keyPath: KeyPath<Object, Value>, sendInitialValue: Bool = false, uniqueValues: Bool = true, fallbackToKeyPathObserver: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let observer = Self.observer(for: object, keyPath: keyPath, uniqueValues: uniqueValues, fallbackToKeyPathObserver: fallbackToKeyPathObserver, handler: handler) else { return nil }
        self.observer = observer
        guard sendInitialValue, let object else { return }
        let value = object[keyPath: keyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object?, keyPath: String, initial: Bool = false, uniqueValues: Bool = true, fallbackToKeyPathStringObserver: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        if let observer = Self.observer(for: object, keyPath: keyPath, uniqueValues: uniqueValues, handler: handler) {
            self.observer = observer
            guard initial, let object, let value = object.value(forKeyPathSafely: keyPath) as? Value else { return }
            handler(value, value)
        } else {
            guard fallbackToKeyPathStringObserver, let object, object.isObservable(keyPath, Value.self) else { return nil }
            self.observer = KeyPathStringObserver(object, keyPath: keyPath, initial: initial, uniqueValues: uniqueValues, handler: handler)
        }
    }
    
    #if os(macOS) || os(iOS)
    init?<Object: NSObject, Value>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, sendInitialValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let observer = HookObserver(object, keyPath: writableKeyPath, handler: handler) else { return nil }
        self.observer = observer
        guard sendInitialValue else { return }
        let value = object[keyPath: writableKeyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, sendInitialValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let observer = HookObserver(object, keyPath: writableKeyPath, uniqueValues: uniqueValues, handler: handler) else { return nil }
        self.observer = observer
        guard sendInitialValue else { return }
        let value = object[keyPath: writableKeyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value) -> Void) {
        guard let observer = HookObserver(object, keyPath: writableKeyPath, willChange: willChange) else { return nil }
        self.observer = observer
    }
    
    init?<Object: NSObject, Value>(_ object: Object, writableKeyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value, Value) -> Void) {
        guard let observer = HookObserver(object, keyPath: writableKeyPath, willChange: willChange) else { return nil }
        self.observer = observer
    }
    #endif
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, willChange: @escaping ((_ oldValue: Value) -> Void)) {
        guard let obs = KeyPathObserver(object, keyPath: keyPath, willChange: willChange) else { return nil }
        observer = obs
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, initial: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
        guard object.isObservable(keyPath, Value.self) else { return nil }
        observer = KeyPathStringObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let newValue = change.newValue as? Value else { return }
            handler(change.oldValue as? Value ?? newValue, newValue)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, willChange: @escaping (_ oldValue: Value) -> Void) {
        guard object.isObservable(keyPath, Value.self) else { return nil }
        guard Object.classInfo().propertyType(at: keyPath) != nil else { return nil }
        observer = KeyPathStringObserver(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue as? Value else { return }
            willChange(oldValue)
        }
    }
    
    private static func observer<Object: NSObject, Value: Equatable>(
        for object: Object?,
        keyPath: KeyPath<Object, Value>,
        uniqueValues: Bool,
        fallbackToKeyPathObserver: Bool = true,
        handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void
    ) -> KVObserver? {
        let keyPathString = keyPath.stringValue
        #if os(macOS)
        if ((keyPathString == "inLiveScroll" || keyPathString == "inLiveMagnify") && object is NSScrollView) || (keyPathString == "isFullscreen" && object is NSWindow) {
            _ = object?[keyPath: keyPath]
        }
        #endif
        return observer(for: object, keyPath: keyPath.stringValue, uniqueValues: uniqueValues, handler: handler) ?? (fallbackToKeyPathObserver ? KeyPathObserver(object, keyPath: keyPath, uniqueValues: uniqueValues, handler: handler) : nil)
    }
    
    private static func observer<Object: NSObject, Value: Equatable>(
        for object: Object?,
        keyPath keyPathString: String,
        uniqueValues: Bool,
        handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void
    ) -> KVObserver? {
        #if os(macOS) || os(iOS)
        if keyPathString == "subviews", let view = object as? NSUIView {
            view.swizzleSubviews()
        }
        #endif
        switch keyPathString {
        #if os(macOS)
        case "occlusionState" where (object is NSApplication || Object.self is NSApplication.Type) && Value.self is NSApplication.OcclusionState.Type:
            return NotificationObserver(object as? NSApplication, keyPath: "occlusionState") { object in
                object._occlusionState = object.occlusionState
                return [.init(for: NSApplication.didChangeOcclusionStateNotification, postedBy: object) { _ in
                    guard object.occlusionState != object._occlusionState else { return }
                    handler(cast(object._occlusionState), cast(object.occlusionState))
                    object._occlusionState = object.occlusionState
                }]
            }
        case "hidden" where (object is NSApplication || Object.self is NSApplication.Type) && Value.self is Bool.Type:
            return NotificationObserver(object as? NSApplication, keyPath: "hidden", NSApplication.didHideNotification, NSApplication.didUnhideNotification, handler)
        case "active" where (object is NSApplication || Object.self is NSApplication.Type) && Value.self is Bool.Type:
            return NotificationObserver(object as? NSApplication, keyPath: "active", NSApplication.didBecomeActiveNotification, NSApplication.didResignActiveNotification, handler)
        case "miniaturized" where (object is NSWindow || Object.self is NSWindow.Type) && Value.self is Bool.Type:
            return NotificationObserver(object as? NSWindow, keyPath: "miniaturized", NSWindow.didMiniaturizeNotification, NSWindow.didDeminiaturizeNotification, handler)
        case "keyWindow" where (object is NSWindow || Object.self is NSWindow.Type) && Value.self is Bool.Type:
            return NotificationObserver(object as? NSWindow, keyPath: "keyWindow", NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification, handler)
        case "mainWindow" where (object is NSWindow || Object.self is NSWindow.Type) && Value.self is Bool.Type:
            return NotificationObserver(object as? NSWindow, keyPath: "mainWindow", NSWindow.didBecomeMainNotification, NSWindow.didResignMainNotification, handler)
        case "inLiveResize" where (object is NSWindow || Object.self is NSWindow.Type) && Value.self is Bool.Type:
            return NotificationObserver(object as? NSWindow, keyPath: "inLiveResize", NSWindow.willStartLiveResizeNotification, NSWindow.didEndLiveResizeNotification, handler)
        case "onActiveSpace" where (object is NSWindow || Object.self is NSWindow.Type) && Value.self is Bool.Type:
            let window = object as? NSWindow
            if let window {
                window._isOnActiveSpace = window.isOnActiveSpace
            }
           return NotificationObserver(window, keyPath: "onActiveSpace") { window in
                [
                    NSWorkspace.shared.notificationCenter.observe(
                        NSWorkspace.activeSpaceDidChangeNotification
                    ) { _ in
                        guard window.isOnActiveSpace != window._isOnActiveSpace else {
                            return
                        }

                        handler(
                            cast(window._isOnActiveSpace),
                            cast(window.isOnActiveSpace)
                        )
                        window._isOnActiveSpace = window.isOnActiveSpace
                    }
                ]
            }
        case "inLiveResize" where (object is NSView || Object.self is NSView.Type) && Value.self is Bool.Type:
            return (HookObserver(object as? NSView, keyPath: keyPathString) { object in
                do {
                    return try [object.hookAfter(#selector(NSView.viewWillStartLiveResize)) {
                        handler(cast(false), cast(true))
                    }, object.hookAfter(#selector(NSView.viewDidEndLiveResize)) { handler(cast(true), cast(false)) }]
                } catch {
                    return []
                }
            })
        case "backgroundStyle"
            where (object is NSView || Object.self is NSView.Type)
            && Value.self is NSView.BackgroundStyle.Type:
            return (HookObserver(object as? NSView, keyPath: keyPathString) {
                guard let hook = ($0.observeBackgroundStyle(uniqueValues, handler)) else { return [] }
                return [hook]
            })
        case "parentViewAppearance" where (object is CALayer || Object.self is CALayer.Type) && Value.self is NSAppearance.Type:
            return LayerAppearanceObserver(object as? CALayer, handler: cast(handler))
        #elseif os(iOS) || os(visionOS)
        case "parentViewUserInterfaceStyle"
            where (object is CALayer || Object.self is CALayer.Type) && Value.self is UIUserInterfaceStyle.Type:
            return LayerAppearanceObserver(object as? CALayer, handler: cast(handler))
        case "traitCollection" where (object is UIView || Object.self is UIView.Type)
            && Value.self is UITraitCollection.Type:
            return TraitCollectionObserver(object as? UIView, handler: cast(handler))
        #endif
        #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
        case "frame" where (object is CALayer || Object.self is CALayer.Type)
            && Value.self is CGRect.Type:
            return LayerFrameObserver(object as? CALayer, uniqueValues: uniqueValues, handler: cast(handler))
        case "sublayers" where (object is CALayer || Object.self is CALayer.Type)
            && Value.self is [CALayer]?.Type:
            return SublayersObserver(object as? CALayer, uniqueValues: uniqueValues, handler: cast(handler))
        #endif
        default:
            break
        }
        return nil
    }
}

private extension KeyValueObservation {
    /// Observes a property at a specific key path.
    class KeyPathObserver<Object: NSObject, Value>: NSObject, KVObserver {
        weak var object: Object?
        let keyPath: KeyPath<Object, Value>
        let keyPathString: String
        var observation: NSKeyValueObservation?
        let handler: (Object, NSKeyValueObservedChange<Value>) -> Void
        let options: NSKeyValueObservingOptions

        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? Object
            guard object !== self.object else {
                isActive = activate
                return
            }
            isActive = false
            self.object = object
            isActive = activate
        }
        
        var isActive: Bool {
            get { object != nil && observation != nil }
            set {
                guard let object = object else { return }
                if newValue {
                    observation = object.observe(keyPath, options: options) { [weak self] object, change in
                        guard let self = self else { return }
                        self.handler(object, change)
                    }
                } else {
                    observation?.invalidate()
                    observation = nil
                }
            }
        }
        
        init?(_ object: Object?, keyPath: KeyPath<Object, Value>, options: NSKeyValueObservingOptions, handler: @escaping ((Object, NSKeyValueObservedChange<Value>) -> Void)) {
            guard let keyPathString = keyPath._kvcKeyPathString else { return nil }
            self.object = object
            self.keyPath = keyPath
            self.keyPathString = keyPathString
            self.options = options
            self.handler = handler
            super.init()
            self.isActive = true
        }
        
        convenience init?(_ object: Object?, keyPath: KeyPath<Object, Value>, willChange: @escaping ((Value) -> Void)) {
            self.init(object, keyPath: keyPath, options: [.prior, .old]) { _, change in
                guard change.isPrior, let old = change.oldValue else { return }
                willChange(old)
            }
        }
        
        convenience init?(_ object: Object?, keyPath: KeyPath<Object, Value>, handler: @escaping ((Value, Value) -> Void)) {
            self.init(object, keyPath: keyPath, options: [.new, .old]) { _, change in
                guard let newValue = change.newValue else { return }
                handler(change.oldValue ?? newValue, newValue)
            }
        }
        
        convenience init?(_ object: Object?, keyPath: KeyPath<Object, Value>, uniqueValues: Bool, handler: @escaping ((Value, Value) -> Void)) where Value: Equatable {
            self.init(object, keyPath: keyPath, options: [.new, .old]) { _, change in
                guard let newValue = change.newValue else { return }
                let oldValue = change.oldValue ?? newValue
                guard !uniqueValues || newValue != oldValue else { return }
                handler(oldValue, newValue)
            }
        }
        
        deinit {
            isActive = false
        }
    }
    
    /// Observes a property at a specific key path.
    class KeyPathStringObserver<Object: NSObject>: NSObject, KVObserver {
        weak var object: Object?
        var keyPathString: String
        let options: NSKeyValueObservingOptions
        let handler: ([NSKeyValueChangeKey: Any]) -> Void
        var context = 0
        
        init(_ object: Object?, keyPath: String, options: NSKeyValueObservingOptions, handler: @escaping ([NSKeyValueChangeKey: Any]) -> Void) {
            self.object = object
            self.keyPathString = keyPath
            self.options = options
            self.handler = handler
            super.init()
            isActive = true
        }
        
        convenience init<Value: Equatable>(_ object: Object?, keyPath: String, initial: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
            self.init(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
                guard let new = change.newValue as? Value else { return }
                if let old = change.oldValue as? Value {
                    guard !uniqueValues || old != new else { return }
                    handler(old, new)
                } else {
                    handler(new, new)
                }
            }
        }
        
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? Object
            guard object !== self.object else {
                isActive = activate
                return
            }
            isActive = false
            self.object = object
            isActive = activate
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
    class HookObserver<Object: NSObject>: NSObject, KVObserver {
        let keyPathString: String
        var hooks: [Hook]
        
        var isActive: Bool {
            get { object != nil && (hooks.first?.isActive ?? false) }
            set {
                guard newValue != isActive else { return }
                
                if object == nil {
                    hooks.forEach { try? $0.revert() }
                    hooks = []
                } else {
                    hooks.forEach { $0.isActive = newValue }
                    guard newValue, hooks.isEmpty else { return }
                    hooks = object.map { hookHandler($0) } ?? []
                }
            }
        }
        
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? Object
            guard object !== self.object else {
                isActive = activate
                return
            }
            hooks.forEach { try? $0.revert() }
            hooks = []
            self.object = object
            isActive = activate
        }
        
        init?(_ object: Object?, keyPath: String, hookHandler: @escaping ((Object) -> [Hook])) {
            self.keyPathString = keyPath
            self.object = object
            self.hookHandler = hookHandler
            self.hooks = object.map { hookHandler($0) } ?? []
            if object != nil, hooks.isEmpty { return nil }
        }
        
        let hookHandler: (Object) -> [Hook]
        weak var object: Object?
        
        convenience init?<Value>(_ object: Object?, keyPath: WritableKeyPath<Object, Value>, handler: @escaping (Value, Value) -> Void) {
            guard let setterName = try? keyPath.setterName() else { return nil }
            self.init(object, keyPath: setterName) {
                guard let hook = (try? $0.hookAfter(set: keyPath) { handler($1, $2) }) else { return [] }
                return [hook]
            }
        }
        
        convenience init?<Value>(_ object: Object?, keyPath: WritableKeyPath<Object, Value>, uniqueValues: Bool, handler: @escaping (Value, Value) -> Void) where Value: Equatable {
            guard let setterName = try? keyPath.setterName() else { return nil }
            self.init(object, keyPath: setterName) {
                guard let hook = try? ($0.hookAfter(set: keyPath, uniqueValues: uniqueValues) {
                    handler($1, $2)
                }) else { return [] }
                return [hook]
            }
        }
        
        convenience init?<Value>(_ object: Object?, keyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value) -> Void) {
            guard let setterName = try? keyPath.setterName() else { return nil }
            self.init(object, keyPath: setterName) {
                guard let hook = (try? $0.hookBefore(set: keyPath) { willChange($1) }) else { return [] }
                return [hook]
            }
        }
        
        convenience init?<Value>(_ object: Object?, keyPath: WritableKeyPath<Object, Value>, willChange: @escaping (Value, Value) -> Void) {
            guard let setterName = try? keyPath.setterName() else { return nil }
            self.init(object, keyPath: setterName) {
                guard let hook = (try? $0.hookBefore(set: keyPath) { willChange($1, $2) }) else { return [] }
                return [hook]
            }
        }
        
        deinit {
            isActive = false
        }
    }
    #endif
    
    /// Observes a notidication.
    class NotificationObserver<Object: NSObject>: NSObject, KVObserver {
        weak var object: Object?
        let handler: (Object) -> ([NotificationToken])
        var tokens: [NotificationToken]
        let keyPathString: String
        
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? Object
            guard object !== self.object else {
                isActive = activate
                return
            }
            isActive = false
            self.object = object
            isActive = activate
        }

        var isActive: Bool {
            get { object != nil && !tokens.isEmpty }
            set {
                guard newValue != isActive, let object = object else { return }
                tokens = newValue ? handler(object) : []
            }
        }
        
        init(_ object: Object?, keyPath: String, handler: @escaping (Object) -> [NotificationToken]) {
            self.object = object
            self.handler = handler
            self.tokens = object.map { handler($0) } ?? []
            self.keyPathString = keyPath
        }
        
        convenience init<V>(_ object: Object?, keyPath: String, _ name1: Notification.Name, _ name2: Notification.Name, _ handler: @escaping (V, V) -> Void) {
            self.init(object, keyPath: keyPath) { [
                .init(for: name1, postedBy: $0) { _ in handler(cast(false), cast(true)) },
                .init(for: name2, postedBy: $0) { _ in handler(cast(true), cast(false)) }
            ] }
        }
        
        deinit {
            isActive = false
        }
    }
    
    #if os(iOS) || os(visionOS)
    class TraitCollectionObserver: NSObject, KVObserver {
        let keyPathString = "traitCollection"
        weak var view: UIView?
        var observerView: UIView?
        let handler: (UITraitCollection, UITraitCollection) -> Void
        
        init(_ view: UIView?, handler: @escaping (UITraitCollection, UITraitCollection) -> Void) {
            self.view = view
            self.handler = handler
            super.init()
            self.isActive = true
        }
                    
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? UIView
            guard object !== view else {
                isActive = activate
                return
            }
            isActive = false
            view = object
            isActive = activate
        }
        
        var isActive: Bool {
            get { view != nil && observerView != nil }
            set {
                guard newValue != isActive, let view = view else { return }
                if newValue {
                    observerView = ObserverView(handler: handler)
                    view.addSubview(observerView!)
                } else {
                    observerView?.removeFromSuperview()
                    observerView = nil
                }
            }
        }
        
        class ObserverView: UIView {
            let handler: (UITraitCollection, UITraitCollection) -> Void
            
            init(handler: @escaping (UITraitCollection, UITraitCollection) -> Void) {
                self.handler = handler
                super.init(frame: .zero)
            }
            
            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
                guard previousTraitCollection != traitCollection else { return }
                super.traitCollectionDidChange(previousTraitCollection)
                handler(previousTraitCollection ?? traitCollection, traitCollection)
            }
        }
        
        deinit {
            isActive = false
        }
    }
    #endif
    #if os(macOS) || os(iOS) || os(visionOS)
    class LayerAppearanceObserver: NSObject, KVObserver {
        weak var layer: CALayer?
        var handler: (_ old: Any, _ new: Any) -> Void
        var superlayerObservations: [KeyValueObservation] = []
        var viewUserStyleObservation: KeyValueObservation?
        #if os(macOS)
        let keyPathString = "parentViewAppearance"
        #else
        let keyPathString = "parentViewUserInterfaceStyle"
        #endif
        
        var isActive: Bool {
            get { layer != nil && !superlayerObservations.isEmpty }
            set {
                guard newValue != isActive, layer != nil else { return }
                if newValue {
                    setupSuperlayerObservation()
                } else {
                    superlayerObservations.removeAll()
                    viewUserStyleObservation = nil
                }
            }
        }

        init(_ layer: CALayer?, handler: @escaping (_ old: Any, _ new: Any) -> Void) {
            self.layer = layer
            self.handler = handler
            super.init()
            self.setupSuperlayerObservation()
        }
        
        deinit {
            isActive = false
        }
        
        private func setupSuperlayerObservation() {
            superlayerObservations = []
            var currentLayer: CALayer? = layer
            while let layer = currentLayer {
                superlayerObservations += layer.observeChanges(for: \.superlayer) { [weak self] _, _ in
                    self?.setupSuperlayerObservation()
                }
                currentLayer = layer.superlayer
            }
            setupViewAppearanceObservation()
        }
        
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? CALayer
            guard object !== layer else {
                isActive = activate
                return
            }
            isActive = false
            layer = object
            isActive = activate
        }
        
        private func setupViewAppearanceObservation() {
            #if os(macOS)
            viewUserStyleObservation = layer?.parentView?.observeChanges(for: \.effectiveAppearance, handler: handler)
            #else
            viewUserStyleObservation = layer?.parentView?.observeChanges(for: \.traitCollection) { [weak self] old, new in
                guard old.userInterfaceStyle != new.userInterfaceStyle else { return }
                self?.handler(old.userInterfaceStyle, new.userInterfaceStyle)
            }
            #endif
        }
    }
    #endif
    #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
    class LayerFrameObserver: NSObject, KVObserver {
        weak var layer: CALayer?
        let handler: (CGRect, CGRect) -> Void
        let keyPathString = "frame"
        var observations: [KVObserver] = []
        let uniqueValues: Bool
        var isActive: Bool {
            get { observations.first?.isActive == true }
            set {
                guard newValue != isActive, let layer = layer else { return }
                if newValue {
                    observations += layer.observeChanges(for: \.bounds, uniqueValues: uniqueValues) { [weak self] _, _ in
                        guard let self = self, let frame = self.layer?.frame else { return }
                        self.handler(frame, frame)
                    }?.observer
                    observations += layer.observeChanges(for: \.position, uniqueValues: uniqueValues) { [weak self] _, _ in
                        guard let self = self, let frame = self.layer?.frame else { return }
                        self.handler(frame, frame)
                    }?.observer
                    observations += layer.observeChanges(for: \.anchorPoint, uniqueValues: uniqueValues) { [weak self] _, _ in
                        guard let self = self, let frame = self.layer?.frame else { return }
                        self.handler(frame, frame)
                    }?.observer
                } else {
                    observations = []
                }
            }
        }

        init(_ layer: CALayer?, uniqueValues: Bool, handler: @escaping (CGRect, CGRect) -> Void) {
            self.layer = layer
            self.handler = handler
            self.uniqueValues = uniqueValues
            super.init()
            self.isActive = true
        }
        
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? CALayer
            guard object !== layer else {
                isActive = activate
                return
            }
            isActive = false
            layer = object
            isActive = activate
        }
        
        deinit {
            isActive = false
        }
    }
    
    class SublayersObserver: NSObject, KVObserver {
        weak var layer: CALayer?
        let handler: ([CALayer]?, [CALayer]?) -> Void
        let keyPathString = "sublayers"
        var observations: [KVObserver] = []
        let uniqueValues: Bool
        
        func setObject(_ object: NSObject?, activate: Bool = false) {
            let object = object as? CALayer
            guard object !== layer else {
                isActive = activate
                return
            }
            isActive = false
            layer = object
            isActive = activate
        }
        
        var isActive: Bool {
            get { observations.first?.isActive == true }
            set {
                guard newValue != isActive, let layer = layer else { return }
                if newValue {
                    observations += KeyPathObserver(layer, keyPath: \.sublayers, options: [.prior, .old]) { layer, change in
                        guard change.isPrior, change.oldValue != nil else { return }
                        layer.willChangeValue(for: \.aSublayers)
                    }
                    observations += KeyPathObserver(layer, keyPath: \.sublayers, options: [.new, .old]) { layer, change in
                        guard change.newValue != nil else { return }
                        layer.didChangeValue(for: \.aSublayers)
                    }
                    observations += KeyPathObserver(layer, keyPath: \.aSublayers, uniqueValues: uniqueValues, handler: handler)
                } else {
                    observations = []
                }
            }
        }
        
        init(_ layer: CALayer?, uniqueValues: Bool, handler: @escaping ([CALayer]?, [CALayer]?) -> Void) {
            self.layer = layer
            self.handler = handler
            self.uniqueValues = uniqueValues
            super.init()
            isActive = true
        }
        
        deinit {
            isActive = false
        }
    }
    #endif
}

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
fileprivate extension CALayer {
    var parentView: NSUIView? {
        delegate as? NSUIView ?? superlayer?.parentView
    }
    
    @objc dynamic var aSublayers: [CALayer]? {
        sublayers
    }
}
#endif

private protocol KVObserver: NSObject {
    var isActive: Bool { get set }
    var keyPathString: String { get }
    func setObject(_ object: NSObject?, activate: Bool)
}

private extension NSObject {
    func isObservable<Value>(_ keyPath: String, _: Value.Type) -> Bool {
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

fileprivate extension NSObject {
    func observeBackgroundStyle<Value>(_ uniqueValues: Bool, _ handler: @escaping (Value, Value) -> Void) -> Hook? {
        try? hook(.string("setBackgroundStyle:"), closure: { original, object, selector, style in
            let oldValue: NSView.BackgroundStyle = object.value(forKey: "backgroundStyle") ?? .normal
            original(object, selector, style)
            guard !uniqueValues || oldValue != style else { return }
            handler(cast(oldValue), cast(style))
        } as @convention(block) ((NSObject, Selector, NSView.BackgroundStyle) -> Void, NSObject, Selector, NSView.BackgroundStyle) -> Void)
    }
}
#endif

#if os(macOS) || os(iOS)
fileprivate extension NSUIView {
    #if os(macOS)
    func swizzleSubviews() {
        guard !didSwizzleSubviews else { return }
        didSwizzleSubviews = true
        do {
            try hook(set: \.subviews) { view, subviews, setter in
                view.setAssociatedValue(true, key: "isSettingSubviews")
                setter(subviews)
                view.setAssociatedValue(false, key: "isSettingSubviews")
            }
            try hook(#selector(NSView.addSubview(_:positioned:relativeTo:)), closure: { original, view, selector, newSubview, position, relative in
                let isSettingSubviews = view.isSettingSubviews
                view.isSettingSubviews = true
                original(view, selector, newSubview, position, relative)
                guard !isSettingSubviews else { return }
                view.isSettingSubviews = false
            } as @convention(block) ((NSView, Selector, NSView, NSWindow.OrderingMode, NSView?) -> Void, NSView, Selector, NSView, NSWindow.OrderingMode, NSView?) -> Void)
            try hook(#selector(NSView.addSubview(_:)), closure: { original, view, selector, subview in
                let isSettingSubviews = view.isSettingSubviews
                view.isSettingSubviews = true
                original(view, selector, subview)
                guard !isSettingSubviews else { return }
                view.isSettingSubviews = false
            } as @convention(block) ((NSView, Selector, NSView) -> Void, NSView, Selector, NSView) -> Void)
            try hook(.string("_removeSubview:"), closure: { original, view, selector, subview in
                let isSettingSubviews = view.isSettingSubviews
                view.isSettingSubviews = true
                original(view, selector, subview)
                guard !isSettingSubviews else { return }
                view.isSettingSubviews = false
            } as @convention(block) ((NSView, Selector, NSView) -> Void, NSView, Selector, NSView) -> Void)
        } catch {
            Swift.print(error)
        }
    }
    #else
    func swizzleSubviews() {
        guard !didSwizzleSubviews else { return }
        didSwizzleSubviews = true
        do {
            try hook(#selector(UIView.addSubview(_:)), closure: { original, view, selector, subview in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView) -> Void, UIView, Selector, UIView) -> Void)
            try hook(#selector(UIView.insertSubview(_:at:)), closure: { original, view, selector, subview, position in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview, position)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView, Int) -> Void, UIView, Selector, UIView, Int) -> Void)
            try hook(#selector(UIView.insertSubview(_:aboveSubview:)), closure: { original, view, selector, subview, otherView in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview, otherView)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView, UIView) -> Void, UIView, Selector, UIView, UIView) -> Void)
            try hook(#selector(UIView.insertSubview(_:belowSubview:)), closure: { original, view, selector, subview, otherView in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview, otherView)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView, UIView) -> Void, UIView, Selector, UIView, UIView) -> Void)
            try hook(#selector(UIView.exchangeSubview(at:withSubviewAt:)), closure: { original, view, selector, from, to in
                view.willChangeValue(for: \.subviews)
                original(view, selector, from, to)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, Int, Int) -> Void, UIView, Selector, Int, Int) -> Void)
            try hookAfter(#selector(UIView.willRemoveSubview(_:)), closure: { view in
                view.willChangeValue(for: \.subviews)
            })
            try hookAfter(.string("_didRemoveSubview:"), closure: { view in
                view.didChangeValue(for: \.subviews)
            })
        } catch {
            Swift.print(error)
        }
    }
    #endif
    
    var didSwizzleSubviews: Bool {
        get { getAssociatedValue("didSwizzleSubviews") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleSubviews") }
    }
    
    var isSettingSubviews: Bool {
        get { getAssociatedValue("isSettingSubviews") ?? false }
        set {
            guard newValue != isSettingSubviews else { return }
            newValue ? willChangeValue(for: \.subviews) : didChangeValue(for: \.subviews)
            setAssociatedValue(newValue, key: "isSettingSubviews")
        }
    }
}
#endif
