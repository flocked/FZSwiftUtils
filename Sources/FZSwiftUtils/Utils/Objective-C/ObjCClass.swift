//
//  ObjCClass.swift
//
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

/// An Objective-C class.
public struct ObjCClass: Hashable {
    /// The class.
    public let cls: AnyClass
    private let id: ObjectIdentifier
    
    static var names: [Self: String] = [:]
    
    public init(_ class: AnyClass) {
        self.cls = `class`
        self.id = ObjectIdentifier(`class`)
    }
    
    public init?(_ className: String) {
        guard let cls = NSClassFromString(className) else { return nil }
        self.init(cls)
    }
    
    /// The name of the class.
    public var name: String {
        class_getName(cls).string
    }
    
    /// The version of the class.
    public var version: Int32 {
        class_getVersion(cls)
    }
    
    public static func version(_ cls: AnyClass) -> Int32 {
        class_getVersion(cls)
    }
    
    public static func name(_ cls: AnyClass) -> String {
        class_getName(cls).string
    }
    
    /// The size of an instance of the class.
    public var instanceSize: Int {
        class_getInstanceSize(cls)
    }
    
    /// The path of the dynamic library / framework the class originated from.
    public var imagePath: String? {
        class_getImageName(cls)?.string
    }
    
    /// The superclass of the class.
    public var superclass: Self? {
        _superclass.map(Self.init)
    }
    
    var _superclass: AnyClass? {
        class_getSuperclass(cls)
    }
    
    /// The root superclass of the class.
    public var rootSuperclass: Self? {
        superclasses.last
    }
    
    /// Returns all superclasses of the class.
    public var superclasses: [Self] {
        Array(first: superclass, next: \.superclass)
    }
    
    /// The subclasses of the class.
    public var subclasses: [Self] {
        subclasses(includeNested: false)
    }
    
    /**
     Returns the subclasses of the class.
     
     - Parameter includeNested: A Boolean value indicating whether to include nested subclasses.
     */
    public func subclasses(includeNested: Bool) -> [ObjCClass] {
        ObjCRuntime.subclasses(of: cls, includeNested: includeNested).map(ObjCClass.init)
    }
    
    /// A Boolean value indicating whether the class is a subclass of the specified other class.
    public func isSubclass(of class: AnyClass) -> Bool {
        ObjCRuntime.addressToSkip.contains(name) ? false : cls.isSubclass(of: `class`)
    }
    
    /// A Boolean value indicating whether the class is a superclass of the specified other class.
    public func isSuperclass(of class: AnyClass) -> Bool {
        `class`.isSubclass(of: cls)
    }
    
    /// A Boolean value indicating whether the class is a meta class.
    public var isMetaClass: Bool {
        skipMetaClass ? false : class_isMetaClass(cls)
    }
    
    /// The meta class for the class.
    public var metaClass: Self? {
        _metaclass.map(Self.init)
    }
    
    var _metaclass: AnyClass? {
        guard !skipMetaClass else { return nil }
        return class_isMetaClass(cls) ? cls : object_getClass(cls)
    }
    
    /// The instance methods of the class.
    public var methods: [ObjCMethod] {
        methods(includeSuperclasses: false)
    }
    
    /**
     Returns the instance methods of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance methods declared by the superclasses.
     */
    public func methods(includeSuperclasses: Bool) -> [ObjCMethod] {
        if !includeSuperclasses {
            return BufferCollection({ class_copyMethodList(cls, $0) }).map(ObjCMethod.init)
        }
        var seen: Set<Selector> = []
        return classes(includeSuperclasses).flatMap({ cls in BufferCollection { class_copyMethodList(cls, $0) }.compactMap({ seen.insert(method_getName($0)).inserted ? ObjCMethod($0) : nil }) })
    }
    
    /// The class methods of the class.
    public var classMethods: [ObjCMethod] {
        classMethods(includeSuperclasses: false)
    }
    
    /**
     Returns the class methods of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class methods declared by the superclasses.
     */
    public func classMethods(includeSuperclasses: Bool) -> [ObjCMethod] {
        metaClass?.methods(includeSuperclasses: includeSuperclasses) ?? []
    }
    
    private var skipMetaClass: Bool {
        ObjCRuntime.classNamesToSkip.contains(name)
    }
    
    /// The instance properties of the class.
    public var properties: [ObjCProperty] {
        properties(includeSuperclasses: false)
    }
    
    /**
     Returns the instance properties of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance properties declared by the superclasses.
     */
    public func properties(includeSuperclasses: Bool) -> [ObjCProperty] {
        if !includeSuperclasses {
            return BufferCollection({ class_copyPropertyList(cls, $0) }).map(ObjCProperty.init)
        }
        var seen: Set<String> = []
        return classes(includeSuperclasses).flatMap({ cls in BufferCollection { class_copyPropertyList(cls, $0) }.compactMap({ seen.insert(property_getName($0).string).inserted ? ObjCProperty($0) : nil }) })
    }
    
