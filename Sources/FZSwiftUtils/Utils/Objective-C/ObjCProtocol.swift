//
//  ObjCProtocol.swift
//  
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

extension Protocol {
    /// The name of the protocol.
    public var name: String {
        ObjCRuntime.name(for: self)
    }
    
    /// Returns all classes impelementing the protocol.
    public func conformingClasses() -> [AnyClass] {
        ObjCRuntime.classes(implementing: self)
    }
    
    /// Returns a the protocol with the specfiiec name.
    public static func named(_ name: String) -> Protocol? {
        NSProtocolFromString(name)
    }
    
    public func containsSelector(_ selector: Selector) -> Bool {
        if protocol_getMethodDescription(self, selector, true, true).name != nil || protocol_getMethodDescription(self, selector, false, true).name != nil {
            return true
        }
        var protocolCount: UInt32 = 0
        guard let superProtocols = protocol_copyProtocolList(self, &protocolCount) else { return false }
        if (0..<Int(protocolCount)).contains(where: { superProtocols[$0].containsSelector(selector) }) {
            return true
        }
        return false
    }
    
    /// Returns all protocols this protocol conforms to, recursively including inherited protocols. Each protocol appears only once.
    public func protocols() -> [Protocol] {
        var seen = Set<String>()
        var result = [Protocol]()
        
        func collect(_ proto: Protocol) {
            let name = String(cString: protocol_getName(proto))
            guard !seen.contains(name) else { return }
            seen.insert(name)
            result.append(proto)
            
            // Get immediate protocols this protocol conforms to
            var count: UInt32 = 0
            if let inherited = protocol_copyProtocolList(proto, &count) {
                for i in 0..<Int(count) {
                    collect(inherited[i])  // Recursive call
                }
            }
        }
        collect(self)
        return result
    }

    public func methodDescription(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) -> objc_method_description? {
        if let description = methodDescriptionWithoutSearchingInheritedProtocols(for: selector, isInstanceMethod: isInstanceMethod, optionalOnly: optionalOnly) {
            return description
        }
        var protocolsCount: UInt32 = 0
        guard let protocolsPointer = protocol_copyProtocolList(self, &protocolsCount) else {
            return nil
        }
        defer {
            free(UnsafeMutableRawPointer(protocolsPointer))
        }
        for inheritedProtocol in protocolsPointer.buffer(count: protocolsCount) {
            if let description = inheritedProtocol.methodDescription(for: selector, isInstanceMethod: isInstanceMethod) {
                return description
            }
        }
        return nil
    }
    
    public func methodTypeEncoding(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) -> String? {
        methodDescription(for: selector, isInstanceMethod: isInstanceMethod, optionalOnly: optionalOnly)?.types?.string
    }
    
    public func methodSignature(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) throws -> Signature {
        guard let types = methodDescription(for: selector, isInstanceMethod: isInstanceMethod, optionalOnly: optionalOnly)?.types else {
            throw HookError.noRespondSelector
        }
        return try Signature(typeEncoding: types)
    }
    
    func methodDescriptionWithoutSearchingInheritedProtocols(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) -> objc_method_description? {
        let optionalDescription = protocol_getMethodDescription(self, selector, false, isInstanceMethod)
        if optionalDescription.name != nil, optionalDescription.types != nil {
            return optionalDescription
        }
        guard !optionalOnly else { return nil }
        let requiredDescription = protocol_getMethodDescription(self, selector, true, isInstanceMethod)
        if requiredDescription.name != nil, requiredDescription.types != nil {
            return requiredDescription
        }
        return nil
    }
}
