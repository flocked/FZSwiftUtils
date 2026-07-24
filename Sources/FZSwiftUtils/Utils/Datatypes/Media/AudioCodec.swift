//
//  AudioCodec.swift
//
//
//  Created by Florian Zand on 24.07.26.
//

import Foundation
import CoreMedia

/// An audio code.
public struct AudioCodec: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
    /// The AC-3 format packaged for transport over an IEC 60958-compliant digital audio interface.
    public static let ac3IEC60958 = Self(kAudioFormat60958AC3)
    /// The AC-3 audio format.
    public static let ac3 = Self(kAudioFormatAC3)
    /// The AES3-2003 audio format.
    public static let aes3 = Self(kAudioFormatAES3)
    /// The A-law 2:1 audio format.
    public static let aLaw = Self(kAudioFormatALaw)
    /// The Adaptive Multi-Rate narrowband speech format.
    public static let amr = Self(kAudioFormatAMR)
    /// The Adaptive Multi-Rate wideband speech format.
    public static let amrWideband = Self(kAudioFormatAMR_WB)
    /// Apple’s IMA 4:1 ADPCM audio format.
    public static let appleIMA4 = Self(kAudioFormatAppleIMA4)
    /// The Apple Lossless audio format.
    public static let appleLossless = Self(kAudioFormatAppleLossless)
    /// The Audible audiobook audio format.
    public static let audible = Self(kAudioFormatAudible)
    /// The DVI/Intel IMA ADPCM audio format.
    public static let dviIntelIMA = Self(kAudioFormatDVIIntelIMA)
    /// The Enhanced AC-3 audio format.
    public static let enhancedAC3 = Self(kAudioFormatEnhancedAC3)
    /// The Free Lossless Audio Codec format.
    public static let flac = Self(kAudioFormatFLAC)
    /// The internet Low Bitrate Codec narrowband speech format.
    public static let iLBC = Self(kAudioFormatiLBC)
    /// The linear PCM audio format.
    public static let linearPCM = Self(kAudioFormatLinearPCM)
    /// The MACE 3:1 audio format.
    public static let mace3 = Self(kAudioFormatMACE3)
    /// The MACE 6:1 audio format.
    public static let mace6 = Self(kAudioFormatMACE6)
    /// The Microsoft GSM 6.10 audio format.
    public static let microsoftGSM = Self(kAudioFormatMicrosoftGSM)
    /// The MIDI stream format.
    public static let midiStream = Self(kAudioFormatMIDIStream)
    /// The MPEG-4 AAC Low Complexity audio format.
    public static let aac = Self(kAudioFormatMPEG4AAC)
    /// The MPEG-4 Enhanced Low Delay AAC audio format.
    public static let aacELD = Self(kAudioFormatMPEG4AAC_ELD)
    /// The MPEG-4 Enhanced Low Delay AAC audio format with spectral band replication.
    public static let aacELDSBR = Self(kAudioFormatMPEG4AAC_ELD_SBR)
    /// The MPEG-4 Enhanced Low Delay AAC version 2 audio format.
    public static let aacELDV2 = Self(kAudioFormatMPEG4AAC_ELD_V2)
    /// The MPEG-4 High-Efficiency AAC audio format.
    public static let heAAC = Self(kAudioFormatMPEG4AAC_HE)
    /// The MPEG-4 High-Efficiency AAC version 2 audio format.
    public static let heAACV2 = Self(kAudioFormatMPEG4AAC_HE_V2)
    /// The MPEG-4 Low Delay AAC audio format.
    public static let aacLD = Self(kAudioFormatMPEG4AAC_LD)
    /// The MPEG-4 Spatial Audio Coding format.
    public static let aacSpatial = Self(kAudioFormatMPEG4AAC_Spatial)
    /// The MPEG-4 Code-Excited Linear Prediction audio format.
    public static let celp = Self(kAudioFormatMPEG4CELP)
    /// The MPEG-4 Harmonic Vector eXcitation Coding audio format.
    public static let hvxc = Self(kAudioFormatMPEG4HVXC)
    /// The MPEG-4 TwinVQ audio format.
    public static let twinVQ = Self(kAudioFormatMPEG4TwinVQ)
    /// The MPEG-D Unified Speech and Audio Coding format.
    public static let usac = Self(kAudioFormatMPEGD_USAC)
    /// The MPEG-1/2 Layer I audio format.
    public static let mpegLayer1 = Self(kAudioFormatMPEGLayer1)
    /// The MPEG-1/2 Layer II audio format.
    public static let mpegLayer2 = Self(kAudioFormatMPEGLayer2)
    /// The MPEG-1/2 Layer III audio format.
    public static let mpegLayer3 = Self(kAudioFormatMPEGLayer3)
    /// The Opus audio format.
    public static let opus = Self(kAudioFormatOpus)
    /// The parameter-value stream format.
    public static let parameterValueStream = Self(kAudioFormatParameterValueStream)
    /// The QDesign Music audio format.
    public static let qDesign = Self(kAudioFormatQDesign)
    /// The QDesign Music 2 audio format.
    public static let qDesign2 = Self(kAudioFormatQDesign2)
    /// The Qualcomm PureVoice audio format.
    public static let qualcomm = Self(kAudioFormatQUALCOMM)
    /// The audio time-code stream format.
    public static let timeCode = Self(kAudioFormatTimeCode)
    /// The μ-law 2:1 audio format.
    public static let uLaw = Self(kAudioFormatULaw)

    public let rawValue: AudioFormatID

    public init(rawValue: AudioFormatID) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: AudioFormatID) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        switch self {
        case .ac3IEC60958: ".ac3IEC60958"
        case .ac3: ".ac3"
        case .aes3: ".aes3"
        case .aLaw: ".aLaw"
        case .amr: ".amr"
        case .amrWideband: ".amrWideband"
        case .appleIMA4: ".appleIMA4"
        case .appleLossless: ".appleLossless"
        case .audible: ".audible"
        case .dviIntelIMA: ".dviIntelIMA"
        case .enhancedAC3: ".enhancedAC3"
        case .flac: ".flac"
        case .iLBC: ".iLBC"
        case .linearPCM: ".linearPCM"
        case .mace3: ".mace3"
        case .mace6: ".mace6"
        case .microsoftGSM: ".microsoftGSM"
        case .midiStream: ".midiStream"
        case .aac: ".aac"
        case .aacELD: ".aacELD"
        case .aacELDSBR: ".aacELDSBR"
        case .aacELDV2: ".aacELDV2"
        case .heAAC: ".heAAC"
        case .heAACV2: ".heAACV2"
        case .aacLD: ".aacLD"
        case .aacSpatial: ".aacSpatial"
        case .celp: ".celp"
        case .hvxc: ".hvxc"
        case .twinVQ: ".twinVQ"
        case .usac: ".usac"
        case .mpegLayer1: ".mpegLayer1"
        case .mpegLayer2: ".mpegLayer2"
        case .mpegLayer3: ".mpegLayer3"
        case .opus: ".opus"
        case .parameterValueStream: ".parameterValueStream"
        case .qDesign: ".qDesign"
        case .qDesign2: ".qDesign2"
        case .qualcomm: ".qualcomm"
        case .timeCode: ".timeCode"
        case .uLaw: ".uLaw"
        default: "AudioCodec(rawValue: \(rawValue))"
        }
    }
}
