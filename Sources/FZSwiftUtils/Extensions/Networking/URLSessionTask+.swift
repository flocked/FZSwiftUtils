//
//  URLSessionTask+.swift
//  
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension URLSessionTask {
    /**
     Sets a custom URL request for the URLSessionTask.

     - Parameter request: The custom URL request to set.
     */
    func setRequest(_ request: URLRequest) {
        guard state == .suspended else { return }
        setValue(request, forKeyPath: "originalRequest")
        setValue(request, forKeyPath: "currentRequest")
    }
    
    /// The expected length of the content.
    var expectedContentLength: Int64? {
        var fileSize = self.countOfBytesExpectedToReceive
        if fileSize < 1 {
            fileSize = response?.expectedContentLength ?? fileSize
        }
        guard fileSize > 0 else { return nil }
        return fileSize
    }
}
