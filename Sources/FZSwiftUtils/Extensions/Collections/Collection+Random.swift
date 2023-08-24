//
//  Collection+Random.swift
//  
//
//  Created by Florian Zand on 23.08.23.
//

import Foundation

public extension Collection {
    /**
     Returns an array of random elements of the collection.
     
     - Parameters amount: The amount of random elements.
     */
    func randomElements(amount: Int) -> [Element] {
        var randomElements = [Element]()
        for _ in 0...amount {
            if let randomElement = self.randomElement() {
                randomElements.append(randomElement)
            } else {
                return randomElements
            }
        }
        return randomElements
    }
}

public extension Collection where Element: Equatable {
    
    /**
     Returns an array of random elements of the collection.
     
     - Parameters amount: The amount of random elements.
     */
    func randomElements(amount: Int) -> [Element] {
        guard amount > 0, self.isEmpty == false else { return [] }
        var elements: [Element] = Array(self)
        var randomElements = [Element]()
        let amount = amount.clamped(max: self.count)
        while randomElements.count < amount && elements.isEmpty == false {
            let index = Int.random(in: 0..<elements.count)
            randomElements.append(elements.remove(at: index ))
        }
        return randomElements
    }
    
    /**
     Returns a random element of the collection.
     
     - Parameters:
        - excluding: The elements of the collection to be excluded from random.
     */
    func randomElement(excluding: [Element]) -> Element? {
        let elements: [Element] =  self.filter({ excluding.contains($0) == false })
        guard elements.isEmpty == false else { return nil }
        return elements.randomElement()
    }
    
    /**
     Returns an array of random elements of the collection.
     
     - Parameters:
        - amount: The amount of random elements.
        - excluding: The elements of the collection to be excluded from random.
     */
    func randomElements(amount: Int, excluding: [Element]) -> [Element] {
        let elements: [Element] =  self.filter({ excluding.contains($0) == false })
        return elements.randomElements(amount: amount)
    }
}
