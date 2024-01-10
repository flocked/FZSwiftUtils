//
//  GPS.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import CoreLocation
import Foundation

public extension ImageSource.ImageProperties {
    struct GPS: Codable { // "{GPS}"
        public var version: [Double]?
        public var latitudeRef: LatitudeRef?
        public var latitude: Double?
        public var longitudeRef: LongitudeRef?
        public var longitude: Double?
        public var altitudeRef: AltitudeRef?
        public var altitude: Double?
        public var timeStamp: Date?
        public var satellites: Double?
        public var status: Status?
        public var measureMode: MeasureMode?
        public var dOP: Double?
        public var speedRef: SpeedRef?
        public var speed: Double?
        public var trackRef: Double?
        public var track: Double?
        public var imgDirectionRef: DirectionRef?
        public var imgDirection: Double?
        public var mapDatum: String?
        public var destLatitudeRef: Double?
        public var destLatitude: Double?
        public var destLongitudeRef: Double?
        public var destLongitude: Double?
        public var destBearingRef: Double?
        public var destBearing: Double?
        public var destDistanceRef: DistanceRef?
        public var destDistance: Double?
        public var processingMethod: String?
        public var areaInformation: String?
        public var dateStamp: Date?
        public var differental: Double?
        public var hPositioningError: Double?

        public enum LatitudeRef: String, Codable {
            case north = "N"
            case south = "S"
        }

        public enum LongitudeRef: String, Codable {
            case east = "E"
            case west = "W"
        }

        public enum AltitudeRef: Int, Codable {
            case aboveSeaLevel = 0
            case belowSeaLevel = 1
        }

        public enum DirectionRef: String, Codable {
            case trueDirection = "T"
            case magneticDirection = "M"
        }

        public enum DistanceRef: String, Codable {
            case kilometers = "K"
            case miles = "M"
            case knots = "N"
        }

        public enum SpeedRef: String, Codable {
            case kilometersPerHour = "K"
            case milesPerHour = "M"
            case knots = "N"
        }

        public enum MeasureMode: String, Codable {
            case twoDimensional = "2"
            case threeDimensional = "3"
        }

        public enum Status: String, Codable {
            case active = "A"
            case void = "V"
        }

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
                return .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }

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

extension CLLocation {
    func location(byAddingAccuracy horizontalError: CLLocationDistance) -> CLLocation {
        CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: CLLocationAccuracy(horizontalError), verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)
    }
}
