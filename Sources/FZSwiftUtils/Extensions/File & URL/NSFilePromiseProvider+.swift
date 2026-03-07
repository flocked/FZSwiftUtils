//
//  NSFilePromiseProvider+.swift
//  
//
//  Created by Florian Zand on 07.03.26.
//

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

public extension NSFilePromiseProvider {
    /// Sets the optional user information to pass to the file promise provider.
    @discardableResult
    func userInfo(_ userInfo: Any?) -> Self {
        self.userInfo = userInfo
        return self
    }

    /**
     Initializes a file promise provider for a certain file type.
     
     - Parameters:
        - fileType: The content type of the file.
        - delegate: An object that conforms to the `NSFilePromiseProviderDelegate` protocol, for providing promised file data.
     */
    convenience init(fileType: UTType, delegate: any NSFilePromiseProviderDelegate) {
        self.init(fileType: fileType.identifier, delegate: delegate)
    }
    
    /**
     Initializes a file promise provider for a certain file type.
     
     - Parameters:
        - fileType: A string describing the file type.
        - fileName: The name of the promised file.
        - operationQueue: The operation queue from which to issue the write request.
        - writeHandler: The handler that writes the contents of the promise to the specified URL. Call the provided completion handler after the file has been written.
     */
    convenience init(fileType: String, filename: String, operationQueue: OperationQueue = .main, writeHandler: @escaping (_ destionationURL: URL, _ completionHandler: @escaping @Sendable ((any Error)?) -> Void) -> Void) {
        let delegate = Delegate(fileName: filename, operationQueue: operationQueue, writeHandler: writeHandler)
        self.init(fileType: fileType, delegate: delegate)
        setAssociatedValue(delegate, key: "filePromiseDelegate")
    }
    
    /**
     Initializes a file promise provider for a certain file type.
     
     - Parameters:
        - fileType: The content type of the file.
        - fileName: The name of the promised file.
        - operationQueue: The operation queue from which to issue the write request.
        - writeHandler: The handler that writes the contents of the promise to the specified URL. Call the provided completion handler after the file has been written.
     */
    convenience init(fileType: UTType, filename: String, operationQueue: OperationQueue = .main, writeHandler: @escaping (_ destionationURL: URL, _ completionHandler: @escaping @Sendable ((any Error)?) -> Void) -> Void) {
        self.init(fileType: fileType.identifier, filename: filename, operationQueue: operationQueue, writeHandler: writeHandler)
    }
    
    private class Delegate: NSObject, NSFilePromiseProviderDelegate {
        let fileName: String
        let operationQueue: OperationQueue
        let writeHandler: (URL, @escaping @Sendable ((any Error)?) -> Void) -> Void
        
        init(fileName: String, operationQueue: OperationQueue, writeHandler: @escaping (URL, @escaping @Sendable ((any Error)?) -> Void) -> Void) {
            self.fileName = fileName
            self.operationQueue = operationQueue
            self.writeHandler = writeHandler
        }
        
        func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
            operationQueue
        }
        
        func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
            fileName
        }
        
        func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping @Sendable ((any Error)?) -> Void) {
            writeHandler(url, completionHandler)
        }
    }
}

#endif
