import Foundation

public extension URLRequest {
    /**
     Creates and initializes a URL request with the given curl command.

     - Parameter curlString: The curl command to parse.
     - Parameter ignoresUnsupportedOptions: A Boolean value indicating whether unsupported options should be ignored.
     */
    init(curlString: String, ignoresUnsupportedOptions: Bool = false) throws {
        self = try CURL(curlString, ignoresUnsupportedOptions: ignoresUnsupportedOptions).request()
    }

    /**
     Returns the curl command equivalent of the request.

     The curl command string includes the URL, HTTP method, headers, and body (if present) of the request.
     
     - Parameter includeCookies: A Boolean value indicating whether to include the cookies of the request.
     - Returns: A string representing the curl command equivalent of the request.
     - Important: The generated curl command may not accurately represent all aspects of the request, such as multipart form data. Binary bodies are represented with shell process substitution, which requires a compatible shell such as bash or zsh.
     */
    func curlString(includeCookies: Bool = false) -> String {
        guard let url else { return "" }

        func shellEscape(_ string: String) -> String {
            "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'"
        }

        var components = ["curl"]

        if let method = httpMethod, method != "GET" {
            if method == "HEAD" {
                components.append("--head")
            } else {
                components.append("-X")
                components.append(shellEscape(method))
            }
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers.sorted(by: \.key, options: .localizedStandard) {
                if !includeCookies && key.caseInsensitiveCompare("Cookie") == .orderedSame {
                    continue
                }

                components.append("-H")
                components.append(shellEscape("\(key): \(value)"))
            }
        }

        if let bodyData = httpBody {
            if let body = String(data: bodyData, encoding: .utf8) {
                components.append("--data-raw")
                components.append(shellEscape(body))
            } else {
                components.append("--data-binary")
                components.append("@<(printf %s \(shellEscape(bodyData.base64EncodedString())) | base64 --decode)")
            }
        } else if httpBodyStream != nil {
            components.append("# Body is provided via httpBodyStream and cannot be represented")
        }

        components.append(shellEscape(url.absoluteString))
        return components.joined(separator: " \\\n\t")
    }
}

