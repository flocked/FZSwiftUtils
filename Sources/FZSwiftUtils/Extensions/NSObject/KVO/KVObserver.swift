//
//  KVObserver.swift
//  
//
//  Created by Florian Zand on 22.02.25.
//

import Foundation

/// An object that KVO observes another object.
protocol KVObserver: NSObject {
    var isActive: Bool { get set }
    var keyPathString: String { get }
}

extension KVObserver {
    var keyPathString: String { "" }
}
