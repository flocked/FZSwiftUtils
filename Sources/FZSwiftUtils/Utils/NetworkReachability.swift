//
//  NetworkReachability.swift
//
//
//  Created by Florian Zand on 29.07.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import SystemConfiguration

/// An object for checking if the device is connected to the network.
public enum NetworkReachability {
    /// A Boolean value indicating whether the device is connected to the network.
    public static var isConnected: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }
    
    /**
     Observes whether the device is connected to the network.
     
     - Parameter callback: The handler that is called when the network reachability changes.
     - Returns: A network reachability observation, or `nil` if the network's reachability can't be observered.
     */
    public static func observe(_ callback: @escaping (_ isConntected: Bool)->()) -> NetworkReachabilityObservation? {
        .init(callback: callback)
    }
}

/// An observation whether the device is connected to the network.
public final class NetworkReachabilityObservation {
    private var reachability: SCNetworkReachability?
    private let callback: (Bool) -> Void

    init?(callback: @escaping (Bool) -> Void) {
        var zeroAddress = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
            sin_family: sa_family_t(AF_INET),
            sin_port: 0,
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0,0,0,0,0,0,0,0)
        )

        guard let ref = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return nil
        }

        self.reachability = ref
        self.callback = callback
        start()
    }

    private func start() {
        guard let reachability = reachability else { return }

        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)

        SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            guard let info = info else { return }
            let observer = Unmanaged<NetworkReachabilityObservation>.fromOpaque(info).takeUnretainedValue()
            observer.reachabilityChanged(flags)
        }, &context)

        SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main)

        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            reachabilityChanged(flags)
        }
    }

    private func stop() {
        guard let reachability = reachability else { return }
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    private func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {
        let isReachable = flags.contains(.reachable) && !flags.contains(.connectionRequired)
        callback(isReachable)
    }
    
    deinit {
        stop()
    }
}

#if canImport(Combine)
import Combine

public extension NetworkReachability {
    /// Returns a publisher for the network reachability.
    static func publisher() -> NetworkReachabilityPublisher? {
        .init()
    }
}

/// A publisher for the network reachability.
public struct NetworkReachabilityPublisher: Publisher {
    public typealias Output = Bool
    public typealias Failure = Never

    private let reachability: SCNetworkReachability

    public init?() {
        var zeroAddress = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
            sin_family: sa_family_t(AF_INET),
            sin_port: 0,
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0,0,0,0,0,0,0,0)
        )

        guard let ref = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return nil
        }

        self.reachability = ref
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = ReachabilitySubscription(subscriber: subscriber, reachability: reachability)
        subscriber.receive(subscription: subscription)
    }
}

/// The C callback trampoline (cannot capture generics!)
private func reachabilityCallback(_ target: SCNetworkReachability, _ flags: SCNetworkReachabilityFlags, _ info: UnsafeMutableRawPointer?) {
    guard let info else { return }
    let subscription = Unmanaged<ReachabilitySubscriptionBase>.fromOpaque(info).takeUnretainedValue()
    subscription.reachabilityChanged(flags)
}

/// A non-generic base class we can reference from the C trampoline
private class ReachabilitySubscriptionBase {
    func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {}
}

private final class ReachabilitySubscription<S: Subscriber>: ReachabilitySubscriptionBase, Subscription where S.Input == Bool, S.Failure == Never {
    private var subscriber: S?
    private let reachability: SCNetworkReachability

    init(subscriber: S, reachability: SCNetworkReachability) {
        self.subscriber = subscriber
        self.reachability = reachability
        super.init()
        start()
    }

    func request(_ demand: Subscribers.Demand) {
        // We ignore demand, just push when state changes
    }

    func cancel() {
        stop()
        subscriber = nil
    }

    private func start() {
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)

        SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context)
        SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main)

        // Emit initial state
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            reachabilityChanged(flags)
        }
    }

    private func stop() {
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    override func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {
        let isReachable = flags.contains(.reachable) && !flags.contains(.connectionRequired)
        _ = subscriber?.receive(isReachable)
    }
}
#endif
#endif
