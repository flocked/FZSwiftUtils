//
//  URLSessionDataTask+Resume.swift
//  
//
//  Created by Florian Zand on 29.06.23.
//

import Foundation

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension URLSession {
    /**
     Creates a resumable data task that retrieves the contents of a URL based on the specified URL request object.
     
     By creating a task based on a request object, you can tune various aspects of the task’s behavior, including the cache policy and timeout interval.
     
     After you create the task, you must start it by calling its resume() method.
     
     - Parameters request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
     - Returns: The new resumable session data task.
     */
    func resumableDataTask(with request: URLRequest) -> URLSessionResumableDataTask {
        let dataTask = self.dataTask(with: request)
        return URLSessionResumableDataTask(dataTask: dataTask, session: self)
    }
    
    /**
     Creates a data task to resume a previously canceled or failed download.
     
     By creating a task based on a request object, you can tune various aspects of the task’s behavior, including the cache policy and timeout interval.
     
     After you create the task, you must start it by calling its resume() method.
     
     This method is equivalent to the `resumableDataTask(withResumeData:completionHandler:)` with a nil completion handler. For detailed usage information, including ways to obtain a resume data object, see that method.
     
     - Parameters request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
     - Parameters resumeData: A resume data object that provides the data necessary to resume a download.
     - Returns: The new resumable session data task.
     */
    func resumableDataTask(withResumeData resumeData: URLSessionResumableDataTask.ResumableData, request: URLRequest) -> URLSessionResumableDataTask {
        let dataTask = self.dataTask(with: request)
        return URLSessionResumableDataTask(dataTask: dataTask, resumeData: resumeData, session: self)
    }
    
    /**
     Creates a resumable data task that retrieves the contents of a URL based on the specified URL request object.
     
     By using a completion handler, the task bypasses calls to delegate methods for response and data delivery, and instead provides any resulting data, response, or error inside the completion handler. Delegate methods for handling authentication challenges, however, are still called.

     After you create the task, you must start it by calling its resume() method.
     
     - Parameters request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
     - Parameters completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
     If you pass nil, only the session delegate methods are called when the task completes, making this method equivalent to the dataTask(with:) method.
     This completion handler takes the following parameters:
     - data: The data returned by the server.
     - data: The resume data returned by task.
     - response: An object that provides response metadata, such as HTTP headers and status code. If you are making an HTTP or HTTPS request, the returned object is actually an HTTPURLResponse object.
     - error: An error object that indicates why the request failed, or nil if the request was successful.
     
     - Returns: The new resumable session data task.
     */
    func resumableDataTask(with request: URLRequest, completionHandler:  @escaping (_ data: Data?, _ resumeData: URLSessionResumableDataTask.ResumableData?, _ response: URLResponse?, _ error: Error?) -> ()) -> URLSessionResumableDataTask {
        let dataTask = self.dataTask(with: request)
        return URLSessionResumableDataTask(dataTask: dataTask, session: self, completionHandler: completionHandler)
    }
    
    /**
     Creates a data task to resume a previously canceled or failed download and calls a handler upon completion.

     By using a completion handler, the task bypasses calls to delegate methods for response and data delivery, and instead provides any resulting data, response, or error inside the completion handler. Delegate methods for handling authentication challenges, however, are still called.
     
     After you create the task, you must start it by calling its resume() method.
     
     This method is equivalent to the `resumableDataTask(withResumeData:completionHandler:)` with a nil completion handler. For detailed usage information, including ways to obtain a resume data object, see that method.
     
     - Parameters request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
     - Parameters resumeData: A resume data object that provides the data necessary to resume a download.
     - Parameters completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
     If you pass nil, only the session delegate methods are called when the task completes, making this method equivalent to the dataTask(with:) method.
     This completion handler takes the following parameters:
     - data: The data returned by the server.
     - data: The resume data returned by task.
     - response: An object that provides response metadata, such as HTTP headers and status code. If you are making an HTTP or HTTPS request, the returned object is actually an HTTPURLResponse object.
     - error: An error object that indicates why the request failed, or nil if the request was successful.
     
     - Returns: The new resumable session data task.
     */
    func resumableDataTask(withResumeData resumeData: URLSessionResumableDataTask.ResumableData, request: URLRequest, completionHandler: @escaping (_ data: Data?, _ resumeData: URLSessionResumableDataTask.ResumableData?, _ response: URLResponse?, _ error: Error?) -> ()) -> URLSessionResumableDataTask {
        let dataTask = self.dataTask(with: request)
        return URLSessionResumableDataTask(dataTask: dataTask, resumeData: resumeData, session: self, completionHandler: completionHandler)
    }
    
    /**
     Downloads data from the request with the specified amount of retries if the download fails.
     
     - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
     - Parameter retryAmount: The amount of retries downloading data when the task fails.
     - Parameter retryInterval: The duration waited until a failed task retries downloading data.
     - Throws: Throws when the data couln't be downloaded.
     - Returns: Returns the downloaded data  and the response metadata.
     */
    func downloadData(with request: URLRequest, retryAmount: Int, retryInterval: TimeDuration = .seconds(15.0) ) throws -> (data: Data, response: URLResponse?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.resumableDataTask(with: request) {
            data = $0
            response = $2
            error = $3
            semaphore.signal()
        }
        dataTask.retryAmount = retryAmount
        dataTask.retryInterval = retryInterval
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
   
        if let error = error { throw error }
        guard let data = data else { throw DownloadErrors.noData }
        
        return (data, response)
    }
}

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
/// A resumable URL session task that returns downloaded data directly to the app in memory.
public class URLSessionResumableDataTask: NSObject {
    /**
     Cancels the task.
     
     This method returns immediately, marking the task as being canceled. Once a task is marked as being canceled, `urlSession(_:task:didCompleteWithError:)` will be sent to the task delegate, passing an error in the domain NSURLErrorDomain with the code `NSURLErrorCancelled`. A task may, under some circumstances, send messages to its delegate before the cancelation is acknowledged.
     
     This method may be called on a task that is suspended.
     */
    public func cancel() {
        dataTask.cancel()
        self.stateHandler?(self.state)
    }

