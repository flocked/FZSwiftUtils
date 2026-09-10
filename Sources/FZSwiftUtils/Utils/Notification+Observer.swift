//
//  Notification+Observer.swift
//  
//
//  Created by Florian Zand on 04.09.26.
//

import Foundation

public extension Notification {
    /// Provides notification observations for an object.
    struct Observer<Object> {
        private let object: Object?
        
        init(_ object: Object?) {
            self.object = object
        }
        
        /**
         Observes notifications posted by the object for the specified notification name.

         - Parameters:
           - keyPath: The key path to the notification name to observe.
           - handler: The handler to call with the posting object and the notification's user information.
         - Returns: A token representing the notification observation.
         */
        func callAsFunction(_ keyPath: KeyPath<Object.Type, Notification.Name>, handler: @escaping (_ object: Object, _ userInfo: [AnyHashable: Any]) -> ()) -> NotificationToken {
            NotificationCenter.default.observe(Object.self[keyPath: keyPath], postedBy: object) {
                guard let object = $0.object as? Object else { return }
                handler(object, $0.userInfo ?? [:])
            }
        }
        
        /**
         Observes notifications posted by the object for the specified notification name.

         - Parameters:
           - keyPath: The key path to the notification name to observe.
           - handler: The handler to call with the posting object and the notification's user information.
         - Returns: A token representing the notification observation.
         */
        public subscript(_ keyPath: KeyPath<Object.Type, Notification.Name>, handler handler: @escaping (_ object: Object, _ userInfo: [AnyHashable: Any]) -> ()) -> NotificationToken {
            self(keyPath, handler: handler)
        }
    }
}

fileprivate extension Notification.Observer {
    func observe(_ name: Notification.Name, _ handler: @escaping ()->()) -> NotificationToken {
        observe(name) { _ in handler() }
    }
    
    @_disfavoredOverload
    func observe(_ name: Notification.Name, _ handler: @escaping (_ userInfo: [AnyHashable: Any]) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: object) {
            handler($0.userInfo ?? [:])
        }
    }
    
    func observe(_ name: Notification.Name, _ handler: @escaping (_ object: Object)->()) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: object) {
            guard let object = $0.object as? Object else { return }
            handler(object)
        }
    }
    
    func observe(_ name: Notification.Name, _ handler: @escaping (_ object: Object, _ userInfo: [AnyHashable: Any]) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: object) {
            guard let object = $0.object as? Object else { return }
            handler(object, $0.userInfo ?? [:])
        }
    }
    
    func observe<V1>(_ name: Notification.Name, _ key1: AnyHashable, _ handler: @escaping (_ object: Object, V1)->()) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: object) {
            guard let object = $0.object as? Object, let v1 = $0.userInfo?[key1] as? V1 else { return }
            handler(object, v1)
        }
    }
    
    func observe<V1, V2>(_ name: Notification.Name, _ key1: AnyHashable, _ key2: AnyHashable, _ handler: @escaping (_ object: Object, V1, V2)->()) -> NotificationToken {
        NotificationCenter.default.observe(name, postedBy: object) {
            guard let object = $0.object as? Object, let v1 = $0.userInfo?[key1] as? V1, let v2 = $0.userInfo?[key2] as? V2 else { return }
            handler(object, v1, v2)
        }
    }
    
    func observe(_ name1: Notification.Name, _ name2: Notification.Name, _ handler: @escaping (Object, Bool) -> ()) -> NotificationToken {
      NotificationCenter.default.observe(name1, postedBy: object) {
            guard let object = $0.object as? Object else { return }
            handler(object, true)
        } + NotificationCenter.default.observe(name2, postedBy: object) {
            guard let object = $0.object as? Object else { return }
            handler(object, false)
        }
    }
    
    func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping ()->()) -> NotificationToken {
        observe(keyPath) { _ in handler() }
    }
    
    @_disfavoredOverload
    func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ userInfo: [AnyHashable: Any]) -> ()) -> NotificationToken {
        observe(Object.self[keyPath: keyPath], handler)
    }
    
    func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ object: Object)->()) -> NotificationToken {
        observe(Object.self[keyPath: keyPath], handler)
    }
    
    func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ object: Object, _ userInfo: [AnyHashable: Any]) -> ()) -> NotificationToken {
        observe(Object.self[keyPath: keyPath], handler)
    }
    
    func observe<V1>(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ key1: AnyHashable, _ handler: @escaping (_ object: Object, V1)->()) -> NotificationToken {
        observe(Object.self[keyPath: keyPath], key1, handler)
    }
    
    func observe<V1, V2>(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ key1: AnyHashable, _ key2: AnyHashable, _ handler: @escaping (_ object: Object, V1, V2)->()) -> NotificationToken {
        observe(Object.self[keyPath: keyPath], key1, key2, handler)
    }
    
    func observe(_ keyPath1: KeyPath<Object.Type, Notification.Name>, _ keyPath2: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (Object, Bool) -> ()) -> NotificationToken {
      observe(Object.self[keyPath: keyPath1], Object.self[keyPath: keyPath2], handler)
    }
}

