//
//  CGImage+.swift
//
//
//  Created by Florian Zand on 30.10.25.
//

#if canImport(CoreGraphic)
import CoreGraphics
import Foundation

extension CGImage {
    /// A Boolean value that determines if the image is lazily loaded.
    public var isLazyLoaded: Bool {
        let description = (CFCopyDescription(self) as String)
        if let match = try? NSRegularExpression(pattern: "\\((IP|DP)\\)")
            .firstMatch(in: description, range: NSRange(description.startIndex..., in: description)) {
            if let range = Range(match.range(at: 1), in: description) {
                let provider = String(description[range])
                switch provider {
                case "IP": return true
                case "DP": return false
                default: break
                }
            }
        }
        return utType != nil
    }
    
    /// A Boolean value that determines if the image has alpha information.
    public var hasAlpha: Bool {
        switch alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast: return false
        default: return true
        }
    }
}

#endif