    /**
     Resumes the task, if it is suspended or cancelled.

     Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
     */
    public func resume() {
        guard (self.state == .suspended || self.state == .canceling) else { return }
            self.startDate = Date()
            if let retryCount = retryCount, retryCount < 0 {
                self.retryCount = self.retryAmount
            }
            
            if let updatedRequest = requestUpdateHandler?() {
                self.currentRequest = updatedRequest
            }
            
            if let resumeData = self.resumeData, let session = session, var request = self.currentRequest {
                resumeData.resume(request: &request)
                self.dataTask = session.dataTask(with: request)
            }
            dataTask.resume()
            stateHandler?(self.state)
    }
    
    /**
     Temporarily suspends a task.

     A task, while suspended, produces no network traffic and isn’t subject to timeouts. Call resume() to resume data transfer.
     */
    public func suspend() {
        dataTask.suspend()
        self.stateHandler?(self.state)
    }
    
    /// The current state of the task—active, suspended, in the process of being canceled, or completed.
    public var state: URLSessionTask.State {
        get { dataTask.state }
    }

    /**
     The relative priority at which you’d like a host to handle the task, specified as a floating point value between 0.0 (lowest priority) and 1.0 (highest priority).

     To provide hints to a host on how to prioritize URL session tasks from your app, specify a priority for each task. Specifying a priority provides only a hint and does not guarantee performance. If you don’t specify a priority, a URL session task has a priority of defaultPriority, with a value of 0.5.
     
     There are three named priorities you can employ, described in URL Session Task Priority.
     
     You can specify or change a task’s priority at any time, but not all networking protocols respond to changes after a task has started. There is no API to let you determine the effective priority for a task from a host’s perspective.
     */
    public var priority: Float {
        get { dataTask.priority }
        set { dataTask.priority = newValue }
    }
    
    /**
     The amount of retries downloading data when the task fails.
     
     If the task fails downloading data and `retryAmount` isn't nil, it will automatically try downloading the data again. If the value is nil, the task won't retry it.
     
     To specific the duration between retries use `retryInterval`.
     */
    public var retryAmount: Int? = 3 {
        didSet {
            if let retryAmount = retryAmount, retryAmount <= 0 {
                self.retryAmount = nil
            }
            self.retryCount = self.retryAmount
        }
    }
    
    /**
     The duration waited until a failed task retries downloading data.
     
     The number of seconds between retrying downloading data. A value of nil will instantly retry downloading it.
     */
    public var retryInterval: TimeDuration? = .seconds(15.0)
    
