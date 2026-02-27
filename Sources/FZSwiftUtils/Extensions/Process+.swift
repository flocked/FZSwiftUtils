//
//  Process+.swift
//
//
//  Created by Florian Zand on 17.08.25.
//

#if os(macOS)
import Foundation

extension Process {
    /**
     The handler to be called whenever there is new text output available.
     
     - Note: If the stream is read from outside of the handler, or more than once inside it, it may be called once when stream is closed and empty.
     */
    public var onStringOutput: ((String)->())? {
        get { standardOutputPipe?.fileHandleStream.onStringOutput }
        set {
            if newValue != nil, standardOutputPipe == nil {
                standardOutput = Pipe()
            }
            standardOutputPipe?.fileHandleStream.onStringOutput = newValue
        }
    }
    
    /**
     The handler to be called whenever there is new output available.
     
     - Note: If the stream is read from outside of the handler, or more than once inside it, it may be called once when stream is closed and empty.
     */
    public var onOutput: ((Process)->())? {
        get { standardOutputPipe?.onOutput }
        set {
            if newValue != nil, standardOutputPipe == nil {
                standardOutput = Pipe()
            }
            standardOutputPipe?.onOutput = newValue
            if let newValue = newValue {
                standardOutputPipe?.fileHandleStream.onOutput = { [weak self] _ in
                    guard let self = self else { return }
                    newValue(self)
                }
            } else {
                standardOutputPipe?.fileHandleStream.onOutput = nil
            }
        }
    }
    
    /// The handler to be called whenever there is new error output available.
    public var onErrorOutput: ((Process)->())? {
        get { standardErrorPipe?.onOutput }
        set {
            if newValue != nil, standardErrorPipe == nil {
                standardError = Pipe()
            }
            standardErrorPipe?.onOutput = newValue
            if let newValue = newValue {
                standardErrorPipe?.fileHandleStream.onOutput = { [weak self] _ in
                    guard let self = self else { return }
                    newValue(self)
                }
            } else {
                standardErrorPipe?.fileHandleStream.onOutput = nil
            }
        }
    }
    
    /// The handler to be called whenever there is new error text output available.
    public var onErrorStringOutput: ((String)->())? {
        get { standardErrorPipe?.fileHandleStream.onStringOutput }
        set {
            if newValue != nil, standardErrorPipe == nil {
                standardError = Pipe()
            }
            standardErrorPipe?.fileHandleStream.onStringOutput = newValue
        }
    }
    
    public func readStringOutput() -> String {
        if standardOutputPipe == nil { standardOutput = Pipe() }
        return standardOutputPipe?.fileHandleStream.read() ?? ""
    }
    
    public func readErrorStringOutput() -> String {
        if standardErrorPipe == nil { standardError = Pipe() }
        return standardErrorPipe?.fileHandleStream.read() ?? ""
    }
    
    private var standardOutputPipe: Pipe? {
        standardOutput as? Pipe
    }
    
    private var standardErrorPipe: Pipe? {
        standardError as? Pipe
    }
}

fileprivate extension Pipe {
    var fileHandleStream: FileHandleStream {
        getAssociatedValue("fileHandleStream", initialValue: .init(fileHandleForReading))
    }
    
    var onOutput: ((Process)->())? {
        get { getAssociatedValue("onOutput") }
        set { setAssociatedValue(newValue, key: "onOutput") }
    }
}

#endif
