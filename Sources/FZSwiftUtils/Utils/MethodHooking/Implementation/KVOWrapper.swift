//
//  KVOWrapper.swift
//
//
//  Created by Wang Ya on 12/27/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import _FZSwiftUtilsObjC

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
        if ObjCClass(KVOedClass).method(for: selector, declaredOnly: true) == nil, let propertyName = try getKVOName(setter: selector) {
            guard let observer = hookObserver else {
                throw HookError.internalError(file: #file, line: #line)
            }
            addObserver(observer, forKeyPath: propertyName, options: .new, context: &RealObserver.context)
            removeObserver(observer, forKeyPath: propertyName, context: &RealObserver.context)
        }
        return KVOedClass
    }
    
    func unwrapKVOIfNeeded() {
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
                try ObjCRuntime.catchException {
                    addObserver(RealObserver.shared, forKeyPath: RealObserver.keyPath, options: .new, context: &RealObserver.context)
                }
                defer {
                    removeObserver(RealObserver.shared, forKeyPath: RealObserver.keyPath, context: &RealObserver.context)
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
        guard let baseClass = object_getClass(self) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        let propertyNameWithUppercase = String(setterName.dropFirst(3).dropLast(1))
        let propertyName =  propertyNameWithUppercase.lowercasedFirst()
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
    static let keyPath = "hookPrivateProperty"
    static var context = 0
    
    private override init() {
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != RealObserver.keyPath else { return }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}

fileprivate class Observer: NSObject {
    private unowned(unsafe) let target: NSObject
    
    init(target: NSObject) {
        self.target = target
        super.init()
        target.addObserver(RealObserver.shared, forKeyPath: RealObserver.keyPath, options: .new, context: &RealObserver.context)
    }
    
    deinit {
        self.target.removeObserver(RealObserver.shared, forKeyPath: RealObserver.keyPath, context: &RealObserver.context)
    }
}
