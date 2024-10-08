//
//  URL+File.swift
//
//  Created by John Sundell
//  Files - https://github.com/JohnSundell/Files
//
//  Modified by:
//  Florian Zand
//  

/*
import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

// MARK: - Locations

/// Enum describing various kinds of locations that can be found on a file system.
public enum LocationKind {
    /// A file can be found at the location.
    case file
    /// A folder can be found at the location.
    case folder
}

/// Protocol adopted by types that represent locations on a file system.
public protocol Location: Equatable, CustomStringConvertible {
    /// The kind of location that is being represented (see `LocationKind`).
    static var kind: LocationKind { get }
    /// The underlying storage for the item at the represented location.
    /// You don't interact with this object as part of the public API.
    var storage: Storage<Self> { get }
    /// Initialize an instance of this location with its underlying storage.
    /// You don't call this initializer as part of the public API, instead
    /// use `init(path:)` on either `File` or `Folder`.
    init(storage: Storage<Self>)
}

public extension Location {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.storage.path == rhs.storage.path
    }

    var description: String {
        "\(String(describing: type(of: self)))(name: \(name), path: \(path))"
    }

    /// The path of this location, relative to the root of the file system.
    var path: String {
        storage.path
    }

    /// A URL representation of the location's `path`.
    var url: URL {
        URL(fileURLWithPath: path)
    }

    /// The name of the location, including any `extension`.
    var name: String {
        url.pathComponents.last!
    }

    /// The name of the location, excluding its `extension`.
    var nameExcludingExtension: String {
        let components = name.split(separator: ".")
        guard components.count > 1 else { return name }
        return components.dropLast().joined()
    }

    /// The file extension of the item at the location.
    var `extension`: String? {
        let components = name.split(separator: ".")
        guard components.count > 1 else { return nil }
        return String(components.last!)
    }

    /// The parent folder that this location is contained within.
    var parent: Folder? {
        storage.makeParentPath(for: path).flatMap { try? Folder(path: $0) }
    }
    
    /// A Boolean value indicating if the resource is readable.
    var isHidden: Bool {
        storage.resources.isHidden
    }
    
    /// A Boolean value indicating if the resource is readable.
    var isReadable: Bool? {
        storage.resources.isReadable
    }
    
    /// A Boolean value indicating if the resource is writable.
    var isWritable: Bool? {
        storage.resources.isWritable
    }
    
    #if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    /// A content type of the resource.
    var contentType: UTType? {
        storage.resources.contentType
    }
    #endif
    
    /// A content type identifier of the resource.
    var contentTypeIdentifier: String? { storage.resources.contentTypeIdentifier }

    /// A content type identifier tree of the resource.
    var contentTypeIdentifierTree: [String]? { contentTypeIdentifier != nil ? storage.resources.contentTypeIdentifierTree : nil }
    
    /// The finder tags of the resource.
    var finderTags: [String] {
        storage.resources.finderTags
    }
    
    /**
     The date when the item at this location was created.
     
     Only returns `nil` in case the item has now been deleted.
     */
    var creationDate: Date? {
        storage.resources.creationDate
    }
    
    /**
     The total file size.
     
     Only returns `nil` in case the item has now been deleted.
     */
    var fileSize: DataSize? {
        storage.resources.fileSize
    }
    
    /**
     The date when the item was created, or renamed into or within its parent directory.
     
     Only returns `nil` in case the item has now been deleted.
     */
    var addedToDirectoryDate: Date? {
        storage.resources.addedToDirectoryDate
    }
    
    /**
     The date when the item content was last accessed.
     
     Only returns `nil` in case the item has now been deleted.
     */
    var lastAccessDate: Date? {
        storage.resources.contentAccessDate
    }
    
    /**
     The date when the item at this location was last modified.
     
     Only returns `nil` in case the item has now been deleted.
     */
    var modificationDate: Date? {
        storage.resources.contentModificationDate
    }

    /// Initialize an instance of an existing location at a given path.
    /// - parameter path: The absolute path of the location.
    /// - throws: `LocationError` if the item couldn't be found.
    init(path: String) throws {
        try self.init(storage: Storage(path: path, fileManager: .default))
    }
    
    /// Initialize an instance of an existing location at a given url.
    /// - parameter url: The url of the location.
    /// - throws: `LocationError` if the item couldn't be found.
    init(url: URL) throws {
        try self.init(storage: Storage(url: url, fileManager: .default))
    }
    

    /// Return the path of this location relative to a parent folder.
    /// For example, if this item is located at `/users/john/documents`
    /// and `/users/john` is passed, then `documents` is returned. If the
    /// passed folder isn't an ancestor of this item, then the item's
    /// absolute `path` is returned instead.
    /// - parameter folder: The folder to compare this item's path against.
    func path(relativeTo folder: Folder) -> String {
        guard path.hasPrefix(folder.path) else {
            return path
        }

        let index = path.index(path.startIndex, offsetBy: folder.path.count)
        return String(path[index...]).removingSuffix("/")
    }

    /// Rename this location, keeping its existing `extension` by default.
    /// - parameter newName: The new name to give the location.
    /// - parameter keepExtension: Whether the location's `extension` should
    ///   remain unmodified (default: `true`).
    /// - throws: `LocationError` if the item couldn't be renamed.
    func rename(to newName: String, keepExtension: Bool = true) throws {
        guard let parent = parent else {
            throw LocationError(path: path, reason: .cannotRenameRoot)
        }

        var newName = newName

        if keepExtension {
            `extension`.map {
                newName = newName.appendingSuffixIfNeeded(".\($0)")
            }
        }

        try storage.move(
            to: parent.path + newName,
            errorReasonProvider: LocationErrorReason.renameFailed
        )
    }

    /// Move this location to a new parent folder
    /// - parameter newParent: The folder to move this item to.
    /// - throws: `LocationError` if the location couldn't be moved.
    func move(to newParent: Folder) throws {
        try storage.move(
            to: newParent.path + name,
            errorReasonProvider: LocationErrorReason.moveFailed
        )
    }

    /// Copy the contents of this location to a given folder
    /// - parameter newParent: The folder to copy this item to.
    /// - throws: `LocationError` if the location couldn't be copied.
    /// - returns: The new, copied location.
    @discardableResult
    func copy(to folder: Folder) throws -> Self {
        let path = folder.path + name
        try storage.copy(to: path)
        return try Self(path: path)
    }

    /// Delete this location. It will be permanently deleted. Use with caution.
    /// - throws: `LocationError` if the item couldn't be deleted.
    func delete() throws {
        try storage.delete()
    }

    /// Assign a new `FileManager` to manage this location. Typically only used
    /// for testing, or when building custom file systems. Returns a new instance,
    /// doensn't modify the instance this is called on.
    /// - parameter manager: The new file manager that should manage this location.
    /// - throws: `LocationError` if the change couldn't be completed.
    func managedBy(_ manager: FileManager) throws -> Self {
        try Self(storage: Storage(path: path, fileManager: manager))
    }
}

