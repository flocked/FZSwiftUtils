//
//  NSObject+Perform.swift
//  
//
//  Created by Florian Zand on 11.07.25.
//

import Foundation
import _NSObjectProxy

extension NSObject {
    /**
     Invokes the specified method of the object.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: Selector, withArguments arguments: [Any?] = []) {
        guard let signature = getMethodSignature(for: selector) else { return }
        let invocation = Invocation(signature: signature)
        invocation.target = self
        invocation.selector = selector
        invocation.arguments = arguments
        invocation.invoke()
    }
    
    /**
     Invokes the specified method of the object.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: String, with arguments: [Any] = []) {
        perform(NSSelectorFromString(selector), with: arguments)
    }
    
    /**
     Invokes the specified method of the object and returns its value.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func perform<V>(_ selector: Selector, with arguments: [Any?] = []) -> V? {
        guard let signature = getMethodSignature(for: selector) else { return nil }
        let invocation = Invocation(signature: signature)
        invocation.target = self
        invocation.selector = selector
        invocation.arguments = arguments
        invocation.invoke()
        return invocation.returnValue as? V
    }
    
    /**
     Invokes the specified method of the object and returns its value.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func perform<V>(_ selector: String, with arguments: [Any?] = []) -> V? {
        perform(NSSelectorFromString(selector), with: arguments)
    }
    
    /**
     Invokes the specified method of the object and returns its value.

     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func performAndReturn(_ selector: Selector, with arguments: [Any?] = []) -> Any? {
        guard let signature = getMethodSignature(for: selector) else { return nil }
        let invocation = Invocation(signature: signature)
        invocation.target = self
        invocation.selector = selector
        invocation.arguments = arguments
        invocation.invoke()
        return invocation.returnValue
    }
    
    /**
     Invokes the specified method of the object and returns its value.

     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func performAndReturn(_ selector: String, with arguments: [Any?] = []) -> Any? {
        performAndReturn(NSSelectorFromString(selector), with: arguments)
    }
}
