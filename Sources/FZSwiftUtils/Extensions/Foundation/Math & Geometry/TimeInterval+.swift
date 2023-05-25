//
//  File.swift
//
//
//  Created by Florian Zand on 26.08.22.
//

import Foundation
import QuartzCore

public extension TimeInterval {
    static var now: TimeInterval {
        return CACurrentMediaTime()
    }
}
