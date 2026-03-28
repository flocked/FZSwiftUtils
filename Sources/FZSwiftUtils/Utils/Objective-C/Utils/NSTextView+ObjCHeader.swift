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
    
    /// A Boolean value indicating whether classes can be clicked.
    public var canClickClasses: Bool = true
    /// A Boolean value indicating whether protocols can be clicked.
    public var canClickProtocols: Bool = true
    /// A Boolean value indicating whether images can be clicked.
    public var canClickImages: Bool = true
    
    /// The handler that gets called when the user clicks on an Objective-C class name in the text.
    public var onClassClick: ((_ class: String) -> Void)?
    /// The handler that gets called when the user clicks on an Objective-C protocol name in the text.
    public var onProtocolClick: ((_ protocol: String) -> Void)?
    /// The handler that gets called when the user clicks on an Objective-C library or framework in the text.
    public var onImageClick: ((_ image: String) -> Void)?
    
    /// The handler that provides a menu for the given class.
    public var classMenuHandler: ((_ class: String) -> NSMenu?)?
    /// The handler that provides a menu for the given protocol.
    public var protocolMenuHandler: ((_ protocol: String) -> NSMenu?)?
    /// The handler that provides a menu for the given image.
    public var imageMenuHandler: ((_ image: String) -> NSMenu?)?

    private var hoveredClickableRange: NSRange?
    
    open override func menu(for event: NSEvent) -> NSMenu? {
        guard let characterIndex = characterIndex(at: event.locationInWindow),
              let symbol = clickableSymbol(at: characterIndex) else {
            return menu
        }
        var menu: NSMenu?
        switch symbol {
        case .class(let name):
            menu = classMenuHandler?(name)
        case .protocol(let name):
            menu = protocolMenuHandler?(name)
        case .image(let name):
            menu = imageMenuHandler?(name)
        }
        guard let menu = menu else {
            return menu
        }
        menu.allowsContextMenuPlugIns = false
        if let range = clickableRange(at: characterIndex) {
            setSelectedRange(range)
        }
        menuNotificationToken = NotificationCenter.default.observe(NSMenu.didEndTrackingNotification, postedBy: menu) { [weak self] _ in
            self?.menuNotificationToken = nil
            self?.setSelectedRange(NSRange(location: NSNotFound, length: 0))
        }
        return menu
    }
    
    var menuNotificationToken: NotificationToken?

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.acceptsMouseMovedEvents = true
    }

    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingAreas.first(where: { $0.userInfo?["track"] != nil }) {
            removeTrackingArea(trackingArea)
        }
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited, .cursorUpdate], owner: self, userInfo: ["track": true]))
    }

    private var isHoveringClickableSymbol = false
    open override func mouseMoved(with event: NSEvent) {
        let wasHoveringClickableSymbol = isHoveringClickableSymbol
        let hoverChanged = updateHover(for: event)
        if hoverChanged || wasHoveringClickableSymbol != isHoveringClickableSymbol {
            if isHoveringClickableSymbol {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        super.mouseMoved(with: event)
    }


    open override func mouseExited(with event: NSEvent) {
        if clearHover() {
            window?.invalidateCursorRects(for: self)
        }
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
        case .image(let name):
            onImageClick?(name)
        }
    }

    @discardableResult
    private func updateHover(for event: NSEvent) -> Bool {
        guard let characterIndex = characterIndex(at: event.locationInWindow),
              let range = clickableRange(at: characterIndex) else {
            return clearHover()
        }
        guard hoveredClickableRange != range else { return false }
        clearHover()
        layoutManager?.addTemporaryAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, forCharacterRange: range)
        hoveredClickableRange = range
        return true
    }


    @discardableResult
    private func clearHover() -> Bool {
        isHoveringClickableSymbol = false
        guard let hoveredClickableRange else { return false }
        layoutManager?.removeTemporaryAttribute(.underlineStyle, forCharacterRange: hoveredClickableRange)
        self.hoveredClickableRange = nil
        return true
    }

    private func clickableSymbol(at characterIndex: Int) -> ClickableSymbol? {
        guard let textStorage, characterIndex >= 0, characterIndex < textStorage.length else {
            return nil
        }
        if canClickClasses, let className = textStorage.attribute(.objcClassName, at: characterIndex, effectiveRange: nil) as? String {
            return .class(className)
        }
        if canClickProtocols, let protocolName = textStorage.attribute(.objcProtocolName, at: characterIndex, effectiveRange: nil) as? String {
            return .protocol(protocolName)
        }
        if canClickImages, let imageName = textStorage.attribute(.objcImageName, at: characterIndex, effectiveRange: nil) as? String {
            return .image(imageName)
        }
        return nil
    }

    private func clickableRange(at characterIndex: Int) -> NSRange? {
        guard let textStorage, characterIndex >= 0, characterIndex < textStorage.length else {
            return nil
        }
        var range = NSRange()
        if canClickClasses, textStorage.attribute(.objcClassName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        if canClickProtocols, textStorage.attribute(.objcProtocolName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        if canClickImages, textStorage.attribute(.objcImageName, at: characterIndex, effectiveRange: &range) != nil {
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
    
    /// Scrolls the text view in its enclosing scroll view so the specified protocol is visible.
    public func scroll(toProtocol protocolName: String) {
        guard let range = firstRange(ofProtocol: protocolName) else { return }
        scrollRangeToVisible(range)
    }

    /// Scrolls the text view in its enclosing scroll view so the specified class is visible.
    public func scroll(toClass cls: String) {
        guard let range = firstRange(ofClass: cls) else { return }
        scrollRangeToVisible(range)
    }

    /// The frames of the specified protocol.
    public func frames(ofProtocol protocolName: String) -> [CGRect] {
        ranges(ofAttribute: .objcProtocolName, value: protocolName).flatMap(frames(forCharacterRange:))
    }

    /// The frames of the specified class.
    public func frames(ofClass className: String) -> [CGRect] {
        ranges(ofAttribute: .objcClassName, value: className).flatMap(frames(forCharacterRange:))
    }
    
    /// The text ranges of the specified class.
    public func ranges(ofClass className: String) -> [NSRange] {
        ranges(ofAttribute: .objcClassName, value: className)
    }

    /// The text ranges of the specified protocol.
    public func ranges(ofProtocol protocolName: String) -> [NSRange] {
        ranges(ofAttribute: .objcProtocolName, value: protocolName)
    }

    /// The protocol names in the specified rectangle.
    public func protocols(in rect: CGRect) -> [String] {
        names(in: rect, attribute: .objcProtocolName)
    }

    /// The class names in the specified rectangle.
    public func classes(in rect: CGRect) -> [String] {
        names(in: rect, attribute: .objcClassName)
    }

    /// The protocol names visible in the text view.
    public var visibleProtocols: [String] {
        protocols(in: visibleRect)
    }

    /// The class names visible in the text view.
    public var visibleClasses: [String] {
        classes(in: visibleRect)
    }

    private func firstRange(ofProtocol protocolName: String) -> NSRange? {
        ranges(ofAttribute: .objcProtocolName, value: protocolName).first
    }

    private func firstRange(ofClass cls: String) -> NSRange? {
        ranges(ofAttribute: .objcClassName, value: cls).first
    }

    private func ranges(ofAttribute attribute: NSAttributedString.Key, value: String) -> [NSRange] {
        guard let textStorage, textStorage.length > 0 else {
            return []
        }
        var results: [NSRange] = []
        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.enumerateAttribute(attribute, in: fullRange) { attributeValue, range, _ in
            guard let name = attributeValue as? String, name == value else { return }
            results.append(range)
        }
        return results
    }

    private func frames(forCharacterRange characterRange: NSRange) -> [CGRect] {
        guard let layoutManager, let textContainer, characterRange.length > 0 else {
            return []
        }
        let glyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        guard glyphRange.length > 0 else {
            return []
        }
        var rects: [CGRect] = []
        layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: .notFound, in: textContainer) { rect, _ in
            let viewRect = rect.offsetBy(dx: self.textContainerOrigin.x, dy: self.textContainerOrigin.y)
            rects.append(viewRect)
        }
        return rects
    }

    private func names(in rect: CGRect, attribute: NSAttributedString.Key) -> [String] {
        guard let textStorage, textStorage.length > 0 else {
            return []
        }
        var results: [String] = []
        var seen = Set<String>()
        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.enumerateAttribute(attribute, in: fullRange) { attributeValue, range, _ in
            guard let name = attributeValue as? String else { return }
            let frames = self.frames(forCharacterRange: range)
            guard frames.contains(where: { $0.intersects(rect) }) else { return }
            if seen.insert(name).inserted {
                results.append(name)
            }
        }
        return results
    }
    
    public struct ClassValues {
        public var properties: [String] = []
        public var classProperties: [String] = []
        public var methods: [String] = []
        public var classMethods: [String] = []
        public var ivars: [String] = []
        
        public func filter(_ info: ObjCClassInfo) -> ClassValues {
            var values = self
            values.properties = values.properties.filter({ name in info.properties.contains(where: { $0.name == name }) })
            values.classProperties = values.classProperties.filter({ name in info.classProperties.contains(where: { $0.name == name }) })
            values.methods = values.methods.filter({ name in info.methods.contains(where: { $0.name == name }) })
            values.classMethods = values.classMethods.filter({ name in info.classMethods.contains(where: { $0.name == name }) })
            values.ivars = values.ivars.filter({ name in info.ivars.contains(where: { $0.name == name }) })
            return values
        }
        
        public func classExtensionString(for info: ObjCClassInfo) -> String? {
            info.classExtensionString(forMethods: Set(methods), classMethods: Set(classMethods), properties: Set(properties), classProperties: Set(classProperties), ivars: Set(ivars))
        }
        
        public var title: String {
            var tiles: [String] = []
            let propertiesCount = (properties + classProperties).count
            if propertiesCount > 0 {
                tiles += propertiesCount == 1 ? "property" : "properties"
            }
            let methodsCount = (methods + classMethods).count
            if methodsCount > 0 {
                tiles += methodsCount == 1 ? "method" : "methods"
            }
            if ivars.count > 0 {
                tiles += ivars.count == 1 ? "ivar" : "ivars"
            }
            if tiles.count == 3 {
                return "\(tiles[0]), \(tiles[1]) and \(tiles[2])"
            } else if tiles.count == 2 {
                return "\(tiles[0]) and \(tiles[1])"
            } else if tiles.count == 1 {
                return "\(tiles[0])"
            }
            return tiles.joined(separator: ", ")
        }
        
        public var isEmpty: Bool {
            count == 0
        }
        
        public var count: Int {
            properties.count + classProperties.count + methods.count + classMethods.count + ivars.count
        }

    }
    
    public func selectedClassValues() -> ClassValues {
        guard let textStorage, textStorage.length > 0 else {
            return ClassValues()
        }
        var seenValues: [NSAttributedString.Key: Set<String>] = [:]
        var _values: [NSAttributedString.Key: [String]] = [:]
        func values(for key: NSAttributedString.Key) -> [String] { _values[key, default: []] }
        func collect(_ key: NSAttributedString.Key, in range: NSRange) {
            textStorage.enumerateAttribute(key, in: range) { value, _, _ in
                guard let name = value as? String, seenValues[key, default: []].insert(name).inserted else { return }
                _values[key, default: []] += name
            }
        }
        for selectedRange in selectedRanges.map(\.rangeValue) {
            guard selectedRange.location != NSNotFound, selectedRange.length > 0 else { continue }
            let boundedRange = NSIntersectionRange(selectedRange, NSRange(location: 0, length: textStorage.length))
            guard boundedRange.length > 0 else { continue }
            collect(.objcProperty, in: boundedRange)
            collect(.objcClassProperty, in: boundedRange)
            collect(.objcMethod, in: boundedRange)
            collect(.objcClassMethod, in: boundedRange)
            collect(.objcIvar, in: boundedRange)
        }
        return ClassValues(properties: values(for: .objcProperty), classProperties: values(for: .objcClassProperty), methods: values(for: .objcMethod), classMethods: values(for: .objcClassMethod), ivars: values(for: .objcIvar))
    }

    private enum ClickableSymbol {
        case `class`(String)
        case `protocol`(String)
        case image(String)
    }
}


#endif
