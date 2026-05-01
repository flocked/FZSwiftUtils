//
//  ProcessInfo+.swift
//
//
//  Created by Florian Zand on 21.03.25.
//

#if os(macOS)
import Foundation

extension ProcessInfo {
    /// The hardware model identifier (e.g., "Mac14,3") for the current Mac.
    public var hardwareModel: String? {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        guard size > 0 else { return nil }

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)

        return String(cString: model)
    }
    
    /*
    /// A collection of observations for `ProcessInfo` notifications.
    public var obserations: Observations {
        Observations()
    }
    
    /**
     A collection of observations for `ProcessInfo` notifications.

     The methods  observers for system state changes and invoke the provided handler whenever a change occurs.
     
     Each method returns a `NotificationToken` that must be retained for the duration of the observation.
     */
    public struct Observations {
        
        /**
         Observes changes to the system's low power mode state.

         The handler is called whenever low power mode is enabled or disabled.

         - Parameter handler: A closure that receives the current low power mode state.
         - Returns: A `NotificationToken` representing the active observation.
         
         Keep a strong reference to the returned token for as long as you want to continue receiving updates.
         */
        public func lowPowerModeState(handler: @escaping (_ isLowPowerModeEnabled: Bool) -> Void) -> NotificationToken {
            NotificationCenter.default.observe(.NSProcessInfoPowerStateDidChange, on: nil) { _ in
                handler(ProcessInfo.processInfo.isLowPowerModeEnabled)
            }
        }
        
        /**
         Observes changes to the system's thermal state.

         The handler is called whenever the thermal state changes.

         - Parameter handler: A closure that receives the current thermal state.
         - Returns: A `NotificationToken` representing the active observation.

         Keep a strong reference to the returned token for as long as you want to continue receiving updates.
         */
        public func termalState(handler: @escaping (_ thermalState: ThermalState) -> Void) -> NotificationToken {
            _ = ProcessInfo.processInfo.thermalState
            return NotificationCenter.default.observe(ProcessInfo.thermalStateDidChangeNotification, on: nil) { _ in
                handler(ProcessInfo.processInfo.thermalState)
            }
        }
    }
     */
}

extension ProcessInfo {
    /**
     Begins an activity using the given options and reason.
          
     You must keep the token alive as long as your activty is running. If the token is deallocated, the activity ends automatically.
     
     - Parameters:
        - options: The activity options.
        - reason: A string used in debugging to indicate the reason the activity began.
     - Returns: A token that keeps the activity alive and ends it on deallocation.
     */
    public func startActivity(_ options: ActivityOptions = [], reason: String) -> ProcessActivityToken {
        ProcessActivityToken(options: options, reason: reason)
    }
}

/**
 A token that represents a process activity created by ``ProcessInfo``.

 To begin an activity, use ``Foundation/ProcessInfo/startActivity(_:reason:)``. This method returns a token that keeps the activity active for the lifetime of the token,  unless the token's ``endActivity()`` is called earlier.

 Use this token to keep the process active while performing work that should not be suspended, such as user-initiated tasks or critical operations.

 The activity is automatically ended when the token is deallocated if it has not already been ended manually.
 */
public final class ProcessActivityToken {
    private let token: any NSObjectProtocol
    
    /// The options used to create the activity.
    public let options: ProcessInfo.ActivityOptions
    
    /// A Boolean value indicating whether the activity is currently active.
    public private(set) var isActive = true
    
    internal init(options: ProcessInfo.ActivityOptions, reason: String) {
        self.options = options
        self.token = ProcessInfo.processInfo.beginActivity(options: options, reason: reason)
    }
    
    /**
     Ends the activity if it is still active.

     Calling this method multiple times has no effect after the activity has already been ended.
     */
    public func endActivity() {
        guard isActive else { return }
        ProcessInfo.processInfo.endActivity(token)
        isActive = false
    }
    
    deinit {
        endActivity()
    }
}



#endif
