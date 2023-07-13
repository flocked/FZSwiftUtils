//
//  Dictorary+.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Dictionary {
    /// The dictionary as CFDictionary.
    func toCFDictionary() -> CFDictionary {
        self as CFDictionary
    }
    
    /// The dictionary as NSDictionary.
    func toNSDictionary() -> NSDictionary {
        self as NSDictionary
    }
}

public extension NSDictionary {
    /// The dictionary as Dictionary.
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
    
    /// The dictionary as CFDictionary.
    func toCFDictionary() -> CFDictionary {
        self as CFDictionary
    }
}
