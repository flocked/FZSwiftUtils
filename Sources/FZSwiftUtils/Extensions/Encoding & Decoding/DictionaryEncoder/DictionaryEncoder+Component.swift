//
//  DictionaryEncoder+Component.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

extension DictionaryEncoder {
    indirect enum Component {
        case value(Any?)
        case container(Container)
        
        func resolveValue() -> Any? {
            switch self {
            case .value(let value):
                value
            case .container(let container):
                container.resolveValue()
            }
        }
        
        var container: Container? {
            switch self {
            case .container(let container): container
            default: nil
            }
        }
    }
}
