//
//  CGImageFrame.swift
//  FZExtensions
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public struct CGImageFrame {
    var image: CGImage
    var duration: TimeInterval
    init(_ image: CGImage, _ duration: TimeInterval) {
        self.image = image
        self.duration = duration
    }
}

public struct ImageFrame {
    var image: NSUIImage
    var duration: TimeInterval
    init(_ image: NSUIImage, _ duration: TimeInterval) {
        self.image = image
        self.duration = duration
    }
}
