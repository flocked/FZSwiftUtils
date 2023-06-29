//
//  AttributedString+.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension AttributedString {
    /**
     Initializes an AttributedString object with a string and custom attributes.

     - Parameters:
        - string: The string value for the AttributedString.
        - configure: A closure used to configure the attributes of the attributed string.

     Use this initializer to conveniently create an AttributedString object with custom attributes applied to the provided string.
     */
    init(_ string: String, _ configure: (inout AttributeContainer) -> Void) {
        var attributes = AttributeContainer()
        configure(&attributes)
        self.init(string, attributes: attributes)
    }
    
    var nsAttributedString: NSAttributedString {
        NSAttributedString(self)
    }
    
    /**
     Returns a lowercase version of the attributed string.

     - Returns: A lowercase copy of the attributed string.
     */
    func lowercased() -> AttributedString {
        return AttributedString(NSAttributedString(self).lowercased())
    }

    /**
     Returns a uppercase version of the attributed string.

     - Returns: A uppercase copy of the attributed string.
     */
    func uppercased() -> AttributedString {
        return AttributedString(NSAttributedString(self).uppercased())
    }

    /**
     Returns a capitalized version of the attributed string.

     - Returns: A capitalized copy of the attributed string.
     */
    func capitalized() -> AttributedString {
        return AttributedString(NSAttributedString(self).capitalized())
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension AttributeContainer {
    /**
     The URL associated with an underlined link attribute in the AttributeContainer.

     Modifying the underlinedLink property will update the link and underlineStyle properties of the AttributeContainer.
     */
    var underlinedLink: URL? {
          get {
              self.link
          }
          set {
              if let newValue = newValue {
                  self.link = newValue
                  self.underlineStyle = .single
              } else {
                  self.link = nil
                  self.underlineStyle = nil
              }
          }
      }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension AttributedStringProtocol {
    /**
     The URL associated with an underlined link attribute in an attributed string..

     Modifying the underlinedLink property will update the link and underlineStyle properties of the attributed string.
     */
    var underlinedLink: URL? {
          get {
              self.link
          }
          set {
              if let newValue = newValue {
                  self.link = newValue
                  self.underlineStyle = .single
              } else {
                  self.link = nil
                  self.underlineStyle = nil
              }
          }
      }
  }

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension Collection where Element == AttributedString {
    /**
     Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
     - Parameters separator: An attributed string to insert between each of the elements in this sequence.
     - Returns: A single, concatenated attributed string.
     */
    func joined(separator: AttributedString) -> AttributedString {
        guard let firstElement = first else { return AttributedString("") }
        return dropFirst().reduce(into: firstElement) { result, element in
            result.append(separator)
            result.append(element)
        }
    }

    /**
     Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
     - Parameters separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
     - Returns: A single, concatenated attributed string.
     */
    func joined(separator: String = "") -> AttributedString {
        guard let firstElement = first else { return AttributedString("") }
        return dropFirst().reduce(into: firstElement) { result, element in
            result.append(AttributedString(separator))
            result.append(element)
        }
    }
}
