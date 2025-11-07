//
//  NSAttributedString+Values.swift
//
//
//  Created by Florian Zand on 11.08.25.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSAttributedString {
    /**
     Creates an attributed string with the specified text and attributes.
     
     Returns an attributed string initialized with the characters of `string` and the attributes `attributes`.
     
     - Parameters:
     - string: The text for the new attributed string.
     - attributes: The attributes for the new attributed string. This method applies the attributes to the entire string.
     
     */
    public convenience init(string: String, attributes: (AttributeValues)->()) {
        let values = AttributeValues()
        values.dic = [:]
        attributes(values)
        self.init(string: string, attributes: values.dic)
    }
    
    
    /// The values of the attributed string.
    public var values: AttributeValues {
        .init(for: self)
    }
    
    /// The values of the attributed string at the specified range.
    public func values(for range: NSRange) -> AttributeValues {
        .init(for: self, range: range)
    }
    
    /// Attribute values of a attributed string.
    public class AttributeValues {
        weak var attributedString: NSAttributedString?
        var dic: [Key: Any]? = nil
        let _range: NSRange?
        
        /// The range of the attribute values.
        public var range: NSRange {
            _range ?? attributedString?.fullRange ?? .zero
        }
        
        init(for attributedString: NSAttributedString? = nil, range: NSRange? = nil) {
            self.attributedString = attributedString
            self._range = range
            let range = _range ?? attributedString?.fullRange ?? .zero
            guard let paragraphStyle = attributedString?.attribute(.paragraphStyle, at: range.location, effectiveRange: nil) as? NSParagraphStyle else { return }
            self.paragraphStyle = ParagraphStyle(style: paragraphStyle)
        }
        
        /// Returns the value for the specified attribute.
        public subscript <V>(attributeName: Key) -> V? {
            get { dic?[attributeName] as? V ?? attributedString?.attribute(attributeName, at: range.location, effectiveRange: nil) as? V }
            set {
                if dic != nil {
                    dic?[attributeName] = newValue
                } else if let attributedString = attributedString as? NSMutableAttributedString {
                    attributedString.setAttribute(attributeName, to: newValue, at: range)
                }
            }
        }
        
        /// Returns the value for the specified attribute.
        public subscript <V>(attributeName: Key) -> V? where V: RawRepresentable {
            get {
                guard let rawValue = attributedString?.attribute(attributeName, at: range.location, effectiveRange: nil) as? V.RawValue else { return nil }
                return V(rawValue: rawValue)
            }
            set {
                guard let attributedString = attributedString as? NSMutableAttributedString else { return }
                attributedString.setAttribute(attributeName, to: newValue?.rawValue, at: range)
            }
        }
        
        // MARK: - Standard Attributes
        
        /// The color of the background behind the text.
        public var backgroundColor: NSUIColor? {
            get { self[.backgroundColor] }
            set { self[.backgroundColor] = newValue }
        }
        
        /// The vertical offset for the position of the text.
        public var baselineOffset: CGFloat? {
            get { self[.baselineOffset] }
            set { self[.baselineOffset] = newValue }
        }
        
        /// The font of the text.
        public var font: NSUIFont? {
            get { self[.font] }
            set { self[.font] = newValue }
        }
        
        /// The color of the text.
        public var foregroundColor: NSUIColor? {
            get { self[.foregroundColor] }
            set { self[.foregroundColor] = newValue }
        }
        
        /// The kerning of the text.
        public var kern: CGFloat? {
            get { self[.kern] }
            set { self[.kern] = newValue }
        }
        
        /// The ligature of the text.
        public var ligature: Int? {
            get { self[.ligature] }
            set { self[.ligature] = newValue }
        }
        
        /// The paragraph style of the text.
        public var paragraphStyle: ParagraphStyle? {
            didSet { _paragraphStyle = paragraphStyle?.nsParagraphStyle() }
        }
        
        private var _paragraphStyle: NSParagraphStyle? {
            get { self[.paragraphStyle] }
            set { self[.paragraphStyle] = newValue }
        }
        
        /// The color of the strikethrough.
        public var strikethroughColor: NSUIColor? {
            get { self[.strikethroughColor] }
            set { self[.strikethroughColor] = newValue }
        }
        
        /// The strikethrough style of the text.
        public var strikethroughStyle: NSUnderlineStyle? {
            get { self[.strikethroughStyle] }
            set { self[.strikethroughStyle] = newValue }
        }
        
        /// The color of the stroke.
        public var strokeColor: NSUIColor? {
            get { self[.strokeColor] }
            set { self[.strokeColor] = newValue }
        }
        
        /// The width of the stroke.
        public var strokeWidth: CGFloat? {
            get { self[.strokeWidth] }
            set { self[.strokeWidth] = newValue }
        }
        
        /// The amount to modify the default tracking.
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public var tracking: CGFloat? {
            get { self[.tracking] }
            set { self[.tracking] = newValue }
        }
        
        /// The color of the underline.
        public var underlineColor: NSUIColor? {
            get { self[.underlineColor] }
            set { self[.underlineColor] = newValue }
        }
        
        /// The underline style of the text.
        public var underlineStyle: NSUnderlineStyle? {
            get { self[.underlineStyle] }
            set { self[.underlineStyle] = newValue }
        }
        
        /// Constants that specify the writing direction.
        public enum WritingDirection: Int {
            /// Left to right and text is embedded in text with another writing direction.
            case leftToRightmbedding
            /// Right to left and text is embedded in text with another writing direction.
            case rightToLeftEmbedding
            /// Left to right and rnables character types with inherent directionality to be overridden when required for special cases, such as for part numbers made of mixed English, digits, and Hebrew letters to be written from right to left.
            case leftToRightOverride
            /// Right to left and rnables character types with inherent directionality to be overridden when required for special cases, such as for part numbers made of mixed English, digits, and Hebrew letters to be written from right to left.
            case rightToLeftOverride
        }
        
        /// The writing direction of the text.
        public var writingDirection: [WritingDirection]? {
            get { self[.writingDirection] }
            set { self[.writingDirection] = newValue }
        }
        
        #if os(macOS)
        /// The name of a glyph info object.
        public var glyphInfo: NSGlyphInfo? {
            get { self[.glyphInfo] }
            set { self[.glyphInfo] = newValue }
        }

        /// The superscript of the text.
        public var superscript: Int? {
            get { self[.superscript] }
            set { self[.superscript] = newValue }
        }
        #endif
        
        // MARK: - Additional Attributes
        
        /// The link for the text.
        public var link: Any? {
            get { self[.link] }
            set { self[.link] = newValue }
        }
        
        /// The replacement position associated with a format string specifier.
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var replacementIndex: Int? {
            get { self[.replacementIndex] }
            set { self[.replacementIndex] = newValue }
        }
        
        /// The shadow of the text.
        public var shadow: NSShadow? {
            get { self[.shadow] }
            set { self[.shadow] = newValue }
        }
        
        /// An attribute that applies a text effect to the text.
        public var textEffect: TextEffectStyle? {
            get { self[.textEffect] }
            set { self[.textEffect] = newValue }
        }
        
        #if compiler(>=6.0)
        /// The custom highlight color to apply to the text.
        @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
        public var textHighlightColorScheme: TextHighlightColorScheme? {
            get { self[.textHighlightColorScheme] }
            set { self[.textHighlightColorScheme] = newValue }
        }
        
        /// An attribute that adds a highlight color to the text to emphasize it.
        @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
        public var textHighlightStyle: TextHighlightStyle? {
            get { self[.textHighlightStyle] }
            set { self[.textHighlightStyle] = newValue }
        }
        #endif
        
        #if os(iOS)
        /// The name of a custom tag associated with a text item.
        @available(iOS 17.0, *)
        public var textItemTag: String? {
            get { self[.textItemTag] }
            set { self[.textItemTag] = newValue }
        }
        #endif
        
        #if os(macOS)
        /// The tooltip text.
        public var toolTip: String? {
            get { self[.toolTip] }
            set { self[.toolTip] = newValue }
        }
        
        /// The cursor object.
        public var cursor: NSCursor? {
            get { self[.cursor] }
            set { self[.cursor] = newValue }
        }

        /// The index of the marked clause segment.
        public var markedClauseSegment: Int? {
            get { self[.markedClauseSegment] }
            set { self[.markedClauseSegment] = newValue }
        }

        /// The spelling state of the text.
        public var spellingState: SpellingState? {
            get { self[.spellingState] }
            set { self[.spellingState] = newValue }
        }

        /// The alternatives for the text.
        public var textAlternatives: NSTextAlternatives? {
            get { self[.textAlternatives] }
            set { self[.textAlternatives] = newValue }
        }
        #endif
        
        #if os(macOS) || os(iOS)
        /// A highlight associated with a Spotlight suggestion.
        @available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
        public var suggestionHighlight: String? {
            get { self[.suggestionHighlight] }
            set { self[.suggestionHighlight] = newValue }
        }
        #endif
        
        // MARK: - Attachment
        
        #if compiler(>=6.0)
        /// The adaptive image glyph for the text.
        @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
        public var adaptiveImageGlyph: NSAdaptiveImageGlyph? {
            get { self[.adaptiveImageGlyph] }
            set { self[.adaptiveImageGlyph] = newValue }
        }
        #endif
        
        /// The attachment for the text.
        public var attachment: NSTextAttachment? {
            get { self[.attachment] }
            set { self[.attachment] = newValue }
        }
        
        // MARK: - Accessibility
        
        #if os(macOS)
        /// Text alignment for accessibility.
        public var accessibilityAlignment: Any? {
            get { self[.accessibilityAlignment] }
            set { self[.accessibilityAlignment] = newValue }
        }
        
        /// Accessibility annotation text attribute.
        public var accessibilityAnnotationTextAttribute: Any? {
            get { self[.accessibilityAnnotationTextAttribute] }
            set { self[.accessibilityAnnotationTextAttribute] = newValue }
        }
        
        /// Accessibility attachment.
        public var accessibilityAttachment: Any? {
            get { self[.accessibilityAttachment] }
            set { self[.accessibilityAttachment] = newValue }
        }
        
        /// Autocorrected text (NSNumber as a Boolean value).
        public var accessibilityAutocorrected: Bool? {
            get { self[.accessibilityAutocorrected] }
            set { self[.accessibilityAutocorrected] = newValue }
        }
        
        /// Text background color (CGColorRef).
        public var accessibilityBackgroundColor: CGColor? {
            get { self[.accessibilityBackgroundColor] }
            set { self[.accessibilityBackgroundColor] = newValue }
        }
        
        /// A key for specifying custom text for accessibility.
        public var accessibilityCustomText: Any? {
            get { self[.accessibilityCustomText] }
            set { self[.accessibilityCustomText] = newValue }
        }
         
        /// Font keys for accessibility (NSDictionary).
        public var accessibilityFont: NSDictionary? {
            get { self[.accessibilityFont] }
            set { self[.accessibilityFont] = newValue }
        }
         
        /// Text foreground color for accessibility (CGColorRef).
        public var accessibilityForegroundColor: CGColor? {
            get { self[.accessibilityForegroundColor] }
            set { self[.accessibilityForegroundColor] = newValue }
        }
         
        /// The accessibility language of the text.
        public var accessibilityLanguage: String? {
            get { self[.accessibilityLanguage] }
            set { self[.accessibilityLanguage] = newValue }
        }
         
        /// Text link for accessibility (id).
        public var accessibilityLink: Any? {
            get { self[.accessibilityLink] }
            set { self[.accessibilityLink] = newValue }
        }
         
        /// The list item index for accessibility.
        public var accessibilityListItemIndex: Int? {
            get { self[.accessibilityListItemIndex] }
            set { self[.accessibilityListItemIndex] = newValue }
        }
         
        /// The list item level for accessibility.
        public var accessibilityListItemLevel: Int? {
            get { self[.accessibilityListItemLevel] }
            set { self[.accessibilityListItemLevel] = newValue }
        }
         
        /// The list item prefix for accessibility.
        public var accessibilityListItemPrefix: String? {
            get { self[.accessibilityListItemPrefix] }
            set { self[.accessibilityListItemPrefix] = newValue }
        }
         
        /// Misspelled text that is visibly marked as misspelled (NSNumber as a Boolean value).
        public var accessibilityMarkedMisspelled: Bool? {
            get { self[.accessibilityMarkedMisspelled] }
            set { self[.accessibilityMarkedMisspelled] = newValue }
        }
         
        /// Misspelled text that isn’t necessarily visibly marked as misspelled (NSNumber as a Boolean value).
        public var accessibilityMisspelled: Bool? {
            get { self[.accessibilityMisspelled] }
            set { self[.accessibilityMisspelled] = newValue }
        }
         
        /// Text shadow for accessibility (NSNumber as a Boolean value).
        public var accessibilityShadow: Bool? {
            get { self[.accessibilityShadow] }
            set { self[.accessibilityShadow] = newValue }
        }
        #endif
         
        #if os(iOS) || os(tvOS) || os(watchOS)
        /// The speech announcement priority for accessibility.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechAnnouncementPriority: Any? {
            get { self[.accessibilitySpeechAnnouncementPriority] }
            set { self[.accessibilitySpeechAnnouncementPriority] = newValue }
        }
         
        /// The pronunciation of a specific word or phrase, such as a proper name.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechIPANotation: String? {
            get { self[.accessibilitySpeechIPANotation] }
            set { self[.accessibilitySpeechIPANotation] = newValue }
        }
         
        /// The language to use when speaking a string.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechLanguage: String? {
            get { self[.accessibilitySpeechLanguage] }
            set { self[.accessibilitySpeechLanguage] = newValue }
        }
         
        /// The pitch to apply to spoken content.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechPitch: CGFloat? {
            get { self[.accessibilitySpeechPitch] }
            set { self[.accessibilitySpeechPitch] = newValue }
        }
         
        /// Whether to speak punctuation.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechPunctuation: Bool? {
            get { self[.accessibilitySpeechPunctuation] }
            set { self[.accessibilitySpeechPunctuation] = newValue }
        }
         
        /// Whether to queue an announcement behind existing speech or to interrupt it.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechQueueAnnouncement: Bool? {
            get { self[.accessibilitySpeechQueueAnnouncement] }
            set { self[.accessibilitySpeechQueueAnnouncement] = newValue }
        }
         
        /// Whether to spell out the text during speech.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var accessibilitySpeechSpellOut: Any? {
            get { self[.accessibilitySpeechSpellOut] }
            set { self[.accessibilitySpeechSpellOut] = newValue }
        }
         
        /// A key for specifying custom attributes to apply to the text.
        public var accessibilityTextCustom: [String]? {
            get { self[.accessibilityTextCustom] }
            set { self[.accessibilityTextCustom] = newValue }
        }
         
        /// A key for specifying the heading level of the text.
        public var accessibilityTextHeadingLevel: Int? {
            get { self[.accessibilityTextHeadingLevel] }
            set { self[.accessibilityTextHeadingLevel] = newValue }
        }
        #endif
        
        #if os(macOS)
        /// Text strikethrough for accessibility (NSNumber as a Boolean value).
        public var accessibilityStrikethrough: Bool? {
            get { self[.accessibilityStrikethrough] }
            set { self[.accessibilityStrikethrough] = newValue }
        }
         
        /// Text strikethrough color for accessibility (CGColorRef).
        public var accessibilityStrikethroughColor: CGColor? {
            get { self[.accessibilityStrikethroughColor] }
            set { self[.accessibilityStrikethroughColor] = newValue }
        }
         
        /// Text superscript style for accessibility (NSNumber).
        public var accessibilitySuperscript: Int? {
            get { self[.accessibilitySuperscript] }
            set { self[.accessibilitySuperscript] = newValue }
        }
         
        /// Text underline style for accessibility (NSNumber).
        public var accessibilityUnderline: Int? {
            get { self[.accessibilityUnderline] }
            set { self[.accessibilityUnderline] = newValue }
        }
         
        /// Text underline color for accessibility (CGColorRef).
        public var accessibilityUnderlineColor: CGColor? {
            get { self[.accessibilityUnderlineColor] }
            set { self[.accessibilityUnderlineColor] = newValue }
        }
        #endif
         
        #if os(iOS) || os(tvOS) || os(watchOS)
        /// UI accessibility text attribute context.
        public var UIAccessibilityTextAttributeContext: Any? {
            get { self[.UIAccessibilityTextAttributeContext] }
            set { self[.UIAccessibilityTextAttributeContext] = newValue }
        }
         
        // MARK: - Markdown Attributes
         
        /// An attribute that provides details for an inline Markdown element.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var inlinePresentationIntent: InlinePresentationIntent? {
            get { self[.inlinePresentationIntent] }
            set { self[.inlinePresentationIntent] = newValue }
        }
         
        /// An attribute that provides details for a block-level Markdown element.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var presentationIntentAttributeName: PresentationIntent? {
            get { self[.presentationIntentAttributeName] }
            set { self[.presentationIntentAttributeName] = newValue }
        }
         
        /// The position in a Markdown source string corresponding to some attributed text.
        @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        public var markdownSourcePosition: Any? {
            get { self[.markdownSourcePosition] }
            set { self[.markdownSourcePosition] = newValue }
        }
         
        /// An alternate description for a URL or image.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var alternateDescription: String? {
            get { self[.alternateDescription] }
            set { self[.alternateDescription] = newValue }
        }
         
        /// The URL for an image in Markdown text.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var imageURL: URL? {
            get { self[.imageURL] }
            set { self[.imageURL] = newValue }
        }
         
        // MARK: - Translation Attributes
         
        /// The language identifier associated with the range of text.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var languageIdentifier: String? {
            get { self[.languageIdentifier] }
            set { self[.languageIdentifier] = newValue }
        }
         
        /// An attribute that contains grammatical properties to apply to the text.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var morphology: Morphology? {
            get { self[.morphology] }
            set { self[.morphology] = newValue }
        }
         
        /// An attribute that tells the system how to apply grammar rules and other modifiers to the range of text.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var inflect: InflectionRule? {
            get { self[.inflectionRule] }
            set { self[.inflectionRule] = newValue }
        }
         
        /// The alternative translation for a string when no suitable inflection exists.
        @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        public var inflectionAlternative: String? {
            get { self[.inflectionAlternative] }
            set { self[.inflectionAlternative] = newValue }
        }
         
        /// An attribute that specifies agreement with a particular argument.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var agreeWithArgument: Any? {
            get { self[.agreeWithArgument] }
            set { self[.agreeWithArgument] = newValue }
        }
         
        /// An attribute that specifies agreement with a concept.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var agreeWithConcept: Any? {
            get { self[.agreeWithConcept] }
            set { self[.agreeWithConcept] = newValue }
        }
         
        /// An attribute that specifies a referent concept.
        @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
        public var referentConcept: Any? {
            get { self[.referentConcept] }
            set { self[.referentConcept] = newValue }
        }
         
        /// An attribute that specifies a localized number format.
        @available(iOS 18.0, tvOS 18.0, watchOS 11.0, *)
        public var localizedNumberFormat: Any? {
            get { self[.localizedNumberFormat] }
            set { self[.localizedNumberFormat] = newValue }
        }
        #endif
         
        // MARK: - Deprecated Keys
         
        /// The expansion factor of the text.
        public var expansion: CGFloat? {
            get { self[.expansion] }
            set { self[.expansion] = newValue }
        }
         
        /// The obliqueness of the text.
        public var obliqueness: CGFloat? {
            get { self[.obliqueness] }
            set { self[.obliqueness] = newValue }
        }
         
        /// The vertical glyph form of the text.
        public var verticalGlyphForm: Int? {
            get { self[.verticalGlyphForm] }
            set { self[.verticalGlyphForm] = newValue }
        }
         
        /*
         /// The character shape attribute.
         public var characterShapeAttributeName: Any? {
             get { self[.characterShapeAttributeName] }
             set { self[.characterShapeAttributeName] = newValue }
         }
         
         /// The screen fonts attribute.
         public var usesScreenFontsDocumentAttribute: Any? {
             get { self[.usesScreenFontsDocumentAttribute] }
             set { self[.usesScreenFontsDocumentAttribute] = newValue }
         }
         */
    }
}

