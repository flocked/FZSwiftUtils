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
     Sends a message to the receiver with the specified arguments.
     
     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the message when it is invoked.
     */
    public func perform(_ selector: Selector, withArguments arguments: [Any?] = []) {
        if arguments.isEmpty {
            perform(selector)
        } else if arguments.count == 1 {
            perform(selector, with: arguments[0])
        } else if arguments.count == 2 {
            perform(selector, with: arguments[0], with: arguments[1])
        } else {
            guard let signature = getMethodSignature(for: selector) else { return }
            let invocation = Invocation(signature: signature)
            invocation.target = self
            invocation.selector = selector
            invocation.arguments = arguments
            invocation.invoke()
        }
    }
    
    /**
     Sends a message to the receiver with the specified arguments.
     
     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: String, withArguments arguments: [Any] = []) {
        perform(NSSelectorFromString(selector), withArguments: arguments)
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.
     
     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    public func perform<V>(_ selector: Selector, withArguments arguments: [Any?] = []) -> V? {
        guard let signature = getMethodSignature(for: selector) else { return nil }
        let invocation = Invocation(signature: signature)
        invocation.target = self
        invocation.selector = selector
        invocation.arguments = arguments
        invocation.invoke()
        return invocation.returnValue as? V
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.

     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    public func perform<V>(_ selector: String, withArguments arguments: [Any?] = []) -> V? {
        perform(NSSelectorFromString(selector), withArguments: arguments)
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.

     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    @_disfavoredOverload
    public func perform(_ selector: Selector, withArguments arguments: [Any?] = []) -> Any? {
        guard let signature = getMethodSignature(for: selector) else { return nil }
        let invocation = Invocation(signature: signature)
        invocation.target = self
        invocation.selector = selector
        invocation.arguments = arguments
        invocation.invoke()
        return invocation.returnValue
    }
    
    /**
     Sends a message to the receiver with the specified arguments and returns the result of the message.

     - Parameters:
        - selector: The selector identifying the message to send.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The result of the message.
     */
    @_disfavoredOverload
    public func perform(_ selector: String, withArguments arguments: [Any?] = []) -> Any? {
        perform(NSSelectorFromString(selector), withArguments: arguments)
    }
}