// MARK: - Storage

/// Type used to store information about a given file system location. You don't
/// interact with this type as part of the public API, instead you use the APIs
/// exposed by `Location`, `File`, and `Folder`.
public final class Storage<LocationType: Location> {
    fileprivate private(set) var path: String
    private let fileManager: FileManager
    
    var url: URL {
        URL(fileURLWithPath: path)
    }

    fileprivate init(path: String, fileManager: FileManager) throws {
        self.path = path
        self.fileManager = fileManager
        try validatePath()
    }
    
    fileprivate init(url: URL, fileManager: FileManager) throws {
        self.path = url.path
        self.fileManager = fileManager
        try validateURL(url)
    }
    
    private func validateURL(_ url: URL) throws {
        guard fileManager.locationExists(at: url.path, kind: LocationType.kind) else {
            throw LocationError(path: url.path, reason: .missing)
        }
    }

    private func validatePath() throws {
        switch LocationType.kind {
        case .file:
            guard !path.isEmpty else {
                throw LocationError(path: path, reason: .emptyFilePath)
            }
        case .folder:
            if path.isEmpty { path = fileManager.currentDirectoryPath }
            if !path.hasSuffix("/") { path += "/" }
        }

        if path.hasPrefix("~") {
            let homePath = ProcessInfo.processInfo.environment["HOME"]!
            path = homePath + path.dropFirst()
        }

        while let parentReferenceRange = path.range(of: "../") {
            let folderPath = String(path[..<parentReferenceRange.lowerBound])
            let parentPath = makeParentPath(for: folderPath) ?? "/"

            guard fileManager.locationExists(at: parentPath, kind: .folder) else {
                throw LocationError(path: parentPath, reason: .missing)
            }

            path.replaceSubrange(..<parentReferenceRange.upperBound, with: parentPath)
        }

        guard fileManager.locationExists(at: path, kind: LocationType.kind) else {
            throw LocationError(path: path, reason: .missing)
        }
    }
}