public extension NSObjectProtocol where Self: Bundle {
    /// Provides observations of notifications posted by the bundle.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: Bundle {
    func didLoad(handler: @escaping (_ bundle: Object, _ classes: [String]) -> ()) -> NotificationToken {
        return observe(\.didLoadNotification) {
            guard let classes = $1[NSLoadedClasses] as? [String] else { return }
            handler($0, classes)
        }
    }
}

public extension Calendar {
    /// Provides observations of global calendar notifications.
    static var observer: Notification.Observer<Calendar.Type> {
        .init(nil)
    }
}

public extension Notification.Observer where Object == Calendar.Type {
    func calendarDayChanged(handler: @escaping () -> ()) -> NotificationToken {
        NotificationCenter.default.observe(.NSCalendarDayChanged) { _ in handler() }
    }
}

public extension TimeZone {
    /// Provides observations of global time zone notifications.
    static var observer: Notification.Observer<TimeZone.Type> {
        .init(nil)
    }
}

public extension Notification.Observer where Object == TimeZone.Type {
    func systemTimeZoneDidChange(handler: @escaping (_ timeZone: TimeZone) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(.NSSystemTimeZoneDidChange) { _ in handler(.current) }
    }
}


#if os(macOS)
import AppKit

public extension NSObjectProtocol where Self: NSView {
    /// Provides observations of notifications posted by the view.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSView {
    func boundsDidChange(handler: @escaping (_ view: Object)->()) -> NotificationToken {
        object!.postsBoundsChangedNotifications = true
        return observe(\.boundsDidChangeNotification, handler)
    }
    
    func frameDidChange(handler: @escaping (_ view: Object)->()) -> NotificationToken {
        object!.postsFrameChangedNotifications = true
        return observe(\.frameDidChangeNotification, handler)
    }
    
