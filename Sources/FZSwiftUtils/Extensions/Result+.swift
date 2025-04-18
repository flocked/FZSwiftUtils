//
//  Result+.swift
//  
//
//  Created by Florian Zand on 18.04.25.
//

import Foundation

public extension Result {
    /// The success value if the result is `.success`, otherwise `nil`.
    var value: Success? {
        try? get()
    }
    
    /// The failure error if the result is `.failure`, otherwise `nil`.
    var error: Failure? {
        switch self {
        case .success: return nil
        case .failure(let failure): return failure
        }
    }
}

