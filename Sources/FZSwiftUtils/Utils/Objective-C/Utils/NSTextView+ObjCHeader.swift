//
//  NSTextView+ObjCHeader.swift
//  
//
//  Created by Florian Zand on 20.03.26.
//

#if os(macOS)
import AppKit

/// A `NSTextView` subclass with clickable Objective-C class and protocol names.
open class ObjCHeaderTextView: NSTextView {
    /// The handler that gets called when the user clicks on an Objective-C class name in the text.
    public var onClassClick: ((String) -> Void)?
    
    /// The handler that gets called when the user clicks on an Objective-C protocol name in the text.
    public var onProtocolClick: ((String) -> Void)?

    private var hoveredClickableRange: NSRange?

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.acceptsMouseMovedEvents = true
    }

    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingAreas.first(where: { $0.userInfo?["track"] != nil }) {
            Swift.print("FOUND")
            removeTrackingArea(trackingArea)
        }
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited, .cursorUpdate], owner: self, userInfo: ["track": true]))
    }

    open override func mouseMoved(with event: NSEvent) {
        updateHover(for: event)
        window?.invalidateCursorRects(for: self)
        super.mouseMoved(with: event)
    }

    open override func mouseExited(with event: NSEvent) {
        clearHover()
        window?.invalidateCursorRects(for: self)
        super.mouseExited(with: event)
    }

    open override func cursorUpdate(with event: NSEvent) {
        if let characterIndex = characterIndex(at: event.locationInWindow),
           clickableRange(at: characterIndex) != nil {
            NSCursor.pointingHand.set()
        } else {
            super.cursorUpdate(with: event)
        }
    }

    open override func mouseDown(with event: NSEvent) {
        guard let characterIndex = characterIndex(at: event.locationInWindow),
              let symbol = clickableSymbol(at: characterIndex) else {
            super.mouseDown(with: event)
            return
        }
        switch symbol {
        case .class(let name):
            onClassClick?(name)
        case .protocol(let name):
            onProtocolClick?(name)
        }
    }

    private func updateHover(for event: NSEvent) {
        guard let characterIndex = characterIndex(at: event.locationInWindow),
              let range = clickableRange(at: characterIndex) else {
            clearHover()
            return
        }
        guard hoveredClickableRange != range else { return }
        clearHover()
        layoutManager?.addTemporaryAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, forCharacterRange: range)
        hoveredClickableRange = range
    }

    private func clearHover() {
        guard let hoveredClickableRange else { return }
        layoutManager?.removeTemporaryAttribute(.underlineStyle, forCharacterRange: hoveredClickableRange)
        self.hoveredClickableRange = nil
    }

    private func clickableSymbol(at characterIndex: Int) -> ClickableSymbol? {
        guard let textStorage, characterIndex >= 0, characterIndex < textStorage.length else {
            return nil
        }
        if let className = textStorage.attribute(.objcClassName, at: characterIndex, effectiveRange: nil) as? String {
            return .class(className)
        }

        if let protocolName = textStorage.attribute(.objcProtocolName, at: characterIndex, effectiveRange: nil) as? String {
            return .protocol(protocolName)
        }
        return nil
    }

    private func clickableRange(at characterIndex: Int) -> NSRange? {
        guard let textStorage, characterIndex >= 0, characterIndex < textStorage.length else {
            return nil
        }
        var range = NSRange()
        if textStorage.attribute(.objcClassName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        if textStorage.attribute(.objcProtocolName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        return nil
    }

    private func characterIndex(at windowPoint: NSPoint) -> Int? {
        guard let layoutManager, let textContainer, let textStorage else {
            return nil
        }
        let pointInView = convert(windowPoint, from: nil)
        let pointInContainer = NSPoint(x: pointInView.x - textContainerOrigin.x, y: pointInView.y - textContainerOrigin.y)
        guard pointInContainer.x >= 0, pointInContainer.y >= 0 else {
            return nil
        }
        var fraction: CGFloat = 0
        let glyphIndex = layoutManager.glyphIndex(for: pointInContainer, in: textContainer, fractionOfDistanceThroughGlyph: &fraction)
        guard glyphIndex < layoutManager.numberOfGlyphs else {
            return nil
        }
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
        guard glyphRect.contains(pointInContainer) else {
            return nil
        }
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        guard characterIndex < textStorage.length else {
            return nil
        }
        return characterIndex
    }

    private enum ClickableSymbol {
        case `class`(String)
        case `protocol`(String)
    }
}


#endif
