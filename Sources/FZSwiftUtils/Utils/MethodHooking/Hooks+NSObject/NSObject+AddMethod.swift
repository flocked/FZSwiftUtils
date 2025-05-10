//
//  NSObject+AddMethod.swift
//
//  Created by Florian Zand on 05.10.23.
//
//

/*
#if os(macOS) || os(iOS)
import Foundation

extension NSObject {
    /**
     Adds an unimplemented protocol instance method to the current object.
     
     Use this method to add an unimplemented protocol method to the object. To replace a already implemented method use ``replaceMethod(_:methodSignature:hookSignature:_:)-swift.type.method``.
     
     Example usage:
     
     ```swift
     @objc protocol MyProtocol {
         @objc optional func optionalMethod(value: Int)
     }

     class MyObject: MyProtocol {
     
     }
     
     let object = MyObject()
     try object.addMethod(#selector(MyProtocol.optionalMethod(value:)),
     methodSignature: (@convention(c)  (AnyObject, Selector, Int) -> ()).self) {
        object, selector, value in
            
     }
     ```
          
     - Returns: The token for resetting the added method.
     */
    @discardableResult
    func addMethod<MethodSignature> (
        _ selector: Selector,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        _ implementation: MethodSignature) throws -> HookToken {
            try HookToken(add: self, selector: selector, hookClosure: implementation).apply(true)
        }
    
    func isMethodAdded(_ selector: Selector) -> Bool {
        addedMethods.contains(selector)
    }
}

extension NSObject {
    var addedMethods: Set<Selector> {
        get { getAssociatedValue("addedMethods") ?? [] }
        set {
            setAssociatedValue(newValue, key: "addedMethods")
            if newValue.count == 1 {
                do {
                    try hook(#selector(NSObject.responds(to:)), closure: { original, object, sel, selector in
                        if let object = object as? NSObject, let selector = selector, object.addedMethods.contains(selector) {
                            return true
                        }
                        return original(object, sel, selector)
                    } as @convention(block) (
                        (AnyObject, Selector, Selector?) -> Bool,
                        AnyObject, Selector, Selector?) -> Bool)
                } catch {
                   debugPrint(error)
                }
            } else if newValue.isEmpty {
                revertHooks(for: #selector(NSObject.responds(to:)))
            }
        }
    }
}
#endif
*/
