//
//  ThrowPosix.swift
//
//
//  Created by Florian Zand on 21.10.26.
//

import Foundation

/**
 Executes a POSIX function and throws an error if it fails.

 Supports two POSIX error-reporting conventions:
 - By default, the function is expected to return `-1` on failure and set `errno` to the error code.
 - If `returnsErrno` is `true`, the function is expected to return `0` on success or an error code directly on failure.

 The original return value is preserved on success. If the function fails, a posix error is thrown.

 - Parameters:
   - call: The POSIX function to execute.
   - returnsErrno: A Boolean value indicating whether the function returns an error code directly instead of setting `errno`.
 - Returns: The return value of the POSIX function.
 - Throws: A posix error if the function fails, or an error thrown by `call`.
 */
 public func throwIfPOSIXError<ReturnType: BinaryInteger>(_ call: @autoclosure () throws -> ReturnType, returnsErrorCode: Bool = false) throws -> ReturnType {
     errno = 0
     let ret = try call()
     guard returnsErrorCode ? ret == 0 : (ret != -1) else {
         let currentErrno = returnsErrorCode ? Int32(ret) : errno
         if currentErrno == 0 { return ret }
         guard let posixCode = POSIXError.Code(rawValue: currentErrno) else {
             throw NSError(domain: NSPOSIXErrorDomain, code: Int(currentErrno))
         }
         throw POSIXError(posixCode)
     }
     return ret
 }
 
