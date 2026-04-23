//
//  DNG.swift
//
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

public extension ImageSource.ImageProperties {
    struct DNG: Codable {
        /// The amount of sharpening required for this camera model.
        public var baselineSharpness: Double?
        /// The fraction of the encoding range, above which the response may become significantly non-linear.
        public var linearResponseLimit: Double?
        /// A hint to the DNG reader about how much chroma blur to apply to the image.
        public var chromaBlurRadius: Double?
        /// A hint to the DNG reader about how strong the camera’s antialias filter is.
        public var antiAliasStrength: Double?
        /// A tag that Adobe Camera Raw uses to control the sensitivity of its Shadows slider.
        public var shadowScale: Double?
        /// The scale factor to apply to the default scale to achieve the best quality image size.
        public var bestQualityScale: Double?
        /// The default scale factors for each direction to convert the image to square pixels.
        public var defaultScale: JSONObject?
        /// A lookup table that maps stored values into linear values.
        public var linearizationTable: JSONObject?
        
        /// The amount by which to adjust the zero point of the exposure, specified in EV units.
        public var baselineExposure: Double?
        /// The relative noise level of the camera model at an ISO of 100.
        public var baselineNoise: Double?
        /// The amount of EV units to add to the baseline exposure during image rendering.
        public var baselineExposureOffset: Double?
        
        /// The analog or digital gain that applies to the stored raw values.
        public var analogBalance: JSONObject?
        /// The selected white balance at the time of capture, encoded as the coordinates of a neutral color in linear reference space values.
        public var asShotNeutral: JSONObject?
        /// The selected white balance at the time of capture, encoded as x-y chromaticity coordinates.
        public var asShotWhiteXY: JSONObject?
        /// A value that specifies how closely green pixels in the blue/green rows track the green pixels in red/green rows.
        public var bayerGreenSplit: Int?
        /// A matrix that maps white balanced camera colors to XYZ D50 colors.
        public var forwardMatrix1: JSONObject?
        /// A matrix that maps white balanced camera colors to XYZ D50 colors.
        public var forwardMatrix2: JSONObject?
        /// A hint to the raw converter about how to handle the black point during rendering.
        public var defaultBlackRender: Int?
        
        /// The repeat pattern size for the black level tag.
        public var blackLevelRepeatDim: JSONObject?
        /// The zero light encoding level, specified as a repeating pattern.
        public var blackLevel: JSONObject?
        /// The difference between the zero-light encoding level for each column and the baseline zero-light encoding level.
        public var blackLevelDeltaH: JSONObject?
        /// The difference between the zero-light encodoing level for each row and the baseline zero-light encoding level.
        public var blackLevelDeltaV: JSONObject?
        /// The saturated encoding level for the raw sample values.
        public var whiteLevel: JSONObject?
        /// The illuminant for the first set of color calibration tags.
        public var calibrationIlluminant1: Int?
        /// The illuminant for an optional second set of color calibration tags.
        public var calibrationIlluminant2: Int?
        /// A transformation matrix that converts XYZ values to reference camera native color spaces, under the first calibration illuminant.
        public var colorMatrix1: [CGFloat]?
        /// A transformation matrix that converts XYZ values to reference camera native color spaces, under the second calibration illuminant.
        public var colorMatrix2: [CGFloat]?
        /// A matrix that transforms reference camera native space values to camera-native space values under the first calibration illuminant.
        public var cameraCalibration1: JSONObject?
        /// A matrix that transforms reference camera native space values to camera-native space values under the second calibration illuminant.
        public var cameraCalibration2: JSONObject?
        /// A reduction matrix that converts color camera-native space values to XYZ values, under the first calibration illuminant.
        public var reductionMatrix1: JSONObject?
        /// A reduction matrix that converts color camera-native space values to XYZ values, under the second calibration illuminant.
        public var reductionMatrix2: JSONObject?
        /// A profile that specifies default color rendering from camera color-space coordinates into the ICC profile space.
        public var asShotICCProfile: JSONObject?
        /// A matrix to apply to the camera color-space coordinates before processing values through the ICC profile.
        public var asShotPreProfileMatrix: JSONObject?
        /// A profile that specifies default color rendering from camera color-space coordinates into the ICC profile space.
        public var currentICCProfile: JSONObject?
        /// A matrix to apply to the current camera color-space coordinates before processing values through the ICC profile.
        public var currentPreProfileMatrix: JSONObject?
        /// The colorimetric reference for the CIE XYZ values.
        public var colorimetricReference: Int?
        /// A string to match against the profile calibration signature for the selected camera profile.
        public var cameraCalibrationSignature: String?
        /// A string that describes the calibration for the current profile.
        public var profileCalibrationSignature: String?
        /// The rectangle that defines the non-masked pixels of the sensor.
        public var activeArea: JSONObject?
        /// A list of non-overlapping rectangles that contain fully masked pixels in the image.
        public var maskedAreas: JSONObject?
        /// The origin of the final image area, relative to the top-left corner of the active area rectangle.
        public var defaultCropOrigin: CGPoint? {
            guard let x = _defaultCropOrigin?[safe: 0], let y = _defaultCropOrigin?[safe: 1] else { return nil }
            return CGPoint(x, y)
        }
        private var _defaultCropOrigin: [CGFloat]?

