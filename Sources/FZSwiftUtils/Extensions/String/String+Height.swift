//
//  String+Height.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension String {
    /**
     Calculates the height of the string with the given constrained width and font.

     - Parameters:
        - width: The width constraint for the string.
        - font: The font used for rendering the string.

     - Returns: The calculated height of the string.
     */
    func height(withConstrainedWidth width: CGFloat, font: NSUIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    /**
     Calculates the width of the string with the given constrained height and font.

     - Parameters:
        - height: The height constraint for the string.
        - font: The font used for rendering the string.

     - Returns: The calculated width of the string.
     */
    func width(withConstrainedHeight height: CGFloat, font: NSUIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

public extension NSAttributedString {
    /**
     Calculates the height of the attributed string with the given constrained width.

     - Parameters:
        - width: The width constraint for the attributed string.

     - Returns: The calculated height of the attributed string.
     */
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.height)
    }

    /**
     Calculates the width of the attributed string with the given constrained height.

     - Parameters:
        - height: The height constraint for the attributed string.

     - Returns: The calculated width of the attributed string.
     */
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.width)
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension AttributedString {
    /**
     Calculates the height of the attributed string with the given constrained width.

     - Parameters:
        - width: The width constraint for the attributed string.

     - Returns: The calculated height of the attributed string.
     */
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let nsAttributedString = NSAttributedString(self)
        return nsAttributedString.height(withConstrainedWidth: width)
    }
    
    /**
     Calculates the height of the attributed string with the given constrained width.

     - Parameters:
        - width: The width constraint for the attributed string.

     - Returns: The calculated height of the attributed string.
     */
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let nsAttributedString = NSAttributedString(self)
        return nsAttributedString.width(withConstrainedHeight: height)
    }
}

#if os(macOS)
import AppKit

public extension String {
    /**
     Calculates the height of the string with the given constrained width, font, maximum number of lines and line break mode.

     - Parameters:
        - width: The width constraint for the string.
        - font: The font used for rendering the string.
        - maxNumberOfLines: The maximum number of lines.
        - lineBreakMode:The line break mode.

     - Returns: The calculated height of the string.
     */
    func height(withConstrainedWidth width: CGFloat, font: NSUIFont, maxNumberOfLines: Int, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        let textField = NSTextField.forCalculatingSize(width: width, font: font, maxNumberOfLines: maxNumberOfLines, lineBreakMode: lineBreakMode)
            textField.stringValue = self
            textField.invalidateIntrinsicContentSize()
            return textField.intrinsicContentSize.height
        }
}

public extension NSAttributedString {
    /**
     Calculates the height of the attributed string with the given constrained width, font, maximum number of lines and line break mode.

     - Parameters:
        - width: The width constraint for the attributed string.
        - font: The font used for rendering the attributed string.
        - maxNumberOfLines: The maximum number of lines.
        - lineBreakMode:The line break mode.

     - Returns: The calculated height of the attributed string.
     */
    func height(withConstrainedWidth width: CGFloat, font: NSUIFont, maxNumberOfLines: Int, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        let textField = NSTextField.forCalculatingSize(width: width, font: font, maxNumberOfLines: maxNumberOfLines, lineBreakMode: lineBreakMode)
        textField.attributedStringValue = self
        textField.invalidateIntrinsicContentSize()
        return textField.intrinsicContentSize.height
    }
}

fileprivate extension NSTextField {
    static func forCalculatingSize(width: CGFloat, font: NSFont?, maxNumberOfLines: Int = 0, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> NSTextField {
        let textField = NSTextField()
        textField.preferredMaxLayoutWidth = width
        textField.font = font
        textField.usesSingleLineMode = false
        textField.maximumNumberOfLines = maxNumberOfLines
        textField.invalidateIntrinsicContentSize()
        textField.lineBreakMode = lineBreakMode
        textField.cell?.wraps = true
        textField.cell?.truncatesLastVisibleLine = true
        textField.cell?.isScrollable = false
        textField.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
        return textField
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit

public extension String {
    /**
     Calculates the height of the string with the given constrained width, font, maximum number of lines and line break mode.

     - Parameters:
        - width: The width constraint for the string.
        - font: The font used for rendering the string.
        - maxNumberOfLines: The maximum number of lines.
        - lineBreakMode:The line break mode.

     - Returns: The calculated height of the string.
     */
    func height(withConstrainedWidth width: CGFloat, font: NSUIFont, maxNumberOfLines: Int, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        let textField = UILabel()
        textField.font = font
        textField.text = self
        textField.lineBreakMode = lineBreakMode

        let rect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        let textRect = textField.textRect(forBounds: rect, limitedToNumberOfLines: maxNumberOfLines)
        return textRect.height
    }
}

public extension NSAttributedString {
    /**
     Calculates the height of the string with the given constrained width, maximum number of lines and line break mode.

     - Parameters:
        - width: The width constraint for the string.
        - maxNumberOfLines: The maximum number of lines.
        - lineBreakMode:The line break mode.

     - Returns: The calculated height of the string.
     */
    func height(withConstrainedWidth width: CGFloat, maxNumberOfLines: Int, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        let textField = UILabel()
        textField.attributedText = self
        textField.lineBreakMode = lineBreakMode
        let rect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        let textRect = textField.textRect(forBounds: rect, limitedToNumberOfLines: maxNumberOfLines)
        return textRect.height
    }
}
#endif
