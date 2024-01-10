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

    /**
     Transforms keys without modifying values.
     
     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
     
     - Note: The collection of transformed keys must not contain duplicates.
     */
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
        )
    }

    /**
     Transforms keys without modifying values.

     - Parameters:
        - transform: A closure that accepts each key of the dictionary as its parameter and returns a transformed key of the same or of a different type.
        - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func mapKeys<Transformed>( _ transform: (Key) throws -> Transformed,
      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Transformed: Value] {
      try .init(
        map { (try transform($0.key), $0.value) },
        uniquingKeysWith: combine
      )
    }

    /**
     Transforms keys without modifying values. Drops (key, value) pairs where the transform results in a nil key.
     
     - Parameter transform: A closure that accepts each key of the dictionary as its parameter and returns a potential transformed key of the same or of a different type.
     
     - Note: The collection of transformed keys must not contain duplicates.
     */
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?) rethrows -> [Transformed: Value] {
      .init(
        uniqueKeysWithValues: try compactMap { key, value in
          try transform(key).map { ($0, value) }
        }
      )
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
        var swiftDictionary = [String: Any]()
          for key: Any in self.allKeys {
              let stringKey = key as! String
              if let keyValue = self.value(forKey: stringKey) {
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
