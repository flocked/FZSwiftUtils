//
//  MediaFormatTypes.swift
//
//
//  Created by Florian Zand on 24.07.26.
//

import Foundation
import CoreMedia

/// An audio format subtype.
public struct AudioFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let aLaw = Self(.aLaw)
    public static let aacAudibleProtected = Self(.aacAudibleProtected)
    public static let aacLCProtected = Self(.aacLCProtected)
    public static let ac3 = Self(.ac3)
    public static let aes3 = Self(.aes3)
    public static let amr = Self(.amr)
    public static let amrWideband = Self(.amr_WB)
    public static let appleIMA4 = Self(.appleIMA4)
    public static let appleLossless = Self(.appleLossless)
    public static let audible = Self(.audible)
    public static let dviIntelIMA = Self(.dviIntelIMA)
    public static let enhancedAC3 = Self(.enhancedAC3)
    public static let flac = Self(.flac)
    public static let iLBC = Self(.iLBC)
    public static let iec60958AC3 = Self(.iec60958AC3)
    public static let linearPCM = Self(.linearPCM)
    public static let mace3 = Self(.mace3)
    public static let mace6 = Self(.mace6)
    public static let microsoftGSM = Self(.microsoftGSM)
    public static let midiStream = Self(.midiStream)
    public static let mpeg4AAC = Self(.mpeg4AAC)
    public static let mpeg4AAC_ELD = Self(.mpeg4AAC_ELD)
    public static let mpeg4AAC_ELD_SBR = Self(.mpeg4AAC_ELD_SBR)
    public static let mpeg4AAC_ELD_V2 = Self(.mpeg4AAC_ELD_V2)
    public static let mpeg4AAC_HE = Self(.mpeg4AAC_HE)
    public static let mpeg4AAC_HE_V2 = Self(.mpeg4AAC_HE_V2)
    public static let mpeg4AAC_LD = Self(.mpeg4AAC_LD)
    public static let mpeg4AAC_Spatial = Self(.mpeg4AAC_Spatial)
    public static let mpeg4CELP = Self(.mpeg4CELP)
    public static let mpeg4HVXC = Self(.mpeg4HVXC)
    public static let mpeg4TwinVQ = Self(.mpeg4TwinVQ)
    public static let mpegD_USAC = Self(.mpegD_USAC)
    public static let mpegLayer1 = Self(.mpegLayer1)
    public static let mpegLayer2 = Self(.mpegLayer2)
    public static let mpegLayer3 = Self(.mpegLayer3)
    public static let opus = Self(.opus)
    public static let parameterValueStream = Self(.parameterValueStream)
    public static let qDesign = Self(.qDesign)
    public static let qDesign2 = Self(.qDesign2)
    public static let qualcomm = Self(.qualcomm)
    public static let timeCode = Self(.timeCode)
    public static let uLaw = Self(.uLaw)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A video format subtype.
public struct VideoFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let animation = Self(.animation)
    public static let cinepak = Self(.cinepak)
    public static let dv = Self(.dv)
    public static let dvcNTSC = Self(.dvcNTSC)
    public static let dvcPAL = Self(.dvcPAL)
    public static let dvcPROHD1080i50 = Self(.dvcPROHD1080i50)
    public static let dvcPROHD1080i60 = Self(.dvcPROHD1080i60)
    public static let dvcPROHD1080p25 = Self(.dvcPROHD1080p25)
    public static let dvcPROHD1080p30 = Self(.dvcPROHD1080p30)
    public static let dvcPROHD720p50 = Self(.dvcPROHD720p50)
    public static let dvcPROHD720p60 = Self(.dvcPROHD720p60)
    public static let dvcPro50NTSC = Self(.dvcPro50NTSC)
    public static let dvcPro50PAL = Self(.dvcPro50PAL)
    public static let dvcProPAL = Self(.dvcProPAL)
    public static let h263 = Self(.h263)
    public static let h264 = Self(.h264)
    public static let hevc = Self(.hevc)
    public static let hevcWithAlpha = Self(.hevcWithAlpha)
    public static let jpeg = Self(.jpeg)
    public static let jpegOpenDML = Self(.jpeg_OpenDML)
    public static let mpeg1Video = Self(.mpeg1Video)
    public static let mpeg2Video = Self(.mpeg2Video)
    public static let mpeg4Video = Self(.mpeg4Video)
    public static let proRes422 = Self(.proRes422)
    public static let proRes422HQ = Self(.proRes422HQ)
    public static let proRes422LT = Self(.proRes422LT)
    public static let proRes422Proxy = Self(.proRes422Proxy)
    public static let proRes4444 = Self(.proRes4444)
    public static let proRes4444XQ = Self(.proRes4444XQ)
    public static let proResRAW = Self(.proResRAW)
    public static let proResRAWHQ = Self(.proResRAWHQ)
    public static let sorensonVideo = Self(.sorensonVideo)
    public static let sorensonVideo3 = Self(.sorensonVideo3)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A pixel format subtype.
