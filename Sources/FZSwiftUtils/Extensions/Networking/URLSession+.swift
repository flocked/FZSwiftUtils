//
//  File.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public extension URLSession {
    func downloadTask(withResumeData resumeData: Data, request: URLRequest) -> URLSessionDownloadTask {
        let downloadTask = self.downloadTask(withResumeData: resumeData)
        downloadTask.setRequest(request)
        return downloadTask
    }
}

public extension URLSessionTask {
    func setRequest(_ request: URLRequest) {
        guard state == .suspended else { return }
        setValue(request, forKeyPath: "originalRequest")
        setValue(request, forKeyPath: "currentRequest")
    }
}