    func didUpdateTrackingAreas(handler: @escaping (_ view: Object)->()) -> NotificationToken {
        observe(\.didUpdateTrackingAreasNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSScrollView {
    /// Provides observations of notifications posted by the scroll view.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSScrollView {
    func willStartLiveScroll(handler: @escaping (_ scrollView: Object)->()) -> NotificationToken {
        observe(\.willStartLiveScrollNotification, handler)
    }
    
    func didLiveScroll(handler: @escaping (_ scrollView: Object)->()) -> NotificationToken {
        observe(\.didLiveScrollNotification, handler)
    }
    
    func willStartLiveMagnify(handler: @escaping (_ scrollView: Object)->()) -> NotificationToken {
        observe(\.willStartLiveMagnifyNotification, handler)
    }
    
    func didEndLiveScroll(handler: @escaping (_ scrollView: Object)->()) -> NotificationToken {
        observe(\.didEndLiveScrollNotification, handler)
    }
    
    func didEndLiveMagnify(handler: @escaping (_ scrollView: Object)->()) -> NotificationToken {
        observe(\.didEndLiveMagnifyNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSSplitView {
    /// Provides observations of notifications posted by the split view.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSSplitView {
    func willResizeSubviews(handler: @escaping (_ splitView: Object, _ dividerIndex: Int, _ byUser: Bool)->()) -> NotificationToken {
        observe(\.willResizeSubviewsNotification) {
            guard let dividerIndex = $1["NSSplitViewDividerIndex"] as? Int else { return }
            handler($0, dividerIndex, $1["NSSplitViewUserResizeKey"] as? Int ?? 0 == 1)
        }
    }
    
    func didResizeSubviews(handler: @escaping (_ splitView: Object, _ dividerIndex: Int, _ byUser: Bool)->()) -> NotificationToken {
        observe(\.didResizeSubviewsNotification) {
            guard let dividerIndex = $1["NSSplitViewDividerIndex"] as? Int else { return }
            handler($0, dividerIndex, $1["NSSplitViewUserResizeKey"] as? Int ?? 0 == 1)
        }
    }
}

public extension NSObjectProtocol where Self: NSMenu {
    /// Provides observations of notifications posted by the menu.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSMenu {
    func didAddItem(handler: @escaping (_ menu: Object, _ item: NSMenuItem) -> ()) -> NotificationToken {
        observe(\.didAddItemNotification) {
            guard let index = $1["NSMenuItemIndex"] as? Int, let item = $0.item(at: index) else { return }
            handler($0, item)
        }
    }
    
    func didChangeItem(handler: @escaping (_ menu: Object, _ item: NSMenuItem) -> ()) -> NotificationToken {
        observe(\.didChangeItemNotification) {
            guard let index = $1["NSMenuItemIndex"] as? Int, let item = $0.item(at: index) else { return }
            handler($0, item)
        }
    }
    
    func willSendItemAction(handler: @escaping (_ menu: Object, _ item: NSMenuItem) -> ()) -> NotificationToken {
        observe(\.willSendActionNotification) {
            guard let item = $1["MenuItem"] as? NSMenuItem else { return }
            handler($0, item)
        }
    }
    
    func didSendItemAction(handler: @escaping (_ menu: Object, _ item: NSMenuItem) -> ()) -> NotificationToken {
        observe(\.didSendActionNotification) {
            guard let item = $1["MenuItem"] as? NSMenuItem else { return }
            handler($0, item)
        }
    }
            
    func didRemoveItem(handler: @escaping (_ menu: Object, _ index: Int) -> ()) -> NotificationToken {
        observe(\.didRemoveItemNotification) {
            guard let index = $1["NSMenuItemIndex"] as? Int else { return }
            handler($0, index)
        }
    }
    
    func didBeginTracking(handler: @escaping (_ menu: Object) -> ()) -> NotificationToken {
        observe(\.didBeginTrackingNotification) { menu, _ in handler(menu) }
    }
    
    func didEndTracking(handler: @escaping (_ menu: Object) -> ()) -> NotificationToken {
        observe(\.didEndTrackingNotification) { menu, _ in handler(menu) }
    }
}

public extension NSObjectProtocol where Self: NSPopover {
    /// Provides observations of notifications posted by the popover.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSPopover {
    func willShow(handler: @escaping (_ popover: Object) -> ()) -> NotificationToken {
        observe(\.willShowNotification, handler)
    }
    
    func didShow(handler: @escaping (_ popover: Object) -> ()) -> NotificationToken {
        observe(\.didShowNotification, handler)
    }
    
    func willClose(handler: @escaping (_ popover: Object, _ reason: NSPopover.CloseReason) -> ()) -> NotificationToken {
        observe(\.willCloseNotification, handler)
    }
    
    func didClose(handler: @escaping (_ popover: Object, _ reason: NSPopover.CloseReason) -> ()) -> NotificationToken {
        observe(\.didCloseNotification, handler)
    }
    
    private func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ popover: Object, _ reason: NSPopover.CloseReason) -> ()) -> NotificationToken {
        observe(keyPath, NSPopover.closeReasonUserInfoKey, handler)
    }
}

public extension NSObjectProtocol where Self: NSTableView {
    /// Provides observations of notifications posted by the table view.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSTableView {
    func columnDidMove(handler: @escaping (_ tableView: Object, _ column: NSTableColumn, _ oldIndex: Int, _ newIndex: Int) -> ()) -> NotificationToken {
        observe(\.columnDidMoveNotification) {
            guard let oldIndex = $1["NSOldColumn"] as? Int, let newIndex = $1["NSNewColumn"] as? Int, let column = $0.tableColumns[safe: newIndex] else { return }
            handler($0, column, oldIndex, newIndex)
        }
    }
    
    func columnDidResize(handler: @escaping (_ tableView: Object, _ column: NSTableColumn, _ oldWidth: CGFloat) -> ()) -> NotificationToken {
        observe(\.columnDidResizeNotification, "NSTableColumn", "NSOldWidth", handler)
    }
    
    func selectionDidChange(handler: @escaping (_ tableView: Object) -> ()) -> NotificationToken {
        observe(\.selectionDidChangeNotification, handler)
    }
    
    func selectionIsChanging(handler: @escaping (_ tableView: Object) -> ()) -> NotificationToken {
        observe(\.selectionIsChangingNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSControl {
    /// Provides observations of notifications posted by the control.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSControl {
    func textDidChange(handler: @escaping (_ control: Object, _ fieldEditor: NSText) -> ()) -> NotificationToken {
        observe(\.textDidChangeNotification, "NSFieldEditor", handler)
    }
    
    func textDidBeginEditing(handler: @escaping (_ control: Object, _ fieldEditor: NSText) -> ()) -> NotificationToken {
        observe(\.textDidBeginEditingNotification, "NSFieldEditor", handler)
    }
    
    func textDidEndEditing(handler: @escaping (_ control: Object, _ fieldEditor: NSText) -> ()) -> NotificationToken {
        observe(\.textDidEndEditingNotification, "NSFieldEditor", handler)
    }
}

public extension NSObjectProtocol where Self: NSWindow {
    /// Provides observations of notifications posted by the window.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSWindow {
    func didBecomeKey(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didBecomeKeyNotification, handler)
    }
    
    func didResignKey(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didResignKeyNotification, handler)
    }
    
    func didBecomeMain(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didBecomeMainNotification, handler)
    }
    
    func didResignMain(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didResignMainNotification, handler)
    }
    
    func willEnterFullScreen(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willEnterFullScreenNotification, handler)
    }
    
    func didEnterFullScreen(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didEnterFullScreenNotification, handler)
    }
    
    func willExitFullScreen(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willExitFullScreenNotification, handler)
    }
    
