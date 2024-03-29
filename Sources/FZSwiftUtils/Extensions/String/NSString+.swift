//
//  NSString+.swift
//
//
//  Parts dopted from:
//  Created by 1024jp on 2016-06-25.
//  Created by Florian Zand on 03.09.22.

import Foundation.NSString

public extension StringProtocol {
    /// Whole range in NSRange.
    var nsRange: NSRange {
        NSRange(location: 0, length: length)
    }

    /// Length of the string.
    var length: Int {
        utf16.count
    }
}

public extension NSString {
    /// Whole range in NSRange.
    var range: NSRange {
        NSRange(location: 0, length: length)
    }

    /// Return NSRange-based character index where just before the given character index
    /// by taking grapheme clusters into account.
    ///
    /// - Parameter location: NSRange-based character index to refer.
    /// - Returns: NSRange-based character index just before the given `location`,
    ///            or `0` when the given `location` is the first.
    func index(before location: Int) -> Int {
        guard location > 0 else { return 0 }

        // avoid returing index between CRLF
        let index = location - 1
        let offset = (character(at: index) == 0x000A && character(at: index - 1) == 0x000D) ? 1 : 0

        return rangeOfComposedCharacterSequence(at: index - offset).lowerBound
    }

    /// Return NSRange-based character index where just after the given character index
    /// by taking grapheme clusters into account.
    ///
    /// - Parameter location: NSRange-based character index to refer.
    /// - Returns: NSRange-based character index just before the given `location`,
    ///            or `location` when the given `location` is the last.
    func index(after location: Int) -> Int {
        guard location < length - 1 else { return length }

        // avoid returing index between CRLF
        let index = location
        let offset = (character(at: index) == 0x000D && character(at: index + 1) == 0x000A) ? 1 : 0

        return rangeOfComposedCharacterSequence(at: index + offset).upperBound
    }

    /// Find and return ranges of passed-in substring with the given range of receiver.
    ///
    /// - Parameters:
    ///   - searchString: The string for which to search.
    ///   - options: A mask specifying search options.
    ///   - searchRange: The range with in the receiver for which to search for aString.
    /// - Returns: An array of NSRange in the receiver of `searchString` within `searchRange`.
    func ranges(of searchString: String, options: NSString.CompareOptions = .literal, range searchRange: NSRange? = nil) -> [NSRange] {
        let searchRange = searchRange ?? range
        var ranges: [NSRange] = []

        var location = searchRange.location
        while location != NSNotFound {
            let range = range(of: searchString, options: options, range: NSRange(location ..< searchRange.upperBound))
            location = range.upperBound

            guard range.location != NSNotFound else { break }

            ranges.append(range)
        }

        return ranges
    }

    /// line range containing a given location
    func lineRange(at location: Int) -> NSRange {
        lineRange(for: NSRange(location: location, length: 0))
    }

    /// line range containing a given location
    func lineContentsRange(at location: Int) -> NSRange {
        lineContentsRange(for: NSRange(location: location, length: 0))
    }

    /// Return line range excluding last line ending character if exists.
    ///
    /// - Parameters:
    ///   - range: A range within the receiver.
    /// - Returns: The range of characters representing the line or lines containing a given range.
    func lineContentsRange(for range: NSRange) -> NSRange {
        var start = 0
        var contentsEnd = 0
        getLineStart(&start, end: nil, contentsEnd: &contentsEnd, for: range)

        return NSRange(location: start, length: contentsEnd - start)
    }

    /// Return the index of the first character of the line touched by the given index.
    ///
    /// - Parameters:
    ///   - index: The index of character for finding the line start.
    /// - Returns: The character index of the nearest line start.
    func lineStartIndex(at index: Int) -> Int {
        var start = 0
        getLineStart(&start, end: nil, contentsEnd: nil, for: NSRange(location: index, length: 0))

        return start
    }

    /// Return the index of the last character before the line ending of the line touched by the given index.
    ///
    /// - Parameters:
    ///   - index: The index of character for finding the line contents end.
    /// - Returns: The character index of the nearest line contents end.
    func lineContentsEndIndex(at index: Int) -> Int {
        var contentsEnd = 0
        getLineStart(nil, end: nil, contentsEnd: &contentsEnd, for: NSRange(location: index, length: 0))

        return contentsEnd
    }

