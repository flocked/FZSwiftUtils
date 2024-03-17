//
//  NSKeyedUnarchiver+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

import Foundation

extension NSKeyedUnarchiver {
    /**
     Decodes a previously-archived object.
     
     - Parameter data: Data of an object previously encoded by `NSKeyedArchiver`.
     - Returns: The decoded object.
     - Throws: If the data isn't an archive, doesn't contain the object or the decoding failed.
     */
    public static func unarchive<Object>(_ data: Data) throws -> Object {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        guard let value = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? Object else {
            throw UnarchiverErrors.failedDecoding
        }
        return value
    }
    
    /// Keyed unarchiver errors.
    public enum UnarchiverErrors: Error {
        /// The decoding of the archive failed.
        case failedDecoding
    }
}

/*
 extension NSKeyedArchiver {
     static func archiver(forWritingWith data: NSMutableData) -> NSKeyedArchiver? {
         if let allocatedObject = NSClassFromString("NSKeyedArchiver")?.alloc() as? NSObject {
             let selector: Selector = NSSelectorFromString("initForWritingWithMutableData:")
             let methodIMP: IMP! = allocatedObject.method(for: selector)
             let objectAfterInit = unsafeBitCast(methodIMP,to:(@convention(c)(AnyObject?,Selector,NSMutableData)->NSObject).self)(allocatedObject,selector, data)
             return objectAfterInit as? NSKeyedArchiver
         }
         return nil
     }
 }

 extension NSKeyedUnarchiver {
     static func unarchiver(forReadingWith data: NSData) -> NSKeyedUnarchiver? {
         if let allocatedObject = NSClassFromString("NSKeyedUnarchiver")?.alloc() as? NSObject {
             let selector: Selector = NSSelectorFromString("initForReadingWithData:")
             let methodIMP: IMP! = allocatedObject.method(for: selector)
             let objectAfterInit = unsafeBitCast(methodIMP,to:(@convention(c)(AnyObject?,Selector, NSData)->NSObject).self)(allocatedObject,selector, data)
             return objectAfterInit as? NSKeyedUnarchiver
         }
         return nil
     }
 }
 */
