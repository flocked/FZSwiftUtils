//
//  Stream.swift
//
//
//  Created by Florian Zand on 16.08.25.
//

import Foundation

/// A stream of text.
public protocol ReadableStream: AnyObject, TextOutputStreamable {
    /// The string encoding used reading strings.
    var encoding: String.Encoding { get set }
    var filehandle: FileHandle { get }

    /**
     All the text the stream contains so far.
     
     If the source is a file this will read everything at once.
     If the stream is empty and still open this will wait for more content or end-of-file.
     
     - Returns: More text from the stream, or `nil` if we have reached the end.
     */
    func readSome() -> String?

    /// Reads everything at once.
    func read() -> String
}

extension ReadableStream {
    public func readSome() -> String? {
        return try? filehandle.readSome(encoding: encoding)
    }

    public func read() -> String {
        do {
            return try filehandle.read(encoding: encoding)
        } catch {
            fatalError("Could not read string.")
        }
    }

    /// Splits stream lazily into lines.
    public func lines() -> LazySequence<AnySequence<String>> {
        AnySequence(PartialSourceLazySplitSequence({ self.readSome() }, separator: "\n").map(String.init)).lazy
    }

    /// Writes the text in this stream to the given TextOutputStream.
    public func write<Target: TextOutputStream>(to target: inout Target) {
        while let text = readSome() { target.write(text) }
    }

    /**
     All the data the stream contains so far.
     
     If the source is a file this will read everything at once.
     If the stream is empty and still open this will wait for more content or end-of-file.
     
     - Returns: More data from the stream, or `nil` if we have reached the end.
     */
    public func readSomeData() -> Data? {
        let data = filehandle.availableData
        return !data.isEmpty ? data : nil
    }

    /**
     Reads everything at once.
     
     Marked with @discardableResult so that the stream can be read before calling .finish() without causing any compiler warnings or requiring developer work-arounds when the result will not be used (see #52 & #57)
     */
    @discardableResult public func readData() -> Data {
        filehandle.readDataToEndOfFile()
    }
}

extension ReadableStream {
    /**
     The handler to be called whenever there is new output available.
     
     - Note: If the stream is read from outside of `handler`, or more than once inside it, it may be called once when stream is closed and empty.
     */
    public var onOutput: ((Self) -> Void)? {
        get { filehandle.getAssociatedValue("onOutput") }
        set {
            filehandle.setAssociatedValue(newValue, key: "onOutput")
            if let newValue = newValue {
                filehandle.readabilityHandler = { [weak self] _ in
                    self.map(newValue)
                }
            } else {
                filehandle.readabilityHandler = nil
            }
        }
    }
    
    /**
     Sets the handler to be called whenever there is new output available.
     
     - Note: If the stream is read from outside of `handler`, or more than once inside it, it may be called once when stream is closed and empty.
     */
    @discardableResult
    public func onOutput(_ onOutput: ((Self) -> Void)?) -> Self {
        self.onOutput = onOutput
        return self
    }
    
    /**
     The handler to be called whenever there is new text output available.
     
     - Note: If the stream is read from outside of `handler`, or more than once inside it, it may be called once when stream is closed and empty.
     */
    public var onStringOutput: ((String) -> Void)? {
        get { filehandle.getAssociatedValue("onStringOutput") }
        set {
            filehandle.setAssociatedValue(newValue, key: "onStringOutput")
            if let newValue = newValue {
                onOutput = { stream in
                    if let output = stream.readSome() {
                        newValue(output)
                    }
                }
            } else {
                onOutput = nil
            }
        }
    }
    
    /**
     Sets the handler to be called whenever there is new text output available.
     
     - Note: If the stream is read from outside of `handler`, or more than once inside it, it may be called once when stream is closed and empty.
     */
    @discardableResult
    public func onStringOutput(_ onStringOutput: ((String) -> Void)?) -> Self {
        self.onStringOutput = onStringOutput
        return self
    }
}

/// An output stream, like standard output or a writeable file.
public protocol WritableStream: AnyObject, TextOutputStream {
    var encoding: String.Encoding { get set }
    var filehandle: FileHandle { get }

    /// Writes the string to the stream.
    func write(_ x: String)

    /**
     Closes the stream.
     
     Must be called on non-file streams when finished writing, to prevent deadlock when reading.
     */
    func close()
}

extension WritableStream {
    public func write(_ x: String) {
        try? filehandle.write(x, encoding: encoding)
    }

    public func close() {
        filehandle.closeFile()
    }

    /**
     Writes the textual representations of the given items into the stream.
     
     Works exactly the same way as `print` from Swift's standard library.
     
     To avoid printing a newline at the end, pass `terminator: ""` or use `write` ìnstead.
     
     - Parameters:
     - items: Zero or more items to print, converted to text with String(describing:).
     - separator: What to print between each item. Default is " ".
     - terminator: What to print at the end. Default is newline.
     */
    @warn_unqualified_access
    public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        var iterator = items.lazy.map(String.init(describing:)).makeIterator()
        iterator.next().map(write)
        while let item = iterator.next() {
            write(separator)
            write(item)
        }
        write(terminator)
    }

    /// Writes data to the stream.
    public func write(data: Data) {
        filehandle.write(data)
    }
}

/// Singleton WritableStream used only for `print`ing to stdout.
public class StdoutStream: WritableStream {
    public var encoding: String.Encoding = .utf8
    public let filehandle = FileHandle.standardOutput

    private init() {}

    public static var `default`: StdoutStream { StdoutStream() }

    public func write(_ x: String) {
        Swift.print(x, terminator: "")
    }

    public func close() {}
}

public class FileHandleStream: ReadableStream, WritableStream {
    public let filehandle: FileHandle
    public var encoding: String.Encoding

    public init(_ filehandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.filehandle = filehandle
        self.encoding = encoding
    }
}

/// Creates a pair of streams. What is written to the 1st one can be read from the 2nd one.
public func streams() -> (WritableStream, ReadableStream) {
    let pipe = Pipe()
    return (FileHandleStream(pipe.fileHandleForWriting, encoding: .utf8), FileHandleStream(pipe.fileHandleForReading, encoding: .utf8))
}
