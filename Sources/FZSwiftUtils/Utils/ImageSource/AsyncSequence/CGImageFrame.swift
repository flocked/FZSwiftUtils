//
//  CGImageFrame.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public struct CGImageFrame {
    public var image: CGImage
    public var duration: TimeInterval?
    public init(_ image: CGImage, _ duration: TimeInterval?) {
        self.image = image
        self.duration = duration
    }
}

public struct ImageFrame {
    public var image: NSUIImage
    public var duration: TimeInterval?
    public init(_ image: NSUIImage, _ duration: TimeInterval?) {
        self.image = image
        self.duration = duration
    }
}
