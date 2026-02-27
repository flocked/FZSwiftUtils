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
     Creates a zsh process with the specified executable and arguments.
     
     - Parameters:
        - executable: The executable to run.
        - arguments: The command arguments that the system uses to launch the executable.
        - directory: The current directory for the process.
     */
    public static func zsh(_ executable: String, arguments: [Any] = [], at directory: URL? = nil) -> Process {
        let process = Process()
        process.environment = ProcessInfo.processInfo.environment
        process.environment?["PATH"] = (try? Process.resolveLoginShellPATH()) ?? "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", ([executable] + arguments.flattened().map(String.init(describing:))).map(\.escaped).joined(separator: " ")]
        process.currentDirectoryURL = directory
        return process
    }
    
    /**
     Creates a zsh process with the specified executable and arguments.
     
     - Parameters:
        - executable: The executable to run.
        - arguments: The command arguments that the system uses to launch the executable.
        - directory: The current directory for the process.
     */
    public static func zsh(_ executable: String, _ arguments: Any..., at directory: URL? = nil) -> Process {
        zsh(executable, arguments: arguments, at: directory)
    }
    
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
    
    /**
     Blocks the process until the receiver is finished.
     
     - Throws: If the exit code is anything but 0.
     */
    public func waitUntilExitThrowing() throws {
        waitUntilExit()
        guard terminationStatus == 0 else {
            throw Errors.returnedErrorCode(command: commandAsString, errorcode: Int(terminationStatus))
        }
    }
    
    /// Resolves the user's login shell PATH.
    public static func resolveLoginShellPATH() throws -> String {
        let shell = Process()
        shell.executableURL = URL(fileURLWithPath: "/bin/zsh")
        shell.arguments = ["-l", "-c", "echo $PATH"]
        let pipe = Pipe()
        shell.standardOutput = pipe
        shell.standardError = Pipe()
        try shell.run()
        shell.waitUntilExit()
        guard shell.terminationStatus == 0 else {
            throw NSError(domain: "ProcessError", code: Int(shell.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Failed to resolve login shell PATH"])
        }
        let path = try pipe.fileHandleForReading.read().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else {
            throw NSError(domain: "ProcessError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resolved PATH is empty"])
        }
        return path
    }
    
    /// Updates this process's environment with the user's login shell PATH.
    public func applyLoginShellPATH() throws {
        var env = environment ?? ProcessInfo.processInfo.environment
        env["PATH"] = try Self.resolveLoginShellPATH()
        environment = env
    }
    
    private var commandAsString: String {
        (arguments ?? []).reduce(executableURL?.path ?? "") { $0 + " " + $1.escaped }
    }
    
    private enum Errors: Error, CustomStringConvertible {
        case returnedErrorCode(command: String, errorcode: Int)
        
        var description: String {
            switch self {
            case .returnedErrorCode(let command, let code):
                return "Command '\(command)' returned with error code \(code)."
            }
        }
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

fileprivate extension String {
    var escaped: String {
        contains(" ") ? "\"\(self)\"" : self
    }
}

#endif