fileprivate extension Storage {
    var resources: URLResources {
        url.resources
    }

    func makeParentPath(for path: String) -> String? {
        guard path != "/" else { return nil }
        let components = url.pathComponents.dropFirst().dropLast()
        guard !components.isEmpty else { return "/" }
        return "/" + components.joined(separator: "/") + "/"
    }

    func move(to newPath: String,
              errorReasonProvider: (Error) -> LocationErrorReason) throws {
        do {
            try fileManager.moveItem(atPath: path, toPath: newPath)

            switch LocationType.kind {
            case .file:
                path = newPath
            case .folder:
                path = newPath.appendingSuffixIfNeeded("/")
            }
        } catch {
            throw LocationError(path: path, reason: errorReasonProvider(error))
        }
    }

    func copy(to newPath: String) throws {
        do {
            try fileManager.copyItem(atPath: path, toPath: newPath)
        } catch {
            throw LocationError(path: path, reason: .copyFailed(error))
        }
    }

    func delete() throws {
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            throw LocationError(path: path, reason: .deleteFailed(error))
        }
    }
}

private extension Storage where LocationType == Folder {
    func makeChildSequence<T: Location>() -> Folder.ChildSequence<T> {
        Folder.ChildSequence(url: Folder(storage: self).url, fileManger: fileManager)
    }

    func subfolder(at folderPath: String) throws -> Folder {
        let folderPath = path + folderPath.removingPrefix("/")
        let storage = try Storage(path: folderPath, fileManager: fileManager)
        return Folder(storage: storage)
    }

    func file(at filePath: String) throws -> File {
        let filePath = path + filePath.removingPrefix("/")
        let storage = try Storage<File>(path: filePath, fileManager: fileManager)
        return File(storage: storage)
    }

    func createSubfolder(at folderPath: String) throws -> Folder {
        let folderPath = path + folderPath.removingPrefix("/")

        guard folderPath != path else {
            throw WriteError(path: folderPath, reason: .emptyPath)
        }

        do {
            try fileManager.createDirectory(
                atPath: folderPath,
                withIntermediateDirectories: true
            )

            let storage = try Storage(path: folderPath, fileManager: fileManager)
            return Folder(storage: storage)
        } catch {
            throw WriteError(path: folderPath, reason: .folderCreationFailed(error))
        }
    }

    func createFile(at filePath: String, contents: Data?) throws -> File {
        let filePath = path + filePath.removingPrefix("/")

        guard let parentPath = makeParentPath(for: filePath) else {
            throw WriteError(path: filePath, reason: .emptyPath)
        }

        if parentPath != path {
            do {
                try fileManager.createDirectory(
                    atPath: parentPath,
                    withIntermediateDirectories: true
                )
            } catch {
                throw WriteError(path: parentPath, reason: .folderCreationFailed(error))
            }
        }

        guard fileManager.createFile(atPath: filePath, contents: contents),
              let storage = try? Storage<File>(path: filePath, fileManager: fileManager) else {
            throw WriteError(path: filePath, reason: .fileCreationFailed)
        }

        return File(storage: storage)
    }
}

// MARK: - Files

