//
//  URLRequest+CURL.swift
//  
//
//  Created by Florian Zand on 04.06.26.
//

import Foundation

public extension URLRequest {
    /// Creates and initializes a URL request with the given curl command.
    init(curlString: String) throws {
        do {
            self = try CURL(curlString).request()
        } catch {
            throw error
        }
    }
    
    /**
     Returns the curl command equivalent of the request.

     The curl command string includes the URL, HTTP method, headers, and body (if present) of the request.
     
     - Parameter includeCookies: A Boolean value indicating whether to include the cookies of the request.
     - Returns: A string representing the curl command equivalent of the request.
     - Important: The generated curl command may not accurately represent all aspects of the request, such as multipart form data.
     */
      func curlString(includeCookies: Bool = false) -> String {
          guard let url else { return "" }
          
          func shellEscape(_ string: String) -> String {
              "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'"
          }
          
          var components = ["curl"]
                    
          if let method = httpMethod, method != "GET" {
              if method == "HEAD" {
                  components += "--head"
              } else {
                  components += "-X \(method)"
              }
          }
          
          if let headers = allHTTPHeaderFields {
              var shouldAddCompressed = false
              for (key, value) in headers.sorted(by: \.key, options: .localizedStandard) {
                  if !includeCookies && key.caseInsensitiveCompare("Cookie") == .orderedSame {
                      continue
                  }
                  if key.caseInsensitiveCompare("Accept-Encoding") == .orderedSame {
                      shouldAddCompressed = true
                  }
                  components += "-H \(shellEscape("\(key): \(value)"))"
              }
              if shouldAddCompressed {
                  components += "--compressed"
              }
          }
          
          if let bodyData = httpBody {
              if let body = String(data: bodyData, encoding: .utf8) {
                  components += "--data-raw \(shellEscape(body))"
              } else {
                  components += "--data-binary @<(echo \(shellEscape(bodyData.base64EncodedString())) | base64 --decode)"
              }
          } else if httpBodyStream != nil {
              components += "# Body is provided via httpBodyStream and cannot be represented"
          }
          
          components += shellEscape(url.absoluteString)
          return components.joined(separator: " \\\n\t")
      }
}