    func didExitFullScreen(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didExitFullScreenNotification, handler)
    }
    
    func willEnterVersionBrowser(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willEnterVersionBrowserNotification, handler)
    }
    
    func didEnterVersionBrowser(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didEnterVersionBrowserNotification, handler)
    }
    
    func willExitVersionBrowser(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willExitVersionBrowserNotification, handler)
    }
    
    func didExitVersionBrowser(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didExitVersionBrowserNotification, handler)
    }
    
    func didChangeBackingProperties(handler: @escaping (_ window: Object, _ oldScaleFactor: CGFloat, _ oldColorSpace: NSColorSpace) -> ()) -> NotificationToken {
        observe(\.didChangeBackingPropertiesNotification, NSWindow.oldScaleFactorUserInfoKey, NSWindow.oldColorSpaceUserInfoKey, handler)
    }
    
    func didChangeScreen(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didChangeScreenNotification, handler)
    }
    
    func didChangeOcclusionState(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didChangeOcclusionStateNotification, handler)
    }
    
    func didChangeScreenProfile(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didChangeScreenProfileNotification, handler)
    }
    
    func willMiniaturize(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willMiniaturizeNotification, handler)
    }
    
    func didMiniaturize(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didMiniaturizeNotification, handler)
    }
    
    func didDeminiaturize(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didDeminiaturizeNotification, handler)
    }
    
    func willBeginSheet(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willBeginSheetNotification, handler)
    }
    
    func didEndSheet(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didEndSheetNotification, handler)
    }
    
    func willStartLiveResize(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willStartLiveResizeNotification, handler)
    }
    
    func didEndLiveResize(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didEndLiveResizeNotification, handler)
    }
    
    func willMove(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willMoveNotification, handler)
    }
    
    func didMove(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didMoveNotification, handler)
    }
    
    func willClose(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.willCloseNotification, handler)
    }
    
    func didResize(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didResizeNotification, handler)
    }
    
    func didUpdate(handler: @escaping (_ window: Object) -> ()) -> NotificationToken {
        observe(\.didUpdateNotification, handler)
    }
    
    func didExpose(handler: @escaping (_ window: Object, _ rect: CGRect) -> ()) -> NotificationToken {
        observe(\.didExposeNotification, "NSExposedRect", handler)
    }
}

public extension NSObjectProtocol where Self: NSWorkspace {
    /// Provides observations of notifications posted by the workspace.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSWorkspace {
    func willLaunchApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.willLaunchApplicationNotification, handler)
    }
    
    func didLaunchApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.didLaunchApplicationNotification, handler)
    }
    
    func didTerminateApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.didTerminateApplicationNotification, handler)
    }
    
    func didActivateApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.didActivateApplicationNotification, handler)
    }
    
    func didDeactivateApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.didDeactivateApplicationNotification, handler)
    }
    
    func didHideApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.didHideApplicationNotification, handler)
    }
    
    func didUnhideApplication(handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        observe(\.didUnhideApplicationNotification, handler)
    }
    
    func sessionDidBecomeActive(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.sessionDidBecomeActiveNotification, handler)
    }
        
    func sessionDidResignActive(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.sessionDidResignActiveNotification, handler)
    }
    
    func didMountVolume(handler: @escaping (_ volume: URL) -> ()) -> NotificationToken {
        observe(\.didMountNotification, handler)
    }
    
    func willUnmountVolume(handler: @escaping (_ volume: URL) -> ()) -> NotificationToken {
        observe(\.willUnmountNotification, handler)
    }
    
    func didUnmountVolume(handler: @escaping (_ volume: URL) -> ()) -> NotificationToken {
        observe(\.didUnmountNotification, handler)
    }
    
    func didRenameVolume(handler: @escaping (_ oldURL: URL?, _ oldLocalizedName: String?, _ newURL: URL?, _ newLocalizedName: String?) -> ()) -> NotificationToken {
        observe(\.didRenameVolumeNotification) {
            handler($0[typed: NSWorkspace.oldVolumeURLUserInfoKey], $0[typed: NSWorkspace.oldLocalizedVolumeNameUserInfoKey], $0[typed: NSWorkspace.volumeURLUserInfoKey], $0[typed: NSWorkspace.localizedVolumeNameUserInfoKey])
        }
    }
    
    func didChangeFileLabels(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.didChangeFileLabelsNotification, handler)
    }
    
    func activeSpaceDidChange(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.activeSpaceDidChangeNotification, handler)
    }
    
    func didWake(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.didWakeNotification, handler)
    }
    
    func willPowerOff(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.willPowerOffNotification, handler)
    }
    
    func willSleep(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.willSleepNotification, handler)
    }
    
    func screensDidSleep(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.screensDidSleepNotification, handler)
    }
    
    func screensDidWake(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.screensDidWakeNotification, handler)
    }
    
    func accessibilityDisplayOptionsDidChange(handler: @escaping () -> ()) -> NotificationToken {
        observe(\.accessibilityDisplayOptionsDidChangeNotification, handler)
    }
    
    private func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ application: NSRunningApplication) -> ()) -> NotificationToken {
        object!.notificationCenter.observe(Object.self[keyPath: keyPath], postedBy: object) {
            guard let application = $0.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
            handler(application)
        }
    }
    
    private func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ volume: URL) -> ()) -> NotificationToken {
        observe(keyPath) {
            guard let path = $0["NSDevicePath"] as? String else { return }
            handler(.file(path))
        }
    }
}

