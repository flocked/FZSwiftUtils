//
//  File.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation

public extension URLSession {
    /**
     Creates a download task to resume a previously canceled or failed download with the specified URL request object and saves the results to a file.
     Creates a download task with resume data and sets a custom request for the task.

     - Parameters:
        - resumeData: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
        - request: The custom request to set for the download task.

     - Returns: The new session download task.
     */
    func downloadTask(withResumeData resumeData: Data, request: URLRequest) -> URLSessionDownloadTask {
        let downloadTask = self.downloadTask(withResumeData: resumeData)
        downloadTask.setRequest(request)
        return downloadTask
    }
}

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
}