    /// The class properties of the class.
    public var classProperties: [ObjCProperty] {
        classProperties(includeSuperclasses: false)
    }
    
    /**
     Returns the class properties of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class properties declared by the superclasses.
     */
    public func classProperties(includeSuperclasses: Bool) -> [ObjCProperty] {
        metaClass?.properties(includeSuperclasses: includeSuperclasses) ?? []
    }
    
    /// The instance variables of the class.
    public var ivars: [ObjCIvar] {
        ivars(includeSuperclasses: false)
    }
    
    /**
     Returns the instance variables of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance variables declared by the superclasses.
     */
    public func ivars(includeSuperclasses: Bool) -> [ObjCIvar] {
        if !includeSuperclasses {
           return BufferCollection { class_copyIvarList(cls, $0) }.map(ObjCIvar.init)
        }
        var seen: Set<String> = []
        return classes(includeSuperclasses).flatMap({ cls in BufferCollection { class_copyIvarList(cls, $0) }.compactMap({ seen.insert(ivar_getName($0)?.string ?? "").inserted ? ObjCIvar($0) : nil }) })
    }
    
    /// The protocols the class conforms to.
    public var protocols: [Protocol] {
        protocols(includeSuperclasses: false)
    }
    
    /**
     Returns the protocols the class conforms to.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols that the superclasses are conforming to.
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.
     */
    public func protocols(includeSuperclasses: Bool, includeInheritedProtocols: Bool = false) -> [Protocol] {
        if !includeSuperclasses, !includeInheritedProtocols {
            return BufferCollection({ class_copyProtocolList(cls, $0) }).collect()
        }
        var visited = Set<ObjectIdentifier>()
        var protocols: [Protocol] = []
        func visit(_ proto: Protocol) {
            guard visited.insert(proto).inserted else { return }
            protocols.append(proto)
            guard includeInheritedProtocols else { return }
            BufferCollection({ protocol_copyProtocolList(proto, $0) }).forEach(visit)
        }
        for cls in classes(includeSuperclasses) {
            BufferCollection({ class_copyProtocolList(cls, $0) }).forEach(visit)
        }
        return protocols
    }
    
    private func classes(_ includeSuperclasses: Bool) -> [AnyClass] {
        return includeSuperclasses ? Array(first: cls, next: { class_getSuperclass($0) }) : [cls]
    }
    
    /// A Boolean value indicating whether the class conforms to the specified protocol.
    public func conforms(to protocol: Protocol) -> Bool {
        class_conformsToProtocol(cls, `protocol`)
    }
    
    /// Returns a Boolean value indicating whether instances of this class respond to the specified selector.
    public func responds(to selector: Selector) -> Bool {
        class_respondsToSelector(cls, selector)
    }
    
    /// Returns a Boolean value indicating whether the class responds to the specified selector.
    public func classResponds(to selector: Selector) -> Bool {
        class_respondsToSelector(_metaclass, selector)
    }
    
    /// Returns the instance property of the class with the specified name.
    public func property(named name: String, declaredOnly: Bool = false) -> ObjCProperty? {
        declaredOnly ? properties.first(where: {$0.name == name }) : class_getProperty(cls, name).map(ObjCProperty.init)
    }
    
    /// Returns the class property of the class with the specified name.
    public func classProperty(named name: String, declaredOnly: Bool = false) -> ObjCProperty? {
        declaredOnly ? classProperties.first(where: { $0.name == name }) : class_getProperty(_metaclass, name).map(ObjCProperty.init)
    }
    
    /// Returns the instance variable of the class with the specified name.
    public func variable(named name: String) -> ObjCIvar? {
        class_getInstanceVariable(cls, name).map(ObjCIvar.init)
    }
    
    /**
     Returns the instance method of the class corresponding to the specified selector.
     
     - Parameters:
        - selector: The selector identifying the method.
        - declaredOnly: If `true`, only methods declared directly by this class are considered; otherwise, methods declared by superclasses are also considered.
     - Returns: The matching instance method, or `nil` if no such method exists.
     */
    public func method(for selector: Selector, declaredOnly: Bool = false) -> ObjCMethod? {
        declaredOnly ? methods.first(where: { $0.name == selector }) : class_getInstanceMethod(cls, selector).map(ObjCMethod.init)
    }
    
    /**
     Returns the class method of the class corresponding to the specified selector.
     
     - Parameters:
        - selector: The selector identifying the method.
        - declaredOnly: If `true`, only methods declared directly by this class are considered; otherwise, methods declared by superclasses are also considered.
     - Returns: The matching class method, or `nil` if no such method exists.
     */
    public func classMethod(for selector: Selector, declaredOnly: Bool = false) -> ObjCMethod? {
        return declaredOnly ? classMethods.first(where: { $0.name == selector }) : class_getClassMethod(cls, selector).map(ObjCMethod.init)
    }
    