extension NSAttributedString.AttributeValues {
    /// Sets the color of the background behind the text.
    @discardableResult
    public func backgroundColor(_ color: NSUIColor?) -> Self {
        self.backgroundColor = color
        return self
    }

    /// Sets the vertical offset for the position of the text.
    @discardableResult
    public func baselineOffset(_ baselineOffset: CGFloat?) -> Self {
        self.baselineOffset = baselineOffset
        return self
    }

    /// Sets the font of the text.
    @discardableResult
    public func font(_ font: NSUIFont?) -> Self {
        self.font = font
        return self
    }

    /// Sets the color of the text.
    @discardableResult
    public func foregroundColor(_ color: NSUIColor?) -> Self {
        self.foregroundColor = color
        return self
    }

    /// Sets the kerning of the text.
    @discardableResult
    public func kern(_ kern: CGFloat?) -> Self {
        self.kern = kern
        return self
    }

    /// Sets the ligature of the text.
    @discardableResult
    public func ligature(_ ligature: Int?) -> Self {
        self.ligature = ligature
        return self
    }

    /// Sets the paragraph style of the text.
    @discardableResult
    public func paragraphStyle(_ style: ParagraphStyle?) -> Self {
        self.paragraphStyle = style
        return self
    }

    /// Sets the color of the strikethrough.
    @discardableResult
    public func strikethroughColor(_ color: NSUIColor?) -> Self {
        self.strikethroughColor = color
        return self
    }

