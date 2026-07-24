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
    public static let appleProRes422 = Self(kCMVideoCodecType_AppleProRes422)
    /// The Apple ProRes 422 HQ codec.
    public static let appleProRes422HQ = Self(kCMVideoCodecType_AppleProRes422HQ)
    /// The Apple ProRes 422 LT codec.
    public static let appleProRes422LT = Self(kCMVideoCodecType_AppleProRes422LT)
    /// The Apple ProRes 422 Proxy codec.
    public static let appleProRes422Proxy = Self(kCMVideoCodecType_AppleProRes422Proxy)
    /// The Apple ProRes 4444 codec.
    public static let appleProRes4444 = Self(kCMVideoCodecType_AppleProRes4444)
    /// The Apple ProRes 4444 XQ codec.
    public static let appleProRes4444XQ = Self(kCMVideoCodecType_AppleProRes4444XQ)
    /// The Apple ProRes RAW codec.
    public static let appleProResRAW = Self(kCMVideoCodecType_AppleProResRAW)
    /// The Apple ProRes RAW HQ codec.
    public static let appleProResRAWHQ = Self(kCMVideoCodecType_AppleProResRAWHQ)
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
    /// The JPEG codec with OpenDML extensions.
    public static let jpegOpenDML = Self(kCMVideoCodecType_JPEG_OpenDML)
    /// The JPEG XL codec.
    public static let jpegXL = Self(kCMVideoCodecType_JPEG_XL)
    /// The JPEG codec.
    public static let jpeg = Self(kCMVideoCodecType_JPEG)
    /// The MPEG-1 video codec.
    public static let mpeg1Video = Self(kCMVideoCodecType_MPEG1Video)
    /// The MPEG-2 video codec.
    public static let mpeg2Video = Self(kCMVideoCodecType_MPEG2Video)
    /// The MPEG-4 Part 2 video codec.
    public static let mpeg4Video = Self(kCMVideoCodecType_MPEG4Video)
    /// The Sorenson Video 3 codec.
    public static let sorensonVideo3 = Self(kCMVideoCodecType_SorensonVideo3)
    /// The Sorenson Video codec.
    public static let sorensonVideo = Self(kCMVideoCodecType_SorensonVideo)
    /// The VP9 codec.
    public static let vp9 = Self(kCMVideoCodecType_VP9)

    public let rawValue: CMVideoCodecType

    public var description: String {
        rawValue.string
    }

    public init(rawValue: FourCharCode) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: FourCharCode) {
        self.rawValue = rawValue
    }
}
