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
    var onStringOutput: ((String)->())? {
        get { stdout?.onStringOutput }
        set {
            if let newValue = newValue {
                onOutput = nil
                setupOutputPipe()
                stdout?.onStringOutput = newValue
            } else {
                stdout?.onStringOutput = nil
            }
        }
    }
    
    /**
     The handler to be called whenever there is new output available.
     
     - Note: If the stream is read from outside of the handler, or more than once inside it, it may be called once when stream is closed and empty.
     */
    var onOutput: ((Process)->())? {
        get { getAssociatedValue("onOutput") }
        set {
            setAssociatedValue(newValue, key: "onOutput")
            if let newValue = newValue {
                onStringOutput = nil
                setupOutputPipe()
                stdout?.onOutput = { [weak self] _ in
                    guard let self = self else { return }
                    newValue(self)
                }
            } else {
                stdout?.onOutput = nil
            }
        }
    }
    
    var onErrorOutput: ((Process)->())? {
        get { getAssociatedValue("onErrorOutput") }
        set {
            setAssociatedValue(newValue, key: "onErrorOutput")
            if let newValue = newValue {
                onErrorStringOutput = nil
                setupOutputPipe(error: true)
                stderror?.onOutput = { [weak self] _ in
                    guard let self = self else { return }
                    newValue(self)
                }
            } else {
                stderror?.onOutput = nil
            }
        }
    }
    
    var onErrorStringOutput: ((String)->())? {
        get { stderror?.onStringOutput }
        set {
            if let newValue = newValue {
                onErrorOutput = nil
                setupOutputPipe(error: true)
                stderror?.onStringOutput = newValue
            } else {
                stderror?.onStringOutput = nil
            }
        }
    }
    
    public func readStringOutput() -> String {
        setupOutputPipe(error: false)
        return stdout!.read()
    }
    
    public func readErrorStringOutput() -> String {
        setupOutputPipe(error: true)
        return stderror!.read()
    }
    
    private var stdout: FileHandleStream? {
        get { getAssociatedValue("stdout") }
        set { setAssociatedValue(newValue, key: "stdout") }
    }
    
    private var stderror: FileHandleStream? {
        get { getAssociatedValue("stderror") }
        set { setAssociatedValue(newValue, key: "stderror") }
    }
    
    private func setupOutputPipe(error: Bool = false) {
        if error {
            guard stderror == nil else { return }
            if let pipe = standardError as? Pipe {
                stderror = .init(pipe.fileHandleForReading)
            } else {
                let pipe = Pipe()
                standardError = pipe
                stderror = .init(pipe.fileHandleForReading)
            }
        } else {
            guard stdout == nil else { return }
            if let pipe = standardOutput as? Pipe {
                stdout = .init(pipe.fileHandleForReading)
            } else {
                let pipe = Pipe()
                standardOutput = pipe
                stdout = .init(pipe.fileHandleForReading)
            }
        }
    }
}


#endif