    /// Sets the strikethrough style of the text.
    @discardableResult
    public func strikethroughStyle(_ style: NSUnderlineStyle?) -> Self {
        self.strikethroughStyle = style
        return self
    }

    /// Sets the color of the stroke.
    @discardableResult
    public func strokeColor(_ color: NSUIColor?) -> Self {
        self.strokeColor = color
        return self
    }

    /// Sets the width of the stroke.
    @discardableResult
    public func strokeWidth(_ width: CGFloat?) -> Self {
        self.strokeWidth = width
        return self
    }

    /// Sets the amount to modify the default tracking.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    @discardableResult
    public func tracking(_ tracking: CGFloat?) -> Self {
        self.tracking = tracking
        return self
    }

    /// Sets the color of the underline.
    @discardableResult
    public func underlineColor(_ color: NSUIColor?) -> Self {
        self.underlineColor = color
        return self
    }

    /// Sets the underline style of the text.
    @discardableResult
    public func underlineStyle(_ style: NSUnderlineStyle?) -> Self {
        self.underlineStyle = style
        return self
    }

    /// Sets the writing direction of the text.
    @discardableResult
    public func writingDirection(_ directions: [WritingDirection]?) -> Self {
        self.writingDirection = directions
        return self
    }

    #if os(macOS)
    /// Sets the name of a glyph info object.
    @discardableResult
    public func glyphInfo(_ glyphInfo: NSGlyphInfo?) -> Self {
        self.glyphInfo = glyphInfo
        return self
    }