public extension NSObjectProtocol where Self: NSApplication {
    /// Provides observations of notifications posted by the application.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSApplication {
    func willHide(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willHideNotification, handler)
    }
    
    func didHide(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didHideNotification, handler)
    }
    
    func willUnhide(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willUnhideNotification, handler)
    }
    
    func didUnhide(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didUnhideNotification, handler)
    }
    
    func didBecomeActive(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didBecomeActiveNotification, handler)
    }
    
    func didChangeScreenParameters(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didChangeScreenParametersNotification, handler)
    }
    
    func didChangeOcclusionState(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didChangeOcclusionStateNotification, handler)
    }
    
    func didFinishLaunching(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didFinishLaunchingNotification, handler)
    }
    
    func didResignActive(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didResignActiveNotification, handler)
    }
    
    func willUpdate(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willUpdateNotification, handler)
    }
    
    func didUpdate(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didUpdateNotification, handler)
    }
    
    func willBecomeActive(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willBecomeActiveNotification, handler)
    }
    
    func willFinishLaunching(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willFinishLaunchingNotification, handler)
    }
    
    func willResignActive(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willResignActiveNotification, handler)
    }
    
    func willTerminate(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.willTerminateNotification, handler)
    }
    
    func didFinishRestoringWindows(handler: @escaping (_ application: Object) -> ()) -> NotificationToken {
        observe(\.didFinishRestoringWindowsNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSComboBox {
    /// Provides observations of notifications posted by the combobox.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSComboBox {
    func willDismiss(handler: @escaping (_ comboBox: Object) -> ()) -> NotificationToken {
        observe(\.willDismissNotification, handler)
    }
    
    func willPopUp(handler: @escaping (_ comboBox: Object) -> ()) -> NotificationToken {
        observe(\.willPopUpNotification, handler)
    }
    
    func selectionDidChange(handler: @escaping (_ comboBox: Object) -> ()) -> NotificationToken {
        observe(\.selectionDidChangeNotification, handler)
    }
    
    func selectionIsChanging(handler: @escaping (_ comboBox: Object) -> ()) -> NotificationToken {
        observe(\.selectionIsChangingNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSHelpManager {
    /// Provides observations of notifications posted by the help manager.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSHelpManager {
    func contextHelpModeDidActivate(handler: @escaping (_ helpManager: Object) -> ()) -> NotificationToken {
        observe(\.contextHelpModeDidActivateNotification, handler)
    }
    
    func contextHelpModeDidDeactivate(handler: @escaping (_ helpManager: Object) -> ()) -> NotificationToken {
        observe(\.contextHelpModeDidDeactivateNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSTextView {
    /// Provides observations of notifications posted by the text view.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension NSTextView {
    /// Provides observations of notifications posted by the text view.
    static var observe: Notification.Observer<NSTextView.Type> {
        .init(self)
    }
}

public extension Notification.Observer where Object == NSTextView.Type {
    func willChangeNotifyingTextView(handler: @escaping (_ old: NSTextView?, _ new: NSTextView?) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSTextView.willChangeNotifyingTextViewNotification) {
            handler($0.userInfo?[typed: "NSOldNotifyingTextView"], $0.userInfo?[typed: "NSNewNotifyingTextView"])
        }
    }
}

/*
 NSTextView.willChangeNotifyingTextViewNotification
 */

public extension Notification.Observer where Object: NSTextView {
    func didChangeTypingAttributes(handler: @escaping (_ textView: Object) -> ()) -> NotificationToken {
        observe(\.didChangeTypingAttributesNotification, handler)
    }
    
    func didChangeSelection(handler: @escaping (_ textView: Object, _ oldRange: NSRange) -> ()) -> NotificationToken {
        observe(\.didChangeSelectionNotification) {
            guard let value = $1["NSOldSelectedCharacterRange"] as? NSValue else { return }
            handler($0, value.rangeValue)
        }
    }
    
    func willSwitchToNSLayoutManager(handler: @escaping (_ textView: Object) -> ()) -> NotificationToken {
        observe(\.willSwitchToNSLayoutManagerNotification, handler)
    }
    
    func didSwitchToNSLayoutManager(handler: @escaping (_ textView: Object) -> ()) -> NotificationToken {
        observe(\.didSwitchToNSLayoutManagerNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSText {
    /// Provides observations of notifications posted by the text.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSText {
    func didChange(handler: @escaping (_ text: Object) -> ()) -> NotificationToken {
        observe(\.didChangeNotification, handler)
    }
    
    func didBeginEditing(handler: @escaping (_ text: Object) -> ()) -> NotificationToken {
        observe(\.didBeginEditingNotification, handler)
    }
    
    func didEndEditing(handler: @escaping (_ text: Object, _ movement: NSTextMovement) -> ()) -> NotificationToken {
        observe(\.didEndEditingNotification) {
            guard let movement = $1[NSText.movementUserInfoKey] as? NSTextMovement else { return }
            handler($0, movement)
        }
    }
}

public extension NSObjectProtocol where Self: NSToolbar {
    /// Provides observations of notifications posted by the toolbar.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSToolbar {
    func willAddItem(handler: @escaping (_ toolbar: Object, _ item: NSToolbarItem, _ index: Int) -> ()) -> NotificationToken {
        observe(\.willAddItemNotification) {
            guard let item = $1["item"] as? NSToolbarItem, let index = $1["newIndex"] as? Int else { return }
            handler($0, item, index)
        }
    }
    
    func didRemoveItem(handler: @escaping (_ toolbar: Object, _ item: NSToolbarItem) -> ()) -> NotificationToken {
        observe(\.didRemoveItemNotification) {
            guard let item = $1["item"] as? NSToolbarItem else { return }
            handler($0, item)
        }
    }
}

public extension NSObjectProtocol where Self: NSFontCollection {
    /// Provides observations of notifications posted by the font collection.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSFontCollection {
    func didChange(handler: @escaping (_ fontCollection: Object, _ action: NSFontCollection.ActionTypeKey,  _ name: NSFontCollection.Name, _ oldName: NSFontCollection.Name?, _ visibility: NSFontCollection.Visibility) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSFontCollection.didChangeNotification, postedBy: nil) { [weak object] notification in
            let userInfo = notification.userInfo ?? [:]
            guard let name = userInfo[NSFontCollection.nameUserInfoKey] as? String, let object = object, NSFontCollection(name: .init(name)) === object, let action = userInfo[NSFontCollection.actionUserInfoKey] as? NSFontCollection.ActionTypeKey, let visibility: NSFontCollection.Visibility = userInfo[typed: NSFontCollection.visibilityUserInfoKey] else { return }
            handler(object, action, .init(name), userInfo[typed: NSFontCollection.oldNameUserInfoKey], visibility)
        }
    }
}

public extension NSColor {
    /// Provides observations of `NSColor`.
    static var observe: Notification.Observer<NSColor.Type> {
        .init(nil)
    }
}

public extension Notification.Observer where Object == NSColor.Type {
    func systemColorsDidChange(handler: @escaping () -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSColor.systemColorsDidChangeNotification) { _ in
            handler()
        }
    }
}

public extension NSObjectProtocol where Self: NSAnimation {
    /// Provides observations of notifications posted by the animation.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSAnimation {
    func didReachProgressMark(handler: @escaping (_ animation: Object, _ progressMark: NSAnimation.Progress) -> ()) -> NotificationToken {
        observe(\.progressMarkNotification) {
            guard let progressMark = $1[NSAnimation.progressMarkUserInfoKey] as? NSAnimation.Progress else { return }
            handler($0, progressMark)
        }
    }
}

public extension NSObjectProtocol where Self: NSPopUpButton {
    /// Provides observations of notifications posted by the popUp button.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSPopUpButton {
    func willPopUp(handler: @escaping (_ popUpButton: Object) -> ()) -> NotificationToken {
        observe(\.willPopUpNotification, handler)
    }
}

public extension NSObjectProtocol where Self: NSOutlineView {
    /// Provides observations of notifications posted by the outline view.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSOutlineView {
    func itemWillCollapse(handler: @escaping (_ outlineView: Object, _ item: Any) -> ()) -> NotificationToken {
        observe(\.itemWillCollapseNotification, handler)
    }
    
    func itemDidCollapse(handler: @escaping (_ outlineView: Object, _ item: Any) -> ()) -> NotificationToken {
        observe(\.itemDidCollapseNotification, handler)
    }
    
    func itemWillExpand(handler: @escaping (_ outlineView: Object, _ item: Any) -> ()) -> NotificationToken {
        observe(\.itemWillExpandNotification, handler)
    }
    
    func itemDidExpand(handler: @escaping (_ outlineView: Object, _ item: Any) -> ()) -> NotificationToken {
        observe(\.itemDidExpandNotification, handler)
    }
    
    private func observe(_ keyPath: KeyPath<Object.Type, Notification.Name>, _ handler: @escaping (_ outlineView: Object, _ item: Any) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(Object.self[keyPath: keyPath], postedBy: object) {
            guard let object = $0.object as? Object, let item = $0.userInfo?["NSObject"] else { return }
            handler(object, item)
        }
    }
}

public extension NSObjectProtocol where Self: NSRuleEditor {
    /// Provides observations of notifications posted by the rule editor.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSRuleEditor {
    func rowsDidChange(handler: @escaping (_ ruleEditor: Object) -> ()) -> NotificationToken {
        observe(\.rowsDidChangeNotification, handler)
    }
}

public extension NSScroller {
    /// Provides observations of notifications related to scrollers globally.
    static var observe: Notification.Observer<NSScroller.Type> {
        .init(self)
    }
}

public extension Notification.Observer where Object == NSScroller.Type {
    func preferredScrollerStyleDidChange(handler: @escaping (_ preferredScrollerStyle: NSScroller.Style) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSScroller.preferredScrollerStyleDidChangeNotification) { _ in
            handler(NSScroller.preferredScrollerStyle)
        }
    }
}

public extension NSObjectProtocol where Self: NSScreen {
    /// Provides observations of notifications posted by the screen.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSScreen {
    func colorSpaceDidChange(handler: @escaping (_ scroller: Object) -> ()) -> NotificationToken {
        observe(\.colorSpaceDidChangeNotification, handler)
    }
}

public extension NSSpellChecker {
    /// Provides observations of notifications posted by the spell checker.
    static var observe: Notification.Observer<NSSpellChecker.Type> {
        .init(self)
    }
}

public extension Notification.Observer where Object == NSSpellChecker.Type {
    func didChangeAutomaticCapitalization(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticCapitalizationNotification) { _ in
            handler(NSSpellChecker.isAutomaticCapitalizationEnabled)
        }
    }

    func didChangeAutomaticDashSubstitution(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticDashSubstitutionNotification) { _ in
            handler(NSSpellChecker.isAutomaticDashSubstitutionEnabled)
        }
    }

    func didChangeAutomaticPeriodSubstitution(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticPeriodSubstitutionNotification) { _ in
            handler(NSSpellChecker.isAutomaticPeriodSubstitutionEnabled)
        }
    }

    func didChangeAutomaticQuoteSubstitution(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticQuoteSubstitutionNotification) { _ in
            handler(NSSpellChecker.isAutomaticQuoteSubstitutionEnabled)
        }
    }

    func didChangeAutomaticSpellingCorrection(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticSpellingCorrectionNotification) { _ in
            handler(NSSpellChecker.isAutomaticSpellingCorrectionEnabled)
        }
    }

    func didChangeAutomaticTextCompletion(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticTextCompletionNotification) { _ in
            handler(NSSpellChecker.isAutomaticTextCompletionEnabled)
        }
    }

    func didChangeAutomaticTextReplacement(handler: @escaping (_ isEnabled: Bool) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSSpellChecker.didChangeAutomaticTextReplacementNotification) { _ in
            handler(NSSpellChecker.isAutomaticTextReplacementEnabled)
        }
    }
    
    /*
    func didChangeAutomaticInlinePrediction(handler: @escaping (_ spellChecker: Object) -> ()) -> NotificationToken {
        observe(\.spellCheckerDidChangeAutomaticInlinePredictionNotification, handler)
    }
     */
}

