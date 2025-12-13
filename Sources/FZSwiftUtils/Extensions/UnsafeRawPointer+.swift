//
//  UnsafeRawPointer+.swift
//
//
//  Created by Florian Zand on 29.11.25.
//

import Foundation

public extension UnsafeRawPointer {
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset from this pointer, in bytes. `offset` must be nonnegative. The default is zero.
     - Returns: A new instance of type `T`, read from the raw bytes at offset. The returned instance is memory-managed and unassociated with the value in the memory referenced by this pointer.
     */
    func load<T>(fromByteOffset offset: Int = 0) -> T {
        load(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.

     - Parameter offset: The offset from this pointer, in bytes. `offset` must be nonnegative. The default is zero.
     - Returns: A new instance of type `T`, read from the raw bytes at offset. The returned instance isn’t associated with the value in the range of memory referenced by this pointer.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.

     - Parameter offset: The offset from this pointer, in bytes. `offset` must be nonnegative. The default is zero.
     - Returns: A new instance of type `T`, read from the raw bytes at offset. The returned instance isn’t associated with the value in the range of memory referenced by this pointer.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T where T : BitwiseCopyable {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
}

public extension UnsafeRawBufferPointer {
    /**
     Returns a new instance of the given type, read from the buffer pointer’s raw memory at the specified byte offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The buffer pointer plus offset must be properly aligned for accessing an instance of type `T`.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func load<T>(fromByteOffset offset: Int = 0) -> T {
        load(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The default is zero.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The default is zero.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T where T : BitwiseCopyable {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
}

public extension UnsafeMutableRawPointer {
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.

     - Parameter offset: The offset from this pointer, in bytes. `offset` must be nonnegative. The default is zero.
     - Returns: A new instance of type `T`, read from the raw bytes at offset. The returned instance is memory-managed and unassociated with the value in the memory referenced by this pointer.
     */
    func load<T>(fromByteOffset offset: Int = 0) -> T {
        load(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset from this pointer, in bytes. `offset` must be nonnegative. The default is zero.
     - Returns: A new instance of type `T`, read from the raw bytes at offset. The returned instance isn’t associated with the value in the range of memory referenced by this pointer.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset from this pointer, in bytes. `offset` must be nonnegative. The default is zero.
     - Returns: A new instance of type `T`, read from the raw bytes at offset. The returned instance isn’t associated with the value in the range of memory referenced by this pointer.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T where T : BitwiseCopyable {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
}

public extension UnsafeMutableRawBufferPointer {
    /**
     Returns a new instance of the given type, read from the buffer pointer’s raw memory at the specified byte offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The buffer pointer plus offset must be properly aligned for accessing an instance of type `T`. The default is zero.
     - Returns: A new instance of type `T` copied from the buffer pointer’s memory.
     */
    func load<T>(fromByteOffset offset: Int = 0) -> T {
        load(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The default is zero.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The default is zero.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T where T : BitwiseCopyable {
        loadUnaligned(fromByteOffset: offset, as: T.self)
    }
}

public extension UnsafeRawPointer {
    func unretained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeUnretainedValue()
    }
    
    func retained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeRetainedValue()
    }
}

public extension UnsafeMutableRawPointer {
    /// Unsafely turns the pointer into the specifed class reference.
    func unretained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeUnretainedValue()
    }
    
    /// Unsafely turns the pointer into the specifed class reference.
    func retained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeRetainedValue()
    }
}

public extension Optional where Wrapped == UnsafeRawPointer {
    /// Unsafely turns the pointer into the specifed class reference.
    func unretained<T: AnyObject>(as type: T.Type = T.self) -> T? {
        optional?.unretained()
    }
    
    /// Unsafely turns the pointer into the specifed class reference.
    func retained<T: AnyObject>(as type: T.Type = T.self) -> T? {
        optional?.retained()
    }
}

public extension Optional where Wrapped == UnsafeMutableRawPointer {
    /// Unsafely turns the pointer into the specifed class reference.
    func unretained<T: AnyObject>(as type: T.Type = T.self) -> T? {
        optional?.unretained()
    }
    
    /// Unsafely turns the pointer into the specifed class reference.
    func retained<T: AnyObject>(as type: T.Type = T.self) -> T? {
        optional?.retained()
    }
}

public extension UnsafeRawPointer {
    /// Unsafely converts a class reference to a pointer.
    init<V: AnyObject>(retained value: V) {
        self.init(Unmanaged.passRetained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    init<V: AnyObject>(unretained value: V) {
        self.init(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    init?<V: AnyObject>(retained value: V?) {
        guard let value = value else { return nil }
        self.init(Unmanaged.passRetained(value).toOpaque())
    }
        
    /// Unsafely converts a class reference to a pointer.
    init?<V: AnyObject>(unretained value: V?) {
        guard let value = value else { return nil }
        self.init(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func unretained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func retained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passRetained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func unretained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { unretained($0) }
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func retained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { retained($0) }
    }
    
    /// Returns a new instance of the given type, constructed from the raw memory at the specified offset.
    func load<T>() -> T {
        load(as: T.self)
    }
}

public extension UnsafeMutableRawPointer {
    /// Unsafely converts a class reference  to a pointer.
    init<V: AnyObject>(retained value: V) {
        self.init(Unmanaged.passRetained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    init<V: AnyObject>(unretained value: V) {
        self.init(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    init?<V: AnyObject>(retained value: V?) {
        guard let value = value else { return nil }
        self.init(Unmanaged.passRetained(value).toOpaque())
    }
        
    /// Unsafely converts a class reference to a pointer.
    init?<V: AnyObject>(unretained value: V?) {
        guard let value = value else { return nil }
        self.init(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func unretained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func retained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passRetained(value).toOpaque())
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func unretained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { unretained($0) }
    }
    
    /// Unsafely converts a class reference to a pointer.
    static func retained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { retained($0) }
    }
    
    /// Returns a new instance of the given type, constructed from the raw memory at the specified offset.
    func load<T>() -> T {
        load(as: T.self)
    }
}


/*

 
 static func unretained<V: AnyObject>(from value: V) -> UnsafeRawPointer {
     UnsafeRawPointer(Unmanaged.passUnretained(value).toOpaque())
 }
 
 static func retained<V: AnyObject>(from value: V) -> UnsafeRawPointer {
     UnsafeRawPointer(Unmanaged.passRetained(value).toOpaque())
 }
 
 static func unretained<V: AnyObject>(from value: V?) -> UnsafeRawPointer? {
     value.map { unretained(from: $0) }
 }
 
 static func retained<V: AnyObject>(from value: V?) -> UnsafeRawPointer? {
     value.map { retained(from: $0) }
 }
 */

/*
public struct JSONValue: ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByNilLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral {
    
   private class Storage {
        var value: Any?
        init(_ value: Any? = nil) {
            self.value = value
        }
    }
    
    private var storage: Storage
    var codingPath: [CodingKey]
    
    public subscript(index: Int) -> Self {
        get { Self(storage: storage, codingPath: codingPath + [.index(index)]) }
    }
    
    public subscript(key: String) -> Self {
        get { Self(storage: storage, codingPath: codingPath + [.key(key)]) }
    }
    
    public var stringValue: String? {
        get { unboxedValue() as? String }
    }
        
    public var intValue: Int? {
        get { unboxedValue() as? Int }
    }
    
    public var doubleValue: Double? {
        get { unboxedValue() as? Double }
    }
    
    public var boolValue: Bool? {
        get { unboxedValue() as? Bool }
    }
    
    public  var arrayValue: [Any]? {
        get { unboxedValue() as? [Any] }
    }
    
    public var dictionaryValue: [String: Any]? {
        get { unboxedValue() as? [String: Any] }
    }
    
    public var isNull: Bool {
        get { unboxedValue() is NSNull }
    }
    
    private init(storage: Storage, codingPath: [CodingKey]) {
        self.storage = storage
        self.codingPath = codingPath
    }
    
    public init(integerLiteral value: Int) {
        self.storage = Storage(value)
        self.codingPath = []
    }
    
    public init(dictionaryLiteral elements: (String, (any JSONSerializable))...) {
        self.storage = Storage(Dictionary(uniqueKeysWithValues: elements))
        codingPath = []
    }
    
    public init(arrayLiteral elements: (any JSONSerializable)...) {
        storage = Storage(elements)
        codingPath = []
    }
    
    public init(booleanLiteral value: Bool) {
        storage = Storage(value)
        codingPath = []
    }
    
    public init(stringLiteral value: String) {
        storage = Storage(value)
        codingPath = []
    }
    
    public init(floatLiteral value: Double) {
        storage = Storage(value)
        codingPath = []
    }
    
    public init(nilLiteral: ()) {
        storage = Storage(NSNull())
        codingPath = []
    }
    
    private func unboxedValue() -> Any? {
        unboxValue(storage.value, codingPath: codingPath)
    }
    
    private func unboxValue(_ value: Any?, codingPath: [CodingKey]) -> Any? {
        guard let value = value else { return nil }
        guard !codingPath.isEmpty else { return value }
        var codingPath = codingPath
        switch codingPath.removeFirst() {
        case .index(let index):
            guard let array = value as? [Any], index < array.count else { return nil }
            return unboxValue(array[index], codingPath: codingPath)
        case .key(let key):
            guard let dic = value as? [String: Any] else { return nil }
            return unboxValue(dic[key], codingPath: codingPath)
        }
    }
    
    public enum CodingKey: Swift.CodingKey {
        case key(String)
        case index(Int)
        
        public var stringValue: String {
            switch self {
            case .key(let key): return key
            case .index(let index): return "[\(index)]"
            }
        }
        
        public var intValue: Int? {
            switch self {
            case .index(let index): return index
            case .key: return nil
            }
        }
        
        public init?(intValue: Int) {
            self = .index(intValue)
        }
        
        public init?(stringValue: String) {
            self = .key(stringValue)
        }
    }
}
*/

import Foundation

// MARK: - JSONCollection Protocol
protocol JSONCollection {
    func value(forKey key: JSONValue.CodingKey) throws -> Any
    func settingValue(_ value: Any?, forKey key: JSONValue.CodingKey) throws -> Any
}

// MARK: - Array Conformance
extension Array: JSONCollection where Element == Any {
    func value(forKey key: JSONValue.CodingKey) throws -> Any {
        switch key {
        case .key:
            throw NSError(domain: "JSONError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access Array with key"])
        case .index(let idx):
            guard indices.contains(idx) else { throw NSError(domain: "JSONError", code: 2, userInfo: nil) }
            return self[idx]
        }
    }
    
    func settingValue(_ value: Any?, forKey key: JSONValue.CodingKey) throws -> Any {
        switch key {
        case .key:
            throw NSError(domain: "JSONError", code: 3, userInfo: nil)
        case .index(let idx):
            guard indices.contains(idx), let v = value else { throw NSError(domain: "JSONError", code: 4, userInfo: nil) }
            var copy = self
            copy[idx] = v
            return copy
        }
    }
}

// MARK: - Dictionary Conformance
extension Dictionary: JSONCollection where Key == String, Value == Any {
    func value(forKey key: JSONValue.CodingKey) throws -> Any {
        switch key {
        case .key(let k):
            guard let v = self[k] else { throw NSError(domain: "JSONError", code: 5, userInfo: nil) }
            return v
        case .index:
            throw NSError(domain: "JSONError", code: 6, userInfo: nil)
        }
    }
    
    func settingValue(_ value: Any?, forKey key: JSONValue.CodingKey) throws -> Any {
        switch key {
        case .key(let k):
            var copy = self
            copy[k] = value
            return copy
        case .index:
            throw NSError(domain: "JSONError", code: 7, userInfo: nil)
        }
    }
}

// MARK: - JSONValue
public struct JSONValue:
    ExpressibleByStringLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByBooleanLiteral
{
    
    // MARK: - Storage
    public final class Storage {
        public var root: Any
        public init(root: Any) { self.root = root }
    }
    
    private var storage: Storage
    private var codingPath: [CodingKey]
    
    // MARK: - Public Initializers
    public init(_ root: Any = [String: Any]()) {
        self.storage = Storage(root: root)
        self.codingPath = []
    }
    
    private init(storage: Storage, codingPath: [CodingKey]) {
        self.storage = storage
        self.codingPath = codingPath
    }
    
    // MARK: - Subscripts
    public subscript(key: String) -> JSONValue {
        get { JSONValue(storage: storage, codingPath: codingPath + [.key(key)]) }
        set { _ = try? self.mutateValue(newValue.storage.root, at: codingPath + [.key(key)]) }
    }
    
    public subscript(index: Int) -> JSONValue {
        get { JSONValue(storage: storage, codingPath: codingPath + [.index(index)]) }
        set { _ = try? self.mutateValue(newValue.storage.root, at: codingPath + [.index(index)]) }
    }
    
    // MARK: - Typed accessors
    public var intValue: Int? {
        get { unboxedValue() as? Int }
        set { _ = try? mutateValue(newValue) }
    }
    
    public var stringValue: String? {
        get { unboxedValue() as? String }
        set { _ = try? mutateValue(newValue) }
    }
    
    public var doubleValue: Double? {
        get { unboxedValue() as? Double }
        set { _ = try? mutateValue(newValue) }
    }
    
    public var boolValue: Bool? {
        get { unboxedValue() as? Bool }
        set { _ = try? mutateValue(newValue) }
    }
    
    public var arrayValue: [Any]? { unboxedValue() as? [Any] }
    public var dictionaryValue: [String: Any]? { unboxedValue() as? [String: Any] }
    public var isNull: Bool { (unboxedValue() as? NSNull) != nil }
    
    // MARK: - Private helpers
    private func unboxedValue() -> Any? {
        JSONValue.valueAt(storage.root, path: codingPath)
    }
    
    private mutating func ensureUnique() {
        
        if !isKnownUniquelyReferenced(&storage) {
            storage = Storage(root: deepCopy(storage.root))
        }
    }
    
    private func deepCopy(_ value: Any) -> Any {
        switch value {
        case let dict as [String: Any]:
            return dict.mapValues { deepCopy($0) }
        case let arr as [Any]:
            return arr.map { deepCopy($0) }
        default:
            return value
        }
    }
    
    // MARK: - Core mutation
    @discardableResult
    private mutating func mutateValue(_ newValue: Any?, at path: [CodingKey]? = nil) throws -> Any? {
        let actualPath = path ?? codingPath
        guard !actualPath.isEmpty else { storage.root = newValue ?? NSNull(); return storage.root }
        ensureUnique()
        let updatedRoot = try applyMutation(storage.root, path: actualPath[...], newValue: newValue)
        storage.root = updatedRoot
        return updatedRoot
    }
    
    private func applyMutation(_ currentValue: Any, path: ArraySlice<CodingKey>, newValue: Any?) throws -> Any {
        var path = path
        guard let head = path.first else { return newValue ?? NSNull() }
        path = path.dropFirst()
        
        guard let collection = currentValue as? JSONCollection else {
            throw NSError(domain: "JSONError", code: 100, userInfo: nil)
        }
        
        if path.isEmpty {
            return try collection.settingValue(newValue, forKey: head)
        } else {
            let child = try collection.value(forKey: head)
            let mutatedChild = try applyMutation(child, path: path, newValue: newValue)
            return try collection.settingValue(mutatedChild, forKey: head)
        }
    }
    
    // MARK: - Static value access
    public static func valueAt(_ root: Any, path: [CodingKey]) -> Any? {
        var node: Any? = root
        for key in path {
            switch (node, key) {
            case (let dict as [String: Any], .key(let k)):
                node = dict[k]
            case (let arr as [Any], .index(let i)):
                guard arr.indices.contains(i) else { return nil }
                node = arr[i]
            default:
                return nil
            }
        }
        return node
    }
    
    // MARK: - CodingKey
    public enum CodingKey: Swift.CodingKey {
        case key(String)
        case index(Int)
        
        public var stringValue: String {
            switch self { case .key(let k): return k; case .index(let i): return "[\(i)]" }
        }
        
        public var intValue: Int? { switch self { case .index(let i): return i; case .key: return nil } }
        
        public init?(stringValue: String) { self = .key(stringValue) }
        public init?(intValue: Int) { self = .index(intValue) }
    }
    
    // MARK: - Literal conformances
    public init(stringLiteral value: String) { self.storage = Storage(root: value); self.codingPath = [] }
    public init(floatLiteral value: Double) { self.storage = Storage(root: value); self.codingPath = [] }
    public init(nilLiteral: ()) { self.storage = Storage(root: NSNull()); self.codingPath = [] }
    public init(arrayLiteral elements: Any...) { self.storage = Storage(root: elements); self.codingPath = [] }
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.storage = Storage(root: Dictionary(uniqueKeysWithValues: elements))
        self.codingPath = []
    }
    public init(integerLiteral value: Int) { self.storage = Storage(root: value); self.codingPath = [] }
    public init(booleanLiteral value: Bool) { self.storage = Storage(root: value); self.codingPath = [] }
}