public struct PixelFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let pixelFormat_16BE555 = Self(.pixelFormat_16BE555)
    public static let pixelFormat_16BE565 = Self(.pixelFormat_16BE565)
    public static let pixelFormat_16LE555 = Self(.pixelFormat_16LE555)
    public static let pixelFormat_16LE5551 = Self(.pixelFormat_16LE5551)
    public static let pixelFormat_16LE565 = Self(.pixelFormat_16LE565)
    public static let pixelFormat_24RGB = Self(.pixelFormat_24RGB)
    public static let pixelFormat_32ARGB = Self(.pixelFormat_32ARGB)
    public static let pixelFormat_32BGRA = Self(.pixelFormat_32BGRA)
    public static let pixelFormat_422YpCbCr10 = Self(.pixelFormat_422YpCbCr10)
    public static let pixelFormat_422YpCbCr16 = Self(.pixelFormat_422YpCbCr16)
    public static let pixelFormat_422YpCbCr8 = Self(.pixelFormat_422YpCbCr8)
    public static let pixelFormat_422YpCbCr8_yuvs = Self(.pixelFormat_422YpCbCr8_yuvs)
    public static let pixelFormat_4444YpCbCrA8 = Self(.pixelFormat_4444YpCbCrA8)
    public static let pixelFormat_444YpCbCr10 = Self(.pixelFormat_444YpCbCr10)
    public static let pixelFormat_444YpCbCr8 = Self(.pixelFormat_444YpCbCr8)
    public static let pixelFormat_8IndexedGray_WhiteIsZero = Self(.pixelFormat_8IndexedGray_WhiteIsZero)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A muxed stream format subtype.
public struct MuxedStreamType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let dv = Self(.dv)
    public static let mpeg1System = Self(.mpeg1System)
    public static let mpeg2Program = Self(.mpeg2Program)
    public static let mpeg2Transport = Self(.mpeg2Transport)
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    public static let embeddedDeviceScreenRecording = Self(.embeddedDeviceScreenRecording)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A closed-caption format subtype.
public struct ClosedCaptionFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let atsc = Self(.atsc)
    public static let cea608 = Self(.cea608)
    public static let cea708 = Self(.cea708)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A text format subtype.
public struct TextFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let mobile3GPP = Self(.mobile3GPP)
    public static let qt = Self(.qt)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A subtitle format subtype.
public struct SubtitleFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let webVTT = Self(.webVTT)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A time-code format subtype.
public struct TimeCodeFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let counter32 = Self(.counter32)
    public static let counter64 = Self(.counter64)
    public static let timeCode32 = Self(.timeCode32)
    public static let timeCode64 = Self(.timeCode64)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A metadata format subtype.
public struct MetadataFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let boxed = Self(.boxed)
    public static let emsg = Self(.emsg)
    public static let icy = Self(.icy)
    public static let id3 = Self(.id3)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

/// A tagged-buffer-group format subtype.
public struct TaggedBufferGroupFormatType: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    public static let tbgr = Self(.tbgr)

    public let rawValue: FourCharCode

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ subType: CMFormatDescription.MediaSubType) {
        self.rawValue = subType.rawValue
    }
}

public extension CMFormatDescription {
    /// The audio format type, or `nil` if this is not an audio format description.
    var audioFormatType: AudioFormatType? {
        mediaType == .audio ? .init(mediaSubType) : nil
    }

    /// The video format type, or `nil` if this is not a video format description.
    var videoFormatType: VideoFormatType? {
        mediaType == .video ? .init(mediaSubType) : nil
    }

    /// The muxed stream type, or `nil` if this is not a muxed format description.
    var muxedStreamType: MuxedStreamType? {
        mediaType == .muxed ? .init(mediaSubType) : nil
    }

    /// The closed-caption format type, or `nil` if this is not a closed-caption format description.
    var closedCaptionFormatType: ClosedCaptionFormatType? {
        mediaType == .closedCaption ? .init(mediaSubType) : nil
    }

    /// The text format type, or `nil` if this is not a text format description.
    var textFormatType: TextFormatType? {
        mediaType == .text ? .init(mediaSubType) : nil
    }

    /// The subtitle format type, or `nil` if this is not a subtitle format description.
    var subtitleFormatType: SubtitleFormatType? {
        mediaType == .subtitle ? .init(mediaSubType) : nil
    }

    /// The time-code format type, or `nil` if this is not a time-code format description.
    var timeCodeFormatType: TimeCodeFormatType? {
        mediaType == .timeCode ? .init(mediaSubType) : nil
    }

    /// The metadata format type, or `nil` if this is not a metadata format description.
    var metadataFormatType: MetadataFormatType? {
        mediaType == .metadata ? .init(mediaSubType) : nil
    }

    /// The tagged-buffer-group format type, or `nil` if this is not a tagged-buffer-group format description.
    var taggedBufferGroupFormatType: TaggedBufferGroupFormatType? {
        mediaType == .taggedBufferGroup ? .init(mediaSubType) : nil
    }
}
