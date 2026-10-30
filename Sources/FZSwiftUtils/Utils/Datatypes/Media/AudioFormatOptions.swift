//
//  AudioFormatOptions.swift
//  
//
//  Created by Florian Zand on 24.07.26.
//

import Foundation
import CoreMedia

/// A set of flags describing an audio format.
public struct AudioFormatOptions: OptionSet, Codable, Hashable, Sendable, CustomStringConvertible {
    // MARK: - Apple Lossless
    /// Apple Lossless data sourced from 16-bit native-endian signed integer data.
    public static let appleLossless16BitSourceData = Self(kAppleLosslessFormatFlag_16BitSourceData)
    /// Apple Lossless data sourced from 20-bit native-endian signed integer data aligned high in 24 bits.
    public static let appleLossless20BitSourceData = Self(kAppleLosslessFormatFlag_20BitSourceData)
    /// Apple Lossless data sourced from 24-bit native-endian signed integer data.
    public static let appleLossless24BitSourceData = Self(kAppleLosslessFormatFlag_24BitSourceData)
    /// Apple Lossless data sourced from 32-bit native-endian signed integer data.
    public static let appleLossless32BitSourceData = Self(kAppleLosslessFormatFlag_32BitSourceData)
    
    // MARK: - General
    /// Indicates that sample bits are aligned high within each sample container.
    public static let isAlignedHigh = Self(kAudioFormatFlagIsAlignedHigh)
    /// Indicates that audio data uses big-endian byte order.
    public static let isBigEndian = Self(kAudioFormatFlagIsBigEndian)
    /// Indicates that samples are floating-point values.
    public static let isFloat = Self(kAudioFormatFlagIsFloat)
    /// Indicates that channels are stored in separate buffers.
    public static let isNonInterleaved = Self(kAudioFormatFlagIsNonInterleaved)
    /// Indicates that the audio format is nonmixable.
    public static let isNonMixable = Self(kAudioFormatFlagIsNonMixable)
    /// Indicates that sample bits occupy all available bits of each sample container.
    public static let isPacked = Self(kAudioFormatFlagIsPacked)
    /// Indicates that samples are signed integer values.
    public static let isSignedInteger = Self(kAudioFormatFlagIsSignedInteger)
    /// An empty set of audio format flags.
    public static let allClear = Self(kAudioFormatFlagsAreAllClear)
    /// The flag indicating the processor's native byte order.
    public static let nativeEndian = Self(kAudioFormatFlagsNativeEndian)
    /// The flags describing packed native-endian floating-point samples.
    public static let nativeFloatPacked = Self(kAudioFormatFlagsNativeFloatPacked)
    
    /// The flags for the canonical audio unit and processing sample type.
    @available(*, deprecated, message: "Use the appropriate native audio format flags instead.")
    public static let audioUnitCanonical = Self(kAudioFormatFlagsAudioUnitCanonical)

    /// The set of flags for the canonical input-output audio sample type.
    @available(*, deprecated, message: "Use the appropriate native audio format flags instead.")
    public static let canonical = Self(kAudioFormatFlagsCanonical)
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    private static let descriptions: [Self: String] = [
        .appleLossless16BitSourceData: "appleLossless16BitSourceData",
        .appleLossless20BitSourceData: "appleLossless20BitSourceData",
        .appleLossless24BitSourceData: "appleLossless24BitSourceData",
        .appleLossless32BitSourceData: "appleLossless32BitSourceData",
        .isAlignedHigh: "isAlignedHigh",
        .isBigEndian: "isBigEndian",
        .isFloat: "isFloat",
        .isNonInterleaved: "isNonInterleaved",
        .isNonMixable: "isNonMixable",
        .isPacked: "isPacked",
        .isSignedInteger: "isSignedInteger",
        .nativeEndian: "nativeEndian",
        .nativeFloatPacked: "nativeFloatPacked"
    ]
    
    public var description: String {
        let strings = elements.map({ Self.descriptions[$0] ?? ".init(rawValue: \($0))"})
        return strings.count == 1 ? strings.first! : "[\(strings.joined(separator: ", "))]"
    }
}

public extension AudioFormatOptions {
    /// The numeric representation used for audio samples.
    enum SampleType: Sendable {
        /// Unsigned integer samples.
        case unsignedInteger
        /// Signed integer samples.
        case signedInteger
        /// Floating-point samples.
        case floatingPoint
    }

    /// The numeric representation used for audio samples.
    var sampleType: SampleType {
        get {
            if contains(.isFloat) {
                return .floatingPoint
            } else if contains(.isSignedInteger) {
                return .signedInteger
            } else {
                return .unsignedInteger
            }
        }
        set {
            self[.isSignedInteger] = newValue == .signedInteger
            self[.isFloat] = newValue == .floatingPoint
        }
    }

