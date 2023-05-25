//
//  SynchronizedArray.swift
//  DMSwift
//
//  Created by Sherzod Khashimov on 10/4/19.
//  Copyright © 2019 Sherzod Khashimov. All rights reserved.
//

import Foundation

public class SynchronizedArray<Element>: BidirectionalCollection {
    private let queue = DispatchQueue(label: "com.FZExtensions.SynchronizedArray", attributes: .concurrent)
    private var array = [Element]()

    public init() {}
}

public extension SynchronizedArray {
    var synchronizedArray: [Element] {
        var array: [Element] = []
        queue.sync {
            array = self.array
        }
        return array
    }

    func index(_ i: Int, offsetBy distance: Int) -> Int {
        queue.sync {
            self.array.index(i, offsetBy: distance)
        }
    }

    func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        queue.sync {
            self.array.index(i, offsetBy: distance, limitedBy: limit)
        }
    }

    func formIndex(after i: inout Int) {
        queue.sync {
            self.array.formIndex(after: &i)
        }
    }

    func formIndex(before i: inout Int) {
        queue.sync {
            self.array.formIndex(before: &i)
        }
    }

    func distance(from start: Int, to end: Int) -> Int {
        queue.sync {
            self.array.distance(from: start, to: end)
        }
    }

    func index(before i: Int) -> Int {
        queue.sync {
            array.index(before: i)
        }
    }

    func index(after i: Int) -> Int {
        queue.sync {
            array.index(after: i)
        }
    }

    var startIndex: Int {
        queue.sync {
            array.startIndex
        }
    }

    var endIndex: Int {
        queue.sync {
            array.endIndex
        }
    }

    var count: Int {
        queue.sync {
            self.array.count
        }
    }

    func append(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.array.removeAll()
        }
    }

    subscript(index: Int) -> Element {
        queue.sync {
            self.array[index]
        }
    }
}

public extension SynchronizedArray where Element: Comparable {
    func index(_ element: Element) -> Int? {
        queue.sync {
            self.array.firstIndex(where: { $0 == element })
        }
    }

    func contains(_ element: Element) -> Bool {
        queue.sync {
            self.array.contains(element)
        }
    }
}
