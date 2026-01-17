//
//  ObjC+String.swift
//
//
//  Created by p-x9 on 2024/06/19
//  
//

import Foundation

extension String {
    func firstBracket(_ open: Character, _ close: Character) -> (content: String, trailing: String?)? {
        var depth = 0
        var openIndex: String.Index?
        for idx in indices {
            switch self[idx] {
            case open:
                if depth == 0 { openIndex = idx }
                depth += 1
            case close:
                depth -= 1
                if depth == 0, let openIndex = openIndex {
                    let trailingStart = index(after: idx)
                    let trailing = trailingStart < endIndex ? String(self[trailingStart...]) : nil
                    return (String(self[index(after: openIndex)..<idx]), trailing)
                }
            default: break
            }
        }
        return nil
    }
    
    func extractString(between character: Character, startingAt startIndex: Index? = nil) -> (content: String, trailing: String)? {
        let startIndex = startIndex ?? self.startIndex
        var inQuote = false
        var idx = startIndex
        while idx < endIndex {
            if self[idx] == "\"" {
                if inQuote {
                    let content = String(self[index(after: startIndex)..<idx])
                    return (content, String(self[index(after: idx)..<endIndex]))
                } else {
                    inQuote = true
                }
            }
            idx = index(after: idx)
        }
        return nil
    }

    func readInitialDigits() -> String? {
        guard !isEmpty else { return nil }
        var start = startIndex
        let hasSign = self[start] == "-"
        if hasSign {
            start = index(after: start)
            if start == endIndex { return nil } // only "-" no digits
        }
        var end = start
        while end < endIndex, self[end].isNumber {
            end = index(after: end)
        }
        if start == end { return nil }
        return String(self[(hasSign ? startIndex : start)..<end])
    }
    
    func trailing(after index: Index) -> String? {
        distance(from: index, to: endIndex) > 0 ? String(self[self.index(after: index) ..< endIndex]) : nil
    }
}
