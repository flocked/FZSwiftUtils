//
//  TryPrint.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 19.06.25.
//

/**
 Attempts to evaluate a throwing expression and returns an optional result.
 
 Similar to `try?`, this function returns `nil` if an error is thrown, but also prints the error to the console.
 
 - Parameter expression: A throwing expression to evaluate.
 - Returns: The result of the expression if no error is thrown, otherwise `nil`.
*/
@discardableResult
public func tryPrint<T>(_ expression: @autoclosure () throws -> T) -> T? {
    do {
        return try expression()
    } catch {
        print(error)
        return nil
    }
}

