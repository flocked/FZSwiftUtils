//
//  VideoCodec.swift
//
//
//  Created by Florian Zand on 24.07.26.
//

import Foundation
import CoreMedia

/// A video codec.
public struct VideoCodec: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    /// The Y’CbCr 8-bit 4:2:2 codec.
    public static let v422YpCbCr8 = Self(kCMVideoCodecType_422YpCbCr8)
    /// The Apple Animation codec.
    public static let animation = Self(kCMVideoCodecType_Animation)
    /// The Apple ProRes 422 codec.
    public static let proRes422 = Self(kCMVideoCodecType_AppleProRes422)
    /// The Apple ProRes 422 HQ codec.
    public static let proRes422HQ = Self(kCMVideoCodecType_AppleProRes422HQ)
    /// The Apple ProRes 422 LT codec.
    public static let proRes422LT = Self(kCMVideoCodecType_AppleProRes422LT)
    /// The Apple ProRes 422 Proxy codec.
    public static let proRes422Proxy = Self(kCMVideoCodecType_AppleProRes422Proxy)
    /// The Apple ProRes 4444 codec.
    public static let proRes4444 = Self(kCMVideoCodecType_AppleProRes4444)
    /// The Apple ProRes 4444 XQ codec.
    public static let proRes4444XQ = Self(kCMVideoCodecType_AppleProRes4444XQ)
    /// The Apple ProRes RAW codec.
    public static let proResRAW = Self(kCMVideoCodecType_AppleProResRAW)
    /// The Apple ProRes RAW HQ codec.
    public static let proResRAWHQ = Self(kCMVideoCodecType_AppleProResRAWHQ)
    /// The AV1 codec.
    public static let av1 = Self(kCMVideoCodecType_AV1)
    /// The Cinepak codec.
    public static let cinepak = Self(kCMVideoCodecType_Cinepak)
    /// The Depth HEVC codec.
    public static let depthHEVC = Self(kCMVideoCodecType_DepthHEVC)
    /// The Disparity HEVC codec.
    public static let disparityHEVC = Self(kCMVideoCodecType_DisparityHEVC)
    /// The Dolby Vision HEVC codec.
    public static let dolbyVisionHEVC = Self(kCMVideoCodecType_DolbyVisionHEVC)
    /// The DV NTSC codec.
    public static let dvcNTSC = Self(kCMVideoCodecType_DVCNTSC)
    /// The DV PAL codec.
    public static let dvcPAL = Self(kCMVideoCodecType_DVCPAL)
    /// The Panasonic DVCPro-50 NTSC codec.
    public static let dvcPro50NTSC = Self(kCMVideoCodecType_DVCPro50NTSC)
    /// The Panasonic DVCPro-50 PAL codec.
    public static let dvcPro50PAL = Self(kCMVideoCodecType_DVCPro50PAL)
    /// The Panasonic DVCPro-HD 1080i50 codec.
    public static let dvcProHD1080i50 = Self(kCMVideoCodecType_DVCPROHD1080i50)
    /// The Panasonic DVCPro-HD 1080i60 codec.
    public static let dvcProHD1080i60 = Self(kCMVideoCodecType_DVCPROHD1080i60)
    /// The Panasonic DVCPro-HD 1080p25 codec.
    public static let dvcProHD1080p25 = Self(kCMVideoCodecType_DVCPROHD1080p25)
    /// The Panasonic DVCPro-HD 1080p30 codec.
    public static let dvcProHD1080p30 = Self(kCMVideoCodecType_DVCPROHD1080p30)
    /// The Panasonic DVCPro-HD 720p50 codec.
    public static let dvcProHD720p50 = Self(kCMVideoCodecType_DVCPROHD720p50)
    /// The Panasonic DVCPro-HD 720p60 codec.
    public static let dvcProHD720p60 = Self(kCMVideoCodecType_DVCPROHD720p60)
    /// The Panasonic DVCPro PAL codec.
    public static let dvcProPAL = Self(kCMVideoCodecType_DVCProPAL)
    /// The H.263 codec.
    public static let h263 = Self(kCMVideoCodecType_H263)
    /// The H.264 codec.
    public static let h264 = Self(kCMVideoCodecType_H264)
    /// The HEVC codec.
    public static let hevc = Self(kCMVideoCodecType_HEVC)
    /// The HEVC codec with alpha support.
    public static let hevcWithAlpha = Self(kCMVideoCodecType_HEVCWithAlpha)
    /// The JPEG codec.
    public static let jpeg = Self(kCMVideoCodecType_JPEG)
    /// The JPEG codec with OpenDML extensions.
    public static let jpegOpenDML = Self(kCMVideoCodecType_JPEG_OpenDML)
    /// The JPEG XL codec.
    public static let jpegXL = Self(kCMVideoCodecType_JPEG_XL)
    /// The MPEG-1 codec.
    public static let mpeg1 = Self(kCMVideoCodecType_MPEG1Video)
    /// The MPEG-2 codec.
    public static let mpeg2 = Self(kCMVideoCodecType_MPEG2Video)
    /// The MPEG-4 Part 2 codec.
    public static let mpeg4 = Self(kCMVideoCodecType_MPEG4Video)
    /// The Sorenson codec.
    public static let sorenson = Self(kCMVideoCodecType_SorensonVideo)
    /// The Sorenson 3 codec.
    public static let sorenson3 = Self(kCMVideoCodecType_SorensonVideo3)
    /// The VP9 codec.
    public static let vp9 = Self(kCMVideoCodecType_VP9)

    public let rawValue: CMVideoCodecType
    
    public init(rawValue: CMVideoCodecType) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: CMVideoCodecType) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        switch self {
        case .v422YpCbCr8: ".v422YpCbCr8"
        case .animation: ".animation"
        case .proRes422: ".proRes422"
        case .proRes422HQ: ".proRes422HQ"
        case .proRes422LT: ".proRes422LT"
        case .proRes422Proxy: ".proRes422Proxy"
        case .proRes4444: ".proRes4444"
        case .proRes4444XQ: ".proRes4444XQ"
        case .proResRAW: ".proResRAW"
        case .proResRAWHQ: ".proResRAWHQ"
        case .av1: ".av1"
        case .cinepak: ".cinepak"
        case .depthHEVC: ".depthHEVC"
        case .disparityHEVC: ".disparityHEVC"
        case .dolbyVisionHEVC: ".dolbyVisionHEVC"
        case .dvcNTSC: ".dvcNTSC"
        case .dvcPAL: ".dvcPAL"
        case .dvcPro50NTSC: ".dvcPro50NTSC"
        case .dvcPro50PAL: ".dvcPro50PAL"
        case .dvcProHD1080i50: ".dvcProHD1080i50"
        case .dvcProHD1080i60: ".dvcProHD1080i60"
        case .dvcProHD1080p25: ".dvcProHD1080p25"
        case .dvcProHD1080p30: ".dvcProHD1080p30"
        case .dvcProHD720p50: ".dvcProHD720p50"
        case .dvcProHD720p60: ".dvcProHD720p60"
        case .dvcProPAL: ".dvcProPAL"
        case .h263: ".h263"
        case .h264: ".h264"
        case .hevc: ".hevc"
        case .hevcWithAlpha: ".hevcWithAlpha"
        case .jpeg: ".jpeg"
        case .jpegOpenDML: ".jpegOpenDML"
        case .jpegXL: ".jpegXL"
        case .mpeg1: ".mpeg1"
        case .mpeg2: ".mpeg2"
        case .mpeg4: ".mpeg4"
        case .sorenson: ".sorenson"
        case .sorenson3: ".sorenson3"
        case .vp9: ".vp9"
        default: "VideoCodec(rawValue: \(rawValue))"
        }
    }

}
