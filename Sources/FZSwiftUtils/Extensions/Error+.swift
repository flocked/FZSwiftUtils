//
//  Error+.swift
//  
//
//  Created by Florian Zand on 27.03.26.
//

import Foundation

public extension URLError {
    @_disfavoredOverload
    init(_ code: Code, failingURL: URL? = nil, networkUnavailableReason: NetworkUnavailableReason? = nil, failureURLPeerTrust: SecTrust? = nil, backgroundTaskCancelledReason: BackgroundTaskCancelledReason? = nil) {
        var userInfo: [String: Any] = [:]
        userInfo[NSURLErrorFailingURLErrorKey] = failingURL
        userInfo[NSURLErrorFailingURLPeerTrustErrorKey] = failureURLPeerTrust
        userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] = backgroundTaskCancelledReason
        userInfo[NSURLErrorNetworkUnavailableReasonKey] = networkUnavailableReason
        self.init(code, userInfo: userInfo)
    }
}
