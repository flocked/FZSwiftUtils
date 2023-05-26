//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    mutating func addHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key) }
    }

    init?(string: String) {
        guard let url = URL(string: string) else { return nil }
        self.init(url: url)
    }

    var bytesRanges: ClosedRange<Int>? {
        get {
            if let string = allHTTPHeaderFields?["Range"] {
                let matches = string.matches(regex: "bytes=(\\d+)-(\\d+)")
                if matches.count == 2, let from = Int(matches[0]), let to = Int(matches[1]) {
                    return from ... to
                }
            }
            return nil
        }
        set {
            if let byteRange = newValue {
                // bytes=345234-34555
                setValue("bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)", forHTTPHeaderField: "Range")
            } else {
                setValue(nil, forHTTPHeaderField: "Range")
            }
        }
    }

    /*
     request.setValue(
                     "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                     forHTTPHeaderField: "Range"
                 )
     */

    var curlString: String {
        guard let url = url else { return "" }

        var baseCommand = "curl \(url.absoluteString)"
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]
        if let method = httpMethod, method != "GET", method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody,
           let body = String(data: data, encoding: .utf8)
        {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }
}
