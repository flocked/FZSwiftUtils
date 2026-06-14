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
    
    /// A Boolean value indicating whether Objective-C class and protocol names can be clicked.
    public var canClickObjCTypes: Bool = true
    /// A Boolean value indicating whether images can be clicked.
    public var canClickImages: Bool = true
    
    /// An action available for an Objective-C symbol in the text view.
    public enum SymbolAction {
        /// Opens the class with the specified name.
        case openClassByName(String)
        /// Opens the specified class.
        case openClass(ObjCClassInfo)
        /// Opens the protocol with the specified name.
        case openProtocolByName(String)
        /// Opens the specified protocol.
        case openProtocol(ObjCProtocolInfo)
        /// Finds classes that conform to the specified protocol.
        case findProtocolConformers(ObjCProtocolInfo)
        /// Finds subclasses of the specified class.
        case findSubclasses(ObjCClassInfo)
        /// Exports the Objective-C header for the specified class.
        case exportHeader(ObjCClassInfo)
        /// Exports the Objective-C header for the specified protocol.
        case exportProtocolHeader(ObjCProtocolInfo)
        /// Opens the specified Objective-C image.
        case openImage(String)
    }

    /// The handler called when a symbol action is selected from the context menu.
    public var symbolActionHandler: ((SymbolAction) -> Void)?

    private var hoveredClickableRange: NSRange?
    private var contextMenuSelectedRanges: [NSValue]?

    open override func rightMouseDown(with event: NSEvent) {
        contextMenuSelectedRanges = selectedRanges
        super.rightMouseDown(with: event)
        contextMenuSelectedRanges = nil
    }
    
    open override func menu(for event: NSEvent) -> NSMenu? {
        guard let characterIndex = characterIndex(at: event.locationInWindow, requiresGlyphHit: false) else {
            return nil
        }
        let owner = owningDeclaration(at: characterIndex)
        if let member = member(at: characterIndex),
           let owner {
            switch owner {
            case .class(let name):
                return memberMenu(for: member.value, range: member.range, className: name, event: event)
            case .protocol(let name):
                return protocolMemberMenu(for: member.value, range: member.range, protocolName: name, event: event)
            }
        }
        if let symbol = clickableSymbol(at: characterIndex),
           let menu = symbolMenu(for: symbol) {
            appendOwnerItems(for: owner, to: menu)
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

        let menu = NSMenu()
        appendOwnerItems(for: owner, to: menu)
        guard !menu.items.isEmpty else { return nil }
        menu.allowsContextMenuPlugIns = false
        return menu
    }

    private func appendOwnerItems(for owner: DeclarationOwner?, to menu: NSMenu) {
        guard let owner else { return }
        let items: [NSMenuItem]
        switch owner {
        case .class(let name):
            guard let info = ObjCClassInfo(name) else { return }
            items = classOwnerMenuItems(for: info)
        case .protocol(let name):
            guard let info = ObjCProtocolInfo(name) else { return }
            items = protocolOwnerMenuItems(for: info)
        }
        guard !items.isEmpty else { return }
        if !menu.items.isEmpty, menu.items.last?.isSeparatorItem != true {
            menu.addItem(.separator())
        }
        items.forEach(menu.addItem)
    }

    private func classOwnerMenuItems(for info: ObjCClassInfo) -> [NSMenuItem] {
        var items: [NSMenuItem] = []
        if let protocolString = info.swiftProtocolString(
            forMethods: Set(info.methods.map(\.name)),
            classMethods: Set(info.classMethods.map(\.name)),
            properties: Set(info.properties.map(\.name)),
            classProperties: Set(info.classProperties.map(\.name)),
            handleUnknownTypes: true
        ) {
            items.append(copyMenuItem(title: "Copy Class as Swift Protocol", string: protocolString))
        }
        items.append(symbolActionMenuItem(title: "Export Class Header…", action: .exportHeader(info)))
        return items
    }

    private func protocolOwnerMenuItems(for info: ObjCProtocolInfo) -> [NSMenuItem] {
        let values = ClassValues(
            properties: uniqueStrings((info.properties + info.optionalProperties).map(\.name)),
            classProperties: uniqueStrings((info.classProperties + info.optionalClassProperties).map(\.name)),
            methods: uniqueStrings((info.methods + info.optionalMethods).map(\.name)),
            classMethods: uniqueStrings((info.classMethods + info.optionalClassMethods).map(\.name))
        )
        var items: [NSMenuItem] = []
        if let protocolString = info.swiftProtocolString(
            forMethods: Set(values.methods),
            classMethods: Set(values.classMethods),
            properties: Set(values.properties),
            classProperties: Set(values.classProperties),
            handleUnknownTypes: true
        ) {
            items.append(copyMenuItem(title: "Copy Protocol as Swift Protocol", string: protocolString))
        }
        items.append(symbolActionMenuItem(title: "Export Protocol Header…", action: .exportProtocolHeader(info)))
        return items
    }

    private func symbolMenu(for symbol: ClickableSymbol) -> NSMenu? {
        let menu = NSMenu()
        switch symbol {
        case .class(let name):
            guard let info = ObjCClassInfo(name) else { return nil }
            menu.addItem(symbolActionMenuItem(title: "Show \"\(name)\"", action: .openClass(info)))
            menu.addItem(symbolActionMenuItem(title: "Show all subclasses of \"\(name)\"", action: .findSubclasses(info)))
        case .protocol(let name):
            guard let info = ObjCProtocolInfo(name) else { return nil }
            menu.addItem(symbolActionMenuItem(title: "Show \"\(name)\"", action: .openProtocol(info)))
            menu.addItem(symbolActionMenuItem(title: "Show all classes using \"\(name)\"", action: .findProtocolConformers(info)))
        case .image(let name):
            menu.addItem(symbolActionMenuItem(title: "Show \"\(name)\"", action: .openImage(name)))
        }
        return menu
    }

    private func symbolActionMenuItem(title: String, action: SymbolAction) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(performSymbolAction(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = action
        return item
    }

    @objc private func performSymbolAction(_ sender: NSMenuItem) {
        guard let action = sender.representedObject as? SymbolAction else { return }
        symbolActionHandler?(action)
    }

    private func memberMenu(for member: HeaderMember, range: NSRange, className: String, event: NSEvent) -> NSMenu? {
        let previousSelectedRanges = contextMenuSelectedRanges ?? selectedRanges
        let menu = NSMenu()
        guard let info = ObjCClassInfo(className) else { return menu }
        let selectedValues = selectedClassValues(in: previousSelectedRanges).filter(info)
        let clickedSelectionRange = NSRange(location: range.location, length: max(range.length, 1))
        let clickedInsideSelection = previousSelectedRanges.contains {
            NSIntersectionRange($0.rangeValue, clickedSelectionRange).length > 0
        }
        let usesMultipleSelection = clickedInsideSelection && selectedValues.count > 1
        var items = usesMultipleSelection
            ? aggregateMenuItems(for: selectedValues, info: info, className: className)
            : menuItems(for: member, info: info, className: className)

        let extensionValues = usesMultipleSelection ? selectedValues : classValues(for: member)
        var addedSelectedMemberCode = false
        if let extensionString = info.swiftExtensionString(
            forMethods: Set(extensionValues.methods),
            classMethods: Set(extensionValues.classMethods),
            properties: Set(extensionValues.properties),
            classProperties: Set(extensionValues.classProperties),
            ivars: Set(extensionValues.ivars),
            handleUnknownTypes: true
        ) {
            if !items.isEmpty {
                items.append(.separator())
            }
            let title = usesMultipleSelection
                ? "Copy Selected Members as Swift Extension"
                : "Copy Member as Swift Extension"
            items.append(copyMenuItem(title: title, string: extensionString))
            addedSelectedMemberCode = true
        }
        if let protocolString = info.swiftProtocolString(
            forMethods: Set(extensionValues.methods),
            classMethods: Set(extensionValues.classMethods),
            properties: Set(extensionValues.properties),
            classProperties: Set(extensionValues.classProperties),
            handleUnknownTypes: true
        ) {
            if !addedSelectedMemberCode, !items.isEmpty {
                items.append(.separator())
            }
            let title = usesMultipleSelection
                ? "Copy Selected Members as Swift Protocol"
                : "Copy Member as Swift Protocol"
            items.append(copyMenuItem(title: title, string: protocolString))
        }
        items.append(.separator())
        items += classOwnerMenuItems(for: info)
        guard !items.isEmpty else { return menu }
        if !menu.items.isEmpty {
            menu.insertItem(.separator(), at: 0)
        }
        for item in items.reversed() {
            menu.insertItem(item, at: 0)
        }
        menu.allowsContextMenuPlugIns = false
        let selectedMemberRanges = usesMultipleSelection
            ? declarationRanges(in: previousSelectedRanges)
            : [range]
        highlightMembers(selectedMemberRanges, whileTracking: menu, restoring: previousSelectedRanges)
        return menu
    }

    private func protocolMemberMenu(for member: HeaderMember, range: NSRange, protocolName: String, event: NSEvent) -> NSMenu? {
        let previousSelectedRanges = contextMenuSelectedRanges ?? selectedRanges
        let menu = NSMenu()
        guard let info = ObjCProtocolInfo(protocolName) else { return menu }
        let selectedValues = selectedClassValues(in: previousSelectedRanges).filter(info)
        let clickedSelectionRange = NSRange(location: range.location, length: max(range.length, 1))
        let clickedInsideSelection = previousSelectedRanges.contains {
            NSIntersectionRange($0.rangeValue, clickedSelectionRange).length > 0
        }
        let usesMultipleSelection = clickedInsideSelection && selectedValues.count > 1
        let values = usesMultipleSelection ? selectedValues : classValues(for: member)
        var items: [NSMenuItem] = []

        let selectors = protocolSelectors(for: values, info: info)
        if !selectors.isEmpty {
            items.append(copyMenuItem(
                title: selectors.count == 1 ? "Copy Selector" : "Copy Selectors",
                string: selectors.joined(separator: "\n")
            ))
        }
        if let protocolString = info.swiftProtocolString(
            forMethods: Set(values.methods),
            classMethods: Set(values.classMethods),
            properties: Set(values.properties),
            classProperties: Set(values.classProperties),
            handleUnknownTypes: true
        ) {
            if !items.isEmpty { items.append(.separator()) }
            items.append(copyMenuItem(title: "Copy Selected Members as Swift Protocol", string: protocolString))
        }

        items.append(.separator())
        items += protocolOwnerMenuItems(for: info)

        if !menu.items.isEmpty { menu.insertItem(.separator(), at: 0) }
        for item in items.reversed() { menu.insertItem(item, at: 0) }
        menu.allowsContextMenuPlugIns = false
        let highlightedRanges = usesMultipleSelection ? declarationRanges(in: previousSelectedRanges) : [range]
        highlightMembers(highlightedRanges, whileTracking: menu, restoring: previousSelectedRanges)
        return menu
    }

    private func protocolSelectors(for values: ClassValues, info: ObjCProtocolInfo) -> [String] {
        let methods = info.methods + info.optionalMethods + info.classMethods + info.optionalClassMethods
        let properties = info.properties + info.optionalProperties + info.classProperties + info.optionalClassProperties
        var selectors = methods.filter {
            ($0.isClassMethod ? values.classMethods : values.methods).contains($0.name)
        }.map(\.name)
        for property in properties where (property.isClassProperty ? values.classProperties : values.properties).contains(property.name) {
            selectors.append(property.getterName)
            if let setterName = property.setterName { selectors.append(setterName) }
        }
        return uniqueStrings(selectors)
    }

    private func highlightMembers(_ ranges: [NSRange], whileTracking menu: NSMenu, restoring selectedRanges: [NSValue]) {
        let ranges = ranges.filter { $0.location != NSNotFound && $0.length > 0 }
        guard !ranges.isEmpty else { return }
        menuBeginNotificationToken = NotificationCenter.default.observe(NSMenu.didBeginTrackingNotification, postedBy: menu) { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.setSelectedRanges(ranges.map(NSValue.init(range:)), affinity: .downstream, stillSelecting: false)
            }
        }
        menuNotificationToken = NotificationCenter.default.observe(NSMenu.didEndTrackingNotification, postedBy: menu) { [weak self] _ in
            guard let self else { return }
            self.setSelectedRanges(selectedRanges, affinity: .downstream, stillSelecting: false)
            self.menuBeginNotificationToken = nil
            self.menuNotificationToken = nil
        }
    }

    private func menuItems(for member: HeaderMember, info: ObjCClassInfo, className: String) -> [NSMenuItem] {
        switch member {
        case .method(let method):
            return menuItems(for: method, className: className, title: nil)
        case .property(let property):
            let accessors = accessors(for: property, info: info)
            var items: [NSMenuItem] = []
            if accessors.getter != nil {
                items.append(copyMenuItem(title: "Copy Getter Selector", string: property.getterName))
            }
            if let setterName = property.setterName, accessors.setter != nil {
                items.append(copyMenuItem(title: "Copy Setter Selector", string: setterName))
            }
            if let getter = accessors.getter {
                items += hookMenuItems(for: getter, className: className, title: "Getter")
            }
            if let setter = accessors.setter {
                items += hookMenuItems(for: setter, className: className, title: "Setter")
            }
            return items
        case .ivar:
            return []
        }
    }

    private func classValues(for member: HeaderMember) -> ClassValues {
        switch member {
        case .method(let method):
            return method.isClassMethod
                ? ClassValues(classMethods: [method.name])
                : ClassValues(methods: [method.name])
        case .property(let property):
            return property.isClassProperty
                ? ClassValues(classProperties: [property.name])
                : ClassValues(properties: [property.name])
        case .ivar(let ivar):
            return ClassValues(ivars: [ivar.name])
        }
    }

    private func aggregateMenuItems(for values: ClassValues, info: ObjCClassInfo, className: String) -> [NSMenuItem] {
        let methods = selectedMethods(for: values, info: info)
        let properties = selectedProperties(for: values, info: info)
        let propertyMethods = properties.flatMap { property -> [ObjCMethodInfo] in
            let propertyAccessors = accessors(for: property, info: info)
            return [propertyAccessors.getter, propertyAccessors.setter].compactMap { $0 }
        }
        let hookMethods = uniqueMethods(methods + propertyMethods)

        var selectorStrings = methods.map(\.name)
        for property in properties {
            let propertyAccessors = accessors(for: property, info: info)
            if propertyAccessors.getter != nil {
                selectorStrings.append(property.getterName)
            }
            if let setterName = property.setterName, propertyAccessors.setter != nil {
                selectorStrings.append(setterName)
            }
        }
        selectorStrings = uniqueStrings(selectorStrings)

        var items: [NSMenuItem] = []
        if !selectorStrings.isEmpty {
            items.append(copyMenuItem(title: "Copy Selectors", string: selectorStrings.joined(separator: "\n")))
        }
        let hooks = hookMethods.compactMap { $0.hookString(className: className) }
        if !hooks.isEmpty {
            items.append(copyMenuItem(title: "Copy Hook Codes", string: hooks.joined(separator: "\n\n")))
        }
        let hooksForAll = hookMethods.compactMap { $0.hookString(className: className, allInstances: true) }
        if !hooksForAll.isEmpty {
            let alternate = copyMenuItem(title: "Copy Hook Codes for All Instances", string: hooksForAll.joined(separator: "\n\n"))
            alternate.isAlternate = true
            alternate.keyEquivalentModifierMask = .option
            items.append(alternate)
        }
        return items
    }

    private func selectedMethods(for values: ClassValues, info: ObjCClassInfo) -> [ObjCMethodInfo] {
        info.methods.filter { values.methods.contains($0.name) }
            + info.classMethods.filter { values.classMethods.contains($0.name) }
    }

    private func selectedProperties(for values: ClassValues, info: ObjCClassInfo) -> [ObjCPropertyInfo] {
        info.properties.filter { values.properties.contains($0.name) }
            + info.classProperties.filter { values.classProperties.contains($0.name) }
    }

    private func accessors(for property: ObjCPropertyInfo, info: ObjCClassInfo) -> (getter: ObjCMethodInfo?, setter: ObjCMethodInfo?) {
        let methods = property.isClassProperty ? info.classMethods : info.methods
        return (
            methods.first(where: { $0.name == property.getterName }),
            property.setterName.flatMap { setterName in methods.first(where: { $0.name == setterName }) }
        )
    }

    private func uniqueMethods(_ methods: [ObjCMethodInfo]) -> [ObjCMethodInfo] {
        var seen = Set<String>()
        return methods.filter { seen.insert("\($0.isClassMethod):\($0.name)").inserted }
    }

    private func uniqueStrings(_ strings: [String]) -> [String] {
        var seen = Set<String>()
        return strings.filter { seen.insert($0).inserted }
    }

    private func menuItems(for method: ObjCMethodInfo, className: String, title: String?) -> [NSMenuItem] {
        let qualifier = title.map { " \($0)" } ?? ""
        var items = [copyMenuItem(title: "Copy\(qualifier) Selector", string: method.name)]
        items += hookMenuItems(for: method, className: className, title: title)
        return items
    }

    private func hookMenuItems(for method: ObjCMethodInfo, className: String, title: String?) -> [NSMenuItem] {
        let qualifier = title.map { " \($0)" } ?? ""
        guard let hook = method.hookString(className: className) else { return [] }
        var items = [copyMenuItem(title: "Copy\(qualifier) Hook Code", string: hook)]
        if !method.isClassMethod,
           let hookAll = method.hookString(className: className, allInstances: true) {
            let alternate = copyMenuItem(title: "Copy\(qualifier) Hook Code for All Instances", string: hookAll)
            alternate.isAlternate = true
            alternate.keyEquivalentModifierMask = .option
            items.append(alternate)
        }
        return items
    }

    private func copyMenuItem(title: String, string: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(copyMenuItemValue(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = string
        return item
    }

    @objc private func copyMenuItemValue(_ sender: NSMenuItem) {
        guard let string = sender.representedObject as? String else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }

    private func member(at characterIndex: Int) -> (value: HeaderMember, range: NSRange)? {
        guard let textStorage, characterIndex >= 0, characterIndex < textStorage.length else { return nil }
        var range = NSRange()
        if let method = textStorage.attribute(.objcMethod, at: characterIndex, effectiveRange: &range) as? ObjCMethodInfo {
            return (.method(method), declarationRange(for: .objcMethod, value: method, at: characterIndex) ?? range)
        }
        if let method = textStorage.attribute(.objcClassMethod, at: characterIndex, effectiveRange: &range) as? ObjCMethodInfo {
            return (.method(method), declarationRange(for: .objcClassMethod, value: method, at: characterIndex) ?? range)
        }
        if let property = textStorage.attribute(.objcProperty, at: characterIndex, effectiveRange: &range) as? ObjCPropertyInfo {
            return (.property(property), declarationRange(for: .objcProperty, value: property, at: characterIndex) ?? range)
        }
        if let property = textStorage.attribute(.objcClassProperty, at: characterIndex, effectiveRange: &range) as? ObjCPropertyInfo {
            return (.property(property), declarationRange(for: .objcClassProperty, value: property, at: characterIndex) ?? range)
        }
        if let ivar = textStorage.attribute(.objcIvar, at: characterIndex, effectiveRange: &range) as? ObjCIvarInfo {
            return (.ivar(ivar), declarationRange(for: .objcIvar, value: ivar, at: characterIndex) ?? range)
        }
        return nil
    }

    private func declarationRange<T: Equatable>(for attribute: NSAttributedString.Key, value: T, at characterIndex: Int) -> NSRange? {
        guard let textStorage else { return nil }
        let text = textStorage.string as NSString
        var lineRange = text.lineRange(for: NSRange(location: characterIndex, length: 0))
        while lineRange.length > 0,
              CharacterSet.newlines.contains(UnicodeScalar(text.character(at: NSMaxRange(lineRange) - 1))!) {
            lineRange.length -= 1
        }
        var result = NSRange(location: NSNotFound, length: 0)
        textStorage.enumerateAttribute(attribute, in: lineRange) { attributeValue, range, _ in
            guard let candidate = attributeValue as? T, candidate == value else { return }
            result = result.location == NSNotFound ? range : NSUnionRange(result, range)
        }
        return result.location == NSNotFound ? nil : lineRange
    }

    private func owningDeclaration(at characterIndex: Int) -> DeclarationOwner? {
        guard let textStorage else { return nil }
        let text = textStorage.string as NSString
        var location = min(characterIndex, text.length)
        while location > 0 {
            let lineRange = text.lineRange(for: NSRange(location: max(0, location - 1), length: 0))
            let line = text.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines)
            if line.hasPrefix("@interface ") {
                let name = line.dropFirst("@interface ".count)
                    .prefix { $0.isLetter || $0.isNumber || $0 == "_" }
                    .description
                return .class(name)
            }
            if line.hasPrefix("@protocol ") {
                let name = line.dropFirst("@protocol ".count)
                    .prefix { $0.isLetter || $0.isNumber || $0 == "_" }
                    .description
                return .protocol(name)
            }
            location = lineRange.location
        }
        return nil
    }
    
    var menuNotificationToken: NotificationToken?
    var menuBeginNotificationToken: NotificationToken?

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

    open override func mouseMoved(with event: NSEvent) {
        updateHover(for: event)
        window?.invalidateCursorRects(for: self)
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
            NSCursor.iBeam.set()
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
            symbolActionHandler?(.openClassByName(name))
        case .protocol(let name):
            symbolActionHandler?(.openProtocolByName(name))
        case .image(let name):
            symbolActionHandler?(.openImage(name))
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
        if canClickObjCTypes, let className = textStorage.attribute(.objcClassName, at: characterIndex, effectiveRange: nil) as? String {
            return .class(className)
        }
        if canClickObjCTypes, let protocolName = textStorage.attribute(.objcProtocolName, at: characterIndex, effectiveRange: nil) as? String {
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
        if canClickObjCTypes, textStorage.attribute(.objcClassName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        if canClickObjCTypes, textStorage.attribute(.objcProtocolName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        if canClickImages, textStorage.attribute(.objcImageName, at: characterIndex, effectiveRange: &range) != nil {
            return range
        }
        return nil
    }

    private func characterIndex(at windowPoint: NSPoint, requiresGlyphHit: Bool = true) -> Int? {
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
        guard layoutManager.numberOfGlyphs > 0 else { return nil }
        if glyphIndex >= layoutManager.numberOfGlyphs {
            return requiresGlyphHit ? nil : max(0, textStorage.length - 1)
        }
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
        guard !requiresGlyphHit || glyphRect.contains(pointInContainer) else {
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

        public func filter(_ info: ObjCProtocolInfo) -> ClassValues {
            var values = self
            let properties = info.properties + info.optionalProperties
            let classProperties = info.classProperties + info.optionalClassProperties
            let methods = info.methods + info.optionalMethods
            let classMethods = info.classMethods + info.optionalClassMethods
            values.properties = values.properties.filter { name in properties.contains { $0.name == name } }
            values.classProperties = values.classProperties.filter { name in classProperties.contains { $0.name == name } }
            values.methods = values.methods.filter { name in methods.contains { $0.name == name } }
            values.classMethods = values.classMethods.filter { name in classMethods.contains { $0.name == name } }
            values.ivars = []
            return values
        }
        
        public func swiftExtensionString(for info: ObjCClassInfo) -> String? {
            info.swiftExtensionString(forMethods: Set(methods), classMethods: Set(classMethods), properties: Set(properties), classProperties: Set(classProperties), ivars: Set(ivars))
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
        selectedClassValues(in: selectedRanges)
    }

    private func selectedClassValues(in selectedRanges: [NSValue]) -> ClassValues {
        guard let textStorage, textStorage.length > 0 else {
            return ClassValues()
        }
        var seenValues: [NSAttributedString.Key: Set<String>] = [:]
        var _values: [NSAttributedString.Key: [String]] = [:]
        func values(for key: NSAttributedString.Key) -> [String] { _values[key, default: []] }
        func collect(_ key: NSAttributedString.Key, in range: NSRange) {
            textStorage.enumerateAttribute(key, in: range) { value, _, _ in
                let name: String?
                switch value {
                case let info as ObjCPropertyInfo:
                    name = info.name
                case let info as ObjCMethodInfo:
                    name = info.name
                case let info as ObjCIvarInfo:
                    name = info.name
                case let nameValue as String:
                    name = nameValue
                default:
                    name = nil
                }
                guard let name, seenValues[key, default: []].insert(name).inserted else { return }
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

    private func declarationRanges(in selectedRanges: [NSValue]) -> [NSRange] {
        guard let textStorage, textStorage.length > 0 else { return [] }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        let attributes: [NSAttributedString.Key] = [.objcProperty, .objcClassProperty, .objcMethod, .objcClassMethod, .objcIvar]
        let text = textStorage.string as NSString
        var ranges: [NSRange] = []
        var seenLocations = Set<Int>()

        for selectedRange in selectedRanges.map(\.rangeValue) {
            let boundedRange = NSIntersectionRange(selectedRange, fullRange)
            guard boundedRange.length > 0 else { continue }
            for attribute in attributes {
                textStorage.enumerateAttribute(attribute, in: boundedRange) { value, range, _ in
                    guard value != nil else { return }
                    var lineRange = text.lineRange(for: NSRange(location: range.location, length: 0))
                    while lineRange.length > 0,
                          CharacterSet.newlines.contains(UnicodeScalar(text.character(at: NSMaxRange(lineRange) - 1))!) {
                        lineRange.length -= 1
                    }
                    if lineRange.length > 0, seenLocations.insert(lineRange.location).inserted {
                        ranges.append(lineRange)
                    }
                }
            }
        }
        return ranges.sorted { $0.location < $1.location }
    }

    private enum ClickableSymbol {
        case `class`(String)
        case `protocol`(String)
        case image(String)
    }

    private enum HeaderMember {
        case method(ObjCMethodInfo)
        case property(ObjCPropertyInfo)
        case ivar(ObjCIvarInfo)
    }

    private enum DeclarationOwner {
        case `class`(String)
        case `protocol`(String)
    }
}

private extension ObjCMethodInfo {
    func selectorExpression(className: String) -> String {
        "#selector(\(className).\(swiftSelectorName))"
    }

    var swiftSelectorName: String {
        let components = name.split(separator: ":", omittingEmptySubsequences: false).dropLast().map(String.init)
        guard !components.isEmpty else { return name }
        guard !argumentTypes.isEmpty else { return components[0] }

        let first = swiftFirstSelectorComponent(components[0])
        let remainingLabels = components.dropFirst().map { "\($0.lowercasedFirst()):" }
        return "\(first.name)(\(([first.label + ":"] + remainingLabels).joined()))"
    }

    func hookString(className: String, allInstances: Bool = false) -> String? {
        guard !allInstances || !isClassMethod else { return nil }
        guard let returnType = returnType.resolvedSwiftType else { return nil }
        let argumentTypes = argumentTypes.compactMap(\.resolvedSwiftType)
        guard argumentTypes.count == self.argumentTypes.count else { return nil }

        let receiverType = isClassMethod ? "\(className).Type" : className
        let receiverName = isClassMethod ? "type" : instanceName(for: className)
        let target = isClassMethod || allInstances ? className : receiverName
        let selectorComponents = name.split(separator: ":", omittingEmptySubsequences: false).dropLast().map(String.init)
        var takenNames: Set<String> = ["original", receiverName, "selector"]
        let argumentNames = argumentTypes.indices.map { index in
            let headerName = signature.arguments[index + 2].name.flatMap { $0.isEmpty ? nil : $0 }
            if let headerName, takenNames.insert(headerName).inserted {
                return headerName
            }
            let selectorComponent = selectorComponents.indices.contains(index) ? selectorComponents[index] : "arg"
            return NamingIntelligent.parameterName(from: selectorComponent, takenNames: &takenNames)
        }
        let closureParameters = (["original", receiverName, "selector"] + argumentNames).joined(separator: ", ")
        let invocation = ([receiverName, "selector"] + argumentNames).joined(separator: ", ")
        let swiftReturnType = returnType == "Void" ? "()" : returnType
        let functionArguments = ([receiverType, "Selector"] + argumentTypes).joined(separator: ", ")
        let selectorExpression = "NSSelectorFromString(\(String(reflecting: name)))"
        let hookCall = allInstances
            ? "hook(all: \(selectorExpression), closure:"
            : "hook(\(selectorExpression), closure:"
        let bodyLines: [String]
        if returnType == "Void" {
            bodyLines = [
                "        // handle.",
                "        original(\(invocation))"
            ]
        } else {
            bodyLines = [
                "        let result = original(\(invocation))",
                "        // handle.",
                "        return result"
            ]
        }
        return ([
            "do {",
            "    try \(target).\(hookCall) {",
            "        \(closureParameters) in"
        ] + bodyLines + [
            "    } as @convention(block) (",
            "        (\(functionArguments)) -> \(swiftReturnType),",
            "        \(functionArguments)) -> \(swiftReturnType))",
            "} catch {",
            "    Swift.print(error)",
            "}"
        ]).joined(separator: "\n")
    }

    func swiftFirstSelectorComponent(_ component: String) -> (name: String, label: String) {
        let prepositions = ["With", "From", "For", "To", "In", "On", "At", "By", "Of", "As"]
        for preposition in prepositions {
            guard let range = component.range(of: preposition, options: .backwards), range.lowerBound != component.startIndex else { continue }
            return (String(component[..<range.lowerBound]), preposition.lowercased())
        }
        if argumentTypes.first?.resolvedSwiftType?.hasSuffix("Event") == true {
            return (component, "with")
        }
        return (component, "_")
    }

    func instanceName(for className: String) -> String {
        instanceName(for: className, fallback: "object")
    }

    func instanceName(for typeName: String, fallback: String) -> String {
        guard typeName.first?.isLetter == true,
              !typeName.contains("<"),
              !typeName.contains("(") else { return fallback }
        var name = typeName
        for prefix in ["NS", "UI"] where name.hasPrefix(prefix) && name.count > prefix.count {
            name.removeFirst(prefix.count)
            break
        }
        let result = name.lowercasedFirst()
        return result.isEmpty ? fallback : result
    }
}

private extension ObjCPropertyInfo {
    func selectorString(className: String, setter: Bool) -> String {
        let accessor = setter ? "setter" : "getter"
        return "NSStringFromSelector(#selector(\(accessor): \(className).\(name)))"
    }
}


#endif
