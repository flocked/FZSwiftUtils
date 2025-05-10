//
//  KVOWrapper.swift
//
//
//  Created by Wang Ya on 12/27/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation
#if SWIFT_PACKAGE
import _OCSources
#endif

extension NSObject {
    func wrapKVOIfNeeded(selector: Selector) throws -> AnyClass {
        guard try isSupportedKVO() else {
            throw HookError.hookKVOUnsupportedInstance
        }
        if hookObserver == nil {
            hookObserver = Observer(target: self)
        }
        guard let KVOedClass = object_getClass(self) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        if getMethodWithoutSearchingSuperClasses(targetClass: KVOedClass, selector: selector) == nil,
           let propertyName = try getKVOName(setter: selector) {
            guard let observer = hookObserver else {
                throw HookError.internalError(file: #file, line: #line)
            }
            // With this code. `getMethodWithoutSearchingSuperClasses(targetClass: KVOedClass, selector: selector)` will be non-nil.
            addObserver(observer, forKeyPath: propertyName, options: .new, context: &swiftHookKVOContext)
            removeObserver(observer, forKeyPath: propertyName, context: &swiftHookKVOContext)
        }
        return KVOedClass
    }
    
    func unwrapKVOIfNeeded() {
        guard hookObserver != nil else {
            return
        }
        hookObserver = nil
    }
    
    private func isSupportedKVO() throws -> Bool {
        if let isSupportedKVO: Bool = FZSwiftUtils.getAssociatedValue("isSupportedKVO", object: self) {
            return isSupportedKVO
        }
        guard let isaClass = object_getClass(self) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        let result: Bool
        if try isKVOed() {
            result = true
        } else {
            do {
                try NSObject.catchException {
                    addObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, options: .new, context: &swiftHookKVOContext)
                }
                defer {
                    removeObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, context: &swiftHookKVOContext)
                }
                guard let isaClassNew = object_getClass(self) else {
                    throw HookError.internalError(file: #file, line: #line)
                }
                result = isaClass != isaClassNew
            } catch {
                result = false
            }
        }
        FZSwiftUtils.setAssociatedValue(result, key: "isSupportedKVO", object: self)
        return result
    }
    
    fileprivate func getKVOName(setter: Selector) throws -> String? {
        let setterName = NSStringFromSelector(setter)
        guard setterName.hasPrefix("set") && setterName.hasSuffix(":") else {
            return nil
        }
        let propertyNameWithUppercase = String(setterName.dropFirst("set".count).dropLast(":".count))
        let propertyName =  propertyNameWithUppercase.lowercasedFirst()
        guard let baseClass = object_getClass(self) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        if let property = class_getProperty(baseClass, propertyName) {
            return String(cString: property_getName(property))
        }
        if let property = class_getProperty(baseClass, propertyNameWithUppercase) {
            return String(cString: property_getName(property))
        }
        if responds(to: NSSelectorFromString(propertyName)) {
            return propertyName
        }
        if responds(to: NSSelectorFromString(propertyNameWithUppercase)) {
            return propertyNameWithUppercase
        }
        if responds(to: NSSelectorFromString("is" + propertyNameWithUppercase)) {
            return propertyName
        }
        return nil
    }
    
    fileprivate func isKVOed() throws -> Bool {
        guard let isaClass = object_getClass(self) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        let typeClass: AnyClass = type(of: self)
        guard isaClass != typeClass else {
            return false
        }
        var tempClass: AnyClass? = isaClass
        while let currentClass = tempClass, currentClass != typeClass {
            if NSStringFromClass(currentClass).hasPrefix("NSKVONotifying_" + NSStringFromClass(class_getSuperclass(currentClass)!)) {
                return true
            }
            tempClass = class_getSuperclass(currentClass)
        }
        return false
    }
    
    private var hookObserver: Observer? {
        get { FZSwiftUtils.getAssociatedValue("hookObserver", object: self) }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "hookObserver", object: self) }
    }
}

fileprivate class RealObserver: NSObject {
    static let shared = RealObserver()
    
    private override init() {
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != swiftHookKeyPath else { return }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}

fileprivate class Observer: NSObject {
    private unowned(unsafe) let target: NSObject
    
    init(target: NSObject) {
        self.target = target
        super.init()
        target.addObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, options: .new, context: &swiftHookKVOContext)
    }
    
    deinit {
        self.target.removeObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, context: &swiftHookKVOContext)
    }
}

fileprivate var swiftHookKVOContext = 0
fileprivate let swiftHookKeyPath = "swiftHookPrivateProperty"
#endif
