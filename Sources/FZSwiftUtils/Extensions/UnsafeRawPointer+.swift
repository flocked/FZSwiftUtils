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
    /**
      Returns the object stored at this pointer **without modifying its retain count**.
     
      - Parameter type: The type of the object to retrieve.
      - Returns: The object referenced by this pointer.
     
      - Note: The caller does **not** take ownership of the object. The object must remain alive while it is used.
      - Warning: The pointer must point to a valid object of the specified type. Using an incorrect type will result in undefined behavior.
     */
    func unretained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeUnretainedValue()
    }
    
    /**
      Returns the object stored at this pointer and **consumes a retain count**.
     
      - Parameter type: The type of the object to retrieve.
      - Returns: The object referenced by this pointer.
     
      - Note: This method balances a previous `passRetained` call. After this call, the caller owns the object and is responsible for ARC management.
      - Warning: The pointer must point to a previously retained object of the specified type. Using an incorrect type or calling more than once will result in undefined behavior.
     */
    func retained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeRetainedValue()
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    init<V: AnyObject>(retained value: V) {
        self.init(Unmanaged.passRetained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    init<V: AnyObject>(unretained value: V) {
        self.init(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    init?<V: AnyObject>(retained value: V?) {
        guard let value = value else { return nil }
        self.init(Unmanaged.passRetained(value).toOpaque())
    }
        
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    init?<V: AnyObject>(unretained value: V?) {
        guard let value = value else { return nil }
        self.init(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    static func unretained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    static func retained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passRetained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    static func unretained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { unretained($0) }
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    static func retained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { retained($0) }
    }
    
    /**
      Releases a previously retained object stored at this pointer.
     
      The pointer **must** point to an object retained with `Unmanaged.passRetained(_:)`. Releasing more than once or using the wrong type is **undefined behavior**.
     
      - Parameter type: The type of the retained object.
     */
    func release<V: AnyObject>(of type: V.Type) {
        Unmanaged<V>.fromOpaque(self).release()
    }
}

public extension UnsafeMutableRawPointer {
    /**
      Returns the object stored at this pointer **without modifying its retain count**.
     
      - Parameter type: The type of the object to retrieve.
      - Returns: The object referenced by this pointer.
     
      - Note: The caller does **not** take ownership of the object. The object must remain alive while it is used.
      - Warning: The pointer must point to a valid object of the specified type. Using an incorrect type will result in undefined behavior.
     */
    func unretained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeUnretainedValue()
    }
    
    /**
      Returns the object stored at this pointer and **consumes a retain count**.
     
      - Parameter type: The type of the object to retrieve.
      - Returns: The object referenced by this pointer.
     
      - Note: This method balances a previous `passRetained` call. After this call, the caller owns the object and is responsible for ARC management.
      - Warning: The pointer must point to a previously retained object of the specified type. Using an incorrect type or calling more than once will result in undefined behavior.
     */
    func retained<T: AnyObject>(as type: T.Type = T.self) -> T {
        Unmanaged<T>.fromOpaque(self).takeRetainedValue()
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    init<V: AnyObject>(retained value: V) {
        self = Unmanaged.passRetained(value).toOpaque()
    }
    
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    init<V: AnyObject>(unretained value: V) {
        self = Unmanaged.passUnretained(value).toOpaque()
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    init?<V: AnyObject>(retained value: V?) {
        guard let value = value else { return nil }
        self = Unmanaged.passRetained(value).toOpaque()
    }
        
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    init?<V: AnyObject>(unretained value: V?) {
        guard let value = value else { return nil }
        self = Unmanaged.passUnretained(value).toOpaque()
    }
    
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    static func unretained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passUnretained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    static func retained<V: AnyObject>(_ value: V) -> Self {
        Self(Unmanaged.passRetained(value).toOpaque())
    }
    
    /**
      Creates a new raw pointer from the specified class reference without performing an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The object must remain alive for the lifetime of the pointer.
     */
    static func unretained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { Self(Unmanaged.passUnretained($0).toOpaque()) }
    }
    
    /**
      Creates a new raw pointer from the specified class reference with an unbalanced retain.
     
      - Parameter value: A class instance.
      - Note: The caller is responsible for releasing the object using `Unmanaged.fromOpaque(ptr).release()`.
     */
    static func retained<V: AnyObject>(_ value: V?) -> Self? {
        value.map { Self(Unmanaged.passRetained($0).toOpaque()) }
    }
    
    /**
      Releases a previously retained object stored at this pointer.
     
      The pointer **must** point to an object retained with `Unmanaged.passRetained(_:)`. Releasing more than once or using the wrong type is **undefined behavior**.
     
      - Parameter type: The type of the retained object.
     */
    func release<V: AnyObject>(of type: V.Type) {
        Unmanaged<V>.fromOpaque(self).release()
    }
}
