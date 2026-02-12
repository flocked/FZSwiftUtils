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
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard let obs = KeyPathObserver(object, keyPath: keyPath, handler: handler) else { return nil }
        observer = obs
        guard sendInitalValue else { return }
        let value = object[keyPath: keyPath]
        handler(value, value)
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) where Value: Equatable {
        var observer: KVObserver?
        let keyPathString = keyPath.stringValue
        #if os(macOS)
        if ((keyPathString == "inLiveScroll" || keyPathString == "inLiveMagnify") && object is NSScrollView) || (keyPathString == "isFullscreen" && object is NSWindow) {
            _ = object[keyPath: keyPath]
        }
        #endif
        #if os(macOS) || os(iOS) || os(tvOS)
        if keyPathString == "subviews", let view = object as? NSUIView {
            view.swizzleSubviews()
        }
        #endif
        switch (keyPathString, object) {
        #if os(macOS)
        case ("occlusionState", let object as NSApplication) where Value.self is NSApplication.OcclusionState.Type:
            object._occlusionState = object.occlusionState
            observer = NotificationObserver(object: object, keyPath: "occlusionState") {
                [.init(NSApplication.didChangeOcclusionStateNotification, object: $0) {_ in
                    guard object.occlusionState != object._occlusionState else { return }
                    handler(cast(object._occlusionState), cast(object.occlusionState))
                    object._occlusionState = object.occlusionState } ] }
        case ("hidden", let object as NSApplication) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "hidden", NSApplication.didHideNotification, NSApplication.didUnhideNotification, handler)
        case ("active", let object as NSApplication) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "active", NSApplication.didBecomeActiveNotification, NSApplication.didResignActiveNotification, handler)
        case ("miniaturized", let object as NSWindow) where Value.self is Bool.Type:
            let aaa = handler as! ((NSWindow, NSWindow)->())
            observer = NotificationObserver(object: object, keyPath: "miniaturized", NSWindow.didMiniaturizeNotification, NSWindow.didDeminiaturizeNotification, handler)
        case ("keyWindow", let object as NSWindow) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "keyWindow", NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification, handler)
        case ("mainWindow", let object as NSWindow) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "mainWindow", NSWindow.didBecomeMainNotification, NSWindow.didResignMainNotification, handler)
        case ("inLiveResize", let object as NSWindow) where Value.self is Bool.Type:
            observer = NotificationObserver(object: object, keyPath: "inLiveResize", NSWindow.willStartLiveResizeNotification, NSWindow.didEndLiveResizeNotification, handler)
        case ("onActiveSpace", let object as NSWindow) where Value.self is Bool.Type:
            object._isOnActiveSpace = object.isOnActiveSpace
            observer = NotificationObserver(object: object, keyPath: "onActiveSpace") { object in
                [NSWorkspace.shared.notificationCenter.observe(NSWorkspace.activeSpaceDidChangeNotification) { _ in
                    guard object.isOnActiveSpace != object._isOnActiveSpace else { return }
                    handler(cast(object._isOnActiveSpace), cast(object.isOnActiveSpace))
                    object._isOnActiveSpace = object.isOnActiveSpace } ] }
        case ("inLiveResize", let object as NSView) where Value.self is Bool.Type:
            do {
                try observer = HookObserver(keyPath: keyPathString, hooks: [ object.hookAfter(#selector(NSView.viewWillStartLiveResize)) { _,_ in
                    handler(cast(false), cast(true))
                }, object.hookAfter(#selector(NSView.viewDidEndLiveResize)) { _,_ in handler(cast(true), cast(false)) }])
            } catch {
                return nil
            }
        case ("backgroundStyle", let obj) where Value.self is NSView.BackgroundStyle.Type:
            guard let hook = obj.observeBackgroundStyle(uniqueValues, handler) else { return nil }
            observer = HookObserver(keyPath: keyPathString, hooks: [hook])
        case ("parentViewAppearance", let object as CALayer) where Value.self is NSAppearance.Type:
            observer = LayerAppearanceObserver(layer: object, handler: cast(handler))
        #elseif os(iOS)
        case ("parentViewUserInterfaceStyle", let object as CALayer) where Value.self is UIUserInterfaceStyle.Type:
            observer = LayerAppearanceObserver(layer: object, handler: cast(handler))
        case ("traitCollection", let object as UIView) where Value.self is UITraitCollection.Type:
            observer = TraitCollectionObserver(view: object, handler: cast(handler))
        #endif
        #if os(macOS) || os(iOS) || os(tvOS)
        case ("frame", let object as CALayer) where Value.self is CGRect.Type:
            observer = LayerFrameObserver(layer: object, uniqueValues: uniqueValues, handler: cast(handler))
        case ("sublayers", let object as CALayer) where Value.self is [CALayer]?.Type:
            observer = SublayersObserver(layer: object, uniqueValues: uniqueValues, handler: cast(handler))
        #endif
        default: break
        }
        guard let observer = observer ?? KeyPathObserver(object, keyPath: keyPath, uniqueValues: uniqueValues, handler: handler) else { return nil }
        self.observer = observer
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
        guard let obs = KeyPathObserver(object, keyPath: keyPath, willChange: willChange) else { return nil }
        observer = obs
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, initial: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        guard object.isObservable(keyPath, Value.self) else { return nil }
        observer = KeyPathStringObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let newValue = change.newValue as? Value else { return }
            handler(change.oldValue as? Value ?? newValue, newValue)
        }
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object, keyPath: String, initial: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
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

fileprivate extension KeyValueObservation {
    /// Observes a property at a specific key path.
    class KeyPathObserver<Object: NSObject, Value>: NSObject, KVObserver {
        weak var object: Object?
        let keyPath: KeyPath<Object, Value>
        let keyPathString: String
        var observation: NSKeyValueObservation?
        let handler: ((Object, NSKeyValueObservedChange<Value>) -> Void)
        let options: NSKeyValueObservingOptions

        var isActive: Bool {
            get { object != nil && observation != nil }
            set {
                guard let object = object else { return }
                if newValue {
                    observation = object.observe(keyPath, options: options) { [ weak self] object, change in
                        guard let self = self else { return }
                        self.handler(object, change)
                    }
                } else {
                    observation?.invalidate()
                    observation = nil
                }
            }
        }
        
        init?(_ object: Object, keyPath: KeyPath<Object, Value>, options: NSKeyValueObservingOptions, handler: @escaping ((Object, NSKeyValueObservedChange<Value>) -> Void)) {
            guard let keyPathString = keyPath._kvcKeyPathString else { return nil }
            self.object = object
            self.keyPath = keyPath
            self.keyPathString = keyPathString
            self.options = options
            self.handler = handler
            super.init()
            self.isActive = true
        }
        
        convenience init?(_ object: Object, keyPath: KeyPath<Object, Value>, willChange: @escaping ((Value) -> Void)) {
            self.init(object, keyPath: keyPath, options: [.prior, .old]) { _, change in
                guard change.isPrior, let old = change.oldValue else { return }
                willChange(old)
            }
        }
        
        convenience init?(_ object: Object, keyPath: KeyPath<Object, Value>, handler: @escaping ((Value, Value) -> Void)) {
            self.init(object, keyPath: keyPath, options: [.new, .old]) { _, change in
                guard let newValue = change.newValue else { return }
                handler(change.oldValue ?? newValue, newValue)
            }
        }
        
        convenience init?(_ object: Object, keyPath: KeyPath<Object, Value>, uniqueValues: Bool, handler: @escaping ((Value, Value) -> Void)) where Value: Equatable {
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
        
        init?<Object: NSObject, Value>(object: Object, keyPath: WritableKeyPath<Object, Value>, uniqueValues: Bool, handler: @escaping (Value, Value) -> Void) where Value: Equatable {
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
            self.init(object: object, keyPath: keyPath) { [
                .init(name1, object: $0) { _ in handler(cast(false), cast(true)) },
                .init(name2, object: $0) { _ in handler(cast(true), cast(false)) }] }
        }
    }
    
    #if os(iOS)
    class TraitCollectionObserver: NSObject, KVObserver {
        let keyPathString = "traitCollection"
        weak var view: UIView?
        var observerView: UIView?
        let handler: (UITraitCollection, UITraitCollection)->()
        
        init(view: UIView, handler: @escaping (UITraitCollection, UITraitCollection) -> Void) {
            self.view = view
            self.handler = handler
            super.init()
            self.isActive = true
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
        
        deinit {
            observerView?.removeFromSuperview()
        }
        
        class ObserverView: UIView {
            let handler: ((UITraitCollection, UITraitCollection) -> Void)
            
            init(handler: @escaping (UITraitCollection, UITraitCollection) -> Void) {
                self.handler = handler
                super.init(frame: .zero)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
                guard previousTraitCollection != traitCollection else { return }
                super.traitCollectionDidChange(previousTraitCollection)
                handler(previousTraitCollection ?? traitCollection, traitCollection)
            }
        }
    }
    #endif
    #if os(macOS) || os(iOS)
    class LayerAppearanceObserver: NSObject, KVObserver {
        weak var layer: CALayer?
        var handler: (_ old: Any, _ new: Any)->()
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
                guard newValue != isActive, let layer = layer else { return }
                if newValue {
                    setupSuperlayerObservation()
                } else {
                    superlayerObservations.removeAll()
                    viewUserStyleObservation = nil
                }
            }
        }

        init(layer: CALayer, handler: @escaping (_ old: Any, _ new: Any)->()) {
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
                superlayerObservations += layer.observeChanges(for: \.superlayer) { [weak self] old, new in
                    self?.setupSuperlayerObservation()
                }
                currentLayer = layer.superlayer
            }
            setupViewAppearanceObservation()
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
    #if os(macOS) || os(iOS) || os(tvOS)
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
                    observations += layer.observeChanges(for: \.bounds, uniqueValues: uniqueValues) { [weak self] old, new in
                        guard let self = self, let frame = self.layer?.frame else { return }
                        self.handler(frame, frame)
                    }?.observer
                    observations += layer.observeChanges(for: \.position, uniqueValues: uniqueValues) { [weak self] old, new in
                        guard let self = self, let frame = self.layer?.frame else { return }
                        self.handler(frame, frame)
                    }?.observer
                    observations += layer.observeChanges(for: \.anchorPoint, uniqueValues: uniqueValues) { [weak self] old, new in
                        guard let self = self, let frame = self.layer?.frame else { return }
                        self.handler(frame, frame)
                    }?.observer
                } else {
                    observations = []
                }
            }
        }

        init(layer: CALayer, uniqueValues: Bool, handler: @escaping (CGRect, CGRect) -> Void) {
            self.layer = layer
            self.handler = handler
            self.uniqueValues = uniqueValues
            super.init()
            self.isActive = true
        }
    }
    
    class SublayersObserver: NSObject, KVObserver {
        weak var layer: CALayer?
        let handler: ([CALayer]?, [CALayer]?) -> Void
        let keyPathString = "sublayers"
        var observations: [KVObserver] = []
        let uniqueValues: Bool
        
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
        
        init(layer: CALayer, uniqueValues: Bool, handler: @escaping ([CALayer]?, [CALayer]?) -> Void) {
            self.layer = layer
            self.handler = handler
            self.uniqueValues = uniqueValues
            super.init()
            isActive = true
        }
    }
    #endif
}