/// Type that represents a file on disk. You can either reference an existing
/// file by initializing an instance with a `path`, or you can create new files
/// using the various `createFile...` APIs available on `Folder`.
public struct File: Location {
    public let storage: Storage<File>

    public init(storage: Storage<File>) {
        self.storage = storage
    }
}

public extension File {
    static var kind: LocationKind {
        return .file
    }

    /// Write a new set of binary data into the file, replacing its current contents.
    /// - parameter data: The binary data to write.
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func write(_ data: Data) throws {
        do {
            try data.write(to: url)
        } catch {
            throw WriteError(path: path, reason: .writeFailed(error))
        }
    }

    /// Write a new string into the file, replacing its current contents.
    /// - parameter string: The string to write.
    /// - parameter encoding: The encoding of the string (default: `UTF8`).
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func write(_ string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw WriteError(path: path, reason: .stringEncodingFailed(string))
        }

        return try write(data)
    }

    /// Append a set of binary data to the file's existing contents.
    /// - parameter data: The binary data to append.
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func append(_ data: Data) throws {
        do {
            let handle = try FileHandle(forWritingTo: url)
            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
        } catch {
            throw WriteError(path: path, reason: .writeFailed(error))
        }
    }

    /// Append a string to the file's existing contents.
    /// - parameter string: The string to append.
    /// - parameter encoding: The encoding of the string (default: `UTF8`).
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func append(_ string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw WriteError(path: path, reason: .stringEncodingFailed(string))
        }

        return try append(data)
    }

    /// Read the contents of the file as binary data.
    /// - throws: `ReadError` if the file couldn't be read.
    func read() throws -> Data {
        do { return try Data(contentsOf: url) }
        catch { throw ReadError(path: path, reason: .readFailed(error)) }
    }

    /// Read the contents of the file as a string.
    /// - parameter encoding: The encoding to decode the file's data using (default: `UTF8`).
    /// - throws: `ReadError` if the file couldn't be read, or if a string couldn't
    ///   be decoded from the file's contents.
    func readAsString(encodedAs encoding: String.Encoding = .utf8) throws -> String {
        guard let string = try String(data: read(), encoding: encoding) else {
            throw ReadError(path: path, reason: .stringDecodingFailed)
        }

        return string
    }

    /// Read the contents of the file as an integer.
    /// - throws: `ReadError` if the file couldn't be read, or if the file's
    ///   contents couldn't be converted into an integer.
    func readAsInt() throws -> Int {
        let string = try readAsString()

        guard let int = Int(string) else {
            throw ReadError(path: path, reason: .notAnInt(string))
        }

        return int
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension File {
    /// Open the file.
    func open() {
        NSWorkspace.shared.openFile(path)
    }
}

#endif

// MARK: - Folders

/// Type that represents a folder on disk. You can either reference an existing
/// folder by initializing an instance with a `path`, or you can create new
/// subfolders using this type's various `createSubfolder...` APIs.
public struct Folder: Location {
    public let storage: Storage<Folder>

    public init(storage: Storage<Folder>) {
        self.storage = storage
    }
}

public extension Folder {
    /// A sequence of child locations contained within a given folder.
    /// You obtain an instance of this type by accessing either `files`
    /// or `subfolders` on a `Folder` instance.
    struct ChildSequence<Child: Location>: Sequence {
        let url: URL
        var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        var maxDepth: Int? = nil
        let fileManger: FileManager
        
        var includsHidden: Bool {
            get { !options.contains(.skipsHiddenFiles)  }
            set { options[.skipsHiddenFiles] = !newValue }
        }
        
        var isRecursive: Bool {
            get { !options.contains(.skipsSubdirectoryDescendants)  }
            set { options[.skipsSubdirectoryDescendants] = !newValue }
        }
        
        init(url: URL, fileManger: FileManager) {
            self.url = url
            self.fileManger = fileManger
        }

        public func makeIterator() -> ChildIterator<Child> {
            ChildIterator(url: url, options: options, maxDepth: maxDepth, fileManger: fileManger)
        }
    }

    /// The type of iterator used by `ChildSequence`. You don't interact
    /// with this type directly. See `ChildSequence` for more information.
    struct ChildIterator<Child: Location>: IteratorProtocol {
        let directoryEnumerator: FileManager.DirectoryEnumerator?
        let maxLevel: Int?
        var maximumLevel = 0
        let fileManger: FileManager

        init(url: URL, options: FileManager.DirectoryEnumerationOptions, maxDepth: Int?, fileManger: FileManager) {
            self.maxLevel = maxDepth
            self.fileManger = fileManger
            directoryEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)
        }
        
        /// The number of levels deep the iterator is in the directory hierarchy being enumerated.
        public var level: Int {
            directoryEnumerator?.level ?? 0
        }
        
        public mutating func next() -> Child? {
            guard let directoryEnumerator = directoryEnumerator else { return nil }
            while let nextURL = directoryEnumerator.nextObject() as? URL {
                if let maxLevel = maxLevel, directoryEnumerator.level > maxLevel {
                    directoryEnumerator.skipDescendants()
                }
                maximumLevel = level
                let childStorage = try? Storage<Child>(path: nextURL.path, fileManager: fileManger)
                let child = childStorage.map(Child.init)
                return child ?? next()
            }
            return nil
        }
    }
}

