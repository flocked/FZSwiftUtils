//
//  Thread+.swift
//
//
//  Created by Florian Zand on 05.09.26.
//

import Foundation

public extension Thread {
    /// Prints the symbols of the current thread's call stack.
    static func printCallStack() {
        callStackSymbols.printEach()
    }
}

public extension Thread {
    /// A symbolicated frame in a thread's call stack.
    struct StackFrame: CustomStringConvertible, CustomDebugStringConvertible {
        /// The return address represented by the frame.
        public let address: UInt
        /// The path of the image containing the address.
        public let imagePath: String?
        /// The base address at which the image is loaded.
        public let imageBaseAddress: UInt?
        /// The name of the symbol associated with the address.
        public let symbolName: String?
        /// The address of the symbol associated with the frame.
        public let symbolAddress: UInt?
        
        fileprivate var index: Int?
        
        /// The name of the image containing the address.
        public var imageName: String? {
            imagePath.map { ($0 as NSString).lastPathComponent }
        }
        
        private var formattedAddress: String {
            String(format: "0x%016llx", UInt64(address))
        }
        
        private var symbolOffset: UInt {
            symbolAddress.map { address >= $0 ? address - $0 : 0 } ?? 0
        }
        
        public var description: String {
            let frame = "\(imageName ?? "???") \(formattedAddress) \(symbolName ?? "???") + \(symbolOffset)"
            return index.map { "\($0) \(frame)" } ?? frame
        }
        
        public var debugDescription: String {
            guard let index else { return description }
            let indexString = String(index).padding(toMinimumLength: ColumnWidth.index)
            let imageName = (imageName ?? "???").padding(toMinimumLength: ColumnWidth.imageName)
            return "\(indexString)\(imageName)\(formattedAddress) \(symbolName ?? "???") + \(symbolOffset)"
        }
        
        private enum ColumnWidth {
            static let index = 4
            static let imageName = 36
        }
        
        /// Creates a stack frame by resolving symbol information for the specified address.
        public init?(address: UInt) {
            self.init(address)
        }
        
        fileprivate init?(_ address: UInt) {
            guard let pointer = UnsafeRawPointer(bitPattern: address) else { return nil }
            var info = Dl_info()
            guard dladdr(pointer, &info) != 0 else { return nil }
            self.address = address
            self.imagePath = info.dli_fname.map { String(cString: $0) }
            self.imageBaseAddress = info.dli_fbase.map { UInt(bitPattern: $0) }
            self.symbolName = info.dli_sname.map { String(cString: $0) }
            self.symbolAddress = info.dli_saddr.map { UInt(bitPattern: $0) }
        }
    }

    /// The symbolicated frames of the current thread's call stack.
    static var callStack: [StackFrame] {
        var frames = callStackReturnAddresses.dropFirst().compactMap {
            StackFrame($0.uintValue)
        }
        for index in frames.indices {
            frames[index].index = index
        }
        return frames
    }
}
