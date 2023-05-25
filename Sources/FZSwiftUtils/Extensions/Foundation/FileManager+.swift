//
//  File.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation

public extension FileManager {
    func createTemporaryDirectory() -> URL {
        let temporaryDirectoryURL: URL
        if #available(macOS 10.12, iOS 10.0, *) {
            temporaryDirectoryURL = temporaryDirectory
        } else {
            temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        }
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        return temporaryDirectoryURL.appendingPathComponent(folderName)
    }

    #if os(macOS)
        enum ApplicationSupportDirectoryType {
            case identifier
            case name
        }

        func applicationSupportDirectory(using type: ApplicationSupportDirectoryType = .name, create: Bool = true) -> URL? {
            if let appSupportURL = urls(for: .applicationSupportDirectory, in: .userDomainMask).first, let pathComponent = (type == .name) ? Bundle.main.bundleName : Bundle.main.bundleIdentifier {
                let directoryURL = appSupportURL.appendingPathComponent(pathComponent)
                if directoryExists(at: directoryURL) {
                    return directoryURL
                } else if create {
                    do {
                        try createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                        return directoryURL
                    } catch {
                        Swift.print(error)
                    }
                }
            }
            return nil
        }
    #endif

    func directoryExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = true
        return fileExists(atPath: path, isDirectory: &isDir)
    }

    func fileExists(at url: URL) -> Bool {
        return fileExists(atPath: url.path)
    }

    func directoryExists(at url: URL) -> Bool {
        return directoryExists(atPath: url.path)
    }
}