extension Folder.ChildSequence: CustomStringConvertible {
    public var description: String {
        return lazy.map({ $0.description }).joined(separator: "\n")
    }
}

public extension Folder.ChildSequence {
    /// Includes the contents of folders.
    var recursive: Self {
        recursive(true)
    }
            
    /**
     Includes the contents of folders upto the specified maximum depth.
     
     - Parameter maxDepth: The maximum depth of enumeration. A value of `0` enumerates files/folders only at the url level.
     */
    func recursive(maxDepth: Int) -> Self {
        var sequence = recursive
        sequence.maxDepth = maxDepth.clamped(min: 0) + 1
        return sequence
    }

    /// Includes all hidden files/folders.
    var includingHidden: Self {
        includingHidden(true)
    }
    
    /// Includes the contents of packages.
    var includingPackageDescendants: Self {
        includingPackageDescendants(true)
    }
    
    /// Returns a new instance of the sequence that'll traverse the folder's contents recursively.
    func recursive(_ recursive: Bool) -> Self {
        var sequence = self
        sequence.maxDepth = nil
        sequence.options[.skipsSubdirectoryDescendants] = !recursive
        return sequence
    }
    
    /// Returns a new instance of the sequence that'll include all hidden all hidden (dot) files/folders.
    func includingHidden(_ include: Bool) -> Self {
        var sequence = self
        sequence.options[.skipsHiddenFiles] = !include
        return sequence
    }
    
    /// Returns a new instance of the sequence that'll treat packages like folders and will traverse their contents.
    func includingPackageDescendants(_ include: Bool) -> Self {
        var sequence = self
        sequence.options[.skipsPackageDescendants] = !include
        return sequence
    }

    /// The number of urls in the sequence.
    var count: Int {
        reduce(0) { count, _ in count + 1 }
    }

    /// Gather the names of all of the locations contained within this sequence.
    /// Complexity: `O(N)`.
    func names() -> [String] {
        return map { $0.name }
    }
    
    /// Return the last location contained within this sequence.
    func last() -> Child? {
        var iterator = makeIterator()
        var child: Child? = nil
        while let _child = iterator.next() {
            child = _child
        }
        return child
    }

    /// Return the first location contained within this sequence.
    /// Complexity: `O(1)`.
    var first: Child? {
        var iterator = makeIterator()
        return iterator.next()
    }

    /// Move all locations within this sequence to a new parent folder.
    /// - parameter folder: The folder to move all locations to.
    /// - throws: `LocationError` if the move couldn't be completed.
    func move(to folder: Folder) throws {
        try forEach { try $0.move(to: folder) }
    }

    /// Delete all of the locations within this sequence. All items will
    /// be permanently deleted. Use with caution.
    /// - throws: `LocationError` if an item couldn't be deleted. Note that
    ///   all items deleted up to that point won't be recovered.
    func delete() throws {
        try forEach { try $0.delete() }
    }
}