    /// Calculate line-by-line ranges that given ranges include.
    ///
    /// - Parameters:
    ///   - ranges: Ranges to include.
    ///   - includingLastEmptyLine: Whether the last empty line should be included; otherwise, return value can be empty.
    /// - Returns: Array of ranges of each indivisual line.
    func lineRanges(for ranges: [NSRange], includingLastEmptyLine: Bool = false) -> [NSRange] {
        guard !ranges.isEmpty else { return [] }

        if includingLastEmptyLine,
           ranges == [NSRange(location: length, length: 0)],
           length == 0 || character(at: length - 1).isNewLine
        {
            return ranges
        }

        var lineRanges = OrderedSet<NSRange>()

        // get line ranges to process
        for range in ranges {
            let linesRange = lineRange(for: range)

            // store each line to process
            enumerateSubstrings(in: linesRange, options: [.byLines, .substringNotRequired]) { _, _, enclosingRange, _ in
                lineRanges.append(enclosingRange)
            }
        }

        return lineRanges.array
    }

    /// Fast way to count the number of lines at the character index (1-based).
    ///
    /// Counting in this way is significantly faster than other ways such as `enumerateSubstrings(in:options:.byLines)`,
    /// `components(separatedBy: .newlines)`, or even just counting `\n` in `.utf16`. (2020-02, Swift 5.1)
    ///
    /// - Parameter location: NSRange-based character index.
    /// - Returns: The number of lines (1-based).
    func lineNumber(at location: Int) -> Int {
        assert(location == 0 || location <= length)

        guard length > 0, location > 0 else { return 1 }

        var count = 0
        var index = 0
        while index < location {
            getLineStart(nil, end: &index, contentsEnd: nil, for: NSRange(location: index, length: 0))
            count += 1
        }

        if character(at: location - 1).isNewLine {
            count += 1
        }

        return count
    }

    /// Find the widest character range that contains the given `index` and not contains given character set.
    ///
    /// - Parameters:
    ///   - set: The character set to end expanding range.
    ///   - index: The index of character to be contained to the result range. `index` must be within `range`.
    ///   - range: The range in which to search. `range` must not exceed the bounds of the receiver.
    /// - Returns: The found character range.
    func rangeOfCharacter(until set: CharacterSet, at index: Int, range: NSRange? = nil) -> NSRange {
        let range = range ?? self.range

        assert(range.contains(index))

        let lowerDelimiterRange = rangeOfCharacter(from: set, options: .backwards, range: NSRange(range.lowerBound ..< index))
        let lowerBound = !lowerDelimiterRange.isNotFound ? lowerDelimiterRange.upperBound : range.lowerBound

        let upperDelimiterRange = rangeOfCharacter(from: set, range: NSRange(index ..< range.upperBound))
        let upperBound = !upperDelimiterRange.isNotFound ? upperDelimiterRange.lowerBound : range.upperBound

        return NSRange(lowerBound ..< upperBound)
    }

    /// Return the lower bound of the composed character sequence by moving the bound in the head direction by counting offset in composed character sequences.
    ///
    /// - Parameters:
    ///   - index: The reference character index in UTF-16.
    ///   - offset: The number of composed character sequences to move index.
    /// - Returns: A character index in UTF-16.
    func lowerBoundOfComposedCharacterSequence(_ index: Int, offsetBy offset: Int) -> Int {
        assert((0 ... length).contains(index))
        assert(offset >= 0)

        if index == length, offset == 0 { return index }

        var remainingCount = (index == length) ? offset : offset + 1
        var boundary = index

        let range = NSRange(..<min(index + 1, length))
        let options: EnumerationOptions = [.byComposedCharacterSequences, .substringNotRequired, .reverse]
        enumerateSubstrings(in: range, options: options) { _, range, _, stop in

            boundary = range.lowerBound
            remainingCount -= 1

            if remainingCount <= 0 {
                stop.pointee = true
            }
        }

        return boundary
    }
}

extension unichar {
    /// A Boolean value indicating whether this character represents a newline.
    var isNewLine: Bool {
        switch self {
        case 0x000A, 0x000B, 0x000C, 0x000D, 0x0085, 0x2028, 0x2029:
            return true
        default:
            return false
        }
    }
}