public extension NSObjectProtocol where Self: NSTextAlternatives {
    /// Provides observations of notifications posted by the text alternatives object.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSTextAlternatives {
    func didsSelectedAlternativeString(handler: @escaping (_ textAlternatives: Object, _ alternativeString: String) -> ()) -> NotificationToken {
        observe(\.selectedAlternativeStringNotification) {
            guard let alternativeString = $1["NSAlternativeString"] as? String else { return }
            handler($0, alternativeString)
        }
    }
}

public extension Notification.Observer where Object: NSTextStorage {
    func willProcessEditing(handler: @escaping (_ textStorage: Object) -> ()) -> NotificationToken {
        observe(\.willProcessEditingNotification, handler)
    }
    
    func didProcessEditing(handler: @escaping (_ textStorage: Object) -> ()) -> NotificationToken {
        observe(\.didProcessEditingNotification, handler)
    }
}

public extension NSFont {
    /// Provides observations of notifications posted by the text alternatives object.
    static var observe: Notification.Observer<NSFont.Type> {
        .init(nil)
    }
}

public extension Notification.Observer where Object == NSFont.Type {
    func fontSetChanged(handler: @escaping () -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSFont.fontSetChangedNotification, postedBy: object) { _ in
            handler()
        }
    }
    
    func antialiasThresholdChanged(handler: @escaping () -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSFont.antialiasThresholdChangedNotification, postedBy: object) { _ in
            handler()
        }
    }
}

