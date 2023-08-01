//
//  HTTPURLResponse+.swift
//  
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension HTTPURLResponse {
    /// A boolean value indicating whether the response’s HTTP status code is sucessful (200-299).
    var statusIsSucess: Bool {
        let code = self.statusCode
        switch code {
        case 200..<300:
            return true
        default:
            return false
        }
    }
}