    /// Sets the superscript of the text.
    @discardableResult
    public func superscript(_ superscript: Int?) -> Self {
        self.superscript = superscript
        return self
    }
    #endif

    // MARK: - Additional Attributes

    /// Sets the link for the text.
    @discardableResult
    public func link(_ link: Any?) -> Self {
        self.link = link
        return self
    }

    /// Sets the replacement position associated with a format string specifier.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func replacementIndex(_ index: Int?) -> Self {
        self.replacementIndex = index
        return self
    }

    /// Sets the shadow of the text.
    @discardableResult
    public func shadow(_ shadow: NSShadow?) -> Self {
        self.shadow = shadow
        return self
    }

    /// Sets the text effect to apply to the text.
    @discardableResult
    public func textEffect(_ effect: NSAttributedString.TextEffectStyle?) -> Self {
        self.textEffect = effect
        return self
    }

    #if compiler(>=6.0)
    /// Sets the custom highlight color scheme to apply to the text.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    @discardableResult
    public func textHighlightColorScheme(_ scheme: NSAttributedString.TextHighlightColorScheme?) -> Self {
        self.textHighlightColorScheme = scheme
        return self
    }

    /// Sets the highlight style to emphasize the text.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    @discardableResult
    public func textHighlightStyle(_ style: NSAttributedString.TextHighlightStyle?) -> Self {
        self.textHighlightStyle = style
        return self
    }
    #endif

    #if os(iOS)
    /// Sets the custom tag associated with a text item.
    @available(iOS 17.0, *)
    @discardableResult
    public func textItemTag(_ tag: String?) -> Self {
        self.textItemTag = tag
        return self
    }
    #endif
    
    #if os(macOS)
    /// Sets the tooltip text.
    @discardableResult
    public func toolTip(_ text: String?) -> Self {
        self.toolTip = text
        return self
    }

    /// Sets the cursor object.
    @discardableResult
    public func cursor(_ cursor: NSCursor?) -> Self {
        self.cursor = cursor
        return self
    }

    /// Sets the index of the marked clause segment.
    @discardableResult
    public func markedClauseSegment(_ index: Int?) -> Self {
        self.markedClauseSegment = index
        return self
    }

    /// Sets the spelling state of the text.
    @discardableResult
    public func spellingState(_ state: NSAttributedString.SpellingState?) -> Self {
        self.spellingState = state
        return self
    }

    /// Sets the alternatives for the text.
    @discardableResult
    public func textAlternatives(_ alternatives: NSTextAlternatives?) -> Self {
        self.textAlternatives = alternatives
        return self
    }
    #endif

    #if os(macOS) || os(iOS)
    /// Sets the highlight associated with a Spotlight suggestion.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
    @discardableResult
    public func suggestionHighlight(_ highlight: String?) -> Self {
        self.suggestionHighlight = highlight
        return self
    }
    #endif

    // MARK: - Attachment

    #if compiler(>=6.0)
    /// Sets the adaptive image glyph for the text.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    @discardableResult
    public func adaptiveImageGlyph(_ glyph: NSAdaptiveImageGlyph?) -> Self {
        self.adaptiveImageGlyph = glyph
        return self
    }
    #endif

    /// Sets the attachment for the text.
    @discardableResult
    public func attachment(_ attachment: NSTextAttachment?) -> Self {
        self.attachment = attachment
        return self
    }

    // MARK: - Accessibility

    #if os(macOS)
    /// Sets the text alignment for accessibility.
    @discardableResult
    public func accessibilityAlignment(_ alignment: Any?) -> Self {
        self.accessibilityAlignment = alignment
        return self
    }

    /// Sets the accessibility annotation text attribute.
    @discardableResult
    public func accessibilityAnnotationTextAttribute(_ attribute: Any?) -> Self {
        self.accessibilityAnnotationTextAttribute = attribute
        return self
    }

    /// Sets the accessibility attachment.
    @discardableResult
    public func accessibilityAttachment(_ attachment: Any?) -> Self {
        self.accessibilityAttachment = attachment
        return self
    }

    /// Sets whether the text is autocorrected for accessibility.
    @discardableResult
    public func accessibilityAutocorrected(_ autocorrected: Bool?) -> Self {
        self.accessibilityAutocorrected = autocorrected
        return self
    }

    /// Sets the text background color for accessibility.
    @discardableResult
    public func accessibilityBackgroundColor(_ color: CGColor?) -> Self {
        self.accessibilityBackgroundColor = color
        return self
    }

    /// Sets the custom text for accessibility.
    @discardableResult
    public func accessibilityCustomText(_ text: Any?) -> Self {
        self.accessibilityCustomText = text
        return self
    }

    /// Sets the font keys for accessibility.
    @discardableResult
    public func accessibilityFont(_ font: NSDictionary?) -> Self {
        self.accessibilityFont = font
        return self
    }

    /// Sets the text foreground color for accessibility.
    @discardableResult
    public func accessibilityForegroundColor(_ color: CGColor?) -> Self {
        self.accessibilityForegroundColor = color
        return self
    }

    /// Sets the accessibility language of the text.
    @discardableResult
    public func accessibilityLanguage(_ language: String?) -> Self {
        self.accessibilityLanguage = language
        return self
    }

    /// Sets the text link for accessibility.
    @discardableResult
    public func accessibilityLink(_ link: Any?) -> Self {
        self.accessibilityLink = link
        return self
    }

    /// Sets the list item index for accessibility.
    @discardableResult
    public func accessibilityListItemIndex(_ index: Int?) -> Self {
        self.accessibilityListItemIndex = index
        return self
    }

    /// Sets the list item level for accessibility.
    @discardableResult
    public func accessibilityListItemLevel(_ level: Int?) -> Self {
        self.accessibilityListItemLevel = level
        return self
    }

    /// Sets the list item prefix for accessibility.
    @discardableResult
    public func accessibilityListItemPrefix(_ prefix: String?) -> Self {
        self.accessibilityListItemPrefix = prefix
        return self
    }

    /// Sets whether the text is visibly marked as misspelled for accessibility.
    @discardableResult
    public func accessibilityMarkedMisspelled(_ markedMisspelled: Bool?) -> Self {
        self.accessibilityMarkedMisspelled = markedMisspelled
        return self
    }

    /// Sets whether the text is misspelled for accessibility.
    @discardableResult
    public func accessibilityMisspelled(_ misspelled: Bool?) -> Self {
        self.accessibilityMisspelled = misspelled
        return self
    }

    /// Sets whether the text has a shadow for accessibility.
    @discardableResult
    public func accessibilityShadow(_ shadow: Bool?) -> Self {
        self.accessibilityShadow = shadow
        return self
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    /// Sets the speech announcement priority for accessibility.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechAnnouncementPriority(_ priority: Any?) -> Self {
        self.accessibilitySpeechAnnouncementPriority = priority
        return self
    }

    /// Sets the pronunciation of a specific word or phrase, such as a proper name.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechIPANotation(_ notation: String?) -> Self {
        self.accessibilitySpeechIPANotation = notation
        return self
    }

    /// Sets the language to use when speaking a string.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechLanguage(_ language: String?) -> Self {
        self.accessibilitySpeechLanguage = language
        return self
    }

    /// Sets the pitch to apply to spoken content.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechPitch(_ pitch: CGFloat?) -> Self {
        self.accessibilitySpeechPitch = pitch
        return self
    }

    /// Sets whether to speak punctuation.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechPunctuation(_ punctuation: Bool?) -> Self {
        self.accessibilitySpeechPunctuation = punctuation
        return self
    }

    /// Sets whether to queue an announcement behind existing speech or to interrupt it.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechQueueAnnouncement(_ queue: Bool?) -> Self {
        self.accessibilitySpeechQueueAnnouncement = queue
        return self
    }

    /// Sets whether to spell out the text during speech.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func accessibilitySpeechSpellOut(_ spellOut: Any?) -> Self {
        self.accessibilitySpeechSpellOut = spellOut
        return self
    }

    /// Sets the custom attributes to apply to the text for accessibility.
    @discardableResult
    public func accessibilityTextCustom(_ attributes: [String]?) -> Self {
        self.accessibilityTextCustom = attributes
        return self
    }

    /// Sets the heading level of the text for accessibility.
    @discardableResult
    public func accessibilityTextHeadingLevel(_ level: Int?) -> Self {
        self.accessibilityTextHeadingLevel = level
        return self
    }
    #endif

    #if os(macOS)
    /// Sets whether the text is strikethrough for accessibility.
    @discardableResult
    public func accessibilityStrikethrough(_ strikethrough: Bool?) -> Self {
        self.accessibilityStrikethrough = strikethrough
        return self
    }

    /// Sets the strikethrough color for accessibility.
    @discardableResult
    public func accessibilityStrikethroughColor(_ color: CGColor?) -> Self {
        self.accessibilityStrikethroughColor = color
        return self
    }

    /// Sets the superscript style for accessibility.
    @discardableResult
    public func accessibilitySuperscript(_ superscript: Int?) -> Self {
        self.accessibilitySuperscript = superscript
        return self
    }

    /// Sets the underline style for accessibility.
    @discardableResult
    public func accessibilityUnderline(_ underline: Int?) -> Self {
        self.accessibilityUnderline = underline
        return self
    }

    /// Sets the underline color for accessibility.
    @discardableResult
    public func accessibilityUnderlineColor(_ color: CGColor?) -> Self {
        self.accessibilityUnderlineColor = color
        return self
    }
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)
    /// Sets the UI accessibility text attribute context.
    @discardableResult
    public func UIAccessibilityTextAttributeContext(_ context: Any?) -> Self {
        self.UIAccessibilityTextAttributeContext = context
        return self
    }

    // MARK: - Markdown Attributes

    /// Sets the details for an inline Markdown element.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func inlinePresentationIntent(_ intent: InlinePresentationIntent?) -> Self {
        self.inlinePresentationIntent = intent
        return self
    }

    /// Sets the details for a block-level Markdown element.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func presentationIntentAttributeName(_ intent: PresentationIntent?) -> Self {
        self.presentationIntentAttributeName = intent
        return self
    }

    /// Sets the position in a Markdown source string corresponding to some attributed text.
    @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @discardableResult
    public func markdownSourcePosition(_ position: Any?) -> Self {
        self.markdownSourcePosition = position
        return self
    }

    /// Sets an alternate description for a URL or image.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func alternateDescription(_ description: String?) -> Self {
        self.alternateDescription = description
        return self
    }

    /// Sets the URL for an image in Markdown text.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func imageURL(_ url: URL?) -> Self {
        self.imageURL = url
        return self
    }

    // MARK: - Translation Attributes

    /// Sets the language identifier associated with the range of text.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func languageIdentifier(_ identifier: String?) -> Self {
        self.languageIdentifier = identifier
        return self
    }

    /// Sets the grammatical properties to apply to the text.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func morphology(_ morphology: Morphology?) -> Self {
        self.morphology = morphology
        return self
    }

    /// Sets the grammar rules and other modifiers to apply to the text.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func inflect(_ rule: InflectionRule?) -> Self {
        self.inflect = rule
        return self
    }

    /// Sets the alternative translation for a string when no suitable inflection exists.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func inflectionAlternative(_ alternative: String?) -> Self {
        self.inflectionAlternative = alternative
        return self
    }

    /// Sets the agreement with a particular argument.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func agreeWithArgument(_ argument: Any?) -> Self {
        self.agreeWithArgument = argument
        return self
    }

    /// Sets the agreement with a concept.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func agreeWithConcept(_ concept: Any?) -> Self {
        self.agreeWithConcept = concept
        return self
    }

    /// Sets the referent concept.
    @available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @discardableResult
    public func referentConcept(_ concept: Any?) -> Self {
        self.referentConcept = concept
        return self
    }

    /// Sets the localized number format.
    @available(iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    @discardableResult
    public func localizedNumberFormat(_ format: Any?) -> Self {
        self.localizedNumberFormat = format
        return self
    }
    #endif
    
    /// Sets the expansion factor of the text.
    @discardableResult
    public func expansion(_ expansion: CGFloat?) -> Self {
        self.expansion = expansion
        return self
    }
    
    /// Sets the obliqueness of the text.
    @discardableResult
    public func obliqueness(_ obliqueness: CGFloat?) -> Self {
        self.obliqueness = obliqueness
        return self
    }
    
    /// Sets the vertical glyph form of the text.
    @discardableResult
    public func verticalGlyphForm(_ verticalGlyphForm: Int?) -> Self {
        self.verticalGlyphForm = verticalGlyphForm
        return self
    }
}