    private func declaredMethod(for cls: AnyClass?, _ selector: Selector) -> Method? {
        guard let cls = cls else { return nil }
        return BufferCollection({ class_copyMethodList(cls, $0)  }).first(where: { method_getName($0) == selector })
    }
    
    /**
     Returns the implementation pointer for the instance method corresponding to the specified selector.
     
     - Parameter selector: The selector identifying the instance method.
     - Returns: The implementation pointer (`IMP`) that would be invoked if the selector were sent to an instance of this class, or `nil` if no implementation can be resolved.
     */
    public func methodImplementation(for selector: Selector) -> IMP? {
        class_getMethodImplementation(cls, selector)
    }
    
    /**
     Returns the implementation pointer for the class method corresponding to the specified selector.
     
     - Parameter selector: The selector identifying the class method.
     - Returns: The implementation pointer (`IMP`) that would be invoked if the selector were sent to the class object itself, or nil if no implementation can be resolved.
     */
    public func classMethodImplementation(for selector: Selector) -> IMP? {
        class_getMethodImplementation(_metaclass, selector)
    }
    
    /// Returns a Boolean value indicating whether this class overrides the specified instance method.
    public func overrides(_ selector: Selector) -> Bool {
        guard declaredMethod(for: cls, selector) != nil, let _superclass else { return false }
        return class_getInstanceMethod(_superclass, selector) != nil
    }
    
    /// Returns a Boolean value indicating whether this class overrides the specified class method.
    public func classOverrides(_ selector: Selector) -> Bool {
        guard !skipMetaClass, declaredMethod(for: _metaclass, selector) != nil, let _superclass else { return false }
        return class_getClassMethod(_superclass, selector) != nil
    }
    
    func `protocol`(for selector: Selector, isInstanceMethod: Bool) throws -> Protocol? {
        var protocolBySignature: [String: Protocol] = [:]
        for proto in  protocols(for: isInstanceMethod ? cls : _metaclass) {
            
            guard let typeEncoding = try? proto.methodTypeEncoding(for: selector, isInstance: isInstanceMethod) else { continue }
            if protocolBySignature[typeEncoding] == nil {
                protocolBySignature[typeEncoding] = proto
            }
        }
        if protocolBySignature.isEmpty {
            return nil
        }
        if protocolBySignature.count == 1 {
            return protocolBySignature.first?.value
        }
        let signatures = protocolBySignature.map { "\"\($0.value.name)\" => \($0.key)"
        }.sorted().joined(separator: ", ")
        throw HookError.inferredProtocolMethodAmbiguous("Found multiple protocol signatures for selector `\(selector.string)`: \(signatures).")
    }
    