    /// A representation of the overall task progress.
    public var progress: Progress {
        dataTask.progress
    }
    
    /**
     The number of bytes that the task expects to receive in the response body.

     This value is determined based on the Content-Length header received from the server. If that header is absent, the value is NSURLSessionTransferSizeUnknown.
     */
    public var countOfBytesExpectedToReceive: Int64 {
        get { dataTask.countOfBytesExpectedToReceive }
    }
    
    /**
     The number of bytes that the task has received from the server in the response body.

     To be notified when this value changes, implement the urlSession(_:dataTask:didReceive:) delegate method (for data and upload tasks) or the urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:) method (for download tasks).
     */
    public var countOfBytesReceived: Int64 {
        get { dataTask.countOfBytesReceived }
    }
    
    /**
     The number of bytes that the task expects to send in the request body.

     The URL loading system can determine the length of the upload data in three ways:
     - From the length of the data object provided as the upload body.
     - From the length of the file on disk provided as the upload body of an upload task (not a download task).
     - From the Content-Length in the request object, if you explicitly set it.
     
     Otherwise, the value is NSURLSessionTransferSizeUnknown (-1) if you provided a stream or body data object, or zero (0) if you did not.
     */
    public var countOfBytesExpectedToSend: Int64 {
        get { dataTask.countOfBytesExpectedToSend }
    }

    /**
     The number of bytes that the task has sent to the server in the request body.

     This byte count includes only the length of the request body itself, not the request headers.
     
     To be notified when this value changes, implement the urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:) delegate method.
     */
    public var countOfBytesSent: Int64 {
        get { dataTask.countOfBytesSent }
    }
        
    /**
     The URL request object currently being handled by the task.

     This value is typically the same as the initial request (originalRequest) except when the server has responded to the initial request with a redirect to a different URL.
     */
    public private(set)var currentRequest: URLRequest? {
        get { dataTask.currentRequest }
        set { if let newValue = newValue, self.currentRequest != newValue {
            dataTask.setRequest(newValue)
        } }
    }
    
    /**
     A handler for updating the url request prior resuming the task.
     
     The handler gets called when `resume()` is called and updates the `currentRequest` property.
     */
    public var requestUpdateHandler: (()->(URLRequest))? = nil
    
    /**
     The original request object passed when the task was created.

     This value is typically the same as the currently active request (currentRequest) except when the server has responded to the initial request with a redirect to a different URL.
     */
    public var originalRequest: URLRequest? {
        get { dataTask.originalRequest }
        set { if let newValue = newValue, self.currentRequest != newValue {
            dataTask.setRequest(newValue)
        } }
    }
    
    /**
     The server’s response to the currently active request.

     This object provides information about the request as provided by the server. This information always includes the original URL. It may also include an expected length, MIME type information, encoding information, a suggested filename, or a combination of these.
     */
    public var response: URLResponse? {
        dataTask.response
    }
    
    /**
     A resume data object that provides the data necessary to resume a task.
     
     If the task fails downloading data, it will provide `resumeData`. Use `resume()` to retry downloading data or `URLSession.resumableDataTask(withResumeData_:, request:)`.
     */
    public private(set) var resumeData: ResumableData?
    
    /**
     An app-provided string value for the current task.

     The system doesn’t interpret this value; use it for whatever purpose you see fit. For example, you could store a description of the task for debugging purposes, or a key to track the task in your own data structures.
     */
    public var taskDescription: String? {
        get { dataTask.taskDescription }
        set { dataTask.taskDescription = newValue }
    }
    
    /**
     An identifier uniquely identifying the task within a given session.

     This value is unique only within the context of a single session; tasks in other sessions may have the same taskIdentifier value.     */
    public var taskIdentifier: Int {
        get { dataTask.taskIdentifier }
    }
    
    /**
     An error object that indicates why the task failed.

     This value is nil if the task is still active or if the transfer completed successfully.
     */
    public var error: Error? {
        get { dataTask.error }
    }
            
    /**
     A Boolean value that determines whether to deliver a partial response body in increments.
     
     Set this property to true to tell the task that the app would benefit from receiving a partial response body in increments. If the app can’t process the response until it has all the data, set this property to false. Task performance may improve when this value is false, in which case the task only delivers data when complete.
     
     This property defaults to true, except in the following cases which default to false:
     - The task delivers results to a completion handler rather than to a delegate.
     - The task is a download task.
     */
    public var prefersIncrementalDelivery: Bool {
        get { dataTask.prefersIncrementalDelivery }
        set { dataTask.prefersIncrementalDelivery = newValue }
    }
    
