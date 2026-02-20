//
//  ProtocolMethod.swift
//
//
//  Created by Codex on 2/19/26.
//

import Foundation
import _Libffi

private var missingMethodUserData: UInt8 = 0

private func missingMethodCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?, ret: UnsafeMutableRawPointer?, args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, userdata: UnsafeMutableRawPointer?) {
    guard let cif = cif, let ret = ret else {
        return
    }
    let returnSize = Int(cif.pointee.rtype.pointee.size)
    guard returnSize > 0 else {
        return
    }
    memset(ret, 0, returnSize)
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
    for inheritedProtocol in protocolsPointer.buffer(count: protocolsCount) {
        addProtocolAndInheritedProtocols(inheritedProtocol, result: &result, includedProtocolNames: &includedProtocolNames)
    }
}

private var protocolMethodContextPool = Set<ProtocolMethodContext>()

private class ProtocolMethodContext: Hashable {
    fileprivate let targetClass: AnyClass
    fileprivate let selector: Selector
    fileprivate let methodCifContext: FFICIFContext
    fileprivate let methodClosureContext: FFIClosureContext
    
    init(targetClass: AnyClass, selector: Selector, protocolType: Protocol, isInstanceMethod: Bool) throws {
        guard let description = protocolType.methodDescription(for: selector, isInstanceMethod: isInstanceMethod), let types = description.types else {
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

final class ProtocolMethodImplementation {
    fileprivate let methodCifContext: FFICIFContext
    fileprivate let methodClosureContext: FFIClosureContext
    
    var targetIMP: IMP {
        methodClosureContext.targetIMP
    }
    
    init(typeEncoding: UnsafePointer<CChar>) throws {
        let signature = try Signature(typeEncoding: typeEncoding)
        self.methodCifContext = try FFICIFContext(signature: signature)
        self.methodClosureContext = try FFIClosureContext(cif: self.methodCifContext.cif,
                                                          userData: &missingMethodUserData,
                                                          fun: missingMethodCalledFunction)
    }
}

func makeProtocolMethodImplementation(protocolType: Protocol, selector: Selector, isInstanceMethod: Bool) throws -> ProtocolMethodImplementation {
    guard let description = protocolType.methodDescription(for: selector, isInstanceMethod: isInstanceMethod),
          let types = description.types else {
        throw HookError.noRespondSelector
    }
    return try ProtocolMethodImplementation(typeEncoding: types)
}

func addProtocolMethodIfNeeded(targetClass: AnyClass, selector: Selector, protocolType: Protocol, isInstanceMethod: Bool) throws {
    guard class_getInstanceMethod(targetClass, selector) == nil else {
        return
    }
    let context = try ProtocolMethodContext(targetClass: targetClass, selector: selector, protocolType: protocolType, isInstanceMethod: isInstanceMethod)
    protocolMethodContextPool.insert(context)
}
