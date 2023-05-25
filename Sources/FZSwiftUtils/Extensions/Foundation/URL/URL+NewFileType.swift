//
//  File.swift
//  
//
//  Created by Florian Zand on 13.05.23.
//

import Foundation

public extension URL {
    enum FileTypeNew: Hashable, CustomStringConvertible {
        case aliasFile
        case application
        case archive
        case audio
        case diskImage
        case document
        case executable
        case folder
        case gif
        case image
        case other(_ pathExtension: String)
        case pdf
        case presentation
        case symbolicLink
        case text
        case video
        
        var typeIdentifier: String? {
            switch self {
            case .aliasFile: return "com.apple.alias-file"
            case .application: return "com.apple.application"
            case .archive: return "public.archive"
            case .audio: return "public.audio"
            case .diskImage: return "public.disk-image"
            case .document: return nil
            case .executable: return "public.executable"
            case .folder: return "public.folder"
            case .gif: return "com.compuserve.gif"
            case .image: return "public.image"
            case .other(_): return nil
            case .pdf: return "com.adobe.pdf"
            case .presentation: return "public.presentation"
            case .symbolicLink: return "public.symlink"
            case .text: return "public.composite-content"
            case .video: return "public.movie"
            }
        }
        
        var commonExtensions: [String] {
            switch self {
            case .image:
                return ["png", "gif", "jpeg", "jpg", "heic", "tiff", "tif", "heif", "pnj"]
            case .video:
                return ["m4v", "mov", "mp4", "ts", "avi", "mpeg", "mpg", "qt", "gifv", "flv", "webm", "m2ts", "wmv", "mts", "mkv"]
            case .gif: return ["gif"]
            case .audio:
                return ["mp3", "wav", "wave", "flac", "ogg", "alac", "m4a", "aiff", "wma", "oga", "aac", "mka"]
            case .pdf:
                return ["pdf"]
            case .text:
                return ["txt"]
            case .archive:
                return ["zip", "rar"]
            case .document:
                return ["pages", "word"]
            case .presentation:
                return ["keynote", "powerpoint"]
            case .application:
                return ["app"]
            default:
                return []
            }
        }
        
        var isMultimedia: Bool {
            self == .video || self == .audio || self == .gif || self == .image
        }
        
        internal static let allCases: [FileType] = [.aliasFile, .symbolicLink, .application, .executable, .archive, .video, .audio, .diskImage, .document, .folder, .gif, .image, .pdf, .presentation, .text]
        
        public var description: String {
            switch self {
            case .aliasFile: return "AliasFile"
            case .application: return "Application"
            case .archive: return "Archive"
            case .audio: return "Music"
            case .diskImage: return "DiskImage"
            case .document: return "Document"
            case .executable: return "Executable"
            case .folder: return "Folder"
            case .gif: return "GIF"
            case .image: return "Image"
            case .other(let value): return "File: .\(value)"
            case .pdf:  return "PDF"
            case .presentation: return "Application"
            case .symbolicLink: return "SymbolicLink"
            case .text: return "Text"
            case .video: return "Movie"
            }
        }
        
        internal var predicate: NSPredicate {
            let key: NSExpression
            let type: NSComparisonPredicate.Operator
            switch self {
            case .executable, .folder, .image, .video, .audio, .pdf, .presentation:
                key = NSExpression(forKeyPath: "_kMDItemGroupId")
                type = .equalTo
            case  .aliasFile, .application, .archive, .diskImage, .text, .gif, .document, .symbolicLink, .other(_):
                key = NSExpression(forKeyPath: "kMDItemContentTypeTree")
                type = .like
            }
            let value: NSExpression
            switch self {
            case .executable: value = NSExpression(format: "%i", 8)
            case .folder: value = NSExpression(format: "%i", 9)
            case .image: value = NSExpression(format: "%i", 13)
            case .video: value = NSExpression(format: "%i", 7)
            case .audio: value = NSExpression(format: "%i", 10)
            case .pdf: value = NSExpression(format: "%i", 11)
            case .presentation: value = NSExpression(format: "%i", 12)
            case .application: value = NSExpression(format: "%@", "com.apple.application")
            case .archive: value = NSExpression(format: "%@", "com.apple.public.archive")
            case .diskImage: value = NSExpression(format: "%@", "public.disk-image")
            case .gif: value = NSExpression(format: "%@", "com.compuserve.gif")
            case .document: value = NSExpression(format: "%@", "public.content")
            case .text: value = NSExpression(format: "%@", "public.text")
            case .aliasFile: value = NSExpression(format: "%@", "com.apple.alias-file")
            case .symbolicLink: value = NSExpression(format: "%@", "public.symlink")
            case .other(let oValue): value = NSExpression(format: "%@", oValue)
            }
            
            let modifier: NSComparisonPredicate.Modifier
            switch self {
            case .application, .archive, .text, .document, .other(_):
                modifier = .any
            default:
                modifier = .direct
            }
            return NSComparisonPredicate(leftExpression: key, rightExpression: value, modifier: modifier, type: type)
        }
        
    }
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, *)
public extension URL.FileTypeNew {
    internal var uttype: UTType? {
        if let identifier = self.typeIdentifier {
            return UTType(identifier)
        }
        return nil
    }
}
#endif