    /**
     A delegate specific to the task.

     This task-specific delegate receives messages from the task before the session’s delegate receives them. This is similar to the behavior of the delegate parameter used by the asychronous methods in URLSession like bytes(for:delegate:) and data(for:delegate:).
     */
    public var delegate: URLSessionTaskDelegate? = nil
    
    /**
     A best-guess upper bound on the number of bytes the client expects to receive.

     The value set for this property should account for the size of both HTTP response headers and the response body. If no value is specified, the system uses NSURLSessionTransferSizeUnknown instead. This property is used by the system to optimize the scheduling of URL session tasks. Developers are strongly encouraged to provide an approximate upper bound, or an exact byte count, if possible, rather than accept the default.
     */
    public var countOfBytesClientExpectsToReceive: Int64 {
        get { dataTask.countOfBytesClientExpectsToReceive }
        set { dataTask.countOfBytesClientExpectsToReceive = newValue }
    }
    
    /**
     A best-guess upper bound on the number of bytes the client expects to send.

     The value set for this property should account for the size of HTTP headers and body data or body stream. If no value is specified, the system uses NSURLSessionTransferSizeUnknown instead. This property is used by the system to optimize the scheduling of URL session tasks. Developers are strongly encouraged to provide an approximate upper bound, or an exact byte count, if possible, rather than accept the default.
     */
    public var countOfBytesClientExpectsToSend: Int64 {
        get { dataTask.countOfBytesClientExpectsToSend }
        set { dataTask.countOfBytesClientExpectsToSend = newValue }
    }
    
    /**
     The earliest date at which the network load should begin.

     For tasks created from background URLSession instances, this property indicates that the network load should not begin any earlier than this date. Setting this property does not guarantee that the load will begin at the specified date, but only that it will not begin sooner. If not specified, no start delay is used.
     
     This property has no effect for tasks created from nonbackground sessions.
     */
    public var earliestBeginDate: Date? {
        get { dataTask.earliestBeginDate }
        set { dataTask.earliestBeginDate = newValue }
    }
    
    public var stateHandler: ((URLSessionTask.State)->())? = nil
    public var didReceiveDataHandler: ((Data)->())? = nil
    public var completionHandler: CompletionHandler? = nil
    
    public typealias CompletionHandler = ((_ data: Data?, _ resumeData: URLSessionResumableDataTask.ResumableData?, _ response: URLResponse?, _ error: Error?) -> ())
    
    internal init(dataTask: URLSessionDataTask, resumeData: ResumableData? = nil, session: URLSession? = nil, completionHandler: CompletionHandler? = nil) {
        self.resumeData = resumeData
        self.dataTask = dataTask
        super.init()
        self.session = session
        self.delegate = dataTask.delegate
        self.completionHandler = completionHandler
        dataTask.delegate = self
    }
    
    deinit {
        self.resumeData = nil
        self.data = Data()
    }
    
    internal var startDate = Date()
        
    internal var dataDelegate: URLSessionDataDelegate? {
        self.delegate as? URLSessionDataDelegate
    }
    
    internal var data: Data = Data()
    internal var dataTask: URLSessionDataTask {
        didSet {
            self.dataTask.delegate = self
        }
    }
    
    internal weak var session: URLSession?
        