        /// The size of the final image area, in raw image coordinates.
        public var defaultCropSize: CGSize? {
            guard let width = _defaultCropSize?[safe: 0], let height = _defaultCropSize?[safe: 1] else { return nil }
            return CGSize(width, height)
        }
        private var _defaultCropSize: [CGFloat]?
        
        /// A default user-crop rectangle in relative coordinates.
        public var defaultUserCrop: JSONObject?
        /// The file name of the original raw file.
        public var originalRawFileName: String?
        /// The compressed contents of the original raw file.
        public var originalRawFileData: JSONObject?
        /// The amount of noise reduction applied to the raw data on a scale of 0.0 to 1.0.
        public var noiseReductionApplied: Double?
        /// An MD5 digest of the raw image data.
        public var newRawImageDigest: JSONObject?
        /// An MD5 digest of the data stored for the original raw file data.
        public var originalRawFileDigest: JSONObject?
        /// A modified MD5 digest of the raw image data.
        public var rawImageDigest: JSONObject?
        /// THe default final size of the larger original file that was the source of this proxy.
        public var originalDefaultFinalSize: JSONObject?
        /// The best-quality final size of the larger original file that was the source of this proxy.
        public var originalBestQualityFinalSize: JSONObject?
        /// The default crop size of the larger original file that was the source of this proxy.
        public var originalDefaultCropSize: JSONObject?
        /// The gain between the main raw IFD and the preview IFD that contains this tag.
        public var rawToPreviewGain: Double?
        /// The amount of noise in the raw image.
        public var noiseProfile: JSONObject?
        /// The spatial layout of the CFA.
        public var cfaLayout: Int?
        /// A mapping between the values in the CFA pattern tag and the plane numbers in linear raw space.
        public var cfaPlaneColor: JSONObject?
        /// The list of opcodes to apply to the raw image, as read directly from the file.
        public var opcodeList1: JSONObject?
        /// THe list of opcodes to apply to the raw image, after mapping it to linear reference values.
        public var dngOpcodeList2: JSONObject?
        /// The list of opcodes to apply to the raw image, after demosaicing it.
        public var dngOpcodeList3: JSONObject?
        /// An opcode to apply a warp to an image to correct for geometric distortion and lateral chromatic aberration for rectilinear lenses.
        public var warpRectilinear: JSONObject?
        /// An opcode to unwrap an image captued with a fisheye lens and map it to a perspective projection.
        public var warpFisheye: JSONObject?
        /// An opcode to apply a gain function to an image to correct vignetting.
        public var fixVignetteRadial: JSONObject?
        /// Private data that manufacturers may store with an image and use in their own converters.
        public var dngPrivateData: JSONObject?
        /// A Boolean value that tells the DNG reader whether the EXIF MakerNote tag is safe to preserve.
        public var makerNoteSafety: Int?
        /// A 16-byte unique identifier for the raw image data.
        public var dngRawDataUniqueID: String?
        /// The size of rectangular blocks that tiles use to group pixels.
        public var subTileBlockSize: JSONObject?
        /// The number of interleaved fields for the rows of the image.
        public var rowInterleaveFactor: Int?
        /// The oldest version for which a file is compatible.
        public var dngBackwardVersion: String?
        /// An encoding of the four-tier version number.
        public var dngVersion: [Double]?
        /// A list of file offsets to extra camera profiles.
        public var extraCameraProfiles: JSONObject?
        /// A string containing the name of the "as shot" camera profile, if any.
        public var asShotProfileName: String?
        /// The number of input samples in each dimension of the hue/saturation/value mapping tables.
        public var profileHueSatMapDims: JSONObject?
        /// The data for the first hue/saturation/value mapping table.
        public var profileHueSatMapData1: JSONObject?
        /// The data for the second hue/saturation/value mapping table.
        public var profileHueSatMapData2: JSONObject?
        /// The encoding option to use when indexing into a 3D look table during raw conversion.
        public var profileHueSatMapEncoding: Int?
        /// The default tone curve to apply when processing the image as a starting point for user adjustments.
        public var profileToneCurve: JSONObject?
        /// A string containing the name of the camera profile.
        public var dngProfileName: String?
        /// The usage rules for the camera profile.
        public var profileEmbedPolicy: Int?
        /// The copyright information for the camera profile.
        public var profileCopyright: String?
        /// The number of input samples in each dimentsion of a default "look" table.
        public var profileLookTableDims: JSONObject?
        /// The default "look" table to apply when processing the image as a starting point for user adjustment.
        public var profileLookTableData: JSONObject?
        /// The encoding option to use when indexing into a 3D look table during raw conversion.
        public var profileLookTableEncoding: Int?
        /// The name of the app that created the preview stored in the IFD.
        public var previewApplicationName: String?
        /// The version number of the app that created the preview stored in the IFD.
        public var previewApplicationVersion: String?
        /// The name of the conversion settings for the preview.
        public var previewSettingsName: String?
        /// A unique ID of the conversion settings used to render the preview.
        public var previewSettingsDigest: String?
        /// The color space associated with the rendered preview.
        public var previewColorSpace: Int?
        /// The date and time for the render of the preview.
        public var previewDateTime: Date?
        /// Information about the lens used for the image.
        public var lensInfo: String?
        /// A unique, nonlocalized name for the camera model.
        public var uniqueCameraModel: String?
        /// The localized camera model name.
        public var localizedCameraModel: String?
        /// The camera serial number.
        public var cameraSerialNumber: String?

