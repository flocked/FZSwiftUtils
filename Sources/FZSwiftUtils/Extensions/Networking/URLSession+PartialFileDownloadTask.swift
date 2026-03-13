//
//  URLSession+PartialFileDownloadTask.swift
//
//
//  Created by Florian Zand on 13.03.26.
//

import Foundation

extension URLSessionTask {
    func didSuccessfullyDownload(error: Error?) -> Bool {
        guard error == nil else { return false }
        if countOfBytesExpectedToReceive > 0 {
            return countOfBytesReceived == countOfBytesExpectedToReceive
        }
        return true
    }
}

extension URLSession {
    func partialDownloadTask(
        for request: URLRequest,
        downloadDirectory: URL,
        fileName: String? = nil,
        partExtension: String = "part",
        completion: @escaping @Sendable (_ fileURL: URL?, _ error: (any Error)?)->()
    ) -> URLSessionPartialDownloadTask {
        .init(session: self, request: request.copy(as: .get), downloadDirectory: downloadDirectory, fileName: fileName, partExtension: partExtension, requestedChunkSize: nil, maxConcurrentChunkCount: 1, completion: completion, initialPartDirectoryURL: nil)
    }
    
    func partialDownloadTask(
        for request: URLRequest,
        downloadDirectory: URL,
        fileName: String? = nil,
        partExtension: String = "part",
        chunkSize: Int64 = 2 * 1024 * 1024,
        maxConcurrentChunkCount: Int = 4,
        completion: @escaping @Sendable (_ fileURL: URL?, _ error: (any Error)?)->()
    ) -> URLSessionPartialDownloadTask {
        .init(session: self, request: request.copy(as: .get), downloadDirectory: downloadDirectory, fileName: fileName, partExtension: partExtension, requestedChunkSize: chunkSize, maxConcurrentChunkCount: maxConcurrentChunkCount, completion: completion, initialPartDirectoryURL: nil)
    }
    
    func partialDownloadTask(
        forPartialFile partialFile: URL,
        maxConcurrentChunkCount: Int = 4,
        completion: @escaping @Sendable (_ fileURL: URL?, _ error: (any Error)?)->()
    ) -> URLSessionPartialDownloadTask {
        let request = try? URLRequest(contentsOf: partialFile.appendingPathComponent("request.json"))
        let fileName = partialFile.deletingPathExtension().lastPathComponent
        let downloadDirectory = partialFile.deletingLastPathComponent()
        let partExtension = partialFile.pathExtension.isEmpty ? "part" : partialFile.pathExtension
        return .init(session: self, request: request, downloadDirectory: downloadDirectory, fileName: fileName, partExtension: partExtension, requestedChunkSize: nil, maxConcurrentChunkCount: maxConcurrentChunkCount, completion: completion, initialPartDirectoryURL: partialFile)
    }
}

final class URLSessionPartialDownloadTask: URLSessionTask, @unchecked Sendable {
    private let stateQueue = DispatchQueue(label: "URLSessionPartialDownloadTask.State")
    private let session: URLSession
    private let downloadDirectory: URL
    private let fileName: String?
    private let partExtension: String
    private let requestedChunkSize: Int64?
    private let completion: (_ fileURL: URL?, _ error: (any Error)?)->()
    private let initialPartDirectoryURL: URL?
    private let operationQueue = PausableOperationQueue()
    
    private var didPublishProgress = false
    private var headTask: URLSessionDataTask?
    private var isCancelled = false
    
    private var _state: URLSessionTask.State = .suspended {
        willSet { willChangeValue(for: \.state) }
        didSet { didChangeValue(for: \.state) }
    }
    
    private var _countOfBytesReceived: Int64 = 0 {
        willSet { willChangeValue(for: \.countOfBytesReceived) }
        didSet {
            didChangeValue(for: \.countOfBytesReceived)
            progress.completedUnitCount = _countOfBytesReceived
        }
    }
    
    private var _countOfBytesExpectedToReceive: Int64 = NSURLSessionTransferSizeUnknown {
        willSet { willChangeValue(for: \.countOfBytesExpectedToReceive) }
        didSet {
            didChangeValue(for: \.countOfBytesExpectedToReceive)
            progress.totalUnitCount = _countOfBytesExpectedToReceive
        }
    }
    
    private var _error: Error? {
        willSet { willChangeValue(for: \.error) }
        didSet { didChangeValue(for: \.error) }
    }
    
    private var _originalRequest: URLRequest? {
        willSet { willChangeValue(for: \.originalRequest) }
        didSet { didChangeValue(for: \.originalRequest) }
    }
    
