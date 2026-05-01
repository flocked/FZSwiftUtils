//
//  GPS.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreLocation
import Foundation
import ImageIO

public extension ImageProperties {
    struct GPS {
        /// The raw values.
        public let rawValues: [CFString: Any]
        
        /// The GPS tag version information.
        public let version: [Double]?
        
        /// The latitude in signed decimal degrees.
        public let latitude: Double?

        /// The longitude in signed decimal degrees.
        public let longitude: Double?

        /// The altitude in signed meters relative to sea level.
        public let altitude: Double?
        
        /// The coordinate represented by the GPS metadata.
        public var coordinate: CLLocationCoordinate2D? {
            guard let latitude = latitude, let longitude = longitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        /// The location represented by the GPS metadata.
        public var location: CLLocation? {
            guard let coordinate = coordinate else { return nil }
            if let altitude = altitude {
                return CLLocation(coordinate: coordinate, altitude: CLLocationDistance(altitude), horizontalAccuracy: horizontalPositioningError ?? -1, verticalAccuracy: -1, timestamp: timeStamp ?? dateStamp ?? .distantPast)
            } else {
                return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
        
        /// The UTC time associated with the GPS measurement.
        public let timeStamp: Date?
        /// The satellites used for the GPS measurement.
        public let satellites: String?
        /// The status of the GPS receiver.
        public let status: Status?
        /// The dimensionality of the GPS measurement.
        public let measureMode: MeasureMode?
        /// The degree of precision for the GPS measurement.
        public let dOP: Double?
        /// The unit used for the speed value.
        public let speedRef: SpeedRef?
        /// The speed of the GPS receiver movement.
        public let speed: Double?
        /// The reference for the track angle.
        public let trackRef: DirectionRef?
        /// The direction of movement of the GPS receiver.
        public let track: Double?
        /// The reference for the image direction value.
        public let imageDirectionRef: DirectionRef?
        /// The direction the image was taken.
        public let imageDirection: Double?
        /// The geodetic survey data used by the GPS receiver.
        public let mapDatum: String?
        
        /// The destination latitude in degrees.
        public let destinationLatitude: Double?
        
        /// The destination longitude in degrees.
        public let destinationLongitude: Double?
        
        /// The destination coordinate represented by the GPS metadata.
        public var destinationCoordinate: CLLocationCoordinate2D? {
            guard let latitude = destinationLatitude, let longitude = destinationLongitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        /// The reference for the destination bearing value.
        public let destinationBearingRef: BearingRef?
        /// The bearing to the destination point.
        public let destinationBearing: Double?
        
        /// The distance to the destination point in meters.
        public let destinationDistance: Double?
        
        /// The name of the positioning method used for the GPS data.
        public let processingMethod: String?
        /// The name of the GPS area associated with the measurement.
        public let areaInformation: String?
        /// The UTC date associated with the GPS measurement.
        public let dateStamp: Date?
        /// The GPS differential correction status.
        public let differential: Double?
        /// The horizontal positioning error in meters.
        public let horizontalPositioningError: Double?
                
        /// The reference system used for a bearing value.
        public enum BearingRef: String, Codable {
            /// Bearing is relative to true north.
            case trueNorth = "T"

            /// Bearing is relative to magnetic north.
            case magneticNorth = "M"
        }

        /// A reference describing whether a direction is true or magnetic.
        public enum DirectionRef: String, Codable {
            /// True direction.
            case trueDirection = "T"
            /// Magnetic direction.
            case magneticDirection = "M"
        }

        /// A unit reference for GPS speed values.
        public enum SpeedRef: String, Codable {
            /// Kilometers per hour.
            case kilometersPerHour = "K"
            /// Miles per hour.
            case milesPerHour = "M"
            /// Knots.
            case knots = "N"
        }

        /// A reference describing whether the GPS fix is two- or three-dimensional.
        public enum MeasureMode: String, Codable {
            /// Two dimensional.
            case twoDimensional = "2"
            /// Three dimensional.
            case threeDimensional = "3"
        }

        /// A status describing whether the GPS measurement is active or void.
        public enum Status: String, Codable {
            /// Active.
            case active = "A"
            /// Void.
            case void = "V"
        }
        
        init(gpsData: [CFString: Any]) {
            rawValues = gpsData

            version = gpsData[typed: kCGImagePropertyGPSVersion]

            let latitudeRef: String? = gpsData[typed: kCGImagePropertyGPSLatitudeRef]
            if let _latitude: Double = gpsData[typed: kCGImagePropertyGPSLatitude] {
                latitude = latitudeRef?.uppercased() == "S" ? -_latitude : _latitude
            } else {
                latitude = nil
            }

            let longitudeRef: String? = gpsData[typed: kCGImagePropertyGPSLongitudeRef]
            if let _longitude: Double = gpsData[typed: kCGImagePropertyGPSLongitude] {
                longitude = longitudeRef?.uppercased() == "W" ? -_longitude : _longitude
            } else {
                longitude = nil
            }

            let altitudeRef: Int? = gpsData[typed: kCGImagePropertyGPSAltitudeRef]
            if let _altitude: Double = gpsData[typed: kCGImagePropertyGPSAltitude] {
                altitude =  altitudeRef == 1 ? -_altitude : _altitude
            } else {
                altitude = nil
            }

            timeStamp = gpsData[typed: kCGImagePropertyGPSTimeStamp, using: ImageProperties.dateFormatter]
            dateStamp = gpsData[typed: kCGImagePropertyGPSDateStamp, using: ImageProperties.dateFormatter]

            satellites = gpsData[typed: kCGImagePropertyGPSSatellites]
            
            status = gpsData[typed: kCGImagePropertyGPSStatus]
            measureMode = gpsData[typed: kCGImagePropertyGPSMeasureMode]
            dOP = gpsData[typed: kCGImagePropertyGPSDOP]

            speedRef = gpsData[typed: kCGImagePropertyGPSSpeedRef]
            speed = gpsData[typed: kCGImagePropertyGPSSpeed]

            trackRef = gpsData[typed: kCGImagePropertyGPSTrackRef]
            track = gpsData[typed: kCGImagePropertyGPSTrack]

            imageDirectionRef = gpsData[typed: kCGImagePropertyGPSImgDirectionRef]
            imageDirection = gpsData[typed: kCGImagePropertyGPSImgDirection]

            mapDatum = gpsData[typed: kCGImagePropertyGPSMapDatum]

            let destLatitudeRef: String? = gpsData[typed: kCGImagePropertyGPSDestLatitudeRef]
            if let _destinationLatitude: Double = gpsData[typed: kCGImagePropertyGPSDestLatitude] {
                destinationLatitude = destLatitudeRef?.uppercased() == "S" ? -_destinationLatitude : _destinationLatitude
            } else {
                destinationLatitude = nil
            }
            
            let destLongitudeRef: String? = gpsData[typed: kCGImagePropertyGPSDestLongitudeRef]
            if let destLongitude: Double = gpsData[typed: kCGImagePropertyGPSDestLongitude] {
                destinationLongitude = destLongitudeRef?.uppercased() == "W" ? -destLongitude : destLongitude
            } else {
                destinationLongitude = nil
            }

            destinationBearingRef = gpsData[typed: kCGImagePropertyGPSDestBearingRef]
            destinationBearing = gpsData[typed: kCGImagePropertyGPSDestBearing]

            let destinationDistanceRef: String? = gpsData[typed: kCGImagePropertyGPSDestDistanceRef]
            if let destDistance: Double = gpsData[typed: kCGImagePropertyGPSDestDistance] {
                switch destinationDistanceRef {
                case "K":
                    destinationDistance = destDistance * 1000
                case "M":
                    destinationDistance = destDistance * 1609.344
                case "N":
                    destinationDistance = destDistance * 1852
                default:
                    destinationDistance = destDistance
                }
            } else {
                destinationDistance = nil
            }

            processingMethod = gpsData[typed: kCGImagePropertyGPSProcessingMethod]
            areaInformation = gpsData[typed: kCGImagePropertyGPSAreaInformation]

            differential = gpsData[typed: kCGImagePropertyGPSDifferental]
            horizontalPositioningError = gpsData[typed: kCGImagePropertyGPSHPositioningError]
        }
    }
}
