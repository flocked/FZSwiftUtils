//
//  DispatchQueue+.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

import Foundation

public extension DispatchQueue {
    /**
     Schedules a work item for execution at the specified time interval, and returns immediately.

     - Parameters:
        - timeInterval: The time interval (in seconds) at which to schedule the work item for execution.
        - execute: The work item containing the task to execute.
     */
    func asyncAfter(_ timeInterval: TimeInterval, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + timeInterval, execute: execute)
    }

    /**
     Schedules a work item for execution at the specified time interval, and returns immediately.

     - Parameters:
        - timeInterval: The time interval at which to schedule the work item for execution.
        - execute: The work item containing the task to execute.
     */
    func asyncAfter(_ timeInterval: TimeDuration, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + timeInterval.seconds, execute: execute)
    }

    /**
     Schedules a block for execution using the specified attributes, and returns immediately.

     - Parameters:
        - timeInterval: The time interval (in seconds) at which to schedule the block for execution.
        - qos: The quality-of-service class to use when executing the block. This parameter determines the priority with which the block is scheduled and executed.
        - flags: Additional attributes to apply when executing the block.
        - work: The block containing the work to perform. This block has no return value and no parameters.
     */
    @preconcurrency
    func asyncAfter(_ timeInterval: TimeInterval, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @Sendable () -> Void) {
        asyncAfter(deadline: .now() + timeInterval, qos: qos, flags: flags, execute: work)
    }

    /**
     Schedules a block for execution using the specified attributes, and returns immediately.

     - Parameters:
        - timeInterval: The time interval  at which to schedule the block for execution.
        - qos: The quality-of-service class to use when executing the block. This parameter determines the priority with which the block is scheduled and executed.
        - flags: Additional attributes to apply when executing the block.
        - work: The block containing the work to perform. This block has no return value and no parameters.
     */
    @preconcurrency
    func asyncAfter(_ timeInterval: TimeDuration, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @Sendable () -> Void) {
        asyncAfter(deadline: .now() + timeInterval.seconds, qos: qos, flags: flags, execute: work)
    }
}
