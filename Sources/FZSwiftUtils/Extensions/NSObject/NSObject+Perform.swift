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
    public func perform(_ selector: Selector, with arguments: [Any] = []) {
        _performing(selector, withArguments: arguments)
    }
    
    /**
     Invokes the specified method of the object.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     */
    public func perform(_ selector: String, with arguments: [Any] = []) {
        _performing(NSSelectorFromString(selector), withArguments: arguments)
    }
    
    /**
     Invokes the specified method of the object and returns its value.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func perform<V>(_ selector: Selector, with arguments: [Any] = []) -> V? {
        _performSelectorAndReturn(selector, withArguments: arguments) as? V
    }
    
    /**
     Invokes the specified method of the object and returns its value.
     
     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func perform<V>(_ selector: String, with arguments: [Any] = []) -> V? {
        _performSelectorAndReturn(NSSelectorFromString(selector), withArguments: arguments) as? V
    }
    
    /**
     Invokes the specified method of the object and returns its value.

     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func performAndReturn(_ selector: Selector, with arguments: [Any] = []) -> Any? {
        _performSelectorAndReturn(selector, withArguments: arguments)
    }
    
    /**
     Invokes the specified method of the object and returns its value.

     - Parameters:
        - selector: The selector that identifies the method to invoke.
        - arguments: The arguments to pass to the method when it is invoked.
     - Returns: The return value of the method when it is invoked.
     */
    public func performAndReturn(_ selector: String, with arguments: [Any] = []) -> Any? {
        _performSelectorAndReturn(NSSelectorFromString(selector), withArguments: arguments)
    }
}
