//
//  Int+.swift
//
//
//  Created by Florian Zand on 14.11.25.
//

extension FixedWidthInteger {
    /**
     Returns a random value within a range of `0` and the specified value.
     
     Use this method to generate an integer within a specific range. This example creates three new values in the range `0...100`.
     
     ```swift
     for _ in 1...3 {
     print(Int.random(max: 100))
     }
     // Prints "53"
     // Prints "64"
     // Prints "5"
     ```
     
     This method is equivalent to calling `random(in:using:)`, passing in the system’s default random generator.
     
     - Parameter max: The maximum value of the range.
     - Returns: A random value within the bounds of range.
     */
    public static func random(max: Self) -> Self {
        random(in: 0...max)
    }
}

public extension BinaryInteger {
    /// Returns the number of digits
    var digitCount: Int {
        numberOfDigits(in: self)
    }
    
    // private recursive method for counting digits
    func numberOfDigits(in number: Self) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number / 10)
        }
    }
    
    /// Returns the position of the single set bit if the integer is a power of two, otherwise `nil`.
    var bitPosition: Int? {
        guard self > 0, (self & (self - 1)) == 0 else { return nil }
        return trailingZeroBitCount
    }
}
