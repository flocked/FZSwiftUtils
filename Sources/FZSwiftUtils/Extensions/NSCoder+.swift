//
//  NSCoder+.swift
//
//
//  Created by Florian Zand on 28.02.25.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSCoder {
    /// Decodes and returns a `NSDirectionalEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsets(forKey key: String) -> NSDirectionalEdgeInsets? {
        decodeObject(of: NSValue.self, forKey: key)?.directionalEdgeInsetsValue
    }
    
    /// Decodes and returns a `CGAffineTransform` value that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransform(forKey key: String) -> CGAffineTransform? {
        decodeObject(of: NSValue.self, forKey: key)?.cgAffineTransformValue
    }
    
    /// Decodes and returns a `CATransform3D` value that was previously encoded with `encode(_:)`.
    func decodeCATransform3D(forKey key: String) -> CATransform3D? {
        decodeObject(of: NSValue.self, forKey: key)?.caTransform3DValue
    }
    
    /// Decodes and returns a `NSRange` value that was previously encoded with `encode(_:)`.
    func decodeRange(forKey key: String) -> NSRange? {
        decodeObject(of: NSValue.self, forKey: key)?.rangeValue
    }
    
    #if os(macOS)
    /// Decodes and returns a `NSEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> NSEdgeInsets? {
        decodeObject(of: NSValue.self, forKey: key)?.edgeInsetsValue
    }
    #elseif canImport(UIKit)
    /// Decodes and returns a `NSEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeCGVector(forKey key: String) -> CGVector? {
        decodeObject(of: NSValue.self, forKey: key)?.cgVectorValue
    }
    #endif
    
    /// Encodes the specified `NSDirectionalEdgeInsets`.
    func encode(_ directionalEdgeInsets: NSDirectionalEdgeInsets, forKey key: String) {
        encode(NSValue(directionalEdgeInsets: directionalEdgeInsets), forKey: key)
    }
    
    /// Encodes the specified `CGAffineTransform`.
    func encode(_ cgAffineTransform: CGAffineTransform, forKey key: String) {
        encode(NSValue(cgAffineTransform: cgAffineTransform), forKey: key)
    }
    
    /// Encodes the specified `CATransform3D`.
    func encode(_ caTransform3D: CATransform3D, forKey key: String) {
        encode(NSValue(caTransform3D: caTransform3D), forKey: key)
    }
    
    /// Encodes the specified `NSRange`.
    func encode(_ range: NSRange, forKey key: String) {
        encode(NSValue(range: range), forKey: key)
    }
    
    #if os(macOS)
    /// Encodes the specified `NSEdgeInsets`.
    func encode(_ edgeInsets: NSEdgeInsets, forKey key: String) {
        encode(NSValue(edgeInsets: edgeInsets), forKey: key)
    }
    #elseif canImport(UIKit)
    /// Encodes the specified `NSEdgeInsets`.
    func encode(_ edgeInsets: UIEdgeInsets, forKey key: String) {
        encode(NSValue(uiEdgeInsets: edgeInsets), forKey: key)
    }
    
    /// Encodes the specified `CATransform3D`.
    func encode(_ cgVector: CGVector, forKey key: String) {
        encode(NSValue(cgVector: cgVector), forKey: key)
    }
    #endif
}