    private func protocols(for cls: AnyClass?) -> [Protocol] {
        guard let cls = cls else { return [] }
        return (cls == self.cls ? self : ObjCClass(cls)).protocols(includeSuperclasses: true, includeInheritedProtocols: true)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

public extension Sequence {
    func map<T, V: Hashable>(_ transform: (Element) throws -> T, uniquedBy keyForValue: (Element) -> V) rethrows -> [T] {
        try compactMap(transform, uniquedBy: keyForValue)
    }

    func map<T, V: Hashable>(_ transform: (Element) throws -> T, uniquedBy keyForValue: (T) -> V) rethrows -> [T] {
        try compactMap(transform, uniquedBy: keyForValue)
    }

    func map<T: Hashable>(unique transform: (Element) throws -> T) rethrows -> [T] {
        try map(transform, uniquedBy: { $0 })
    }

    func compactMap<T, V: Hashable>(_ transform: (Element) throws -> T?, uniquedBy keyForValue: (Element) -> V) rethrows -> [T] {
        var seen: Set<V> = []
        return try compactMap {
            seen.insert(keyForValue($0)).inserted ? try transform($0) : nil
        }
    }

    func compactMap<T, V: Hashable>(_ transform: (Element) throws -> T?, uniquedBy keyForValue: (T) -> V) rethrows -> [T] {
        var seen: Set<V> = []
        return try compactMap {
            guard let result = try transform($0) else { return nil }
            return seen.insert(keyForValue(result)).inserted ? result : nil
        }
    }

    func compactMap<T: Hashable>(unique transform: (Element) throws -> T?) rethrows -> [T] {
        try compactMap(transform, uniquedBy: { $0 })
    }
}

public extension Sequence {
    func map<T, V: Equatable>(_ transform: (Element) throws -> T, uniquedBy keyForValue: (T) -> V) rethrows -> [T] {
        try compactMap(transform, uniquedBy: keyForValue)
    }

    func map<T, V: Equatable>(_ transform: (Element) throws -> T, uniquedBy keyForValue: (Element) -> V) rethrows -> [T] {
        try compactMap(transform, uniquedBy: keyForValue)
    }

    func map<T: Equatable>(unique transform: (Element) throws -> T) rethrows -> [T] {
        try map(transform, uniquedBy: { $0 })
    }

    func compactMap<T, V: Equatable>(_ transform: (Element) throws -> T?, uniquedBy keyForValue: (T) -> V) rethrows -> [T] {
        var seen: [V] = []
        return try compactMap {
            guard let result = try transform($0) else { return nil }
            let key = keyForValue(result)
            guard !seen.contains(key) else { return nil }
            seen.append(key)
            return result
        }
    }

    func compactMap<T: Equatable>(unique transform: (Element) throws -> T?) rethrows -> [T] {
        try compactMap(transform, uniquedBy: { $0 })
    }

    func compactMap<T, V: Equatable>(_ transform: (Element) throws -> T?, uniquedBy keyForValue: (Element) -> V) rethrows -> [T] {
        var seen: [V] = []
        return try compactMap {
            let key = keyForValue($0)
            guard !seen.contains(key) else { return nil }
            seen.append(key)
            return try transform($0)
        }
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    /// Inserts the given element into the collection if an equal element isn't already present.
    @discardableResult
    mutating func insert(_ newElement: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let index = firstIndex(of: newElement) {
            return (false, self[index])
        }
        append(newElement)
        return (true, newElement)
    }
    
    
    @discardableResult
    mutating func update(_ newElement: Element, at index: Index) -> (updated: Bool, old: Element?) {
        if let old = self[safe: index] {
            guard old != newElement else { return (false, old) }
            replaceSubrange(index...index, with: CollectionOfOne(newElement))
            return (true, old)
        }
        guard index == endIndex else { return (false, nil) }
        insert(newElement, at: index)
        return (true, nil)
    }
}

public extension RangeReplaceableCollection where Element: Hashable {
    /// Inserts the given element into the collection if an equal element isn't already present.
    @discardableResult
    mutating func insert(_ newElement: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let index = firstIndex(of: newElement) {
            return (false, self[index])
        }
        append(newElement)
        return (true, newElement)
    }
    
    /// Inserts the given element at the specified position if an equal element isn't already present.
    @discardableResult
    @_disfavoredOverload
    mutating func insert(_ newElement: Element, at index: Index) -> (inserted: Bool, memberAfterInsert: Element) {
        if let old = self[safe: index] {
            return (false, old)
        }
        insert(newElement, at: index)
        return (true, newElement)
    }
}

public extension RangeReplaceableCollection {
    /// Replaces the specified subrange with the given element and returns the replaced elements, or `nil` if the subrange is invalid.
    @_disfavoredOverload
    mutating func replaceSubrange<C: Collection<Element>>(_ subrange: ClosedRange<Index>, with newElements: C) -> [Element]? {
        guard let old: [Element] = self[safe: subrange] else { return nil }
        replaceSubrange(subrange, with: newElements)
        return old
    }
    
    /// Replaces the specified subrange with the given element and returns the replaced elements, or `nil` if the subrange is invalid.
    @discardableResult
    mutating func replaceSubrange(_ subrange: ClosedRange<Index>, with newElement: Element) -> [Element]? {
        replaceSubrange(subrange, with: CollectionOfOne(newElement))
    }
    
    /// Replaces the specified subrange with the given element and returns the replaced elements, or `nil` if the element is `nil` or the subrange is invalid.
    @discardableResult
    mutating func replaceSubrange(_ subrange: ClosedRange<Index>, with newElement: Element?) -> [Element]? {
        guard let newElement else { return nil }
        return replaceSubrange(subrange, with: newElement)
    }
    
    /// Replaces the element at the specified index with the given elements and returns the replaced element, or `nil` if the index is invalid.
    @discardableResult
    mutating func replace<C: Collection<Element>>(at index: Index, with newElements: C) -> Element? {
        guard let old = self[safe: index] else { return nil }
        replaceSubrange(index...index, with: newElements)
        return old
    }
    
    /// Replaces the element at the specified index with the given element and returns the replaced element, or `nil` if the index is invalid.
    @discardableResult
    mutating func replace(at index: Index, with newElement: Element) -> Element? {
        replace(at: index, with: CollectionOfOne(newElement))
    }
    
    /// Replaces the element at the specified index with the given element and returns the replaced element, or `nil` if the element is `nil` or the index is invalid.
    @discardableResult
    mutating func replace(at index: Index, with newElement: Element?) -> Element? {
        guard let newElement else { return nil }
        return replace(at: index, with: newElement)
    }
}
