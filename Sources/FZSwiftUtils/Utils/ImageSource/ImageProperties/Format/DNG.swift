//
//  DNG.swift
//
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct DNG {
        /// The raw values.
        public let rawValues: [CFString: Any]
        /// The amount of sharpening required for this camera model.
        public let baselineSharpness: Double?
        /// The fraction of the encoding range, above which the response may become significantly non-linear.
        public let linearResponseLimit: Double?
        /// A hint to the DNG reader about how much chroma blur to apply to the image.
        public let chromaBlurRadius: Double?
        /// A hint to the DNG reader about how strong the camera’s antialias filter is.
        public let antiAliasStrength: Double?
        /// A tag that Adobe Camera Raw uses to control the sensitivity of its Shadows slider.
        public let shadowScale: Double?
        /// The scale factor to apply to the default scale to achieve the best quality image size.
        public let bestQualityScale: Double?
        /// The default scale factors for each direction to convert the image to square pixels.
        public let defaultScale: Any?
        /// A lookup table that maps stored values into linear values.
        public let linearizationTable: Any?
        
        /// The amount by which to adjust the zero point of the exposure, specified in EV units.
        public let baselineExposure: Double?
        /// The relative noise level of the camera model at an ISO of 100.
        public let baselineNoise: Double?
        /// The amount of EV units to add to the baseline exposure during image rendering.
        public let baselineExposureOffset: Double?
        
        /// The analog or digital gain that applies to the stored raw values.
        public let analogBalance: Any?
        /// The selected white balance at the time of capture, encoded as the coordinates of a neutral color in linear reference space values.
        public let asShotNeutral: Any?
        /// The selected white balance at the time of capture, encoded as x-y chromaticity coordinates.
        public let asShotWhiteXY: Any?
        /// A value that specifies how closely green pixels in the blue/green rows track the green pixels in red/green rows.
        public let bayerGreenSplit: Int?
        /// A matrix that maps white balanced camera colors to XYZ D50 colors.
        public let forwardMatrix1: Any?
        /// A matrix that maps white balanced camera colors to XYZ D50 colors.
        public let forwardMatrix2: Any?
        /// A hint to the raw converter about how to handle the black point during rendering.
        public let defaultBlackRender: Int?
        
        /// The repeat pattern size for the black level tag.
        public let blackLevelRepeatDim: Any?
        /// The zero light encoding level, specified as a repeating pattern.
        public let blackLevel: Any?
        /// The difference between the zero-light encoding level for each column and the baseline zero-light encoding level.
        public let blackLevelDeltaH: Any?
        /// The difference between the zero-light encodoing level for each row and the baseline zero-light encoding level.
        public let blackLevelDeltaV: Any?
        /// The saturated encoding level for the raw sample values.
        public let whiteLevel: Any?
        /// The illuminant for the first set of color calibration tags.
        public let calibrationIlluminant1: Int?
        /// The illuminant for an optional second set of color calibration tags.
        public let calibrationIlluminant2: Int?
        /// A transformation matrix that converts XYZ values to reference camera native color spaces, under the first calibration illuminant.
        public let colorMatrix1: [CGFloat]?
        /// A transformation matrix that converts XYZ values to reference camera native color spaces, under the second calibration illuminant.
        public let colorMatrix2: [CGFloat]?
        /// A matrix that transforms reference camera native space values to camera-native space values under the first calibration illuminant.
        public let cameraCalibration1: Any?
        /// A matrix that transforms reference camera native space values to camera-native space values under the second calibration illuminant.
        public let cameraCalibration2: Any?
        /// A reduction matrix that converts color camera-native space values to XYZ values, under the first calibration illuminant.
        public let reductionMatrix1: Any?
        /// A reduction matrix that converts color camera-native space values to XYZ values, under the second calibration illuminant.
        public let reductionMatrix2: Any?
        /// A profile that specifies default color rendering from camera color-space coordinates into the ICC profile space.
        public let asShotICCProfile: Any?
        /// A matrix to apply to the camera color-space coordinates before processing values through the ICC profile.
        public let asShotPreProfileMatrix: Any?
        /// A profile that specifies default color rendering from camera color-space coordinates into the ICC profile space.
        public let currentICCProfile: Any?
        /// A matrix to apply to the current camera color-space coordinates before processing values through the ICC profile.
        public let currentPreProfileMatrix: Any?
        /// The colorimetric reference for the CIE XYZ values.
        public let colorimetricReference: Int?
        /// A string to match against the profile calibration signature for the selected camera profile.
        public let cameraCalibrationSignature: String?
        /// A string that describes the calibration for the current profile.
        public let profileCalibrationSignature: String?
        /// The rectangle that defines the non-masked pixels of the sensor.
        public let activeArea: Any?
        /// A list of non-overlapping rectangles that contain fully masked pixels in the image.
        public let maskedAreas: Any?
        /// The origin of the final image area, relative to the top-left corner of the active area rectangle.
        public let defaultCropOrigin: CGPoint?
        /// The size of the final image area, in raw image coordinates.
        public let defaultCropSize: CGSize?
        /// A default user-crop rectangle in relative coordinates.
        public let defaultUserCrop: Any?
        /// The file name of the original raw file.
        public let originalRawFileName: String?
        /// The compressed contents of the original raw file.
        public let originalRawFileData: Any?
        /// The amount of noise reduction applied to the raw data on a scale of 0.0 to 1.0.
        public let noiseReductionApplied: Double?
        /// An MD5 digest of the raw image data.
        public let newRawImageDigest: Any?
        /// An MD5 digest of the data stored for the original raw file data.
        public let originalRawFileDigest: Any?
        /// A modified MD5 digest of the raw image data.
        public let rawImageDigest: Any?
        /// THe default final size of the larger original file that was the source of this proxy.
        public let originalDefaultFinalSize: Any?
        /// The best-quality final size of the larger original file that was the source of this proxy.
        public let originalBestQualityFinalSize: Any?
        /// The default crop size of the larger original file that was the source of this proxy.
        public let originalDefaultCropSize: Any?
        /// The gain between the main raw IFD and the preview IFD that contains this tag.
        public let rawToPreviewGain: Double?
        /// The amount of noise in the raw image.
        public let noiseProfile: Any?
        /// The spatial layout of the CFA.
        public let cfaLayout: Int?
        /// A mapping between the values in the CFA pattern tag and the plane numbers in linear raw space.
        public let cfaPlaneColor: Any?
        /// The list of opcodes to apply to the raw image, as read directly from the file.
        public let opcodeList1: Any?
        /// THe list of opcodes to apply to the raw image, after mapping it to linear reference values.
        public let dngOpcodeList2: Any?
        /// The list of opcodes to apply to the raw image, after demosaicing it.
        public let dngOpcodeList3: Any?
        /// An opcode to apply a warp to an image to correct for geometric distortion and lateral chromatic aberration for rectilinear lenses.
        public let warpRectilinear: Any?
        /// An opcode to unwrap an image captued with a fisheye lens and map it to a perspective projection.
        public let warpFisheye: Any?
        /// An opcode to apply a gain function to an image to correct vignetting.
        public let fixVignetteRadial: Any?
        /// Private data that manufacturers may store with an image and use in their own converters.
        public let dngPrivateData: Any?
        /// A Boolean value that tells the DNG reader whether the EXIF MakerNote tag is safe to preserve.
        public let makerNoteSafety: Int?
        /// A 16-byte unique identifier for the raw image data.
        public let dngRawDataUniqueID: String?
        /// The size of rectangular blocks that tiles use to group pixels.
        public let subTileBlockSize: Any?
        /// The number of interleaved fields for the rows of the image.
        public let rowInterleaveFactor: Int?
        /// The oldest version for which a file is compatible.
        public let dngBackwardVersion: [Int]?
        /// An encoding of the four-tier version number.
        public let dngVersion: [Double]?
        /// A list of file offsets to extra camera profiles.
        public let extraCameraProfiles: Any?
        /// A string containing the name of the "as shot" camera profile, if any.
        public let asShotProfileName: String?
        /// The number of input samples in each dimension of the hue/saturation/value mapping tables.
        public let profileHueSatMapDims: Any?
        /// The data for the first hue/saturation/value mapping table.
        public let profileHueSatMapData1: Any?
        /// The data for the second hue/saturation/value mapping table.
        public let profileHueSatMapData2: Any?
        /// The encoding option to use when indexing into a 3D look table during raw conversion.
        public let profileHueSatMapEncoding: Int?
        /// The default tone curve to apply when processing the image as a starting point for user adjustments.
        public let profileToneCurve: Any?
        /// A string containing the name of the camera profile.
        public let dngProfileName: String?
        /// The usage rules for the camera profile.
        public let profileEmbedPolicy: Int?
        /// The copyright information for the camera profile.
        public let profileCopyright: String?
        /// The number of input samples in each dimentsion of a default "look" table.
        public let profileLookTableDims: Any?
        /// The default "look" table to apply when processing the image as a starting point for user adjustment.
        public let profileLookTableData: Any?
        /// The encoding option to use when indexing into a 3D look table during raw conversion.
        public let profileLookTableEncoding: Int?
        /// The name of the app that created the preview stored in the IFD.
        public let previewApplicationName: String?
        /// The version number of the app that created the preview stored in the IFD.
        public let previewApplicationVersion: String?
        /// The name of the conversion settings for the preview.
        public let previewSettingsName: String?
        /// A unique ID of the conversion settings used to render the preview.
        public let previewSettingsDigest: [Int]?
        /// The color space associated with the rendered preview.
        public let previewColorSpace: Int?
        /// The date and time for the render of the preview.
        public let previewDateTime: Date?
        /// Information about the lens used for the image.
        public let lensInfo: String?
        /// A unique, nonlocalized name for the camera model.
        public let uniqueCameraModel: String?
        /// The localized camera model name.
        public let localizedCameraModel: String?
        /// The camera serial number.
        public let cameraSerialNumber: String?

        init(dngData: [CFString: Any]) {
            rawValues = dngData
            
            baselineSharpness = dngData[typed: kCGImagePropertyDNGBaselineSharpness]
            linearResponseLimit = dngData[typed: kCGImagePropertyDNGLinearResponseLimit]
            chromaBlurRadius = dngData[typed: kCGImagePropertyDNGChromaBlurRadius]
            antiAliasStrength = dngData[typed: kCGImagePropertyDNGAntiAliasStrength]
            shadowScale = dngData[typed: kCGImagePropertyDNGShadowScale]
            bestQualityScale = dngData[typed: kCGImagePropertyDNGBestQualityScale]
            defaultScale = dngData[kCGImagePropertyDNGDefaultScale]
            linearizationTable = dngData[kCGImagePropertyDNGLinearizationTable]
            
            baselineExposure = dngData[typed: kCGImagePropertyDNGBaselineExposure]
            baselineNoise = dngData[typed: kCGImagePropertyDNGBaselineNoise]
            baselineExposureOffset = dngData[typed: kCGImagePropertyDNGBaselineExposureOffset]
            
            analogBalance = dngData[kCGImagePropertyDNGAnalogBalance]
            asShotNeutral = dngData[kCGImagePropertyDNGAsShotNeutral]
            asShotWhiteXY = dngData[kCGImagePropertyDNGAsShotWhiteXY]
            bayerGreenSplit = dngData[typed: kCGImagePropertyDNGBayerGreenSplit]
            forwardMatrix1 = dngData[kCGImagePropertyDNGForwardMatrix1]
            forwardMatrix2 = dngData[kCGImagePropertyDNGForwardMatrix2]
            defaultBlackRender = dngData[typed: kCGImagePropertyDNGDefaultBlackRender]
            
            blackLevelRepeatDim = dngData[kCGImagePropertyDNGBlackLevelRepeatDim]
            blackLevel = dngData[kCGImagePropertyDNGBlackLevel]
            blackLevelDeltaH = dngData[kCGImagePropertyDNGBlackLevelDeltaH]
            blackLevelDeltaV = dngData[kCGImagePropertyDNGBlackLevelDeltaV]
            whiteLevel = dngData[kCGImagePropertyDNGWhiteLevel]
            calibrationIlluminant1 = dngData[typed: kCGImagePropertyDNGCalibrationIlluminant1]
            calibrationIlluminant2 = dngData[typed: kCGImagePropertyDNGCalibrationIlluminant2]
            colorMatrix1 = dngData[typed: kCGImagePropertyDNGColorMatrix1]
            colorMatrix2 = dngData[typed: kCGImagePropertyDNGColorMatrix2]
            cameraCalibration1 = dngData[kCGImagePropertyDNGCameraCalibration1]
            cameraCalibration2 = dngData[kCGImagePropertyDNGCameraCalibration2]
            reductionMatrix1 = dngData[kCGImagePropertyDNGReductionMatrix1]
            reductionMatrix2 = dngData[kCGImagePropertyDNGReductionMatrix2]
            asShotICCProfile = dngData[kCGImagePropertyDNGAsShotICCProfile]
            asShotPreProfileMatrix = dngData[kCGImagePropertyDNGAsShotPreProfileMatrix]
            currentICCProfile = dngData[kCGImagePropertyDNGCurrentICCProfile]
            currentPreProfileMatrix = dngData[kCGImagePropertyDNGCurrentPreProfileMatrix]
            colorimetricReference = dngData[typed: kCGImagePropertyDNGColorimetricReference]
            cameraCalibrationSignature = dngData[typed: kCGImagePropertyDNGCameraCalibrationSignature]
            profileCalibrationSignature = dngData[typed: kCGImagePropertyDNGProfileCalibrationSignature]
            activeArea = dngData[kCGImagePropertyDNGActiveArea]
            maskedAreas = dngData[kCGImagePropertyDNGMaskedAreas]
            if let origin: [CGFloat] = dngData[typed: kCGImagePropertyDNGDefaultCropOrigin], let x = origin[safe: 0], let y = origin[safe: 1] {
                defaultCropOrigin = CGPoint(x: x, y: y)
            } else {
                defaultCropOrigin = nil
            }
            if let size: [CGFloat] = dngData[typed: kCGImagePropertyDNGDefaultCropSize], let width = size[safe: 0], let height = size[safe: 1] {
                defaultCropSize = CGSize(width: width, height: height)
            } else {
                defaultCropSize = nil
            }
            
            defaultUserCrop = dngData[kCGImagePropertyDNGDefaultUserCrop]
            originalRawFileName = dngData[typed: kCGImagePropertyDNGOriginalRawFileName]
            originalRawFileData = dngData[kCGImagePropertyDNGOriginalRawFileData]
            noiseReductionApplied = dngData[typed: kCGImagePropertyDNGNoiseReductionApplied]
            newRawImageDigest = dngData[kCGImagePropertyDNGNewRawImageDigest]
            originalRawFileDigest = dngData[kCGImagePropertyDNGOriginalRawFileDigest]
            rawImageDigest = dngData[kCGImagePropertyDNGRawImageDigest]
            originalDefaultFinalSize = dngData[kCGImagePropertyDNGOriginalDefaultFinalSize]
            originalBestQualityFinalSize = dngData[kCGImagePropertyDNGOriginalBestQualityFinalSize]
            originalDefaultCropSize = dngData[kCGImagePropertyDNGOriginalDefaultCropSize]
            rawToPreviewGain = dngData[typed: kCGImagePropertyDNGRawToPreviewGain]
            noiseProfile = dngData[kCGImagePropertyDNGNoiseProfile]
            cfaLayout = dngData[typed: kCGImagePropertyDNGCFALayout]
            cfaPlaneColor = dngData[kCGImagePropertyDNGCFAPlaneColor]
            opcodeList1 = dngData[kCGImagePropertyDNGOpcodeList1]
            dngOpcodeList2 = dngData[kCGImagePropertyDNGOpcodeList2]
            dngOpcodeList3 = dngData[kCGImagePropertyDNGOpcodeList3]
            warpRectilinear = dngData[kCGImagePropertyDNGWarpRectilinear]
            warpFisheye = dngData[kCGImagePropertyDNGWarpFisheye]
            fixVignetteRadial = dngData[kCGImagePropertyDNGFixVignetteRadial]
            dngPrivateData = dngData[kCGImagePropertyDNGPrivateData]
            makerNoteSafety = dngData[typed: kCGImagePropertyDNGMakerNoteSafety]
            dngRawDataUniqueID = dngData[typed: kCGImagePropertyDNGRawDataUniqueID]
            subTileBlockSize = dngData[kCGImagePropertyDNGSubTileBlockSize]
            rowInterleaveFactor = dngData[typed: kCGImagePropertyDNGRowInterleaveFactor]
            dngBackwardVersion = dngData[typed: kCGImagePropertyDNGBackwardVersion]
            dngVersion = dngData[typed: kCGImagePropertyDNGVersion]
            extraCameraProfiles = dngData[kCGImagePropertyDNGExtraCameraProfiles]
            asShotProfileName = dngData[typed: kCGImagePropertyDNGAsShotProfileName]
            profileHueSatMapDims = dngData[kCGImagePropertyDNGProfileHueSatMapDims]
            profileHueSatMapData1 = dngData[kCGImagePropertyDNGProfileHueSatMapData1]
            profileHueSatMapData2 = dngData[kCGImagePropertyDNGProfileHueSatMapData2]
            profileHueSatMapEncoding = dngData[typed: kCGImagePropertyDNGProfileHueSatMapEncoding]
            profileToneCurve = dngData[kCGImagePropertyDNGProfileToneCurve]
            dngProfileName = dngData[typed: kCGImagePropertyDNGProfileName]
            profileEmbedPolicy = dngData[typed: kCGImagePropertyDNGProfileEmbedPolicy]
            profileCopyright = dngData[typed: kCGImagePropertyDNGProfileCopyright]
            profileLookTableDims = dngData[kCGImagePropertyDNGProfileLookTableDims]
            profileLookTableData = dngData[kCGImagePropertyDNGProfileLookTableData]
            profileLookTableEncoding = dngData[typed: kCGImagePropertyDNGProfileLookTableEncoding]
            previewApplicationName = dngData[typed: kCGImagePropertyDNGPreviewApplicationName]
            previewApplicationVersion = dngData[typed: kCGImagePropertyDNGPreviewApplicationVersion]
            previewSettingsName = dngData[typed: kCGImagePropertyDNGPreviewSettingsName]
            previewSettingsDigest = dngData[typed: kCGImagePropertyDNGPreviewSettingsDigest]
            previewColorSpace = dngData[typed: kCGImagePropertyDNGPreviewColorSpace]
            previewDateTime = dngData[typed: kCGImagePropertyDNGPreviewDateTime, using: ImageProperties.dateFormatter]
            lensInfo = dngData[typed: kCGImagePropertyDNGLensInfo]
            uniqueCameraModel = dngData[typed: kCGImagePropertyDNGUniqueCameraModel]
            localizedCameraModel = dngData[typed: kCGImagePropertyDNGLocalizedCameraModel]
            cameraSerialNumber = dngData[typed: kCGImagePropertyDNGCameraSerialNumber]
        }
    }
}