/// The paragraph or ruler attributes for an attributed string.
public struct ParagraphStyle: CustomStringConvertible {
                
    /// The text alignment of the paragraph.
    public var alignment: NSTextAlignment
                
    /// The indentation of the first line of the paragraph.
    public var firstLineHeadIndent: CGFloat
        
    /// The indentation of the paragraph’s lines other than the first.
    public var headIndent: CGFloat
        
    /// The trailing indentation of the paragraph.
    public var tailIndent: CGFloat
                
    /// The line height multiple.
    public var lineHeightMultiple: CGFloat
        
    /// The paragraph’s maximum line height.
    public var maximumLineHeight: CGFloat
        
    /// The paragraph’s minimum line height.
    public var minimumLineHeight: CGFloat
        
    /// The distance in points between the bottom of one line fragment and the top of the next.
    public var lineSpacing: CGFloat
        
    /// Distance between the bottom of this paragraph and top of next.
    public var paragraphSpacing: CGFloat
        
    /// The distance between the paragraph’s top and the beginning of its text content.
    public var paragraphSpacingBefore: CGFloat
                
    /// The text tab objects that represent the paragraph’s tab stops.
    public var tabStops: [NSTextTab]
        
    /// The documentwide default tab interval.
    public var defaultTabInterval: CGFloat
                    
