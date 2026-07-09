//
//  FinderTags.swift
//  
//
//  Created by Florian Zand on 02.05.26.
//

#if os(macOS)
import AppKit

/// A representation of a Finder tag.
public struct FinderTag: Hashable, CustomStringConvertible {
    /// The name of the Finder Tag.
    public var name: String
    /// he color of the Finder tag.
    public var color: Color = .none
    
    /// Creates a represntation of a Finder tag with the specified name and color.
    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    var rawValue: String {
        "\(name)\n\(color.rawValue)"
    }

    init?(_ rawValue: String) {
        let components = rawValue.split(separator: "\n")
        guard let name = components.first else { return nil }
        self.name = String(name)
        guard components.count > 1, let color = Color(rawValue: Int(components[1]) ?? -1) else { return }
        self.color = color
    }
    
    public var description: String {
        "\(name) (\(color))"
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
    public enum Color: Int, CaseIterable, Hashable, CustomStringConvertible, Codable {
        /// None.
        case none
        /// Gray.
        case gray
        /// Green.
        case green
        /// Purple.
        case purple
        /// Blue.
        case blue
        /// Yellow.
        case yellow
        /// Red.
        case red
        /// Orange.
        case orange
        
        public var description: String {
            switch self {
            case .none: "none"
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
        public var color: NSColor {
            switch self {
                case .none: .clear
                case .gray: .systemGray
                case .green: .systemGreen
                case .purple: .systemPurple
                case .blue: .systemBlue
                case .yellow: .systemYellow
                case .red: .systemRed
                case .orange: .systemOrange
            }
        }
        
        public static let allCases: [Self] = [.none, .red, .orange, .yellow, .green, .blue, .purple, .gray]
    }
}
#endif
