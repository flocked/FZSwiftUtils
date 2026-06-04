//
//  FileType.swift
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
    /// The file type of the url.
    var fileType: FileType? {
        FileType(url: self)
    }

    /// A Boolean value indicating whether the file is a video.
    var isVideo: Bool {
        fileType == .video
    }

    /// A Boolean value indicating whether the file is an image.
    var isImage: Bool {
        fileType == .image
    }

    /// A Boolean value indicating whether the file is a GIF.
    var isGIF: Bool {
        fileType == .gif
    }

    /// A Boolean value indicating whether the file is a multimedia file (audio, image, GIF or video).
    var isMultimedia: Bool {
        fileType?.isMultimedia ?? false
    }
}

/// The type of a file.
public struct FileType: CaseIterable, CustomStringConvertible, Hashable, Codable {
    /// The content type of the file type.
    public let contentType: UTType
    /// The content type identifier of the file type.
    public var identifier: String { contentType.identifier }
    /// The most common file extensions of the file type.
    public let commonExtensions: [String]
    /// The description of the file type.
    public let description: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(contentType)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.contentType == rhs.contentType
    }

    /// Audio ("mp3", "m4a", "aac"…)
    public static let audio = Self(.audio, "Audio",
                                   ["mp3", "m4a", "aac", "wav", "flac", "alac", "ogg", "aiff", "wma", "oga", "mka", "wave", "opus", "amr", "aif"]
    )

    /// Video ("mp4", "mov", "m4v"…)
    public static let video = Self(.movie, "Video",
                                   ["mp4", "mov", "m4v", "avi", "mkv", "wmv", "flv", "webm", "ts", "mpeg", "mpg", "qt", "gifv", "m2ts", "mts", "3gp", "3g2", "mxf", "ogv", "rm"]
    )

    /// Image ("jpg", "jpeg", "png"…)
    public static let image = Self(.image, "Image",
                                   ["jpg", "jpeg", "png", "heic", "tiff", "heif", "tif", "webp", "svg", "ico", "raw", "bmp", "jfif"]
    )

    /// GIF ("gif")
    public static let gif = Self(.gif, "GIF",
                                 ["gif"]
    )

    /// PDF ("pdf")
    public static let pdf = Self(.pdf, "PDF",
                                 ["pdf"]
    )

    /// Text ("txt", "md", "csv"…)
    public static let text = Self(.text, "Text",
                                  ["txt", "md", "csv", "rtf", "log", "tex"]
    )

    /// Archive ("zip", "rar", "7z"…)
    public static let archive = Self(.archive, "Archive",
                                     ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "lzma", "cab", "tgz"]
    )

    /// Document ("docx", "doc", "pages"…)
    public static let document = Self(.compositeContent, "Document",
                                      ["docx", "doc", "pages", "odt", "rtf", "word", "txt", "xml", "md", "wps", "sxw", "dotx"]
    )

    /// Spreadsheet ("xlsx", "xls", "ods"…)
    public static let spreadsheet = Self(.spreadsheet, "Spreadsheet",
                                         ["xlsx", "xls", "ods", "csv", "tsv", "xlsm", "xlsb", "numbers"]
    )

    /// Presentation ("pptx", "powerpoint", "keynote"…)
    public static let presentation = Self(.presentation, "Presentation",
                                          ["pptx", "powerpoint", "keynote", "odp", "ppt", "prezi", "pps", "ppsx"]
    )

    /// Application ("app", "exe", "apk"…)
    public static let application = Self(.application, "Application",
                                         ["app", "exe", "apk", "bat", "msi"]
    )

    /// DiskImage ("iso", "dmg", "vmdk"…)
    public static let diskImage = Self(.diskImage, "DiskImage",
                                       ["iso", "dmg", "vmdk", "vhd", "img"]
    )

    /// Executable ("exe", "sh", "bat"…)
    public static let executable = Self(.executable, "Executable",
                                        ["exe", "sh", "bat", "com", "bin"]
    )

    /// Calendar ("ics", "ifb")
    public static let calendar = Self(.calendarEvent, "Calendar",
                                      ["ics", "ifb"]
    )

    /// Contact ("vcf", "vcard", "abbu")
    public static let contact = Self(.contact, "Contact",
                                     ["vcf", "vcard", "abbu"]
    )

    /// Font ("ttf", "otf", "woff"…)
    public static let font = Self(.font, "Font",
                                  ["ttf", "otf", "woff", "woff2", "eot", "pfb", "pfm"]
    )

    /// Source Code ("js", "py", "rb"…)
    public static let sourceCode = Self(.sourceCode, "Source Code",
                                        ["js", "py", "rb", "pl", "php", "java", "swift", "c", "cpp", "cs", "go", "rs", "sh", "kt", "h", "m"]
    )

    /// AliasFile
    public static let aliasFile = Self(.aliasFile, "AliasFile", [])

    /// SymbolicLink
    public static let symbolicLink = Self(.symbolicLink, "SymbolicLink", [])

    /// Folder
    public static let folder = Self(.folder, "Folder", [])

    /// Database ("sqlite", "db", "mdb"…)
    public static let database = Self(.database, "Database",
                                      ["sqlite", "db", "mdb", "accdb", "sql"]
    )
    
    // let cadFileExtensions = ["dwg","dxf","stp","step","igs","iges","stl","obj","fbx","sldprt","sldasm","slddrw","skp","f3d","3ds","max","x_t","x_b","prt","asm","dgn","dwt","ipt","iam"]

    public static let allCases: [Self] = [
        .audio, .video, .gif, .image, .pdf, .document, .spreadsheet, .presentation, .text, .archive, .aliasFile, .symbolicLink, .folder, .application, .executable, .diskImage, .font, .contact, .calendar, .sourceCode, .database,
    ]
    
    /// All multimedia file types (`audio`, `video`, `image` and `gif`).
    static let multimediaTypes: [Self] = [.gif, .image, .video, .audio]

    /// All image file types (`image` and `gif`).
    static let imageTypes: [Self] = [.gif, .image]
    
    /// A Boolean value indicating whether the file type is a multimedia type (either `audio`, `video`, `image` or `gif`).
    var isMultimedia: Bool {
        Self.multimediaTypes.contains(self)
    }

    /// A Boolean value indicating whether the file type is an image type (either `image` or `gif`).
    var isImageType: Bool {
        Self.imageTypes.contains(self)
    }
    
    /// Returns the type for the specified content type.
    public init?(contentType: UTType) {
        if let fileType = Self.allCases.first(where: { $0.contentType == contentType || contentType.conforms(to: $0.contentType)}) {
            self = fileType
        } else if let fileExtension = contentType.preferredFilenameExtension, let fileType = Self.allCases.first(where: {$0.commonExtensions.contains(fileExtension)}) {
            self = fileType
        } else {
            return nil
        }
    }
    
    /// Returns the type for the file at the specified url.
    public init?(url: URL) {
        if url.hasDirectoryPath {
            self = .folder
        } else if let fileType = Self(fileExtension: url.pathExtension) {
            self = fileType
        } else if let contentType = url.contentType {
            self.init(contentType: contentType)
        } else {
            return nil
        }
    }

    /// Returns the type for the specified file extension.
    public init?(fileExtension: String) {
        let fileExtension = fileExtension.lowercased()
        if fileExtension == "" {
            self = .folder
        } else if let fileType = Self.allCases.first(where: { $0.commonExtensions.contains(fileExtension) }) {
            self = fileType
        } else if let contentType = UTType(filenameExtension: fileExtension) {
            self.init(contentType: contentType)
        } else {
            return nil
        }
    }
    
    fileprivate init(_ contentType: UTType, _ description: String, _ commonExtensions: [String]) {
        self.contentType = contentType
        self.description = description
        self.commonExtensions = commonExtensions
    }
}
