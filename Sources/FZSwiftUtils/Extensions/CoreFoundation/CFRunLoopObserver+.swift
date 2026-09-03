//
//  CFRunLoopObserver+.swift
//
//
//  Created by Florian Zand on 03.09.26.
//

import Foundation

public extension CFType where Self == CFRunLoopObserver {
    /**
     Creates a run loop observer with the specified handler.
               
     The run loop observer is not automatically added to a run loop. To add the observer to a run loop, call the run loop's ``addObserver(_:mode:)`` method. An observer can be registered with only one run loop, although it can be added to multiple run loop modes within that run loop.
     
     - Parameters:
        - allocator: The allocator to use to allocate memory for the new observer, or `nil` to use the current default allocator.
        - activities: The activity stages of the run loop during which the observer is called.
        - repeats: A Boolean value indicating whether the observer is called every time through the run loop. If set to `false`, the observer is invalidated after it is called once, even if the observer was scheduled to be called at multiple stages within the run loop.
        - order: A priority index indicating the order in which run loop observers are processed. When multiple run loop observers are scheduled in the same activity stage in a given run loop mode, the observers are processed in increasing order of this parameter.
        - handler: The handler to call with the observer that is firing and the current activity stage of the run loop.
     */
    init(allocator: CFAllocator? = nil, activities: CFRunLoopActivity, repeats: Bool = true, order: Int = 0, handler: @escaping ((_ observer: CFRunLoopObserver, _ activity: CFRunLoopActivity) -> Void)) {
        self = CFRunLoopObserverCreateWithHandler(allocator, activities.rawValue, repeats, order) { observer, activities in
            guard let observer else { return }
            handler(observer, activities)
        }
    }
}

public extension CFRunLoopObserver {
    /**
     A Boolean value indicating whether the observer is valid.
     
     A nonrepeating observer is automatically invalidated after it is called once.
     */
    var isValid: Bool {
        CFRunLoopObserverIsValid(self)
    }

    /// A Boolean value indicating whether the observer repeats.
    var repeats: Bool {
        CFRunLoopObserverDoesRepeat(self)
    }

    /**
     The ordering parameter of the observer.
     
     When multiple observers are scheduled in the same run loop mode and stage, this value determines the order (from small to large) in which the observers are called.
     */
    var order: CFIndex {
        CFRunLoopObserverGetOrder(self)
    }

    /// The activities that the observer monitors.
    var activities: CFRunLoopActivity {
        CFRunLoopActivity(rawValue: CFRunLoopObserverGetActivities(self))
    }

    /**
     Invalidates the observer, preventing it from firing again.

     If the observer is currently attached to one or more run loops, invalidating it removes the observer from all of them.
     */
    func invalidate() {
        CFRunLoopObserverInvalidate(self)
    }
    
    /// The context associated with the observer.
    var context: CFRunLoopObserverContext {
        var context = CFRunLoopObserverContext()
        CFRunLoopObserverGetContext(self, &context)
        return context
    }
}
