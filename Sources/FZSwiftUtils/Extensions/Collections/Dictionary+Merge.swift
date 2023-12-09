//
//  Dictionary+Merge.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

public extension Dictionary {
    /**
     The dictionary merged with another dictionary.
     
     - Parameter dictionary: The dictionary for merging.
     - Returns: A dictionary with merged values.
     */
    func merged(_ dictionary: Self) -> Self {
        self + dictionary
    }
    
    /**
     Merges the dictionary with another dictionary.
     
     - Parameter dictionary: The dictionary for merging.
     */
    mutating func merge(_ dictionary: Self) {
        self += dictionary
    }
}

public func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
  var result = lhs
  rhs.forEach {
    if let dict = $1 as? [Key: Value] {
      if let exist = result[$0] as? [Key: Value] {
        result[$0] = exist + dict as? Value
      } else {
        result[$0] = dict as? Value
      }
    } else {
      result[$0] = $1
    }
  }
  return result
}

public func +=<Key, Value> (lhs: inout [Key: Value], rhs: [Key: Value]) {
  lhs = lhs + rhs
}