#if os(macOS) || os(iOS) || os(tvOS)
fileprivate extension CALayer {
    var parentView: NSUIView? {
        delegate as? NSUIView ?? superlayer?.parentView
    }
    
    @objc dynamic var aSublayers: [CALayer]? {
        sublayers
    }
}
#endif

fileprivate protocol KVObserver: NSObject {
    var isActive: Bool { get set }
    var keyPathString: String { get }
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
    func observeBackgroundStyle<Value>(_ uniqueValues: Bool, _ handler: @escaping (Value, Value)->()) -> Hook? {
         try? hook("setBackgroundStyle:", closure: { original, object, selector, style in
             let oldValue: NSView.BackgroundStyle = object.value(forKey: "backgroundStyle") ?? .normal
             original(object, selector, style)
             guard !uniqueValues || oldValue != style else { return }
             handler(cast(oldValue), cast(style))
         } as @convention(block) ((NSObject, Selector, NSView.BackgroundStyle) -> Void, NSObject, Selector, NSView.BackgroundStyle) -> Void)
    }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS)
fileprivate extension NSUIView {
    #if os(macOS)
    func swizzleSubviews() {
        guard !didHookSubviews else { return }
        didHookSubviews = true
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
            } as @convention(block) ((NSView, Selector, NSView, NSWindow.OrderingMode, NSView?) -> (), NSView, Selector, NSView, NSWindow.OrderingMode, NSView?) -> ())
            try hook(#selector(NSView.addSubview(_:)), closure: { original, view, selector, subview in
                let isSettingSubviews = view.isSettingSubviews
                view.isSettingSubviews = true
                original(view, selector, subview)
                guard !isSettingSubviews else { return }
                view.isSettingSubviews = false
            } as @convention(block) ((NSView, Selector, NSView) -> (), NSView, Selector, NSView) -> ())
            try hook(.string("_removeSubview:"), closure: { original, view, selector, subview in
                let isSettingSubviews = view.isSettingSubviews
                view.isSettingSubviews = true
                original(view, selector, subview)
                guard !isSettingSubviews else { return }
                view.isSettingSubviews = false
            } as @convention(block) ((NSView, Selector, NSView) -> (), NSView, Selector, NSView) -> ())
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
            } as @convention(block) ((UIView, Selector, UIView) -> (), UIView, Selector, UIView) -> ())
            try hook(#selector(UIView.insertSubview(_:at:)), closure: { original, view, selector, subview, position in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview, position)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView, Int) -> (), UIView, Selector, UIView, Int) -> ())
            try hook(#selector(UIView.insertSubview(_:aboveSubview:)), closure: { original, view, selector, subview, otherView in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview, otherView)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView, UIView) -> (), UIView, Selector, UIView, UIView) -> ())
            try hook(#selector(UIView.insertSubview(_:belowSubview:)), closure: { original, view, selector, subview, otherView in
                view.willChangeValue(for: \.subviews)
                original(view, selector, subview, otherView)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, UIView, UIView) -> (), UIView, Selector, UIView, UIView) -> ())
            try hook(#selector(UIView.exchangeSubview(at:withSubviewAt:)), closure: { original, view, selector, from, to in
                view.willChangeValue(for: \.subviews)
                original(view, selector, from, to)
                view.didChangeValue(for: \.subviews)
            } as @convention(block) ((UIView, Selector, Int, Int) -> (), UIView, Selector, Int, Int) -> ())
            try hookAfter(#selector(UIView.willRemoveSubview(_:)), closure: { view, selector in
                view.willChangeValue(for: \.subviews)
            })
            try hookAfter(.string("_didRemoveSubview:"), closure: { view, selector in
                view.didChangeValue(for: \.subviews)
            })
        } catch {
            Swift.print(error)
        }
    }
    #endif
    
    var didHookSubviews: Bool {
        get { getAssociatedValue("didHookSubviews") ?? false }
        set { setAssociatedValue(newValue, key: "didHookSubviews") }
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
