//
//  Sequence+Zip.swift
//
//
//  Created by Florian Zand on 30.04.25.
//

import Foundation

public func zip<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) -> Zip3Sequence<S1, S2, S3> {
    Zip3Sequence(s1, s2, s3)
}

public func zip<S1: Sequence, S2: Sequence, S3: Sequence, S4: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> Zip4Sequence<S1, S2, S3, S4> {
    Zip4Sequence(s1, s2, s3, s4)
}

/// A sequence of truples built out of three underlying sequences.
public struct Zip3Sequence<Sequence1, Sequence2, Sequence3>: Sequence where Sequence1 : Sequence, Sequence2 : Sequence, Sequence3 : Sequence {
    let s1: Sequence1
    let s2: Sequence2
    let s3: Sequence3
    
    init(_ s1: Sequence1, _ s2: Sequence2, _ s3: Sequence3) {
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
    }

    public func makeIterator() -> Iterator {
        Iterator(self)
    }
    
    /// An iterator for ``Zip3Sequence``.
    public struct Iterator: IteratorProtocol {
        var it1: Sequence1.Iterator
        var it2: Sequence2.Iterator
        var it3: Sequence3.Iterator
        
        init(_ sequence: Zip3Sequence) {
            self.it1 = sequence.s1.makeIterator()
            self.it2 = sequence.s2.makeIterator()
            self.it3 = sequence.s3.makeIterator()
        }
        
        public mutating func next() -> (Sequence1.Element, Sequence2.Element, Sequence3.Element)? {
            guard let ele1 = it1.next(), let ele2 = it2.next(), let ele3 = it3.next() else { return nil }
            return (ele1, ele2, ele3)
        }
    }
}

public struct Zip4Sequence<Sequence1, Sequence2, Sequence3, Sequence4>: Sequence where Sequence1 : Sequence, Sequence2 : Sequence, Sequence3 : Sequence, Sequence4 : Sequence {
    let s1: Sequence1
    let s2: Sequence2
    let s3: Sequence3
    let s4: Sequence4
    
    init(_ s1: Sequence1, _ s2: Sequence2, _ s3: Sequence3, _ s4: Sequence4) {
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
        self.s4 = s4
    }
    
    public func makeIterator() -> Iterator {
        Iterator(self)
    }
    
    /// An iterator for ``Zip4Sequence``.
    public struct Iterator: IteratorProtocol {
        var it1: Sequence1.Iterator
        var it2: Sequence2.Iterator
        var it3: Sequence3.Iterator
        var it4: Sequence4.Iterator
        
        init(_ sequence: Zip4Sequence) {
            self.it1 = sequence.s1.makeIterator()
            self.it2 = sequence.s2.makeIterator()
            self.it3 = sequence.s3.makeIterator()
            self.it4 = sequence.s4.makeIterator()
        }
        
        public mutating func next() -> (Sequence1.Element, Sequence2.Element, Sequence3.Element,  Sequence4.Element)? {
            guard let ele1 = it1.next(), let ele2 = it2.next(), let ele3 = it3.next(), let ele4 = it4.next() else { return nil }
            return (ele1, ele2, ele3, ele4)
        }
    }
}
