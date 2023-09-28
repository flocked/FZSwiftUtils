//
//  Dictorary+.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Dictionary {
    /// Edits all values.
    mutating func editEach(_ body: (_ key: Key, _ value: inout Value) throws -> Void) rethrows {
        for keyVal in self {
            var value = keyVal.value
            try body(keyVal.key, &value)
            self[keyVal.key] = value
        }
    }
}

public extension Dictionary {
    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }
    
    /// The dictionary as `NSDictionary`.
    var nsDictionary: NSDictionary {
        self as NSDictionary
    }
}

public extension NSDictionary {
    /// The dictionary as `Dictionary`.
    func toDictionary() -> [String: Any] {
        var swiftDictionary = Dictionary<String, Any>()
          for key : Any in self.allKeys {
              let stringKey = key as! String
              if let keyValue = self.value(forKey: stringKey){
                  swiftDictionary[stringKey] = keyValue
              }
          }
          return swiftDictionary
    }
    
    /// The dictionary as `CFDictionary`.
    var cfDictionary: CFDictionary {
        self as CFDictionary
    }
}
