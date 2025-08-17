//
//  Reachability.swift
//
//
//  Created by Florian Zand on 29.07.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import SystemConfiguration

/// An object for checking if the device is connected to the network.
public enum Reachability {
    /// A Boolean value indicating whether the device is connected to the network.
    public static func isConnectedToNetwork() -> Bool {
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
    public static func observe(_ callback: @escaping (_ isConntected: Bool)->()) -> ReachabilityObservation? {
        .init(callback: callback)
    }
}

/// An observation whether the device is connected to the network.
public final class ReachabilityObservation {
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
            let observer = Unmanaged<ReachabilityObservation>.fromOpaque(info).takeUnretainedValue()
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
#endif
