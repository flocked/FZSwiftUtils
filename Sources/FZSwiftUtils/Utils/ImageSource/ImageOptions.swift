//
//  NewOptions.swift
//  ATest
//
//  Created by Florian Zand on 03.06.22.
//

import Foundation

public extension ImageSource {
    struct ImageOptions: Codable {
        public var shouldCache: Bool? = true
        public var shouldDecodeImmediately: Bool? = nil
        public var subsampleFactor: SubsampleFactor? = nil
        public var shouldAllowFloat: Bool? = false
        
        public enum SubsampleFactor: Int, Codable {
            case factor2 = 2
            case factor4 = 4
            case factor8 = 8
        }
        
        internal var dic: CFDictionary {
            return self.toDictionary() as CFDictionary
        }
        
        public init() { }
        
        public enum CodingKeys: String, CodingKey {
            case shouldAllowFloat = "kCGImageSourceShouldAllowFloat"
            case shouldCache = "kCGImageSourceShouldCache"
            case shouldDecodeImmediately = "kCGImageSourceShouldCacheImmediately"
            case subsampleFactor = "kCGImageSourceSubsampleFactor"
        }
    }
    
    struct ThumbnailOptions: Codable {
        public var shouldCache: Bool? = true
        public var shouldDecodeImmediately: Bool? = true
        public var subsampleFactor: SubsampleFactor? = nil
        public var shouldAllowFloat: Bool? = false
        public var maxSize: Int? = nil
        public var shouldTransform: Bool? = nil
        internal var createIfAbsent: Bool? = nil
        internal var createAlways: Bool? = true
        
        public var createOption: CreateOption {
            get { if createAlways == true { return .always }
                else if createIfAbsent == true { return .ifAbsent }
                return .never }
            set { self.createAlways = (newValue == .always) ? true : nil
                self.createIfAbsent = (newValue == .ifAbsent) ? true : nil }
        }
        
        public enum SubsampleFactor: Int, Codable {
            case factor2 = 2
            case factor4 = 4
            case factor8 = 8
        }
        
        public enum CreateOption: Codable {
            case ifAbsent
            case always
            case never
        }
        
        internal var dic: CFDictionary {
            return self.toDictionary() as CFDictionary
        }
        
        public init() { }
        
        public static func maxSize(_ maxSize: CGSize) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.maxSize = Int(max(maxSize.width, maxSize.height))
            return options
        }
        
        public static func maxSize(_ maxSize: Int) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.maxSize = maxSize
            return options
        }
            
        public static func subsampleFactor(_ subsampleFactor: SubsampleFactor) -> ThumbnailOptions {
            var options = ThumbnailOptions()
            options.subsampleFactor = subsampleFactor
            return options
        }
        
        public enum CodingKeys: String, CodingKey {
            case shouldAllowFloat = "kCGImageSourceShouldAllowFloat"
            case shouldCache = "kCGImageSourceShouldCache"
            case shouldDecodeImmediately = "kCGImageSourceShouldCacheImmediately"
            case subsampleFactor = "kCGImageSourceSubsampleFactor"
            case maxSize = "kCGImageSourceThumbnailMaxPixelSize"
            case shouldTransform = "kCGImageSourceCreateThumbnailWithTransform"
            case createIfAbsent = "kCGImageSourceCreateThumbnailFromImageIfAbsent"
            case createAlways = "kCGImageSourceCreateThumbnailFromImageAlways"
        }
    }
}