public extension NSObjectProtocol where Self: NSBrowser {
    /// Provides observations of notifications posted by the browser.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSBrowser {
    func columnConfigurationDidChange(handler: @escaping (_ browser: Object) -> ()) -> NotificationToken {
        observe(\.columnConfigurationDidChangeNotification, handler)
    }
}

extension NSImageRep {
    /// A change to the registry of available image representation classes.
    public enum RegistryChange: String {
        /// An image representation class was added to the registry.
        case registered
        /// An image representation class was removed from the registry.
        case removed
    }
}
public extension Notification.Observer where Object == NSImageRep.Type {
    func registryDidChange(handler: @escaping (_ imageRepClass: NSImageRep.Type, _ change: NSImageRep.RegistryChange) -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSImageRep.registryDidChangeNotification, postedBy: nil) {
            guard let imageRepClass = $0.object as? NSImageRep.Type else { return }
            handler(imageRepClass, NSImageRep.registeredClasses.contains(imageRepClass) ? .registered : .removed)
        }
    }
}

public extension NSObjectProtocol where Self: NSTextInputContext {
    /// Provides observations of notifications posted by the text input context.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension NSTextInputContext {
    /// Provides observations of notifications posted by text input contexts.
    static var observe: Notification.Observer<NSTextInputContext.Type> {
        .init(nil)
    }
}

