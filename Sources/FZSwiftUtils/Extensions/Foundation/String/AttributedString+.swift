//
//  AttributedString+.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

@available(macOS 12, iOS 15.0, *)
public extension AttributedString {
    func lowercased() -> AttributedString {
        return AttributedString(NSAttributedString(self).lowercased())
    }

    func uppercased() -> AttributedString {
        return AttributedString(NSAttributedString(self).uppercased())
    }

    func capitalized() -> AttributedString {
        return AttributedString(NSAttributedString(self).capitalized())
    }
    
    mutating func editAttributes(_ block: ((inout AttributeContainer)->())) {
        if var attributes = self.runs.first?.attributes {
            block(&attributes)
            self.setAttributes(attributes)
        }
    }
    
    init(_ string: String, _ configure: (inout AttributeContainer) -> Void) {
        var attributes = AttributeContainer()
        configure(&attributes)
        self.init(string, attributes: attributes)
    }
}

@available(macOS 12, iOS 15.0, *)
public extension AttributeContainer {
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

@available(macOS 12, iOS 15.0, *)
public extension AttributedStringProtocol {
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