    private var _currentRequest: URLRequest? {
        willSet { willChangeValue(for: \.currentRequest) }
        didSet { didChangeValue(for: \.currentRequest) }
    }
    
    private var _response: URLResponse? {
        willSet { willChangeValue(for: \.response) }
        didSet { didChangeValue(for: \.response) }
    }
    
    private var _progress = Progress(totalUnitCount: NSURLSessionTransferSizeUnknown) {
        willSet { willChangeValue(for: \.progress) }
        didSet { didChangeValue(for: \.progress) }
    }
    
    init(session: URLSession, request: URLRequest?, downloadDirectory: URL, fileName: String?, partExtension: String, requestedChunkSize: Int64?, maxConcurrentChunkCount: Int, completion: @escaping (_ fileURL: URL?, _ error: (any Error)?)->(), initialPartDirectoryURL: URL?) {
        self.session = session
        self._originalRequest = request
        self.downloadDirectory = downloadDirectory
        self.fileName = fileName
        self.partExtension = partExtension
        self.requestedChunkSize = requestedChunkSize
        self.completion = completion
        self.initialPartDirectoryURL = initialPartDirectoryURL
        self.operationQueue.maxConcurrentOperationCount = maxConcurrentChunkCount
        super.init()
    }
    
    public override func resume() {
        guard state == .suspended, !isCancelled else { return }
        _state = .running
        guard let request = originalRequest else {
            _error = URLError(.unsupportedURL)
            cancel()
            return
        }
        headTask = session.dataTask(with: request.copy(as: .head)) { [weak self] _, response, error in
            guard let self = self, self.state == .running else { return }
            self.headTask = nil
            if let error = error {
                self._error = error
                self.cancel()
            } else if let response = response {
                self.processResponse(response)
            } else {
                self._error = URLError(.badServerResponse)
                self.cancel()
            }
        }
        headTask?.resume()
    }
    
    public override func suspend() {
        guard stateQueue.sync(execute: { state == .running && !isCancelled }) else { return }
        stateQueue.sync { _state = .suspended }
        headTask?.cancel()
        headTask = nil
        operationQueue.cancelAllOperations()
        resetProgress()
    }
    
    public override func cancel() {
        guard stateQueue.sync(execute: { (state == .running || state == .suspended) && !isCancelled }) else { return }
        stateQueue.sync {
            isCancelled = true
            _state = .canceling
        }
        headTask?.cancel()
        headTask = nil
        operationQueue.cancelAllOperations()
        completion(nil, _error)
        resetProgress()
        stateQueue.sync { _state = .suspended }
    }
    
    private func resetProgress() {
        _progress = Progress(totalUnitCount: countOfBytesExpectedToReceive)
        _progress.completedUnitCount = countOfBytesReceived
        didPublishProgress = false
    }
    
    func processResponse(_ response: URLResponse) {
        let finalFileName: String
        if let fileName = fileName ?? response.suggestedFilename {
            finalFileName = fileName
        } else if let fileExtension = response.contentType?.preferredFilenameExtension {
            finalFileName = "download.\(fileExtension)"
        } else {
            finalFileName = "download"
        }
        let partFile = downloadDirectory.appendingPathComponent(finalFileName + ".\(partExtension)")
        var contentLength: Int64?
        var chunkSize = requestedChunkSize
        let acceptsByteRanges = response.http?.value(forHTTPHeaderField: .acceptRanges)?.lowercased() == "bytes"
        if acceptsByteRanges, response.expectedContentLength > 0 {
            contentLength = response.expectedContentLength
        }
        
        var createPartFile = !FileManager.default.directoryExists(at: partFile)
        if !createPartFile {
            if let partInfo = PartInfo.load(at: partFile) {
                if partInfo.request != _originalRequest {
                    _originalRequest = partInfo.request
                }
                if partInfo.chunkSize != chunkSize {
                    chunkSize = partInfo.chunkSize
                }
                if partInfo.contentLength != contentLength {
                    do {
                        try FileManager.default.removeItem(at: partFile)
                        createPartFile = true
                    } catch {
                        _error = error
                        cancel()
                    }
                }
            }
        }
        if createPartFile {
            do {
               try FileManager.default.createDirectory(at: partFile, withIntermediateDirectories: true)
                try PartInfo(request: _originalRequest!, chunkSize: chunkSize, contentLength: contentLength).save(at: partFile)
            } catch {
                self._error = error
                self.cancel()
            }
        }
        if let contentLength = contentLength {
            if let chunkSize = chunkSize {
                do {
                    for chunk in Chunk.chunks(contentLength: contentLength, chunkSize: chunkSize) {
                        let fileURL = partFile.appendingPathComponent("\(chunk.index)")
                        if FileManager.default.fileExists(at: fileURL) {
                            if let bytes = fileURL.resources.fileSize?.bytes {
                                guard bytes != chunkSize else { continue }
                               try try FileManager.default.removeItem(at: fileURL)
                                downloadChunk(chunk, request: _originalRequest!, partDirectoryURL: partFile)
                            } else {
                                try try FileManager.default.removeItem(at: fileURL)
                                downloadChunk(chunk, request: _originalRequest!, partDirectoryURL: partFile)
                            }
                        } else {
                            downloadChunk(chunk, request: _originalRequest!, partDirectoryURL: partFile)
                        }
                    }
                } catch {
                    
                }
            }
            
        }
    }
    