fileprivate struct CURL: Sendable {
    private var result: ParseResult

    init(_ string: String, ignoresUnsupportedOptions: Bool) throws {
        let parser = Parser(command: string)
        self.result = try parser.parse(ignoresUnsupportedOptions: ignoresUnsupportedOptions)
    }

    func request() throws -> URLRequest {
        var request = URLRequest(url: result.url)
        request.httpMethod = result.httpMethod

        for header in result.headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        if !result.postData.isEmpty {
            let data = result.postData.joined(separator: "&")
            request.httpBody = data.data(using: .utf8)
        } else if !result.files.isEmpty {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = try buildMultipartBody(boundary: boundary, postFields: result.postFields, files: result.files)
        } else if !result.postFields.isEmpty {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let joined = result.postFields.map { key, value in
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            }
            .joined(separator: "&")

            request.httpBody = joined.data(using: .utf8)
        }

        if let user = result.user {
            let loginData = "\(user):\(result.password ?? "")".data(using: .utf8)!
            request.setValue("Basic \(loginData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func buildMultipartBody(boundary: String, postFields: [String: String], files: [String: String]) throws -> Data {
        var body = Data()
        let boundaryData = "--\(boundary)\r\n".data(using: .utf8)!
        let endBoundaryData = "--\(boundary)--\r\n".data(using: .utf8)!

        for (key, value) in postFields {
            body.append(boundaryData)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append(value.data(using: .utf8) ?? Data())
            body.append("\r\n".data(using: .utf8)!)
        }

        for (key, filePath) in files {
            body.append(boundaryData)

            let actualPath = filePath.hasPrefix("@") ? String(filePath.dropFirst()) : filePath
            let filename = URL(fileURLWithPath: actualPath).lastPathComponent

            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType(for: filename))\r\n\r\n".data(using: .utf8)!)

            body.append(try Data(contentsOf: URL(fileURLWithPath: actualPath)))

            body.append("\r\n".data(using: .utf8)!)
        }

        body.append(endBoundaryData)
        return body
    }

    private func mimeType(for filename: String) -> String {
        switch URL(fileURLWithPath: filename).pathExtension.lowercased() {
        case "jpg", "jpeg": "image/jpeg"
        case "png": "image/png"
        case "gif": "image/gif"
        case "txt": "text/plain"
        case "json": "application/json"
        case "xml": "application/xml"
        case "pdf": "application/pdf"
        case "zip": "application/zip"
        default: "application/octet-stream"
        }
    }

    enum Option: Sendable {
        case url(String)
        case data(String)
        case form(String, String)
        case header(String, String)
        case referer(String)
        case userAgent(String)
        case user(String, String?)
        case requestMethod(String)
        case head
        case ignored
    }

    enum ParserError: Error, LocalizedError, Sendable {
        case invalidBegin
        case noURL
        case invalidURL(String)
        case noSuchOption(String)
        case inValidParameter(String)
        case otherSyntaxError
        
        var errorDescription: String? {
            switch self {
            case .invalidBegin:
                "Your command should start with \"curl\"."
            case .noURL:
                "You did not specify a URL in your command."
            case .invalidURL(let url):
                "The URL \(url) is invalid. Only the HTTP and HTTPS protocols are currently supported."
            case .noSuchOption(let option):
                "\(option) is not supported."
            case .inValidParameter(let option):
                "The parameter for \(option) is not supported."
            default:
                nil
            }
        }
    }

    struct Lexer {
        static func tokenize(_ string: String) -> [String] {
            let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
            var tokens = [String]()
            var buffer = ""
            var iterator = string.makeIterator()
            var quote: Character?
            var isEscaped = false

            while let character = iterator.next() {
                if isEscaped {
                    if character != "\n" {
                        buffer.append(character)
                    }
                    isEscaped = false
                    continue
                }

                if let activeQuote = quote {
                    if character == activeQuote {
                        quote = nil
                    } else if activeQuote == "\"" && character == "\\" {
                        isEscaped = true
                    } else {
                        buffer.append(character)
                    }
                    continue
                }

                if character == "\\" {
                    isEscaped = true
                    continue
                }

                if character == "'" || character == "\"" {
                    quote = character
                    continue
                }

                if character == " " || character == "\n" || character == "\t" {
                    if !buffer.isEmpty {
                        tokens.append(buffer)
                        buffer = ""
                    }
                    continue
                }

                buffer.append(character)
            }

            if !buffer.isEmpty {
                tokens.append(buffer)
            }

            return tokens
        }

        private static func parseHeader(_ string: String, option: String) throws -> Option {
            guard let colonIndex = string.firstIndex(of: ":") else {
                throw ParserError.inValidParameter(option)
            }

            let key = string[..<colonIndex]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let value = string[string.index(after: colonIndex)...]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return .header(key, value)
        }

        fileprivate static func handleShortCommand(
            _ tokens: [String],
            _ index: inout Int,
            _ token: String,
            _ options: inout [Option],
            ignoresUnsupportedOptions: Bool
        ) throws {
            func value() throws -> String {
                let nextIndex = index + 1
                guard nextIndex < tokens.count else {
                    throw ParserError.inValidParameter(token)
                }

                index = nextIndex
                return tokens[nextIndex]
            }

            func ignoreValue() throws {
                _ = try value()
                options.append(.ignored)
            }

            switch token {
            case "-d":
                options.append(.data(try value()))

            case "-F":
                let formValue = try value()
                guard let equalsIndex = formValue.firstIndex(of: "=") else {
                    throw ParserError.inValidParameter(token)
                }

                let key = String(formValue[..<equalsIndex])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(formValue[formValue.index(after: equalsIndex)...])

                options.append(.form(key, value))

            case "-H":
                options.append(try parseHeader(try value(), option: token))

            case "-e":
                options.append(.referer(try value()))

            case "-A":
                options.append(.userAgent(try value()))

            case "-X":
                options.append(.requestMethod(try value()))

            case "-u":
                let userValue = try value()
                let components = userValue.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)

                if components.count == 2 {
                    options.append(.user(String(components[0]), String(components[1])))
                } else {
                    options.append(.user(userValue, nil))
                }

            case "-I":
                options.append(.head)

            case "-b":
                options.append(.header("Cookie", try value()))

            case "-L", "-k", "-s", "-S", "-v", "-i":
                options.append(.ignored)

            case "-m", "-o", "-O", "-x":
                try ignoreValue()

            default:
                guard !ignoresUnsupportedOptions else { return }
                throw ParserError.noSuchOption(token)
            }
        }

        fileprivate static func handleLongCommand(
            _ tokens: [String],
            _ index: inout Int,
            _ options: inout [Option],
            ignoresUnsupportedOptions: Bool
        ) throws {
            let token = tokens[index]

            let name: String
            let inlineValue: String?

            if let equalsIndex = token.firstIndex(of: "=") {
                name = String(token[..<equalsIndex])
                inlineValue = String(token[token.index(after: equalsIndex)...])
            } else {
                name = token
                inlineValue = nil
            }

            func value() throws -> String {
                if let inlineValue {
                    return inlineValue
                }

                let nextIndex = index + 1
                guard nextIndex < tokens.count else {
                    throw ParserError.inValidParameter(name)
                }

                index = nextIndex
                return tokens[nextIndex]
            }

            func ignoreValue() throws {
                _ = try value()
                options.append(.ignored)
            }

            switch name {
            case "--url":
                options.append(.url(try value()))

            case "--data", "--data-raw", "--data-binary":
                options.append(.data(try value()))

            case "--form", "--form-string":
                let formValue = try value()
                guard let equalsIndex = formValue.firstIndex(of: "=") else {
                    throw ParserError.inValidParameter(name)
                }

                let key = String(formValue[..<equalsIndex])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(formValue[formValue.index(after: equalsIndex)...])

                options.append(.form(key, value))

            case "--header":
                options.append(try parseHeader(try value(), option: name))

            case "--cookie":
                options.append(.header("Cookie", try value()))

            case "--referer":
                options.append(.referer(try value()))

            case "--user-agent":
                options.append(.userAgent(try value()))

            case "--request":
                options.append(.requestMethod(try value()))

            case "--user":
                let userValue = try value()
                let components = userValue.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)

                if components.count == 2 {
                    options.append(.user(String(components[0]), String(components[1])))
                } else {
                    options.append(.user(userValue, nil))
                }

            case "--head":
                options.append(.head)

            case "--compressed", "--location", "--insecure", "--silent", "--show-error", "--verbose", "--include":
                options.append(.ignored)

            case "--connect-timeout", "--max-time", "--retry", "--output", "--proxy", "--request-target":
                try ignoreValue()

            default:
                guard !ignoresUnsupportedOptions else { return }
                throw ParserError.noSuchOption(name)
            }
        }

        static func convertTokensToOptions(_ tokens: [String], ignoresUnsupportedOptions: Bool) throws -> [Option] {
            guard tokens.first == "curl" else {
                throw ParserError.invalidBegin
            }

            guard tokens.count >= 2 else {
                throw ParserError.noURL
            }

            var options = [Option]()
            var index = 1

            while index < tokens.count {
                let token = tokens[index]

                if token.hasPrefix("--") {
                    try handleLongCommand(
                        tokens,
                        &index,
                        &options,
                        ignoresUnsupportedOptions: ignoresUnsupportedOptions
                    )
                } else if token.hasPrefix("-") {
                    try handleShortCommand(
                        tokens,
                        &index,
                        token,
                        &options,
                        ignoresUnsupportedOptions: ignoresUnsupportedOptions
                    )
                } else {
                    options.append(.url(token))
                }

                index += 1
            }

            return options
        }
    }

    struct ParseResult: Sendable {
        var url: URL
        var user: String?
        var password: String?
        var postData: [String]
        var headers: [String: String]
        var postFields: [String: String]
        var files: [String: String]
        var httpMethod: String
    }

    struct Parser {
        public private(set) var command: String

        init(command: String) {
            self.command = command
        }

        static func compile(_ options: [Option]) throws -> ParseResult {
            var url = ""
            var user: String?
            var password: String?
            var postData: [String] = []
            var headers: [String: String] = [:]
            var postFields: [String: String] = [:]
            var files: [String: String] = [:]
            var httpMethod: String?

            for option in options {
                switch option {
                case .url(let string):
                    url = string

                case .data(let data):
                    postData.append(data)

                case .form(let key, let value):
                    if value.hasPrefix("@") {
                        files[key] = value
                    } else {
                        postFields[key] = value
                    }

                case .header(let key, let value):
                    headers[key] = value

                case .referer(let string):
                    headers["Referer"] = string

                case .userAgent(let string):
                    headers["User-Agent"] = string

                case .user(let currentUser, let currentPassword):
                    user = currentUser
                    password = currentPassword

                case .requestMethod(let method):
                    httpMethod = method

                case .head:
                    httpMethod = "HEAD"

                case .ignored:
                    break
                }
            }

            let finalHTTPMethod: String = {
                if let httpMethod {
                    return httpMethod
                }

                if !postData.isEmpty || !postFields.isEmpty || !files.isEmpty {
                    return "POST"
                }

                return "GET"
            }()

            url = url.trimmingCharacters(in: .whitespacesAndNewlines)

            guard url.hasPrefix("https://") || url.hasPrefix("http://") else {
                throw ParserError.invalidURL(url)
            }

            do {
                let pattern = "https?://(.*)@(.*)"
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(url.startIndex..<url.endIndex, in: url)
                let matches = regex.matches(in: url, range: range)

                if let match = matches.first,
                   let usernameRange = Range(match.range(at: 1), in: url) {
                    let substring = url[usernameRange]
                    let components = substring.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)

                    if user == nil {
                        user = String(components[0])

                        if components.count == 2 {
                            password = String(components[1])
                        }
                    }

                    url.removeSubrange(usernameRange)
                    url.remove(at: usernameRange.lowerBound)
                }
            } catch {}

            guard let finalURL = URL(string: url) else {
                throw ParserError.invalidURL(url)
            }

            return ParseResult(
                url: finalURL,
                user: user,
                password: password,
                postData: postData,
                headers: headers,
                postFields: postFields,
                files: files,
                httpMethod: finalHTTPMethod
            )
        }

        func parse(ignoresUnsupportedOptions: Bool) throws -> ParseResult {
            let command = command.trimmingCharacters(in: .whitespacesAndNewlines)

            let processedCommand = command
                .replacingOccurrences(of: "\\\\\\r?\\n", with: " ", options: .regularExpression)

            let tokens = Lexer.tokenize(processedCommand)
            let options = try Lexer.convertTokensToOptions(tokens, ignoresUnsupportedOptions: ignoresUnsupportedOptions)

            return try Parser.compile(options)
        }
    }
}
