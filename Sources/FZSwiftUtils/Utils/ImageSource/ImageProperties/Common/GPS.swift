//
//  GPS.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreLocation
import Foundation

public extension ImageSource.ImageProperties {
    struct GPS: Codable {
        /// The GPS tag version information.
        public var version: [Double]?
        /// The reference direction for the latitude value.
        public var latitudeRef: LatitudeRef?
        /// The latitude in degrees.
        public var latitude: Double?
        /// The reference direction for the longitude value.
        public var longitudeRef: LongitudeRef?
        /// The longitude in degrees.
        public var longitude: Double?
        /// The reference used for the altitude value.
        public var altitudeRef: AltitudeRef?
        /// The altitude of the destination in meters.
        public var altitude: Double?
        /// The UTC time associated with the GPS measurement.
        public var timeStamp: Date?
        /// The satellites used for the GPS measurement.
        public var satellites: String?
        /// The status of the GPS receiver.
        public var status: Status?
        /// The dimensionality of the GPS measurement.
        public var measureMode: MeasureMode?
        /// The degree of precision for the GPS measurement.
        public var dOP: Double?
        /// The unit used for the speed value.
        public var speedRef: SpeedRef?
        /// The speed of the GPS receiver movement.
        public var speed: Double?
        /// The reference for the track angle.
        public var trackRef: Double?
        /// The direction of movement of the GPS receiver.
        public var track: Double?
        /// The reference for the image direction value.
        public var imgDirectionRef: DirectionRef?
        /// The direction the image was taken.
        public var imgDirection: Double?
        /// The geodetic survey data used by the GPS receiver.
        public var mapDatum: String?
        /// The reference for the destination latitude value.
        public var destLatitudeRef: String?
        /// The destination latitude in degrees.
        public var destLatitude: Double?
        /// The reference for the destination longitude value.
        public var destLongitudeRef: Double?
        /// The destination longitude in degrees.
        public var destLongitude: Double?
        /// The reference for the destination bearing value.
        public var destBearingRef: String?
        /// The bearing to the destination point.
        public var destBearing: Double?
        /// The unit used for the destination distance value.
        public var destDistanceRef: DistanceRef?
        /// The distance to the destination point.
        public var destDistance: Double?
        /// The name of the positioning method used for the GPS data.
        public var processingMethod: String?
        /// The name of the GPS area associated with the measurement.
        public var areaInformation: String?
        /// The UTC date associated with the GPS measurement.
        public var dateStamp: Date?
        /// The GPS differential correction status.
        public var differental: Double?
        /// The horizontal positioning error in meters.
        public var hPositioningError: Double?

        /// A latitude hemisphere reference.
        public enum LatitudeRef: String, Codable {
            /// North.
            case north = "N"
            /// South.
            case south = "S"
        }

        /// A longitude hemisphere reference.
        public enum LongitudeRef: String, Codable {
            /// East.
            case east = "E"
            /// West.
            case west = "W"
        }

        /// A reference describing whether altitude is above or below sea level.
        public enum AltitudeRef: Int, Codable {
            /// Above sea level.
            case aboveSeaLevel = 0
            /// Below sea level.
            case belowSeaLevel = 1
        }

        /// A reference describing whether a direction is true or magnetic.
        public enum DirectionRef: String, Codable {
            /// True direction.
            case trueDirection = "T"
            /// Magnetic direction.
            case magneticDirection = "M"
        }

        /// A unit reference for GPS distance values.
        public enum DistanceRef: String, Codable {
            /// Kilometers.
            case kilometers = "K"
            /// Miles.
            case miles = "M"
            /// Knots.
            case knots = "N"
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

        /// The location represented by the GPS metadata.
        public var location: CLLocation? {
            guard let coordinate = coordinate else { return nil }
            if var altitude = altitude, let timestamp = timeStamp {
                if altitudeRef == .belowSeaLevel {
                    altitude = -altitude
                }
                var location = CLLocation(coordinate: coordinate, altitude: CLLocationDistance(altitude), horizontalAccuracy: .zero, verticalAccuracy: .zero, timestamp: timestamp)
                if let destDistance = destDistance {
                    location = location.location(byAddingAccuracy: destDistance)
                }
                return location
            } else {
                return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }

        /// The coordinate represented by the GPS metadata.
        public var coordinate: CLLocationCoordinate2D? {
            guard let latitude = latitude, let longitude = longitude else { return nil }
            var coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            if latitudeRef == .south {
                coord.latitude = -coord.latitude
            }
            if longitudeRef == .west {
                coord.longitude = -coord.longitude
            }
            return coord
        }

        enum CodingKeys: String, CodingKey {
            case version = "GPSVersion"
            case latitudeRef = "LatitudeRef"
            case latitude = "Latitude"
            case longitudeRef = "LongitudeRef"
            case longitude = "Longitude"
            case altitudeRef = "AltitudeRef"
            case altitude = "Altitude"
            case timeStamp = "TimeStamp"
            case satellites = "Satellites"
            case status = "Status"
            case measureMode = "MeasureMode"
            case dOP = "DOP"
            case speedRef = "SpeedRef"
            case speed = "Speed"
            case trackRef = "TrackRef"
            case track = "Track"
            case imgDirectionRef = "ImgDirectionRef"
            case imgDirection = "ImgDirection"
            case mapDatum = "MapDatum"
            case destLatitudeRef = "DestLatitudeRef"
            case destLatitude = "DestLatitude"
            case destLongitudeRef = "DestLongitudeRef"
            case destLongitude = "DestLongitude"
            case destBearingRef = "DestBearingRef"
            case destBearing = "DestBearing"
            case destDistanceRef = "DestDistanceRef"
            case destDistance = "DestDistance"
            case processingMethod = "ProcessingMethod"
            case areaInformation = "AreaInformation"
            case dateStamp = "DateStamp"
            case differental = "Differential"
            case hPositioningError = "HPositioningError"
        }
    }
}

fileprivate extension CLLocation {
    func location(byAddingAccuracy horizontalError: CLLocationDistance) -> CLLocation {
        CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: CLLocationAccuracy(horizontalError), verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)
    }
}