    internal var retryCount: Int? = 3
    internal var retryTimer: Timer? = nil
}

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension URLSessionResumableDataTask: URLSessionTaskDelegate {
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        self.delegate?.urlSession?(session, didCreateTask: task)
    }

    
    /*
    public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping @Sendable (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        self.delegate?.urlSession?(session, task: task, willBeginDelayedRequest: request, completionHandler: completionHandler)
    }
     */
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        self.delegate?.urlSession?(session, taskIsWaitingForConnectivity: task)
    }

    
    /*
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        self.delegate?.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
    }

    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.delegate?.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        self.delegate?.urlSession?(session, task: task, needNewBodyStream: completionHandler)
    }
     */
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.delegate?.urlSession?(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.delegate?.urlSession?(session, task: task, didFinishCollecting: metrics)
    }

    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil, let response = task.response,
           let resumableData = ResumableData(response: response, data: self.data) {
            self.resumeData = resumableData
            self.data = Data()
            if let retryCount = retryCount {
                self.retryCount = retryCount - 1
            }
            
            if (retryCount ?? 1000) >= 0 {
                if let retryInterval = retryInterval {
                    retryTimer = Timer(timeDuration: retryInterval, repeats: false, block: { [weak self] timer in
                        guard let self = self else { return }
                        self.resume()
                    })
                } else {
                    self.resume()
                }
            } else {
                self.retryCount = self.retryAmount
                completionHandler?(nil, resumableData, response, error)
                stateHandler?(self.state)
                delegate?.urlSession?(session, task: task, didCompleteWithError: error)
            }
        } else {
            completionHandler?((data.isEmpty || error != nil) ? nil : data, nil, response, error)
            stateHandler?(self.state)
            delegate?.urlSession?(session, task: task, didCompleteWithError: error)
        }
    }
}

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension URLSessionResumableDataTask: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if let expectedContentLength = dataTask.response?.expectedContentLength, expectedContentLength > 0 {
            self.progress.totalUnitCount = expectedContentLength
        }
        
        if let resumableData = self.resumeData, let response = dataTask.response, ResumableData.isResumedResponse(response) {
            self.data = resumableData.data
            self.progress.completedUnitCount = Int64(self.data.count)
            self.progress.updateEstimatedTimeRemaining(dateStarted: self.startDate)
            self.resumeData = nil
        } else {
            self.data += data
            self.progress.completedUnitCount = Int64(self.data.count)
            self.progress.updateEstimatedTimeRemaining(dateStarted: self.startDate)
            self.didReceiveDataHandler?(data)
            self.dataDelegate?.urlSession?(session, dataTask: dataTask, didReceive: data)
        }
    }
    
    /*
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping @Sendable (CachedURLResponse?) -> Void) {
        self.dataDelegate?.urlSession?(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler)
    }
     */
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        self.dataDelegate?.urlSession?(session, dataTask: dataTask, didBecome: streamTask)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        self.dataDelegate?.urlSession?(session, dataTask: dataTask, didBecome: downloadTask)
    }
    
    /*
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void) {
        if let expectedFileSize = dataTask.expectedFileSize {
            self.progress.totalUnitCount = Int64(expectedFileSize)
        }
        
        completionHandler(.allow)
        self.dataDelegate?.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }
     */
     
}

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension URLSessionResumableDataTask {
    struct ResumableData {
        public let data: Data
        internal let validator: String // Either `Last-Modified` or `ETag`

        public init?(response: URLResponse, data: Data) {
            // Check if "Accept-Ranges" is present and the response is valid.
            guard !data.isEmpty,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 /* OK */ || response.statusCode == 206, /* Partial Content */
                let acceptRanges = response.allHeaderFields["Accept-Ranges"] as? String,
                acceptRanges.lowercased() == "bytes",
                let validator = ResumableData.validator(from: response) else {
                    return nil
            }
            self.data = data
            self.validator = validator
        }
        
        public func resume(request: inout URLRequest) {
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["Range"] = "bytes=\(data.count)-"
            headers["If-Range"] = validator
            request.allHTTPHeaderFields = headers
        }

        private static func validator(from response: HTTPURLResponse) -> String? {
            if let entityTag = response.allHeaderFields["ETag"] as? String {
                return entityTag
            }
            // There seems to be a bug with ETag where HTTPURLResponse would canonicalize
            // it to Etag instead of ETag
            // https://bugs.swift.org/browse/SR-2429
            if let entityTag = response.allHeaderFields["Etag"] as? String {
                return entityTag
            }
            if let lastModified = response.allHeaderFields["Last-Modified"] as? String {
                return lastModified
            }
            return nil
        }
        
        /// Check if the server resumed the response.
        public static func isResumedResponse(_ response: URLResponse) -> Bool {
            return (response as? HTTPURLResponse)?.statusCode == 206
        }
    }
}

fileprivate extension URLSessionDataTask {
    var expectedFileSize: Int64? {
        var fileSize = self.countOfBytesExpectedToReceive
        if fileSize < 1 {
            fileSize = response?.expectedContentLength ?? fileSize
        }
        guard fileSize > 0 else { return nil }
        return fileSize
    }
}
