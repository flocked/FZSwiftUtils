//
//  FinderTags.swift
//  
//
//  Created by Florian Zand on 02.05.26.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A representation of a Finder tag.
public struct FinderTag: Hashable, CustomStringConvertible, Codable {
    /// The name of the Finder Tag.
    public var name: String
    /// he color of the Finder tag.
    public var color: Color = .none
    
    /// Creates a represntation of a Finder tag with the specified name and color.
    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }

    init?(string: String) {
        let components = string.split(separator: "\n")
        guard let name = components.first else { return nil }
        self.name = String(name)
        guard components.count > 1, let color = Color(rawValue: Int(components[1]) ?? -1) else { return }
        self.color = color
    }
    
    public var description: String {
        "\(name) (\(color))"
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