    struct PartInfo: Codable {
        let request: URLRequest
        let chunkSize: Int64?
        let contentLength: Int64?
        
        func save(at partFile: URL) throws {
            try (JSONEncoder().encode(self)).write(to: partFile)
        }
        
        static func load(at partFile: URL) -> PartInfo? {
            do {
               return try JSONDecoder().decode(Data(contentsOf: partFile.appendingPathComponent("info.json")))
            } catch {
                return nil
            }
        }
    }
    
    func downloadCHunks() {
       // Chunk.chunks(contentLength: <#T##Int64#>, chunkSize: <#T##Int64#>)
    }
    
    func downloadChunk(_ chunk: Chunk, request: URLRequest, partDirectoryURL: URL) {
        var request = request
        request.setValue("bytes=\(chunk.start)-\(chunk.end)", forHTTPHeaderField: "Range")
        let chunkFileURL = partDirectoryURL.appendingPathComponent("\(chunk.index)")
        let operation = DownloadOperation(request: request, session: session, fileURL: chunkFileURL)
        operation.completionBlock = { [weak self] in
            guard let self = self else { return }
            if operation.state == .finished {
                self._countOfBytesReceived += chunk.length
            } else if operation.state == .failed {
                self._error = operation.error
                self.cancel()
            }
        }
    }
    
    class DownloadOperation: AsyncOperation, URLSessionDataDelegate, ProgressReporting {
        let request: URLRequest
        let session: URLSession
        let fileURL: URL
        var dataTask: URLSessionDataTask?
        var error: (any Error)?
        var fileHandle: FileHandle?
        let progress = Progress()
        
        init(request: URLRequest, session: URLSession, fileURL: URL) {
            self.request = request
            self.session = session
            self.fileURL = fileURL
        }
        
        override func main() {
            do {
                guard FileManager.default.createFile(at: fileURL) else {
                    finish(withError: URLError(.cannotCreateFile))
                    return
                }
                fileHandle = try FileHandle(forWritingTo: fileURL)
                dataTask = session.dataTask(with: request)
                dataTask?.delegate = self
                dataTask?.resume()
            } catch {
                self.cancel()
            }
        }
        
        override func cancel() {
            super.cancel()
            guard isCancelled else { return }
            dataTask?.cancel()
            dataTask = nil
        }
        
        func finish(withError error: Error) {
            self.error = error
            finish(success: false)
        }
                
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
            try? fileHandle?.close()
            fileHandle = nil
            if let error = error {
                finish(withError: error)
            } else {
                if task.countOfBytesExpectedToReceive > 0, task.countOfBytesExpectedToSend != task.countOfBytesReceived {
                    finish(withError: NetworkError(.incompleteDownload))
                } else {
                    finish()
                }
            }
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            do {
                try fileHandle?.write(contentsOf: data)
                guard dataTask.countOfBytesExpectedToReceive > 0 else { return }
                progress.totalUnitCount = dataTask.countOfBytesExpectedToReceive
                progress.completedUnitCount += dataTask.countOfBytesReceived
            } catch {
                cancel()
            }
        }
    }
    
    struct Chunk {
        let index: Int
        let start: Int64
        let end: Int64

        var length: Int64 {
            end - start + 1
        }
        
        static func chunks(contentLength: Int64, chunkSize: Int64) -> [Chunk] {
            stride(from: Int64(0), to: contentLength, by: Int(chunkSize)).enumerated().map {
                Chunk(index: $0, start: $1, end: min($1 + chunkSize, contentLength) - 1)
            }
        }
    }
}

fileprivate extension URLRequest {
    init(contentsOf url: URL) throws {
        do {
            self = try JSONDecoder().decode(Data(contentsOf: url))
        } catch {
            throw error
        }
    }
}