public extension Folder {
    static var kind: LocationKind {
        return .folder
    }

    /// The folder that the program is currently operating in.
    static var current: Folder {
        return try! Folder(path: "")
    }

    /// The root folder of the file system.
    static var root: Folder {
        return try! Folder(path: "/")
    }

    /// The current user's Home folder.
    static var home: Folder {
        return try! Folder(path: "~")
    }

    /// The system's temporary folder.
    static var temporary: Folder {
        return try! Folder(path: NSTemporaryDirectory())
    }

    /// A sequence containing all of this folder's subfolders. Initially
    /// non-recursive, use `recursive` on the returned sequence to change that.
    var subfolders: ChildSequence<Folder> {
        return storage.makeChildSequence()
    }

    /// A sequence containing all of this folder's files. Initially
    /// non-recursive, use `recursive` on the returned sequence to change that.
    var files: ChildSequence<File> {
        return storage.makeChildSequence()
    }

    /// Return a subfolder at a given path within this folder.
    /// - parameter path: A relative path within this folder.
    /// - throws: `LocationError` if the subfolder couldn't be found.
    func subfolder(at path: String) throws -> Folder {
        return try storage.subfolder(at: path)
    }

    /// Return a subfolder with a given name.
    /// - parameter name: The name of the subfolder to return.
    /// - throws: `LocationError` if the subfolder couldn't be found.
    func subfolder(named name: String) throws -> Folder {
        return try storage.subfolder(at: name)
    }

    /// Return whether this folder contains a subfolder at a given path.
    /// - parameter path: The relative path of the subfolder to look for.
    func containsSubfolder(at path: String) -> Bool {
        return (try? subfolder(at: path)) != nil
    }

    /// Return whether this folder contains a subfolder with a given name.
    /// - parameter name: The name of the subfolder to look for.
    func containsSubfolder(named name: String) -> Bool {
        return (try? subfolder(named: name)) != nil
    }

