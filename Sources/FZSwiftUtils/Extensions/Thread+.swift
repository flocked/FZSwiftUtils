//
//  Thread+.swift
//
//
//  Created by Florian Zand on 05.09.26.
//

import Foundation

public extension Thread {
    static func printStackTrace() {
        callStackSymbols.printEach()
    }
}