fileprivate struct CURL: Sendable {
    private var result: ParseResult

    init(_ str: String) throws {
        let paser = Parser(command: str)
        self.result = try paser.parse()
    }

    func request() -> URLRequest {
        var request = URLRequest(url: result.url)
        request.httpMethod = result.httpMethod
        for header in result.headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        if let data = result.postData {
            request.httpBody = data.data(using: .utf8)
        } else if !result.files.isEmpty {
            // Handle multipart/form-data when files are present.
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = buildMultipartBody(boundary: boundary, postFields: result.postFields, files: result.files)
        } else if !result.postFields.isEmpty {
            // Handle application/x-www-form-urlencoded for simple form data.
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let joined = result.postFields.map { k, v in
                "\(k.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")=\(v.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")"
            }.joined(separator: "&")
            request.httpBody = joined.data(using: .utf8)
        }

        if let user = result.user {
            let loginData = String(format: "%@:%@", user, result.password ?? "").data(using: String.Encoding.utf8)!
            let base64LoginData = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func buildMultipartBody(boundary: String, postFields: [String: String], files: [String: String]) -> Data {
        var body = Data()
        let boundaryData = "--\(boundary)\r\n".data(using: .utf8)!
        let endBoundaryData = "--\(boundary)--\r\n".data(using: .utf8)!
        
        // Add the form fields.
        for (key, value) in postFields {
            body.append(boundaryData)
            let fieldHeader = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!
            body.append(fieldHeader)
            body.append(value.data(using: .utf8) ?? Data())
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add the files.
        for (key, filePath) in files {
            body.append(boundaryData)
            
            // Remove the @ prefix from the file path.
            let actualPath = String(filePath.dropFirst())
            let filename = URL(fileURLWithPath: actualPath).lastPathComponent
            
            let fileHeader = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!
            body.append(fileHeader)
            
            // Attempt to determine the content type based on the file extension.
            let contentType = mimeType(for: filename)
            let contentTypeHeader = "Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!
            body.append(contentTypeHeader)
            
            // Read the file data.
            if let fileData = try? Data(contentsOf: URL(fileURLWithPath: actualPath)) {
                body.append(fileData)
            } else {
                // If the file cannot be read, append an error placeholder.
                let errorData = "[File not found or unreadable: \(actualPath)]".data(using: .utf8) ?? Data()
                body.append(errorData)
            }
            
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append(endBoundaryData)
        return body
    }
    
    /// Determines the MIME type based on a file's extension.
    ///
    /// - Parameter filename: The name of the file to evaluate.
    /// - Returns: The corresponding MIME type as a string.
    private func mimeType(for filename: String) -> String {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "txt":
            return "text/plain"
        case "json":
            return "application/json"
        case "xml":
            return "application/xml"
        case "pdf":
            return "application/pdf"
        case "zip":
            return "application/zip"
        default:
            return "application/octet-stream"
        }
    }

    /// Represents the supported cURL options that can be parsed from a command.
    enum Option: Sendable {
        /// The URL to fetch.
        case url(String)
        /// The HTTP POST data (`-d` or `--data`).
        case data(String)
        /// The HTTP multipart POST data (`-F` or `--form`).
        case form(_ key: String, _ value: String)
        /// A custom HTTP header (`-H` or `--header`).
        case header(_ key: String, _ value: String)
        /// The referer URL (`-e` or `--referer`).
        case referer(String)
        /// The User-Agent string (`-A` or `--user-agent`).
        case userAgent(String)
        /// The server user and optional password (`-u` or `--user`).
        case user(_ user: String, _ password: String?)
        /// The HTTP request method (`-X` or `--request`).
        case requestMethod(String)
    }
    
    /// Errors that can occur while parsing parameters.
    enum ParserError: Error, LocalizedError, Sendable {
        /// The command does not begin with `curl`.
        case invalidBegin
        /// A URL was not provided.
        case noURL
        /// The provided URL format is invalid.
        case invalidURL(String)
        /// The specified option is not supported.
        case noSuchOption(String)
        /// The provided parameter is invalid.
        case inValidParameter(String)
        /// Another syntax error occurred.
        case otherSyntaxError
        
        public var errorDescription: String? {
            switch self {
            case .invalidBegin:
                return "Your command should start with \"curl\"."
            case .noURL:
                return "You did not specify a URL in your command."
            case .invalidURL(let url):
                return "The URL \(url) is invalid. Only the HTTP and HTTPS protocols are currently supported."
            case .noSuchOption(let option):
                return "\(option) is not supported."
            case .inValidParameter(let option):
                return "The parameter for \(option) is not supported."
            default:
                return nil
            }
        }
    }
    
    struct Lexer {
        static func tokenize(_ str: String) -> [String] {
            let str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            var slices = [String]()
            let scanner = Scanner(string: str)
            scanner.charactersToBeSkipped = nil
            var buffer = ""
            
            while scanner.isAtEnd == false {
                let result = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: " \n\"\'") )
                if result == nil {
                    scanner.currentIndex = str.index(after: scanner.currentIndex)
                }
                if scanner.isAtEnd {
                    buffer += result ?? ""
                    slices.append(buffer)
                    break
                }
                
                let lastChar = String(str[scanner.currentIndex])
                if lastChar == "\"" || lastChar == "\'" {
                    let quote = lastChar
                    buffer += result ?? ""
                    scanner.currentIndex = str.index(after: scanner.currentIndex)
                    while true {
                        if let scannedString = scanner.scanUpToString(quote) {
                            buffer.append(scannedString)
                            if scanner.isAtEnd {
                                if !buffer.isEmpty {
                                    slices.append(buffer)
                                }
                                buffer = ""
                                break
                            }
                            if scannedString[scannedString.index(before: scannedString.endIndex)] != "\\" {
                                // Find the matching quotation mark.
                                scanner.currentIndex = str.index(after: scanner.currentIndex)
                                if let _ = scanner.scanCharacters(from: CharacterSet(charactersIn: " \n") ) {
                                    if !buffer.isEmpty {
                                        slices.append(buffer)
                                        buffer = ""
                                    }
                                }
                                break
                            } else {
                                // The quotation mark is escaped. Continue parsing.
                                scanner.currentIndex = str.index(after: scanner.currentIndex)
                                buffer.remove(at: buffer.index(before: buffer.endIndex))
                                buffer.append(quote)
                            }
                        } else {
                            if !buffer.isEmpty {
                                slices.append(buffer)
                                buffer = ""
                            }
                            break
                        }
                    }
                    if scanner.isAtEnd {
                        if !buffer.isEmpty {
                            slices.append(buffer)
                            buffer = ""
                        }
                        break
                    }
                } else {
                    buffer += result ?? ""
                    if !buffer.isEmpty {
                        slices.append(buffer)
                    }
                    buffer = ""
                }
            }
            return slices
        }
        
        fileprivate static func handleShortCommands(_ tokens: [String], _ index: Int, _ token: String, _ options: inout [Option]) throws {
            let nextToken = tokens[index]
            switch token {
            case "-d":
                options.append(.data(nextToken))
            case "-F":
                let components = nextToken.components(separatedBy: "=")
                if components.count < 2 {
                    throw ParserError.inValidParameter(token)
                }
                options.append(.form(components[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), components[1]))
            case "-H":
                let components = nextToken.components(separatedBy: ":")
                if components.count < 2 {
                    throw ParserError.inValidParameter(token)
                }
                options.append(.header(components[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), components[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
            case "-e":
                options.append(.referer(nextToken))
            case "-A":
                options.append(.userAgent(nextToken))
            case "-X":
                options.append(.requestMethod(nextToken))
            case "-u":
                let components = nextToken.components(separatedBy: ":")
                if components.count >= 2 {
                    options.append(.user(components[0], components[1]))
                } else {
                    options.append(.user(components[0], nil))
                }
            default:
                throw ParserError.noSuchOption(token)
            }
        }
        
        fileprivate static func handleLongCommands(_ token: String, _ options: inout [Option]) throws {
            let components = token.components(separatedBy: "=")
            switch components[0] {
            case "--data":
                if components.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                options.append(.data(components[1]))
            case "--form", "-form-string":
                if components.count < 3 {
                    throw ParserError.inValidParameter(components[0])
                }
                options.append(.form(components[1], components[2]))
            case "--header":
                if components.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                let keyValue = components[1].components(separatedBy: ":")
                if keyValue.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                options.append(.header(keyValue[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), keyValue[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
            case "--referer":
                if components.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                options.append(.referer(components[1]))
            case "--user-agent":
                if components.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                options.append(.userAgent(components[1]))
            case "--request":
                if components.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                options.append(.requestMethod(components[1]))
            case "--user":
                if components.count < 2 {
                    throw ParserError.inValidParameter(components[0])
                }
                let userPassword = components[1].components(separatedBy: ":")
                if userPassword.count >= 2 {
                    options.append(.user(userPassword[0], userPassword[1]))
                } else {
                    options.append(.user(userPassword[0], nil))
                }
            default:
                throw ParserError.noSuchOption(components[0])
            }
        }
        
        static func convertTokensToOptions(_ tokens: [String]) throws -> [Option] {
            switch tokens.first {
            case "curl": break
            default: throw ParserError.invalidBegin
            }
            if tokens.count < 2 {
                throw ParserError.noURL
            }
            var options = [Option]()
            var index = 1
            while index < tokens.count {
                let token = tokens[index]
                if token.hasPrefix("--") {
                    try handleLongCommands(token, &options)
                }
                else if token.hasPrefix("-") {
                    index += 1
                    if index >= tokens.count {
                        throw ParserError.inValidParameter(token)
                    }
                    try handleShortCommands(tokens, index, token, &options)
                }  else {
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
        var postData: String?
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
            var url: String = ""
            var user: String?
            var password: String?
            var postData: String?
            var headers: [String: String] = [:]
            var postFields: [String: String] = [:]
            var files: [String: String] = [:]
            var httpMethod: String?
            
            for option in options {
                switch option {
                case .url(let str):
                    url = str
                case .data(let data):
                    postData = data
                case .form(let key, let value):
                    if value.hasPrefix("@") {
                        files[key] = value
                    } else {
                        postFields[key] = value
                    }
                case .header(let key, let value):
                    headers[key] = value
                case .referer(let str):
                    headers["Referer"] = str
                case .userAgent(let str):
                    headers["User-Agent"] = str
                case .user(let aUser, let aPassword):
                    user = aUser
                    password = aPassword
                case .requestMethod(let method):
                    httpMethod = method
                }
            }
            
            let finalHTTPMethod: String = {
                if let httpMethod = httpMethod {
                    return httpMethod
                }
                if postData != nil {
                    return "POST"
                }
                if !postFields.isEmpty {
                    return "POST"
                }
                if !files.isEmpty {
                    return "POST"
                }
                return "GET"
            }()
            
            url = url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if !url.hasPrefix("https://") && !url.hasPrefix("http://") {
                throw ParserError.invalidURL(url)
            }
            
            do {
                let pattern = "https?://(.*)@(.*)"
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: url, options: [], range: NSMakeRange(0, url.count))
                if matches.count > 0 {
                    let usernameRange = matches[0].range(at: 1)
                    let start = url.index(url.startIndex, offsetBy: usernameRange.location)
                    let end = url.index(url.startIndex, offsetBy: usernameRange.location + usernameRange.length)
                    let substring = url[start..<end]
                    let components = substring.components(separatedBy: ":")
                    if user == nil {
                        user = components[0]
                        if components.count >= 2 {
                            password = components[1]
                        }
                    }
                    url.removeSubrange(start...end)
                }
            } catch {
            }
            
            guard let finalUrl = URL(string: url) else {
                throw ParserError.invalidURL(url)
            }
            
            return ParseResult(url: finalUrl, user: user, password: password, postData: postData, headers: headers, postFields: postFields, files: files, httpMethod: finalHTTPMethod)
        }
        
        func parse() throws -> ParseResult {
            let command = self.command.trimmingCharacters(in: CharacterSet.whitespaces)
            // Handle line continuation characters (\) followed by whitespace or newlines.
            let processedCommand = command.replace(pattern: "\\\\\\s*\\n", with: " ")?.replacingOccurrences(of: "  +", with: " ", options: .regularExpression) ?? command
            let slices = Lexer.tokenize(processedCommand)
            let options = try Lexer.convertTokensToOptions(slices)
            let result = try Parser.compile(options)
            return result
        }
    }
}