    /// Create a new subfolder at a given path within this folder. In case
    /// the intermediate folders between this folder and the new one don't
    /// exist, those will be created as well. This method throws an error
    /// if a folder already exists at the given path.
    /// - parameter path: The relative path of the subfolder to create.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createSubfolder(at path: String) throws -> Folder {
        return try storage.createSubfolder(at: path)
    }

    /// Create a new subfolder with a given name. This method throws an error
    /// if a subfolder with the given name already exists.
    /// - parameter name: The name of the subfolder to create.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createSubfolder(named name: String) throws -> Folder {
        return try storage.createSubfolder(at: name)
    }

    /// Create a new subfolder at a given path within this folder. In case
    /// the intermediate folders between this folder and the new one don't
    /// exist, those will be created as well. If a folder already exists at
    /// the given path, then it will be returned without modification.
    /// - parameter path: The relative path of the subfolder.
    /// - throws: `WriteError` if a new folder couldn't be created.
    @discardableResult
    func createSubfolderIfNeeded(at path: String) throws -> Folder {
        return try (try? subfolder(at: path)) ?? createSubfolder(at: path)
    }

    /// Create a new subfolder with a given name. If a subfolder with the given
    /// name already exists, then it will be returned without modification.
    /// - parameter name: The name of the subfolder.
    /// - throws: `WriteError` if a new folder couldn't be created.
    @discardableResult
    func createSubfolderIfNeeded(withName name: String) throws -> Folder {
        return try (try? subfolder(named: name)) ?? createSubfolder(named: name)
    }

    /// Return a file at a given path within this folder.
    /// - parameter path: A relative path within this folder.
    /// - throws: `LocationError` if the file couldn't be found.
    func file(at path: String) throws -> File {
        return try storage.file(at: path)
    }

    /// Return a file within this folder with a given name.
    /// - parameter name: The name of the file to return.
    /// - throws: `LocationError` if the file couldn't be found.
    func file(named name: String) throws -> File {
        return try storage.file(at: name)
    }

    /// Return whether this folder contains a file at a given path.
    /// - parameter path: The relative path of the file to look for.
    func containsFile(at path: String) -> Bool {
        return (try? file(at: path)) != nil
    }

    /// Return whether this folder contains a file with a given name.
    /// - parameter name: The name of the file to look for.
    func containsFile(named name: String) -> Bool {
        return (try? file(named: name)) != nil
    }

    /// Create a new file at a given path within this folder. In case
    /// the intermediate folders between this folder and the new file don't
    /// exist, those will be created as well. This method throws an error
    /// if a file already exists at the given path.
    /// - parameter path: The relative path of the file to create.
    /// - parameter contents: The initial `Data` that the file should contain.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createFile(at path: String, contents: Data? = nil) throws -> File {
        return try storage.createFile(at: path, contents: contents)
    }

    /// Create a new file with a given name. This method throws an error
    /// if a file with the given name already exists.
    /// - parameter name: The name of the file to create.
    /// - parameter contents: The initial `Data` that the file should contain.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createFile(named fileName: String, contents: Data? = nil) throws -> File {
        return try storage.createFile(at: fileName, contents: contents)
    }

    /// Create a new file at a given path within this folder. In case
    /// the intermediate folders between this folder and the new file don't
    /// exist, those will be created as well. If a file already exists at
    /// the given path, then it will be returned without modification.
    /// - parameter path: The relative path of the file.
    /// - parameter contents: The initial `Data` that any newly created file
    ///   should contain. Will only be evaluated if needed.
    /// - throws: `WriteError` if a new file couldn't be created.
    @discardableResult
    func createFileIfNeeded(at path: String,
                            contents: @autoclosure () -> Data? = nil) throws -> File {
        return try (try? file(at: path)) ?? createFile(at: path, contents: contents())
    }

    /// Create a new file with a given name. If a file with the given
    /// name already exists, then it will be returned without modification.
    /// - parameter name: The name of the file.
    /// - parameter contents: The initial `Data` that any newly created file
    ///   should contain. Will only be evaluated if needed.
    /// - throws: `WriteError` if a new file couldn't be created.
    @discardableResult
    func createFileIfNeeded(withName name: String,
                            contents: @autoclosure () -> Data? = nil) throws -> File {
        return try (try? file(named: name)) ?? createFile(named: name, contents: contents())
    }

    /// Return whether this folder contains a given location as a direct child.
    /// - parameter location: The location to find.
    func contains<T: Location>(_ location: T) -> Bool {
        switch T.kind {
        case .file: return containsFile(named: location.name)
        case .folder: return containsSubfolder(named: location.name)
        }
    }

    /// Move the contents of this folder to a new parent
    /// - parameter folder: The new parent folder to move this folder's contents to.
    /// - parameter includeHidden: Whether hidden files should be included (default: `false`).
    /// - throws: `LocationError` if the operation couldn't be completed.
    func moveContents(to folder: Folder, includeHidden: Bool = false) throws {
        var files = self.files
        files.includsHidden = includeHidden
        try files.move(to: folder)

        var folders = subfolders
        folders.includsHidden = includeHidden
        try folders.move(to: folder)
    }

    /// Empty this folder, permanently deleting all of its contents. Use with caution.
    /// - parameter includeHidden: Whether hidden files should also be deleted (default: `false`).
    /// - throws: `LocationError` if the operation couldn't be completed.
    func empty(includingHidden includeHidden: Bool = false) throws {
        var files = self.files
        files.includsHidden = includeHidden
        try files.delete()

        var folders = subfolders
        folders.includsHidden = includeHidden
        try folders.delete()
    }
    
    func isEmpty(includingHidden includeHidden: Bool = false) -> Bool {
        var files = self.files
        files.includsHidden = includeHidden
        
        if files.first != nil {
            return false
        }

        var folders = subfolders
        folders.includsHidden = includeHidden
        return folders.first == nil
    }
}

