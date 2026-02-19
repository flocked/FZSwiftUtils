//
//  ProtocolMethod.swift
//
//
//  Created by Codex on 2/19/26.
//

import Foundation
import _Libffi

private var missingMethodUserData: UInt8 = 0

private func missingMethodCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?,
                                         ret: UnsafeMutableRawPointer?,
                                         args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                                         userdata: UnsafeMutableRawPointer?) {
    guard let cif = cif, let ret = ret else {
        return
    }
    let returnSize = Int(cif.pointee.rtype.pointee.size)
    guard returnSize > 0 else {
        return
    }
    memset(ret, 0, returnSize)
}

private func methodDescriptionWithoutSearchingInheritedProtocols(protocol proto: Protocol, selector: Selector, isInstanceMethod: Bool) -> objc_method_description? {
    let optionalDescription = protocol_getMethodDescription(proto, selector, false, isInstanceMethod)
    if optionalDescription.name != nil, optionalDescription.types != nil {
        return optionalDescription
    }
    let requiredDescription = protocol_getMethodDescription(proto, selector, true, isInstanceMethod)
    if requiredDescription.name != nil, requiredDescription.types != nil {
        return requiredDescription
    }
    return nil
}

private func methodDescription(protocol proto: Protocol, selector: Selector, isInstanceMethod: Bool) -> objc_method_description? {
    if let description = methodDescriptionWithoutSearchingInheritedProtocols(protocol: proto, selector: selector, isInstanceMethod: isInstanceMethod) {
        return description
    }
    var protocolsCount: UInt32 = 0
    guard let protocolsPointer = protocol_copyProtocolList(proto, &protocolsCount) else {
        return nil
    }
    defer {
        free(UnsafeMutableRawPointer(protocolsPointer))
    }
    let protocolsBuffer = UnsafeBufferPointer(start: protocolsPointer, count: Int(protocolsCount))
    for inheritedProtocol in protocolsBuffer {
        if let description = methodDescription(protocol: inheritedProtocol, selector: selector, isInstanceMethod: isInstanceMethod) {
            return description
        }
    }
    return nil
}

private func addProtocolAndInheritedProtocols(_ proto: Protocol, result: inout [Protocol], includedProtocolNames: inout Set<String>) {
    let protocolName = NSStringFromProtocol(proto)
    guard !includedProtocolNames.contains(protocolName) else {
        return
    }
    includedProtocolNames.insert(protocolName)
    result.append(proto)
    var protocolsCount: UInt32 = 0
    guard let protocolsPointer = protocol_copyProtocolList(proto, &protocolsCount) else {
        return
    }
    defer {
        free(UnsafeMutableRawPointer(protocolsPointer))
    }
    let protocolsBuffer = UnsafeBufferPointer(start: protocolsPointer, count: Int(protocolsCount))
    for inheritedProtocol in protocolsBuffer {
        addProtocolAndInheritedProtocols(inheritedProtocol, result: &result, includedProtocolNames: &includedProtocolNames)
    }
}

private func classForProtocolDiscovery(_ targetClass: AnyClass, _ isInstanceMethod: Bool) -> AnyClass? {
    if isInstanceMethod {
        return targetClass
    }
    guard class_isMetaClass(targetClass) else {
        return targetClass
    }
    return NSClassFromString(NSStringFromClass(targetClass))
}

private func protocolsRecursivelyAdoptedByClassHierarchy(targetClass: AnyClass, isInstanceMethod: Bool) -> [Protocol] {
    guard let lookupClass = classForProtocolDiscovery(targetClass, isInstanceMethod) else {
        return []
    }
    var result: [Protocol] = []
    var includedProtocolNames = Set<String>()
    var currentClass: AnyClass? = lookupClass
    while let cls = currentClass {
        var protocolsCount: UInt32 = 0
        if let protocolsPointer = class_copyProtocolList(cls, &protocolsCount) {
            let protocolsBuffer = UnsafeBufferPointer(start: protocolsPointer, count: Int(protocolsCount))
            for proto in protocolsBuffer {
                addProtocolAndInheritedProtocols(proto, result: &result, includedProtocolNames: &includedProtocolNames)
            }
            free(UnsafeMutableRawPointer(protocolsPointer))
        }
        currentClass = class_getSuperclass(cls)
    }
    return result
}

