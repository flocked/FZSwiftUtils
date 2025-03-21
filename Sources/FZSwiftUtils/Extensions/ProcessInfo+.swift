//
//  ProcessInfo+.swift
//
//
//  Created by Florian Zand on 21.03.25.
//

#if os(macOS)
import Foundation

extension ProcessInfo {
    /// The hardware model identifier (e.g., "Mac14,3") for the current Mac.
    public var hardwareModel: String? {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        guard size > 0 else { return nil }

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)

        return String(cString: model)
    }
}

#endif