#if os(iOS) || os(tvOS) || os(macOS)
public extension Folder {
    /// Resolve a folder that matches a search path within a given domain.
    /// - parameter searchPath: The directory path to search for.
    /// - parameter domain: The domain to search in.
    /// - parameter fileManager: Which file manager to search using.
    /// - throws: `LocationError` if no folder could be resolved.
    static func matching(
        _ searchPath: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask = .userDomainMask,
        resolvedBy fileManager: FileManager = .default
    ) throws -> Folder {
        let urls = fileManager.urls(for: searchPath, in: domain)

        guard let match = urls.first else {
            throw LocationError(
                path: "",
                reason: .unresolvedSearchPath(searchPath, domain: domain)
            )
        }

        return try Folder(storage: Storage(
            path: match.relativePath,
            fileManager: fileManager
        ))
    }

    /// The current user's Documents folder
    static var documents: Folder? {
        return try? .matching(.documentDirectory)
    }

    /// The current user's Library folder
    static var library: Folder? {
        return try? .matching(.libraryDirectory)
    }
}
#endif

// MARK: - Errors

/// Error type thrown by all of Files' throwing APIs.
public struct FilesError<Reason>: Error {
    /// The absolute path that the error occured at.
    public var path: String
    /// The reason that the error occured.
    public var reason: Reason

    /// Initialize an instance with a path and a reason.
    /// - parameter path: The absolute path that the error occured at.
    /// - parameter reason: The reason that the error occured.
    public init(path: String, reason: Reason) {
        self.path = path
        self.reason = reason
    }
}

extension FilesError: CustomStringConvertible {
    public var description: String {
        return """
        Files encountered an error at '\(path)'.
        Reason: \(reason)
        """
    }
}

/// Enum listing reasons that a location manipulation could fail.
public enum LocationErrorReason {
    /// The location couldn't be found.
    case missing
    /// An empty path was given when refering to a file.
    case emptyFilePath
    /// The user attempted to rename the file system's root folder.
    case cannotRenameRoot
    /// A rename operation failed with an underlying system error.
    case renameFailed(Error)
    /// A move operation failed with an underlying system error.
    case moveFailed(Error)
    /// A copy operation failed with an underlying system error.
    case copyFailed(Error)
    /// A delete operation failed with an underlying system error.
    case deleteFailed(Error)
    /// A search path couldn't be resolved within a given domain.
    case unresolvedSearchPath(
        FileManager.SearchPathDirectory,
        domain: FileManager.SearchPathDomainMask
    )
}

/// Enum listing reasons that a write operation could fail.
public enum WriteErrorReason {
    /// An empty path was given when writing or creating a location.
    case emptyPath
    /// A folder couldn't be created because of an underlying system error.
    case folderCreationFailed(Error)
    /// A file couldn't be created.
    case fileCreationFailed
    /// A file couldn't be written to because of an underlying system error.
    case writeFailed(Error)
    /// Failed to encode a string into binary data.
    case stringEncodingFailed(String)
}

/// Enum listing reasons that a read operation could fail.
public enum ReadErrorReason {
    /// A file couldn't be read because of an underlying system error.
    case readFailed(Error)
    /// Failed to decode a given set of data into a string.
    case stringDecodingFailed
    /// Encountered a string that doesn't contain an integer.
    case notAnInt(String)
}

/// Error thrown by location operations - such as find, move, copy and delete.
public typealias LocationError = FilesError<LocationErrorReason>
/// Error thrown by write operations - such as file/folder creation.
public typealias WriteError = FilesError<WriteErrorReason>
/// Error thrown by read operations - such as when reading a file's contents.
public typealias ReadError = FilesError<ReadErrorReason>

// MARK: - Private system extensions

private extension FileManager {
    func locationExists(at path: String, kind: LocationKind) -> Bool {
        var isFolder: ObjCBool = false

        guard fileExists(atPath: path, isDirectory: &isFolder) else {
            return false
        }

        switch kind {
        case .file: return !isFolder.boolValue
        case .folder: return isFolder.boolValue
        }
    }
}

private extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    func appendingSuffixIfNeeded(_ suffix: String) -> String {
        guard !hasSuffix(suffix) else { return self }
        return appending(suffix)
    }
}
*/
