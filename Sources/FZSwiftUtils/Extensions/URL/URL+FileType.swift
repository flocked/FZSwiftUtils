//
//  URL+NewFileType.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

#if canImport(UIKit)
import MobileCoreServices
#endif

public extension URL {
    enum FileType: Hashable, CustomStringConvertible, CaseIterable {
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
        
        

        public init?(url: URL) {
        /*    if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
                if let uttype = UTType(url: url), let fileType = FileType(uttype: uttype) {
                    self = fileType
                    return
                }
            } else { */
                if let contentTypeIdentifier = url.contentTypeIdentifier, let fileType = FileType(contentTypeIdentifier: contentTypeIdentifier) {
                    self = fileType
                    return
                } else if let fileType = FileType(contentTypeTree: url.contentTypeIdentifierTree) {
                    self = fileType
                    return
                }
           // }
            if let fileType = FileType(fileExtension: url.pathExtension) {
                self = fileType
                return
            } else {
                return nil
            }
        }

        public init?(fileExtension: String) {
            guard fileExtension != "" else {
                self = .folder
                return
            }

            if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
                if let uttype = UTType(filenameExtension: fileExtension), let fileType = FileType(uttype: uttype) {
                    self = fileType
                    return
                }
            }

            if let fileType = FileType.allCases.first(where: { $0.commonExtensions.contains(fileExtension.lowercased()) }) {
                self = fileType
                return
            } else {
                return nil
            }
        }

        public init?(contentTypeIdentifier: String) {
            guard let fileType = FileType.allCases.first(where: { $0.identifier == contentTypeIdentifier }) else {
                return nil
            }
            self = fileType
        }

        public init?(contentTypeTree: [String]) {
            let allIdentifiers = FileType.allCases.compactMap { $0.identifier }
            if let identifier = contentTypeTree.first(where: { allIdentifiers.contains($0) }), let fileType = FileType(contentTypeIdentifier: identifier) {
                self = fileType
                return
            } else {
                return nil
            }
        }

        #if canImport(UniformTypeIdentifiers)
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public init?(uttype: UTType) {
            
            if let fileType = FileType.allCases.first(where: {
                if let allUTType = $0.uttype, uttype.conforms(to: allUTType) {
                    return true
                }
                return false
            }) {
                self = fileType
            } else if let pathExtension = uttype.preferredFilenameExtension {
                self = .other(pathExtension)
            } else {
                return nil
            }
        }
        #endif
    }

    var fileType: FileType? {
        return FileType(url: self)
    }

    var isVideo: Bool {
        fileType == .video
    }

    var isImage: Bool {
        fileType == .image
    }

    var isGIF: Bool {
        fileType == .gif
    }

    var isMultimedia: Bool {
        fileType?.isMultimedia ?? false
    }
}

public extension URL.FileType {
    var identifier: String? {
        switch self {
        case .aliasFile: return "com.apple.alias-file"
        case .symbolicLink: return "public.symlink"
        case .folder: return "public.folder"
        case .application: return "com.apple.application"
        case .archive: return "public.archive"
        case .audio: return "public.audio"
        case .diskImage: return "public.disk-image"
        case .executable: return "public.executable"
        case .video: return "public.movie"
        case .gif: return "com.compuserve.gif"
        case .image: return "public.image"
        case .pdf: return "com.adobe.pdf"
        case .presentation: return "public.presentation"
        case .text: return "public.text"
        case .document: return "public.composite-content"
        case let .other(pathExtension):
            guard pathExtension != "" else {
                return "public.folder"
            }
            if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
                if let identifier = UTType(filenameExtension: pathExtension)?.identifier {
                    return identifier
                }
            }
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue(), let mimeIdentifier = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeIdentifier as String
            }
            return nil
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

    var description: String {
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
        case let .other(value): return "File (.\(value))"
        case .pdf: return "PDF"
        case .presentation: return "Application"
        case .symbolicLink: return "SymbolicLink"
        case .text: return "Text"
        case .video: return "Movie"
        }
    }

    var isMultimedia: Bool {
        self == .video || self == .audio || self == .gif || self == .image
    }

    static let allCases: [URL.FileType] = [.aliasFile, .symbolicLink, .folder, .application, .executable, .video, .audio,  .gif, .image, .archive, .diskImage, .document, .pdf, .presentation, .text]

    static var multimediaTypes: [URL.FileType] = [.gif, .image, .video]
    static var imageTypes: [URL.FileType] = [.gif, .image]

    #if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    var uttype: UTType? {
        if let identifier = identifier {
            return UTType(identifier)
        }
        return nil
    }
    #endif

    internal var predicate: NSPredicate {
        let key: NSExpression
        let type: NSComparisonPredicate.Operator
        switch self {
        case .executable, .folder, .image, .video, .audio, .pdf, .presentation:
            key = NSExpression(forKeyPath: "_kMDItemGroupId")
            type = .equalTo
        case .aliasFile, .application, .archive, .diskImage, .text, .gif, .document, .symbolicLink, .other:
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
        case let .other(oValue): value = NSExpression(format: "%@", oValue)
        }

        let modifier: NSComparisonPredicate.Modifier
        switch self {
        case .application, .archive, .text, .document, .other:
            modifier = .any
        default:
            modifier = .direct
        }
        return NSComparisonPredicate(leftExpression: key, rightExpression: value, modifier: modifier, type: type)
    }
}

/*
 if let groupID = item.item.value(forAttribute: "_kMDItemGroupId") as? Int {
     switch groupID {
     case 8:
         fileType =  .executable
     case 9:
         fileType = .folder
     case 13:
         fileType =  .image
     case 7:
         fileType = .video
     case 10:
         fileType = .audio
     case 11:
         fileType = .pdf
     case 12:
         fileType = .presentation
     default:
         break
     }
 }
 */