func inferProtocolForMethod(targetClass: AnyClass, selector: Selector, isInstanceMethod: Bool) throws -> Protocol? {
    let allProtocols = protocolsRecursivelyAdoptedByClassHierarchy(targetClass: targetClass, isInstanceMethod: isInstanceMethod)
    var protocolBySignature = [String: Protocol]()
    for proto in allProtocols {
        guard let description = methodDescriptionWithoutSearchingInheritedProtocols(protocol: proto, selector: selector, isInstanceMethod: isInstanceMethod),
              let types = description.types else {
            continue
        }
        let signature = String(cString: types)
        if protocolBySignature[signature] == nil {
            protocolBySignature[signature] = proto
        }
    }
    if protocolBySignature.isEmpty {
        return nil
    }
    if protocolBySignature.count == 1 {
        return protocolBySignature.first!.value
    }
    let protocolsDescription = protocolBySignature.map {
        "\"\(NSStringFromProtocol($0.value))\" => \($0.key)"
    }.sorted().joined(separator: ", ")
    throw HookError.inferredProtocolMethodAmbiguous("Auto-discovery found multiple protocol signatures for selector `\(NSStringFromSelector(selector))`: \(protocolsDescription).")
}

func methodSignatureForProtocol(_ protocolType: Protocol, selector: Selector, isInstanceMethod: Bool) throws -> Signature {
    guard let description = methodDescription(protocol: protocolType, selector: selector, isInstanceMethod: isInstanceMethod),
          let types = description.types else {
        throw HookError.noRespondSelector
    }
    return try Signature(typeEncoding: types)
}

func typeEncodingForProtocolMethod(_ protocolType: Protocol, selector: Selector, isInstanceMethod: Bool) throws -> String {
    guard let description = methodDescription(protocol: protocolType, selector: selector, isInstanceMethod: isInstanceMethod),
          let types = description.types else {
        throw HookError.noRespondSelector
    }
    return String(cString: types)
}

private var protocolMethodContextPool = Set<ProtocolMethodContext>()

private class ProtocolMethodContext: Hashable {
    fileprivate let targetClass: AnyClass
    fileprivate let selector: Selector
    fileprivate let methodCifContext: FFICIFContext
    fileprivate let methodClosureContext: FFIClosureContext
    
    init(targetClass: AnyClass, selector: Selector, protocolType: Protocol, isInstanceMethod: Bool) throws {
        guard let description = methodDescription(protocol: protocolType, selector: selector, isInstanceMethod: isInstanceMethod),
              let types = description.types else {
            throw HookError.noRespondSelector
        }
        let signature = try Signature(typeEncoding: types)
        self.targetClass = targetClass
        self.selector = selector
        self.methodCifContext = try FFICIFContext(signature: signature)
        self.methodClosureContext = try FFIClosureContext(cif: self.methodCifContext.cif,
                                                          userData: &missingMethodUserData,
                                                          fun: missingMethodCalledFunction)
        guard class_addMethod(targetClass, selector, self.methodClosureContext.targetIMP, types) else {
            throw HookError.internalError(file: #file, line: #line)
        }
    }
    
    static func == (lhs: ProtocolMethodContext, rhs: ProtocolMethodContext) -> Bool {
        lhs.targetClass == rhs.targetClass && lhs.selector == rhs.selector
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(targetClass))
        hasher.combine(selector)
    }
}

func addProtocolMethodIfNeeded(targetClass: AnyClass, selector: Selector, protocolType: Protocol, isInstanceMethod: Bool) throws {
    guard class_getInstanceMethod(targetClass, selector) == nil else {
        return
    }
    let context = try ProtocolMethodContext(targetClass: targetClass,
                                            selector: selector,
                                            protocolType: protocolType,
                                            isInstanceMethod: isInstanceMethod)
    protocolMethodContextPool.insert(context)
}
