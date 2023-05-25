//
//  NewTiff.swift
//  ATest
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

extension ImageProperties.TIFF {
public struct Extended: Codable {
    public var compression: Double?
    public var photometricInterpretation: Double?
    public var documentName: Double?
    public var imageDescription: Double?
    public var resolutionUnit: Double?
    public var software: Double?
    public var transferFunction: Double?
    public var artist: Double?
    public var hostComputer: Double?
    public var copyright: Double?
    public var whitePoint: Double?
    public var primaryChromaticities: Double?
    public var tileWidth: Double?
    public var tileLength: Double?
    
    enum CodingKeys: String, CodingKey {
        case compression = "Compression"
        case photometricInterpretation = "PhotometricInterpretation"
        case documentName = "DocumentName"
        case imageDescription = "ImageDescription"
        case resolutionUnit = "ResolutionUnit"
        case software = "Software"
        case transferFunction = "TransferFunction"
        case artist = "Artist"
        case hostComputer = "HostComputer"
        case copyright = "Copyright"
        case whitePoint = "WhitePoint"
        case primaryChromaticities = "PrimaryChromaticities"
        case tileWidth = "TileWidth"
        case tileLength = "TileLength"
    }
}
}