    /// The byte order used to store audio samples.
    enum ByteOrder: Sendable {
        /// Little-endian byte order.
        case littleEndian
        /// Big-endian byte order.
        case bigEndian
    }

    /// The byte order used to store audio samples.
    var byteOrder: ByteOrder {
        get { contains(.isBigEndian) ? .bigEndian : .littleEndian }
        set { self[.isBigEndian] = newValue == .bigEndian }
    }

    /// The bit alignment of audio samples within each channel.
    enum Alignment: Sendable {
        /// Samples are aligned low.
        case low
        /// Samples are aligned high.
        case high
    }

    /// The bit alignment of audio samples within each channel.
    var alignment: Alignment {
        get { contains(.isAlignedHigh) ? .high : .low }
        set { self[.isAlignedHigh] = newValue == .high }
    }

    /// The packing of audio sample bits within each channel.
    enum Packing: Sendable {
        /// Samples are unpacked.
        case unpacked
        /// Samples are packed.
        case packed
    }

    /// The packing of audio sample bits within each channel.
    var packing: Packing {
        get { contains(.isPacked) ? .packed : .unpacked }
        set { self[.isPacked] = newValue == .packed }
    }

    /// The channel layout of the audio data.
    enum Interleaving: Sendable {
        /// Channel data is interleaved.
        case interleaved
        /// Channel data is stored in separate buffers.
        case nonInterleaved
    }

    /// The channel layout of the audio data.
    var interleaving: Interleaving {
        get { contains(.isNonInterleaved) ? .nonInterleaved : .interleaved }
        set { self[.isNonInterleaved] = newValue == .nonInterleaved }
    }
    
    /// The number of fractional bits used to represent each fixed-point sample.
    var fractionalBits: UInt32 {
        get { (rawValue & Self.linearPCMSampleFractionMask) >> Self.linearPCMSampleFractionShift }
        set {
            self = Self(rawValue: (rawValue & ~Self.linearPCMSampleFractionMask) | (min(newValue, Self.linearPCMSampleFractionMask >> Self.linearPCMSampleFractionShift) << Self.linearPCMSampleFractionShift))
        }
    }
    
    private static let linearPCMSampleFractionMask: UInt32 = kLinearPCMFormatFlagsSampleFractionMask

    private static let linearPCMSampleFractionShift: UInt32 = kLinearPCMFormatFlagsSampleFractionShift
    
    /// The source sample bit depth of Apple Lossless audio data.
    enum AppleLosslessSourceData: UInt32, Codable, Hashable, Sendable, CustomStringConvertible {
        /// Audio data sourced from 16-bit native-endian signed integer data.
        case bit16 = 1
        /// Audio data sourced from 20-bit native-endian signed integer data aligned high in 24 bits.
        case bit20 = 2
        /// Audio data sourced from 24-bit native-endian signed integer data.
        case bit24 = 3
        /// Audio data sourced from 32-bit native-endian signed integer data.
        case bit32 = 4
        
        public var description: String {
            switch self {
            case .bit16: "16-bit"
            case .bit20: "20-bit"
            case .bit24: "24-bit"
            case .bit32: "32-bit"
            }
        }
    }

    /// The source sample bit depth of Apple Lossless audio data.
    var appleLosslessSourceData: AppleLosslessSourceData? {
        get {  AppleLosslessSourceData(rawValue: rawValue & Self.appleLosslessSourceDataMask) }
        set { self = Self(rawValue: (rawValue & ~Self.appleLosslessSourceDataMask) | (newValue?.rawValue ?? 0)) }
    }

    private static let appleLosslessSourceDataMask: UInt32 = 0x7
    
    /**
     Creates audio format options.

     - Parameters:
       - sampleType: The numeric representation (float, signed int, or unsigned int).
       - byteOrder: The byte order.
       - alignment: Bit alignment within each channel container.
       - packing: Sample packing layout within channels.
       - interleaving: Channel buffer interleaving strategy.
       - fractionalBits: Fractional bit count for fixed-point integer PCM formats.
     */
    init(sampleType: SampleType = .signedInteger, byteOrder: ByteOrder = .littleEndian, alignment: Alignment = .low, packing: Packing = .packed, interleaving: Interleaving = .interleaved, fractionalBits: UInt32 = 0, appleLosslessSourceData: AppleLosslessSourceData? = nil) {
        self.init(rawValue: 0)
        self.sampleType = sampleType
        self.byteOrder = byteOrder
        self.alignment = alignment
        self.packing = packing
        self.interleaving = interleaving
        self.fractionalBits = fractionalBits
        self.appleLosslessSourceData = appleLosslessSourceData
    }
    
    /// Creates audio format options with the specified source sample bit depth of Apple Lossless audio data.
    init(appleLosslessSourceData: AppleLosslessSourceData) {
        self.init(rawValue: 0)
        self.appleLosslessSourceData = appleLosslessSourceData
    }
}
