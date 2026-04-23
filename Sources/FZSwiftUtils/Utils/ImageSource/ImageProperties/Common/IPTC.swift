//
//  IPTC.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct IPTC: Codable {
        /// The About CV term metadata.
        public var aboutCvTerm: AnyCodable?
        /// The About CV term CV identifier.
        public var aboutCvTermCvId: AnyCodable?
        /// The About CV term identifier.
        public var aboutCvTermId: AnyCodable?
        /// The About CV term name.
        public var aboutCvTermName: AnyCodable?
        /// The refined About CV term metadata.
        public var aboutCvTermRefinedAbout: AnyCodable?
        /// The action advised metadata.
        public var actionAdvised: AnyCodable?
        /// The additional model information.
        public var addlModelInfo: AnyCodable?
        /// The artwork circa date created metadata.
        public var artworkCircaDateCreated: AnyCodable?
        /// The artwork content description.
        public var artworkContentDescription: AnyCodable?
        /// The artwork contribution description.
        public var artworkContributionDescription: AnyCodable?
        /// The artwork copyright notice.
        public var artworkCopyrightNotice: AnyCodable?
        /// The artwork copyright owner identifier.
        public var artworkCopyrightOwnerID: AnyCodable?
        /// The artwork copyright owner name.
        public var artworkCopyrightOwnerName: AnyCodable?
        /// The artwork creator metadata.
        public var artworkCreator: AnyCodable?
        /// The artwork creator identifier.
        public var artworkCreatorID: AnyCodable?
        /// The artwork creation date metadata.
        public var artworkDateCreated: AnyCodable?
        /// The artwork licensor identifier.
        public var artworkLicensorID: AnyCodable?
        /// The artwork licensor name.
        public var artworkLicensorName: AnyCodable?
        /// The artwork or object metadata.
        public var artworkOrObject: AnyCodable?
        /// The artwork physical description.
        public var artworkPhysicalDescription: AnyCodable?
        /// The artwork source metadata.
        public var artworkSource: AnyCodable?
        /// The artwork source inventory URL.
        public var artworkSourceInvURL: AnyCodable?
        /// The artwork source inventory number.
        public var artworkSourceInventoryNo: AnyCodable?
        /// The artwork style period.
        public var artworkStylePeriod: AnyCodable?
        /// The artwork title.
        public var artworkTitle: AnyCodable?
        /// The audio bitrate metadata.
        public var audioBitrate: AnyCodable?
        /// The audio bitrate mode.
        public var audioBitrateMode: AnyCodable?
        /// The audio channel count.
        public var audioChannelCount: AnyCodable?
        /// The byline metadata.
        public var byline: [String]?
        /// The byline title metadata.
        public var bylineTitle: [String]?
        /// The caption or abstract metadata.
        public var captionAbstract: String?
        /// The category metadata.
        public var category: AnyCodable?
        /// The contact city address.
        public var ciAdrCity: AnyCodable?
        /// The contact country address.
        public var ciAdrCtry: AnyCodable?
        /// The contact extended address.
        public var ciAdrExtadr: AnyCodable?
        /// The contact postal code address.
        public var ciAdrPcode: AnyCodable?
        /// The contact region address.
        public var ciAdrRegion: AnyCodable?
        /// The contact work email.
        public var ciEmailWork: AnyCodable?
        /// The contact work telephone.
        public var ciTelWork: AnyCodable?
        /// The contact work URL.
        public var ciUrlWork: AnyCodable?
        /// The circa date created metadata.
        public var circaDateCreated: AnyCodable?
        /// The city metadata.
        public var city: String?
        /// The contact metadata.
        public var contact: AnyCodable?
        /// The container format metadata.
        public var containerFormat: AnyCodable?
        /// The container format identifier.
        public var containerFormatIdentifier: AnyCodable?
        /// The container format name.
        public var containerFormatName: AnyCodable?
        /// The content location code.
        public var contentLocationCode: AnyCodable?
        /// The content location name.
        public var contentLocationName: AnyCodable?
        /// The contributor metadata.
        public var contributor: AnyCodable?
        /// The contributor identifier.
        public var contributorIdentifier: AnyCodable?
        /// The contributor name.
        public var contributorName: AnyCodable?
        /// The contributor role.
        public var contributorRole: AnyCodable?
        /// The controlled vocabulary term.
        public var controlledVocabularyTerm: AnyCodable?
        /// The copyright notice.
        public var copyrightNotice: String?
        /// The copyright year.
        public var copyrightYear: AnyCodable?
        /// The primary location code.
        public var countryPrimaryLocationCode: AnyCodable?
        /// The primary location name.
        public var countryPrimaryLocationName: String?
        /// The country code.
        public var countryCode: AnyCodable?
        /// The country name.
        public var countryName: AnyCodable?
        /// The creator metadata.
        public var creator: AnyCodable?
        /// The creator contact information.
        public var creatorContactInfo: [String: String]?
        /// The creator identifier.
        public var creatorIdentifier: AnyCodable?
        /// The creator name.
        public var creatorName: AnyCodable?
        /// The creator role.
        public var creatorRole: AnyCodable?
        /// The credit metadata.
        public var credit: String?
        /// The data-on-screen metadata.
        public var dataOnScreen: AnyCodable?
        /// The data-on-screen region metadata.
        public var dataOnScreenRegion: AnyCodable?
        /// The data-on-screen region depth.
        public var dataOnScreenRegionD: AnyCodable?
        /// The data-on-screen region height.
        public var dataOnScreenRegionH: AnyCodable?
        /// The data-on-screen region text.
        public var dataOnScreenRegionText: AnyCodable?
        /// The data-on-screen region unit.
        public var dataOnScreenRegionUnit: AnyCodable?
        /// The data-on-screen region width.
        public var dataOnScreenRegionW: AnyCodable?
        /// The data-on-screen region x position.
        public var dataOnScreenRegionX: AnyCodable?
        /// The data-on-screen region y position.
        public var dataOnScreenRegionY: AnyCodable?
        /// The creation date.
        public var dateCreated: AnyCodable?
        /// The digital creation date.
        public var digitalCreationDate: AnyCodable?
        /// The digital creation time.
        public var digitalCreationTime: AnyCodable?
        /// The digital image GUID.
        public var digitalImageGUID: AnyCodable?
        /// The digital source file type.
        public var digitalSourceFileType: AnyCodable?
        /// The digital source type.
        public var digitalSourceType: AnyCodable?
        /// The dopesheet metadata.
        public var dopesheet: AnyCodable?
        /// The dopesheet link metadata.
        public var dopesheetLink: AnyCodable?
        /// The dopesheet link target.
        public var dopesheetLinkLink: AnyCodable?
        /// The dopesheet link qualifier.
        public var dopesheetLinkLinkQualifier: AnyCodable?
        /// The edit status.
        public var editStatus: AnyCodable?
        /// The editorial update metadata.
        public var editorialUpdate: AnyCodable?
        /// The embedded encoded rights expression.
        public var embdEncRightsExpr: AnyCodable?
        /// The embedded encoded rights expression metadata.
        public var embeddedEncodedRightsExpr: AnyCodable?
        /// The embedded encoded rights expression language identifier.
        public var embeddedEncodedRightsExprLangID: AnyCodable?
        /// The embedded encoded rights expression type.
        public var embeddedEncodedRightsExprType: AnyCodable?
        /// The episode metadata.
        public var episode: AnyCodable?
        /// The episode identifier.
        public var episodeIdentifier: AnyCodable?
        /// The episode name.
        public var episodeName: AnyCodable?
        /// The episode number.
        public var episodeNumber: AnyCodable?
        /// The event metadata.
        public var event: AnyCodable?
        /// The expiration date.
        public var expirationDate: AnyCodable?
        /// The expiration time.
        public var expirationTime: AnyCodable?
        /// The external metadata link.
        public var externalMetadataLink: AnyCodable?
        /// The feed identifier.
        public var feedIdentifier: AnyCodable?
        /// The fixture identifier.
        public var fixtureIdentifier: AnyCodable?
        /// The GPS altitude metadata.
        public var gPSAltitude: AnyCodable?
        /// The GPS latitude metadata.
        public var gPSLatitude: AnyCodable?
        /// The GPS longitude metadata.
        public var gPSLongitude: AnyCodable?
        /// The genre metadata.
        public var genre: AnyCodable?
        /// The genre CV identifier.
        public var genreCvId: AnyCodable?
        /// The genre CV term identifier.
        public var genreCvTermId: AnyCodable?
        /// The genre CV term name.
        public var genreCvTermName: AnyCodable?
        /// The refined genre CV term metadata.
        public var genreCvTermRefinedAbout: AnyCodable?
        /// The headline metadata.
        public var headline: String?
        /// The IPTC last edited metadata.
        public var iPTCLastEdited: AnyCodable?
        /// The identifier metadata.
        public var identifier: AnyCodable?
        /// The orientation of the IPTC image.
        public var orientation: CGImagePropertyOrientation?
        /// The image type metadata.
        public var imageType: AnyCodable?
        /// The keywords metadata.
        public var keywords: [String]?
        /// The language identifier.
        public var languageIdentifier: AnyCodable?
        /// The linked encoded rights expression.
        public var linkedEncRightsExpr: AnyCodable?
        /// The linked encoded rights expression metadata.
        public var linkedEncodedRightsExpr: AnyCodable?
        /// The linked encoded rights expression language identifier.
        public var linkedEncodedRightsExprLangID: AnyCodable?
        /// The linked encoded rights expression type.
        public var linkedEncodedRightsExprType: AnyCodable?
        /// The created location metadata.
        public var locationCreated: AnyCodable?
        /// The location identifier.
        public var locationId: AnyCodable?
        /// The location name.
        public var locationName: AnyCodable?
        /// The shown location metadata.
        public var locationShown: AnyCodable?
        /// The maximum available height.
        public var maxAvailHeight: AnyCodable?
        /// The maximum available width.
        public var maxAvailWidth: AnyCodable?
        /// The model age metadata.
        public var modelAge: AnyCodable?
        /// The object attribute reference.
        public var objectAttributeReference: AnyCodable?
        /// The object cycle metadata.
        public var objectCycle: AnyCodable?
        /// The object name.
        public var objectName: String?
        /// The object type reference.
        public var objectTypeReference: AnyCodable?
        /// The organisation-in-image code.
        public var organisationInImageCode: AnyCodable?
        /// The organisation-in-image name.
        public var organisationInImageName: AnyCodable?
        /// The original transmission reference.
        public var originalTransmissionReference: String?
        /// The originating program.
        public var originatingProgram: AnyCodable?
        /// The person-heard metadata.
        public var personHeard: AnyCodable?
        /// The person-heard identifier.
        public var personHeardIdentifier: AnyCodable?
        /// The person-heard name.
        public var personHeardName: AnyCodable?
        /// The person-in-image metadata.
        public var personInImage: AnyCodable?
        /// The person-in-image characteristic metadata.
        public var personInImageCharacteristic: AnyCodable?
        /// The person-in-image CV term CV identifier.
        public var personInImageCvTermCvId: AnyCodable?
        /// The person-in-image CV term identifier.
        public var personInImageCvTermId: AnyCodable?
        /// The person-in-image CV term name.
        public var personInImageCvTermName: AnyCodable?
        /// The refined person-in-image CV term metadata.
        public var personInImageCvTermRefinedAbout: AnyCodable?
        /// The person-in-image description.
        public var personInImageDescription: AnyCodable?
        /// The person-in-image identifier.
        public var personInImageId: AnyCodable?
        /// The person-in-image name.
        public var personInImageName: AnyCodable?
        /// The person-in-image details metadata.
        public var personInImageWDetails: AnyCodable?
        /// The product-in-image metadata.
        public var productInImage: AnyCodable?
        /// The product-in-image description.
        public var productInImageDescription: AnyCodable?
        /// The product-in-image GTIN.
        public var productInImageGTIN: AnyCodable?
        /// The product-in-image name.
        public var productInImageName: AnyCodable?
        /// The program version.
        public var programVersion: AnyCodable?
        /// The province or state metadata.
        public var provinceOrState: AnyCodable?
        /// The province state metadata.
        public var provinceState: String?
        /// The publication event metadata.
        public var publicationEvent: AnyCodable?
        /// The publication event date.
        public var publicationEventDate: AnyCodable?
        /// The publication event identifier.
        public var publicationEventIdentifier: AnyCodable?
        /// The publication event name.
        public var publicationEventName: AnyCodable?
        /// The rating metadata.
        public var rating: AnyCodable?
        /// The rating region metadata.
        public var ratingRatingRegion: AnyCodable?
        /// The rating region city.
        public var ratingRegionCity: AnyCodable?
        /// The rating region country code.
        public var ratingRegionCountryCode: AnyCodable?
        /// The rating region country name.
        public var ratingRegionCountryName: AnyCodable?
        /// The rating region GPS altitude.
        public var ratingRegionGPSAltitude: AnyCodable?
        /// The rating region GPS latitude.
        public var ratingRegionGPSLatitude: AnyCodable?
        /// The rating region GPS longitude.
        public var ratingRegionGPSLongitude: AnyCodable?
        /// The rating region identifier.
        public var ratingRegionIdentifier: AnyCodable?
        /// The rating region location identifier.
        public var ratingRegionLocationId: AnyCodable?
        /// The rating region location name.
        public var ratingRegionLocationName: AnyCodable?
        /// The rating region province state.
        public var ratingRegionProvinceState: AnyCodable?
        /// The rating region sublocation.
        public var ratingRegionSublocation: AnyCodable?
        /// The rating region world region.
        public var ratingRegionWorldRegion: AnyCodable?
        /// The maximum rating scale value.
        public var ratingScaleMaxValue: AnyCodable?
        /// The minimum rating scale value.
        public var ratingScaleMinValue: AnyCodable?
        /// The rating source link.
        public var ratingSourceLink: AnyCodable?
        /// The rating value.
        public var ratingValue: AnyCodable?
        /// The rating value logo link.
        public var ratingValueLogoLink: AnyCodable?
        /// The reference date.
        public var referenceDate: AnyCodable?
        /// The reference number.
        public var referenceNumber: AnyCodable?
        /// The reference service.
        public var referenceService: AnyCodable?
        /// The registry entry role.
        public var registryEntryRole: AnyCodable?
        /// The registry identifier.
        public var registryID: AnyCodable?
        /// The registry item identifier.
        public var registryItemID: AnyCodable?
        /// The registry organisation identifier.
        public var registryOrganisationID: AnyCodable?
        /// The release date.
        public var releaseDate: AnyCodable?
        /// The release-ready metadata.
        public var releaseReady: AnyCodable?
        /// The release time.
        public var releaseTime: AnyCodable?
        /// The scene metadata.
        public var scene: AnyCodable?
        /// The season metadata.
        public var season: AnyCodable?
        /// The season identifier.
        public var seasonIdentifier: AnyCodable?
        /// The season name.
        public var seasonName: AnyCodable?
        /// The season number.
        public var seasonNumber: AnyCodable?
        /// The series metadata.
        public var series: AnyCodable?
        /// The series identifier.
        public var seriesIdentifier: AnyCodable?
        /// The series name.
        public var seriesName: AnyCodable?
        /// The shown event metadata.
        public var shownEvent: AnyCodable?
        /// The shown event identifier.
        public var shownEventIdentifier: AnyCodable?
        /// The shown event name.
        public var shownEventName: AnyCodable?
        /// The source metadata.
        public var source: String?
        /// The special instructions.
        public var specialInstructions: String?
        /// The star rating metadata.
        public var starRating: Double?
        /// The storyline identifier.
        public var storylineIdentifier: AnyCodable?
        /// The stream-ready metadata.
        public var streamReady: AnyCodable?
        /// The style period metadata.
        public var stylePeriod: AnyCodable?
        /// The sublocation metadata.
        public var subLocation: AnyCodable?
        /// The subject reference metadata.
        public var subjectReference: AnyCodable?
        /// The alternate sublocation metadata.
        public var sublocation: AnyCodable?
        /// The supplemental category metadata.
        public var supplementalCategory: AnyCodable?
        /// The supply chain source metadata.
        public var supplyChainSource: AnyCodable?
        /// The supply chain source identifier.
        public var supplyChainSourceIdentifier: AnyCodable?
        /// The supply chain source name.
        public var supplyChainSourceName: AnyCodable?
        /// The temporal coverage metadata.
        public var temporalCoverage: AnyCodable?
        /// The temporal coverage start.
        public var temporalCoverageFrom: AnyCodable?
        /// The temporal coverage end.
        public var temporalCoverageTo: AnyCodable?
        /// The creation time.
        public var timeCreated: AnyCodable?
        /// The transcript metadata.
        public var transcript: AnyCodable?
        /// The transcript link metadata.
        public var transcriptLink: AnyCodable?
        /// The transcript link target.
        public var transcriptLinkLink: AnyCodable?
        /// The transcript link qualifier.
        public var transcriptLinkLinkQualifier: AnyCodable?
        /// The urgency metadata.
        public var urgency: AnyCodable?
        /// The usage terms metadata.
        public var usageTerms: String?
        /// The video bitrate metadata.
        public var videoBitrate: AnyCodable?
        /// The video bitrate mode.
        public var videoBitrateMode: AnyCodable?
        /// The video display aspect ratio.
        public var videoDisplayAspectRatio: AnyCodable?
        /// The video encoding profile.
        public var videoEncodingProfile: AnyCodable?
        /// The video shot type metadata.
        public var videoShotType: AnyCodable?
        /// The video shot type identifier.
        public var videoShotTypeIdentifier: AnyCodable?
        /// The video shot type name.
        public var videoShotTypeName: AnyCodable?
        /// The video streams count.
        public var videoStreamsCount: AnyCodable?
        /// The visual color metadata.
        public var visualColor: AnyCodable?
        /// The workflow tag metadata.
        public var workflowTag: AnyCodable?
        /// The workflow tag CV identifier.
        public var workflowTagCvId: AnyCodable?
        /// The workflow tag CV term identifier.
        public var workflowTagCvTermId: AnyCodable?
        /// The workflow tag CV term name.
        public var workflowTagCvTermName: AnyCodable?
        /// The refined workflow tag CV term metadata.
        public var workflowTagCvTermRefinedAbout: AnyCodable?
        /// The world region metadata.
        public var worldRegion: AnyCodable?
        /// The writer or editor metadata.
        public var writerEditor: [String]?

        enum CodingKeys: String, CodingKey {
            case aboutCvTerm = "AboutCvTerm"
            case aboutCvTermCvId = "AboutCvTermCvId"
            case aboutCvTermId = "AboutCvTermId"
            case aboutCvTermName = "AboutCvTermName"
            case aboutCvTermRefinedAbout = "AboutCvTermRefinedAbout"
            case actionAdvised = "ActionAdvised"
            case addlModelInfo = "AddlModelInfo"
            case artworkCircaDateCreated = "ArtworkCircaDateCreated"
            case artworkContentDescription = "ArtworkContentDescription"
            case artworkContributionDescription = "ArtworkContributionDescription"
            case artworkCopyrightNotice = "ArtworkCopyrightNotice"
            case artworkCopyrightOwnerID = "ArtworkCopyrightOwnerID"
            case artworkCopyrightOwnerName = "ArtworkCopyrightOwnerName"
            case artworkCreator = "ArtworkCreator"
            case artworkCreatorID = "ArtworkCreatorID"
            case artworkDateCreated = "ArtworkDateCreated"
            case artworkLicensorID = "ArtworkLicensorID"
            case artworkLicensorName = "ArtworkLicensorName"
            case artworkOrObject = "ArtworkOrObject"
            case artworkPhysicalDescription = "ArtworkPhysicalDescription"
            case artworkSource = "ArtworkSource"
            case artworkSourceInvURL = "ArtworkSourceInvURL"
            case artworkSourceInventoryNo = "ArtworkSourceInventoryNo"
            case artworkStylePeriod = "ArtworkStylePeriod"
            case artworkTitle = "ArtworkTitle"
            case audioBitrate = "AudioBitrate"
            case audioBitrateMode = "AudioBitrateMode"
            case audioChannelCount = "AudioChannelCount"
            case byline = "Byline"
            case bylineTitle = "BylineTitle"
            case captionAbstract = "Caption/Abstract"
            case category = "Category"
            case ciAdrCity = "CiAdrCity"
            case ciAdrCtry = "CiAdrCtry"
            case ciAdrExtadr = "CiAdrExtadr"
            case ciAdrPcode = "CiAdrPcode"
            case ciAdrRegion = "CiAdrRegion"
            case ciEmailWork = "CiEmailWork"
            case ciTelWork = "CiTelWork"
            case ciUrlWork = "CiUrlWork"
            case circaDateCreated = "CircaDateCreated"
            case city = "City"
            case contact = "Contact"
            case containerFormat = "ContainerFormat"
            case containerFormatIdentifier = "ContainerFormatIdentifier"
            case containerFormatName = "ContainerFormatName"
            case contentLocationCode = "ContentLocationCode"
            case contentLocationName = "ContentLocationName"
            case contributor = "Contributor"
            case contributorIdentifier = "ContributorIdentifier"
            case contributorName = "ContributorName"
            case contributorRole = "ContributorRole"
            case controlledVocabularyTerm = "ControlledVocabularyTerm"
            case copyrightNotice = "CopyrightNotice"
            case copyrightYear = "CopyrightYear"
            case countryPrimaryLocationCode = "Country/PrimaryLocationCode"
            case countryPrimaryLocationName = "Country/PrimaryLocationName"
            case countryCode = "CountryCode"
            case countryName = "CountryName"
            case creator = "Creator"
            case creatorContactInfo = "CreatorContactInfo"
            case creatorIdentifier = "CreatorIdentifier"
            case creatorName = "CreatorName"
            case creatorRole = "CreatorRole"
            case credit = "Credit"
            case dataOnScreen = "DataOnScreen"
            case dataOnScreenRegion = "DataOnScreenRegion"
            case dataOnScreenRegionD = "DataOnScreenRegionD"
            case dataOnScreenRegionH = "DataOnScreenRegionH"
            case dataOnScreenRegionText = "DataOnScreenRegionText"
            case dataOnScreenRegionUnit = "DataOnScreenRegionUnit"
            case dataOnScreenRegionW = "DataOnScreenRegionW"
            case dataOnScreenRegionX = "DataOnScreenRegionX"
            case dataOnScreenRegionY = "DataOnScreenRegionY"
            case dateCreated = "DateCreated"
            case digitalCreationDate = "DigitalCreationDate"
            case digitalCreationTime = "DigitalCreationTime"
            case digitalImageGUID = "DigitalImageGUID"
            case digitalSourceFileType = "DigitalSourceFileType"
            case digitalSourceType = "DigitalSourceType"
            case dopesheet = "Dopesheet"
            case dopesheetLink = "DopesheetLink"
            case dopesheetLinkLink = "DopesheetLinkLink"
            case dopesheetLinkLinkQualifier = "DopesheetLinkLinkQualifier"
            case editStatus = "EditStatus"
            case editorialUpdate = "EditorialUpdate"
            case embdEncRightsExpr = "EmbdEncRightsExpr"
            case embeddedEncodedRightsExpr = "EmbeddedEncodedRightsExpr"
            case embeddedEncodedRightsExprLangID = "EmbeddedEncodedRightsExprLangID"
            case embeddedEncodedRightsExprType = "EmbeddedEncodedRightsExprType"
            case episode = "Episode"
            case episodeIdentifier = "EpisodeIdentifier"
            case episodeName = "EpisodeName"
            case episodeNumber = "EpisodeNumber"
            case event = "Event"
            case expirationDate = "ExpirationDate"
            case expirationTime = "ExpirationTime"
            case externalMetadataLink = "ExternalMetadataLink"
            case feedIdentifier = "FeedIdentifier"
            case fixtureIdentifier = "FixtureIdentifier"
            case gPSAltitude = "GPSAltitude"
            case gPSLatitude = "GPSLatitude"
            case gPSLongitude = "GPSLongitude"
            case genre = "Genre"
            case genreCvId = "GenreCvId"
            case genreCvTermId = "GenreCvTermId"
            case genreCvTermName = "GenreCvTermName"
            case genreCvTermRefinedAbout = "GenreCvTermRefinedAbout"
            case headline = "Headline"
            case iPTCLastEdited = "IPTCLastEdited"
            case identifier = "Identifier"
            case orientation = "ImageOrientation"
            case imageType = "ImageType"
            case keywords = "Keywords"
            case languageIdentifier = "LanguageIdentifier"
            case linkedEncRightsExpr = "LinkedEncRightsExpr"
            case linkedEncodedRightsExpr = "LinkedEncodedRightsExpr"
            case linkedEncodedRightsExprLangID = "LinkedEncodedRightsExprLangID"
            case linkedEncodedRightsExprType = "LinkedEncodedRightsExprType"
            case locationCreated = "LocationCreated"
            case locationId = "LocationId"
            case locationName = "LocationName"
            case locationShown = "LocationShown"
            case maxAvailHeight = "MaxAvailHeight"
            case maxAvailWidth = "MaxAvailWidth"
            case modelAge = "ModelAge"
            case objectAttributeReference = "ObjectAttributeReference"
            case objectCycle = "ObjectCycle"
            case objectName = "ObjectName"
            case objectTypeReference = "ObjectTypeReference"
            case organisationInImageCode = "OrganisationInImageCode"
            case organisationInImageName = "OrganisationInImageName"
            case originalTransmissionReference = "OriginalTransmissionReference"
            case originatingProgram = "OriginatingProgram"
            case personHeard = "PersonHeard"
            case personHeardIdentifier = "PersonHeardIdentifier"
            case personHeardName = "PersonHeardName"
            case personInImage = "PersonInImage"
            case personInImageCharacteristic = "PersonInImageCharacteristic"
            case personInImageCvTermCvId = "PersonInImageCvTermCvId"
            case personInImageCvTermId = "PersonInImageCvTermId"
            case personInImageCvTermName = "PersonInImageCvTermName"
            case personInImageCvTermRefinedAbout = "PersonInImageCvTermRefinedAbout"
            case personInImageDescription = "PersonInImageDescription"
            case personInImageId = "PersonInImageId"
            case personInImageName = "PersonInImageName"
            case personInImageWDetails = "PersonInImageWDetails"
            case productInImage = "ProductInImage"
            case productInImageDescription = "ProductInImageDescription"
            case productInImageGTIN = "ProductInImageGTIN"
            case productInImageName = "ProductInImageName"
            case programVersion = "ProgramVersion"
            case provinceOrState = "Province/State"
            case provinceState = "ProvinceState"
            case publicationEvent = "PublicationEvent"
            case publicationEventDate = "PublicationEventDate"
            case publicationEventIdentifier = "PublicationEventIdentifier"
            case publicationEventName = "PublicationEventName"
            case rating = "Rating"
            case ratingRatingRegion = "RatingRatingRegion"
            case ratingRegionCity = "RatingRegionCity"
            case ratingRegionCountryCode = "RatingRegionCountryCode"
            case ratingRegionCountryName = "RatingRegionCountryName"
            case ratingRegionGPSAltitude = "RatingRegionGPSAltitude"
            case ratingRegionGPSLatitude = "RatingRegionGPSLatitude"
            case ratingRegionGPSLongitude = "RatingRegionGPSLongitude"
            case ratingRegionIdentifier = "RatingRegionIdentifier"
            case ratingRegionLocationId = "RatingRegionLocationId"
            case ratingRegionLocationName = "RatingRegionLocationName"
            case ratingRegionProvinceState = "RatingRegionProvinceState"
            case ratingRegionSublocation = "RatingRegionSublocation"
            case ratingRegionWorldRegion = "RatingRegionWorldRegion"
            case ratingScaleMaxValue = "RatingScaleMaxValue"
            case ratingScaleMinValue = "RatingScaleMinValue"
            case ratingSourceLink = "RatingSourceLink"
            case ratingValue = "RatingValue"
            case ratingValueLogoLink = "RatingValueLogoLink"
            case referenceDate = "ReferenceDate"
            case referenceNumber = "ReferenceNumber"
            case referenceService = "ReferenceService"
            case registryEntryRole = "RegistryEntryRole"
            case registryID = "RegistryID"
            case registryItemID = "RegistryItemID"
            case registryOrganisationID = "RegistryOrganisationID"
            case releaseDate = "ReleaseDate"
            case releaseReady = "ReleaseReady"
            case releaseTime = "ReleaseTime"
            case scene = "Scene"
            case season = "Season"
            case seasonIdentifier = "SeasonIdentifier"
            case seasonName = "SeasonName"
            case seasonNumber = "SeasonNumber"
            case series = "Series"
            case seriesIdentifier = "SeriesIdentifier"
            case seriesName = "SeriesName"
            case shownEvent = "ShownEvent"
            case shownEventIdentifier = "ShownEventIdentifier"
            case shownEventName = "ShownEventName"
            case source = "Source"
            case specialInstructions = "SpecialInstructions"
            case starRating = "StarRating"
            case storylineIdentifier = "StorylineIdentifier"
            case streamReady = "StreamReady"
            case stylePeriod = "StylePeriod"
            case subLocation = "SubLocation"
            case subjectReference = "SubjectReference"
            case sublocation = "Sublocation"
            case supplementalCategory = "SupplementalCategory"
            case supplyChainSource = "SupplyChainSource"
            case supplyChainSourceIdentifier = "SupplyChainSourceIdentifier"
            case supplyChainSourceName = "SupplyChainSourceName"
            case temporalCoverage = "TemporalCoverage"
            case temporalCoverageFrom = "TemporalCoverageFrom"
            case temporalCoverageTo = "TemporalCoverageTo"
            case timeCreated = "TimeCreated"
            case transcript = "Transcript"
            case transcriptLink = "TranscriptLink"
            case transcriptLinkLink = "TranscriptLinkLink"
            case transcriptLinkLinkQualifier = "TranscriptLinkLinkQualifier"
            case urgency = "Urgency"
            case usageTerms = "UsageTerms"
            case videoBitrate = "VideoBitrate"
            case videoBitrateMode = "VideoBitrateMode"
            case videoDisplayAspectRatio = "VideoDisplayAspectRatio"
            case videoEncodingProfile = "VideoEncodingProfile"
            case videoShotType = "VideoShotType"
            case videoShotTypeIdentifier = "VideoShotTypeIdentifier"
            case videoShotTypeName = "VideoShotTypeName"
            case videoStreamsCount = "VideoStreamsCount"
            case visualColor = "VisualColor"
            case workflowTag = "WorkflowTag"
            case workflowTagCvId = "WorkflowTagCvId"
            case workflowTagCvTermId = "WorkflowTagCvTermId"
            case workflowTagCvTermName = "WorkflowTagCvTermName"
            case workflowTagCvTermRefinedAbout = "WorkflowTagCvTermRefinedAbout"
            case worldRegion = "WorldRegion"
            case writerEditor = "Writer/Editor"
        }
    }
}
