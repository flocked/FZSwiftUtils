//
//  String+Height.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)
    import AppKit

    public extension String {
        func height(using width: CGFloat, font: NSFont, maxLines: Int? = nil) -> CGFloat {
            let textField = NSTextField()
            textField.preferredMaxLayoutWidth = width
            textField.font = font
            textField.stringValue = self
            textField.textLayout = .truncates
            textField.usesSingleLineMode = true
            textField.maximumNumberOfLines = 1
            if let maxLines = maxLines {
                if maxLines > 1 {
                    textField.usesSingleLineMode = false
                    textField.maximumNumberOfLines = maxLines
                    textField.textLayout = .wraps
                }
            }
            textField.invalidateIntrinsicContentSize()
            return textField.intrinsicContentSize.height
        }
    }

    public extension NSAttributedString {
        func height(using width: CGFloat, maxLines: Int? = nil) -> CGFloat {
            let textField = NSTextField()
            textField.preferredMaxLayoutWidth = width
            textField.attributedStringValue = self
            textField.textLayout = .truncates
            textField.usesSingleLineMode = true
            textField.maximumNumberOfLines = 1
            if let maxLines = maxLines {
                if maxLines > 1 {
                    textField.usesSingleLineMode = false
                    textField.maximumNumberOfLines = maxLines
                    textField.textLayout = .wraps
                }
            }

            textField.invalidateIntrinsicContentSize()
            return textField.intrinsicContentSize.height
        }
    }

    fileprivate extension NSTextField {
        var textLayout: TextLayout? {
            get {
                switch (lineBreakMode, cell?.wraps, cell?.isScrollable) {
                case (.byWordWrapping, true, false):
                    return .wraps
                case (.byTruncatingTail, false, false):
                    return .truncates
                case (.byClipping, false, true):
                    return .scrolls
                default:
                    return nil
                }
            }
            set {
                if let newValue = newValue {
                    lineBreakMode = newValue.lineBreakMode
                    usesSingleLineMode = false
                    cell?.wraps = newValue.wraps
                    truncatesLastVisibleLine = true
                    cell?.isScrollable = newValue.isScrollable
                    setContentCompressionResistancePriority(newValue.layoutPriority, for: .horizontal)
                }
            }
        }

        var truncatesLastVisibleLine: Bool {
            get { cell?.truncatesLastVisibleLine ?? false }
            set { cell?.truncatesLastVisibleLine = newValue }
        }

        enum TextLayout: Int, CaseIterable {
            case truncates = 0
            case wraps = 1
            case scrolls = 2

            public init?(lineBreakMode: NSLineBreakMode) {
                guard let found = Self.allCases.first(where: { $0.lineBreakMode == lineBreakMode }) else { return nil }
                self = found
            }

            internal var isScrollable: Bool {
                return (self == .scrolls)
            }

            internal var wraps: Bool {
                return (self == .wraps)
            }

            internal var layoutPriority: NSLayoutConstraint.Priority {
                return (self == .wraps) ? .fittingSizeCompression : .defaultLow
            }

            internal var lineBreakMode: NSLineBreakMode {
                switch self {
                case .wraps:
                    return .byWordWrapping
                case .truncates:
                    return .byTruncatingTail
                case .scrolls:
                    return .byClipping
                }
            }
        }
    }

#elseif canImport(UIKit)
    import UIKit

    public extension String {
        func height(using width: CGFloat, font: UIFont, maxLines: Int? = nil) -> CGFloat {
            let textField = UILabel()
            textField.font = font
            textField.text = self

            var numberOfLines = 1
            if let maxLines = maxLines, maxLines > 1 {
                numberOfLines = maxLines
            }

            let rect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
            let textRect = textField.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
            return textRect.height
        }
    }

    public extension NSAttributedString {
        func height(using width: CGFloat, maxLines: Int? = nil) -> CGFloat {
            let textField = UILabel()
            textField.attributedText = self

            var numberOfLines = 1
            if let maxLines = maxLines, maxLines > 1 {
                numberOfLines = maxLines
            }

            let rect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
            let textRect = textField.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
            return textRect.height
        }
    }
#endif