public extension Notification.Observer where Object == NSTextInputContext.Type {
    func keyboardSelectionDidChange(handler: @escaping () -> ()) -> NotificationToken {
        NotificationCenter.default.observe(NSTextInputContext.keyboardSelectionDidChangeNotification) { _ in
            handler()
        }
    }
}

public extension NSObjectProtocol where Self: NSColorPanel {
    /// Provides observations of notifications posted by text input contexts.
    var observe: Notification.Observer<Self> {
        .init(self)
    }
}

public extension Notification.Observer where Object: NSColorPanel {
    func colorDidChange(handler: @escaping (_ colorPanel: Object) -> ()) -> NotificationToken {
        observe(\.colorDidChangeNotification, handler)
    }
}

public extension Notification.Observer where Object: FileHandle {
    /*
     NSFileHandleNotificationDataItem
     An NSData object containing the available data read from a socket connection.
     @"NSFileHandleError"
     An NSNumber object containing an integer representing the UNIX-type error which occurred.
     */
    func readCompletion(handler: @escaping (_ fileHandle: Object) -> ()) -> NotificationToken {
        observe(\.readCompletionNotification, handler)
    }
    
    func dataAvailable(handler: @escaping (_ fileHandle: Object) -> ()) -> NotificationToken {
        observe(.NSFileHandleDataAvailable, handler)
    }
    
    /*
     NSFileHandleNotificationFileHandleItem
     The NSFileHandle object representing the “near” end of a socket connection.
     @"NSFileHandleError"
     An NSNumber object containing an integer representing the UNIX-type error which occurred.
     */
    func connectionAccepted(handler: @escaping (_ fileHandle: Object) -> ()) -> NotificationToken {
        observe(.NSFileHandleConnectionAccepted, handler)
    }
    
    /*
     NSFileHandleNotificationDataItem
     An NSData object containing the available data read from a socket connection.
     @"NSFileHandleError"
     An NSNumber object containing an integer representing the UNIX-type error which occurred.
     */
    func readToEndOfFileCompletion(handler: @escaping (_ fileHandle: Object) -> ()) -> NotificationToken {
        observe(.NSFileHandleReadToEndOfFileCompletion, handler)
    }
}


#endif

#if canImport(AVKit)
import AVKit

@available(macOS 14.0, *)
public extension Notification.Observer where Object: AVAudioApplication {
    func inputMuteStateChanged(handler: @escaping (_ audioApplication: Object) -> ()) -> NotificationToken {
        observe(\.inputMuteStateChangeNotification, handler)
    }
}



public extension Notification.Observer where Object: AVCaptureDevice {
    func wasConnected(handler: @escaping (_ captureDevice: Object) -> ()) -> NotificationToken {
        observe(\.wasConnectedNotification, handler)
    }
    
    func wasDisconnected(handler: @escaping (_ captureDevice: Object) -> ()) -> NotificationToken {
        observe(\.wasDisconnectedNotification, handler)
    }
}
#endif