    #if os(macOS)
    /// The text blocks that contain the paragraph.
    public var textBlocks: [NSTextBlock]
    
    /// The threshold for using tightening as an alternative to truncation.
    public var tighteningFactorForTruncation: Float
    #endif
        
    /// The text lists that contain the paragraph.
    public var textLists: [NSTextList]
                
    /// The mode for breaking lines in the paragraph that don’t fit within a container.
    public var lineBreakMode: NSLineBreakMode
        
    /// The strategy for breaking lines while laying out paragraphs.
    public var lineBreakStrategy: NSParagraphStyle.LineBreakStrategy
        
    /// The paragraph’s threshold for hyphenation.
    public var hyphenationFactor: Float

    /// A Boolean value that indicates whether the paragraph style uses the system hyphenation settings.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public var usesDefaultHyphenation: Bool {
        get { _usesDefaultHyphenation as? Bool ?? false }
        set { _usesDefaultHyphenation = newValue }
    }
    
    private var _usesDefaultHyphenation: Any?
        
    /// A Boolean value that indicates whether the system tightens character spacing before truncating text.
    public var allowsDefaultTighteningForTruncation: Bool
                        
    #if os(macOS)
    /// The HTML header level of the paragraph.
    public var headerLevel: Int
    #else
    /// The HTML header level of the paragraph.
    public let headerLevel: Int
    #endif
    
    /// The base writing direction for the paragraph.
    public var baseWritingDirection: NSWritingDirection
    
    /**
     Returns the default writing direction for the specified language.
     
     - Parameter languageName: The language specified in ISO language region format. Can be `nil` to return a default writing direction derived from the user’s defaults database.
     - Returns: The default writing direction.
     */
    public static func defaultWritingDirection(forLanguage languageName: String?) -> NSWritingDirection {
        NSParagraphStyle.defaultWritingDirection(forLanguage: languageName)
    }
                
    public init() {
        self = ParagraphStyle(style: .default)
    }
    
    /// The default paragraph style.
    public static var `default` = ParagraphStyle()
        
    init(style: NSParagraphStyle, headerLevel: Int = 0) {
        self.alignment = style.alignment
        self.firstLineHeadIndent = style.firstLineHeadIndent
        self.headIndent = style.headIndent
        self.tailIndent = style.tailIndent
        self.lineHeightMultiple = style.lineHeightMultiple
        self.maximumLineHeight = style.maximumLineHeight
        self.minimumLineHeight = style.minimumLineHeight
        self.lineSpacing = style.lineSpacing
        self.paragraphSpacing = style.paragraphSpacing
        self.paragraphSpacingBefore = style.paragraphSpacingBefore
        self.tabStops = style.tabStops
        self.defaultTabInterval = style.defaultTabInterval
        self.textLists = style.textLists
        self.lineBreakMode = style.lineBreakMode
        self.lineBreakStrategy = style.lineBreakStrategy
        self.hyphenationFactor = style.hyphenationFactor
        self.allowsDefaultTighteningForTruncation = style.allowsDefaultTighteningForTruncation
        self.headerLevel = headerLevel
        self.baseWritingDirection = style.baseWritingDirection
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            _usesDefaultHyphenation = style.usesDefaultHyphenation
        }
        #if os(macOS)
        self.textBlocks = style.textBlocks
        self.tighteningFactorForTruncation = style.tighteningFactorForTruncation
        #endif
    }
                
    /// The `NSParagraphStyle` representation of the paragraph style.
    public func nsParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = maximumLineHeight
        paragraphStyle.minimumLineHeight = minimumLineHeight
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.paragraphSpacingBefore = paragraphSpacingBefore
        paragraphStyle.tabStops = tabStops
        paragraphStyle.defaultTabInterval = defaultTabInterval
        paragraphStyle.textLists = textLists
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineBreakStrategy = lineBreakStrategy
        paragraphStyle.hyphenationFactor = hyphenationFactor
        paragraphStyle.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            paragraphStyle.usesDefaultHyphenation = usesDefaultHyphenation
        }
        paragraphStyle.baseWritingDirection = baseWritingDirection
        #if os(macOS)
        paragraphStyle.headerLevel = headerLevel
        paragraphStyle.textBlocks = textBlocks
        paragraphStyle.tighteningFactorForTruncation = tighteningFactorForTruncation
        #endif
        return paragraphStyle
    }
    
    public var description: String {
        nsParagraphStyle().description
    }
}
