//
//  Chance.swift
//  Chance
//
//  Created by Florian Zand on 22.12.22.
//

import Foundation

public enum Chance {
    public static func by(_ amount: CGFloat) -> Bool {
        let amount = amount.clamped(max: 1.0)
        let random = CGFloat.random(in: 0 ... 1.0)
        return (amount >= random)
    }

    public static func by(_ amount: CGFloat, action: () -> Void) {
        if by(amount) {
            action()
        }
    }
}
