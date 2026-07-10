//
//  FinderTags.swift
//  
//
//  Created by Florian Zand on 02.05.26.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A representation of a macOS Finder tag.
public struct FinderTag: Hashable, Codable, CustomStringConvertible, Sendable {
    /// The name of the Finder Tag.
    public let name: String
    /// The color of the Finder tag.
    public var color: Color?
    
    /// Creates a representation of a macOS Finder tag with the specified name and color.
    public init(name: String, color: Color?) {
        self.name = name
        self.color = color
    }
    
    init?(_ rawValue: String) {
        let components = rawValue.split(separator: "\n")
        guard let name = components.first else { return nil }
        self.name = String(name)
        self.color = components.count > 1 ? Color(rawValue: Int(components[1]) ?? -1) : nil
    }
    
    var rawValue: String {
        color != nil ? "\(name)\n\(color!.rawValue)" : name
    }
    
    public var description: String {
        color != nil ? "\(name) (\(color!))" : name
    }
    
    /// A Finder tag without color with the specified name.
    public static func uncolored(_ name: String) -> Self {
        .init(name: name, color: .none)
    }
    
    /// A gray Finder tag with the specified name.
    public static func gray(_ name: String) -> Self {
        .init(name: name, color: .gray)
    }
    
    /// A green Finder tag with the specified name.
    public static func green(_ name: String) -> Self {
        .init(name: name, color: .green)
    }
    
    /// A purple Finder tag with the specified name.
    public static func purple(_ name: String) -> Self {
        .init(name: name, color: .purple)
    }
    
    /// A blue Finder tag with the specified name.
    public static func blue(_ name: String) -> Self {
        .init(name: name, color: .blue)
    }
    
    /// A yellow Finder tag with the specified name.
    public static func yellow(_ name: String) -> Self {
        .init(name: name, color: .yellow)
    }
    
    /// A red Finder tag with the specified name.
    public static func red(_ name: String) -> Self {
        .init(name: name, color: .red)
    }
    
    /// An orange Finder tag with the specified name.
    public static func orange(_ name: String) -> Self {
        .init(name: name, color: .orange)
    }
    
    /// The color of a Finder tag.
    public enum Color: Int, CaseIterable, Hashable, CustomStringConvertible, Codable, Sendable {
        /// Gray.
        case gray = 1
        /// Green.
        case green = 2
        /// Purple.
        case purple = 3
        /// Blue.
        case blue = 4
        /// Yellow.
        case yellow = 5
        /// Red.
        case red = 6
        /// Orange.
        case orange = 7
        
        public var description: String {
            switch self {
            case .gray: "gray"
            case .green: "green"
            case .purple: "purple"
            case .blue: "blue"
            case .yellow: "yellow"
            case .red: "red"
            case .orange: "orange"
            }
        }
        
        /// The represented color of the tag.
        public var color: NSUIColor {
            switch self {
                case .gray: .systemGray
                case .green: .systemGreen
                case .purple: .systemPurple
                case .blue: .systemBlue
                case .yellow: .systemYellow
                case .red: .systemRed
                case .orange: .systemOrange
            }
        }
    }
}
