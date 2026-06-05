//
//  URLSessionConfiguration+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension URLSessionConfiguration {
    /// A dictionary of additional headers to send with requests.
    var httpAdditionalHeadersMapped: [HTTPRequestHeaderField: Any] {
        get { httpAdditionalHeaders?.mapKeys({ HTTPRequestHeaderField(String(describing: $0)) }) ?? [:] }
        set { httpAdditionalHeaders = newValue.mapKeys({ $0.rawValue as AnyHashable }) }
    }
    
    /// Sets the dictionary of additional headers to send with requests.
    @discardableResult
    func httpAdditionalHeaders(_ headers: [AnyHashable: Any]?) -> Self {
        httpAdditionalHeaders = headers
        return self
    }
    
    /// Sets the dictionary of additional headers to send with requests.
    @discardableResult
    @_disfavoredOverload
    func httpAdditionalHeaders(_ headers: [HTTPRequestHeaderField: Any]) -> Self {
        httpAdditionalHeadersMapped = headers
        return self
    }
    
    /// Sets the maximum number of simultaneous connections to make to a given host.
    @discardableResult
    func httpMaximumConnectionsPerHost(_ httpMaximumConnectionsPerHost: Int) -> Self {
        self.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost
        return self
    }
    
    /// Sets the Boolean value that determines whether connections should be made over a cellular network.
    @discardableResult
    func allowsCellularAccess(_ allows: Bool) -> Self {
        self.allowsCellularAccess = allows
        return self
    }
    
    /// Sets the Boolean value that indicates whether the session should wait for connectivity to become available, or fail immediately.
    @discardableResult
    func waitsForConnectivity(_ waitsForConnectivity: Bool) -> Self {
        self.waitsForConnectivity = waitsForConnectivity
        return self
    }
    
    /// Sets the Boolean value that determines whether requests should contain cookies from the cookie store.
    @discardableResult
    func httpShouldSetCookies(_ httpShouldSetCookies: Bool) -> Self {
        self.httpShouldSetCookies = httpShouldSetCookies
        return self
    }
        
    /// Sets the timeout interval to use when waiting for additional data.
    @discardableResult
    func timeoutIntervalForRequest(_ timeoutIntervalForRequest: TimeInterval) -> Self {
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
        return self
    }
    
    /// Sets the timeout interval to use when waiting for additional data.
    @discardableResult
    @_disfavoredOverload
    func timeoutIntervalForRequest(_ timeoutIntervalForRequest: TimeDuration) -> Self {
        self.timeoutIntervalForRequest = timeoutIntervalForRequest.seconds
        return self
    }
    
    /// Sets the maximum amount of time that a resource request should be allowed to take.
    @discardableResult
    func timeoutIntervalForResource(_ timeoutIntervalForResource: TimeInterval) -> Self {
        self.timeoutIntervalForResource = timeoutIntervalForResource
        return self
    }
    
    /// Sets the maximum amount of time that a resource request should be allowed to take.
    @discardableResult
    @_disfavoredOverload
    func timeoutIntervalForResource(_ timeoutIntervalForResource: TimeDuration) -> Self {
        self.timeoutIntervalForResource = timeoutIntervalForResource.seconds
        return self
    }
}
