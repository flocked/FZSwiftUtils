//
//  URLSession+.swift
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
        let downloadTask = downloadTask(withResumeData: resumeData)
        downloadTask.setRequest(request)
        return downloadTask
    }
}