        enum CodingKeys: String, CodingKey {
            case baselineSharpness = "BaselineSharpness"
            case linearResponseLimit = "LinearResponseLimit"
            case chromaBlurRadius = "ChromaBlurRadius"
            case antiAliasStrength = "AntiAliasStrength"
            case shadowScale = "ShadowScale"
            case bestQualityScale = "BestQualityScale"
            case defaultScale = "DefaultScale"
            case linearizationTable = "LinearizationTable"
            case baselineExposure = "BaselineExposure"
            case baselineNoise = "BaselineNoise"
            case baselineExposureOffset = "BaselineExposureOffset"
            case analogBalance = "AnalogBalance"
            case asShotNeutral = "AsShotNeutral"
            case asShotWhiteXY = "AsShotWhiteXY"
            case bayerGreenSplit = "BayerGreenSplit"
            case forwardMatrix1 = "ForwardMatrix1"
            case forwardMatrix2 = "ForwardMatrix2"
            case defaultBlackRender = "DefaultBlackRender"
            case blackLevelRepeatDim = "BlackLevelRepeatDim"
            case blackLevel = "BlackLevel"
            case blackLevelDeltaH = "BlackLevelDeltaH"
            case blackLevelDeltaV = "BlackLevelDeltaV"
            case whiteLevel = "WhiteLevel"
            case calibrationIlluminant1 = "CalibrationIlluminant1"
            case calibrationIlluminant2 = "CalibrationIlluminant2"
            case colorMatrix1 = "ColorMatrix1"
            case colorMatrix2 = "ColorMatrix2"
            case cameraCalibration1 = "CameraCalibration1"
            case cameraCalibration2 = "CameraCalibration2"
            case reductionMatrix1 = "ReductionMatrix1"
            case reductionMatrix2 = "ReductionMatrix2"
            case asShotICCProfile = "AsShotICCProfile"
            case asShotPreProfileMatrix = "AsShotPreProfileMatrix"
            case currentICCProfile = "CurrentICCProfile"
            case currentPreProfileMatrix = "CurrentPreProfileMatrix"
            case colorimetricReference = "ColorimetricReference"
            case cameraCalibrationSignature = "CameraCalibrationSignature"
            case profileCalibrationSignature = "ProfileCalibrationSignature"
            case activeArea = "ActiveArea"
            case maskedAreas = "MaskedAreas"
            case _defaultCropOrigin = "DefaultCropOrigin"
            case _defaultCropSize = "DefaultCropSize"
            case defaultUserCrop = "DefaultUserCrop"
            case originalRawFileName = "OriginalRawFileName"
            case originalRawFileData = "OriginalRawFileData"
            case noiseReductionApplied = "NoiseReductionApplied"
            case newRawImageDigest = "NewRawImageDigest"
            case originalRawFileDigest = "OriginalRawFileDigest"
            case rawImageDigest = "RawImageDigest"
            case originalDefaultFinalSize = "OriginalDefaultFinalSize"
            case originalBestQualityFinalSize = "OriginalBestQualityFinalSize"
            case originalDefaultCropSize = "OriginalDefaultCropSize"
            case rawToPreviewGain = "RawToPreviewGain"
            case noiseProfile = "NoiseProfile"
            case cfaLayout = "CFALayout"
            case cfaPlaneColor = "CFAPlaneColor"
            case opcodeList1 = "OpcodeList1"
            case dngOpcodeList2 = "DNGOpcodeList2"
            case dngOpcodeList3 = "DNGOpcodeList3"
            case warpRectilinear = "WarpRectilinear"
            case warpFisheye = "WarpFisheye"
            case fixVignetteRadial = "FixVignetteRadial"
            case dngPrivateData = "DNGPrivateData"
            case makerNoteSafety = "MakerNoteSafety"
            case dngRawDataUniqueID = "DNGRawDataUniqueID"
            case subTileBlockSize = "SubTileBlockSize"
            case rowInterleaveFactor = "RowInterleaveFactor"
            case dngBackwardVersion = "DNGBackwardVersion"
            case dngVersion = "DNGVersion"
            case extraCameraProfiles = "ExtraCameraProfiles"
            case asShotProfileName = "AsShotProfileName"
            case profileHueSatMapDims = "ProfileHueSatMapDims"
            case profileHueSatMapData1 = "ProfileHueSatMapData1"
            case profileHueSatMapData2 = "ProfileHueSatMapData2"
            case profileHueSatMapEncoding = "ProfileHueSatMapEncoding"
            case profileToneCurve = "ProfileToneCurve"
            case dngProfileName = "DNGProfileName"
            case profileEmbedPolicy = "ProfileEmbedPolicy"
            case profileCopyright = "ProfileCopyright"
            case profileLookTableDims = "ProfileLookTableDims"
            case profileLookTableData = "ProfileLookTableData"
            case profileLookTableEncoding = "ProfileLookTableEncoding"
            case previewApplicationName = "PreviewApplicationName"
            case previewApplicationVersion = "PreviewApplicationVersion"
            case previewSettingsName = "PreviewSettingsName"
            case previewSettingsDigest = "PreviewSettingsDigest"
            case previewColorSpace = "PreviewColorSpace"
            case previewDateTime = "PreviewDateTime"
            case lensInfo = "LensInfo"
            case uniqueCameraModel = "UniqueCameraModel"
            case localizedCameraModel = "LocalizedCameraModel"
            case cameraSerialNumber = "CameraSerialNumber"
        }
    }
}
