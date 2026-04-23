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
        public var aboutCvTerm: JSONObject?
        /// The About CV term CV identifier.
        public var aboutCvTermCvId: JSONObject?
        /// The About CV term identifier.
        public var aboutCvTermId: JSONObject?
        /// The About CV term name.
        public var aboutCvTermName: JSONObject?
        /// The refined About CV term metadata.
        public var aboutCvTermRefinedAbout: JSONObject?
        /// The action advised metadata.
        public var actionAdvised: JSONObject?
        /// The additional model information.
        public var addlModelInfo: JSONObject?
        /// The artwork circa date created metadata.
        public var artworkCircaDateCreated: JSONObject?
        /// The artwork content description.
        public var artworkContentDescription: JSONObject?
        /// The artwork contribution description.
        public var artworkContributionDescription: JSONObject?
        /// The artwork copyright notice.
        public var artworkCopyrightNotice: JSONObject?
        /// The artwork copyright owner identifier.
        public var artworkCopyrightOwnerID: JSONObject?
        /// The artwork copyright owner name.
        public var artworkCopyrightOwnerName: JSONObject?
        /// The artwork creator metadata.
        public var artworkCreator: JSONObject?
        /// The artwork creator identifier.
        public var artworkCreatorID: JSONObject?
        /// The artwork creation date metadata.
        public var artworkDateCreated: JSONObject?
        /// The artwork licensor identifier.
        public var artworkLicensorID: JSONObject?
        /// The artwork licensor name.
        public var artworkLicensorName: JSONObject?
        /// The artwork or object metadata.
        public var artworkOrObject: JSONObject?
        /// The artwork physical description.
        public var artworkPhysicalDescription: JSONObject?
        /// The artwork source metadata.
        public var artworkSource: JSONObject?
        /// The artwork source inventory URL.
        public var artworkSourceInvURL: JSONObject?
        /// The artwork source inventory number.
        public var artworkSourceInventoryNo: JSONObject?
        /// The artwork style period.
        public var artworkStylePeriod: JSONObject?
        /// The artwork title.
        public var artworkTitle: JSONObject?
        /// The audio bitrate metadata.
        public var audioBitrate: JSONObject?
        /// The audio bitrate mode.
        public var audioBitrateMode: JSONObject?
        /// The audio channel count.
        public var audioChannelCount: JSONObject?
        /// The byline metadata.
        public var byline: [String]?
        /// The byline title metadata.
        public var bylineTitle: [String]?
        /// The caption or abstract metadata.
        public var captionAbstract: String?
        /// The category metadata.
        public var category: JSONObject?
        /// The contact city address.
        public var ciAdrCity: JSONObject?
        /// The contact country address.
        public var ciAdrCtry: JSONObject?
        /// The contact extended address.
        public var ciAdrExtadr: JSONObject?
        /// The contact postal code address.
        public var ciAdrPcode: JSONObject?
        /// The contact region address.
        public var ciAdrRegion: JSONObject?
        /// The contact work email.
        public var ciEmailWork: JSONObject?
        /// The contact work telephone.
        public var ciTelWork: JSONObject?
        /// The contact work URL.
        public var ciUrlWork: JSONObject?
        /// The circa date created metadata.
        public var circaDateCreated: JSONObject?
        /// The city metadata.
        public var city: String?
        /// The contact metadata.
        public var contact: JSONObject?
        /// The container format metadata.
        public var containerFormat: JSONObject?
        /// The container format identifier.
        public var containerFormatIdentifier: JSONObject?
        /// The container format name.
        public var containerFormatName: JSONObject?
        /// The content location code.
        public var contentLocationCode: JSONObject?
        /// The content location name.
        public var contentLocationName: JSONObject?
        /// The contributor metadata.
        public var contributor: JSONObject?
        /// The contributor identifier.
        public var contributorIdentifier: JSONObject?
        /// The contributor name.
        public var contributorName: JSONObject?
        /// The contributor role.
        public var contributorRole: JSONObject?
        /// The controlled vocabulary term.
        public var controlledVocabularyTerm: JSONObject?
        /// The copyright notice.
        public var copyrightNotice: String?
        /// The copyright year.
        public var copyrightYear: JSONObject?
        /// The primary location code.
        public var countryPrimaryLocationCode: JSONObject?
        /// The primary location name.
        public var countryPrimaryLocationName: String?
        /// The country code.
        public var countryCode: JSONObject?
        /// The country name.
        public var countryName: JSONObject?
        /// The creator metadata.
        public var creator: JSONObject?
        /// The creator contact information.
        public var creatorContactInfo: [String: String]?
        /// The creator identifier.
        public var creatorIdentifier: JSONObject?
        /// The creator name.
        public var creatorName: JSONObject?
        /// The creator role.
        public var creatorRole: JSONObject?
        /// The credit metadata.
        public var credit: String?
        /// The data-on-screen metadata.
        public var dataOnScreen: JSONObject?
        /// The data-on-screen region metadata.
        public var dataOnScreenRegion: JSONObject?
        /// The data-on-screen region depth.
        public var dataOnScreenRegionD: JSONObject?
        /// The data-on-screen region height.
        public var dataOnScreenRegionH: JSONObject?
        /// The data-on-screen region text.
        public var dataOnScreenRegionText: JSONObject?
        /// The data-on-screen region unit.
        public var dataOnScreenRegionUnit: JSONObject?
        /// The data-on-screen region width.
        public var dataOnScreenRegionW: JSONObject?
        /// The data-on-screen region x position.
        public var dataOnScreenRegionX: JSONObject?
        /// The data-on-screen region y position.
        public var dataOnScreenRegionY: JSONObject?
        /// The creation date.
        public var dateCreated: JSONObject?
        /// The digital creation date.
        public var digitalCreationDate: JSONObject?
        /// The digital creation time.
        public var digitalCreationTime: JSONObject?
        /// The digital image GUID.
        public var digitalImageGUID: JSONObject?
        /// The digital source file type.
        public var digitalSourceFileType: JSONObject?
        /// The digital source type.
        public var digitalSourceType: JSONObject?
        /// The dopesheet metadata.
        public var dopesheet: JSONObject?
        /// The dopesheet link metadata.
        public var dopesheetLink: JSONObject?
        /// The dopesheet link target.
        public var dopesheetLinkLink: JSONObject?
        /// The dopesheet link qualifier.
        public var dopesheetLinkLinkQualifier: JSONObject?
        /// The edit status.
        public var editStatus: JSONObject?
        /// The editorial update metadata.
        public var editorialUpdate: JSONObject?
        /// The embedded encoded rights expression.
        public var embdEncRightsExpr: JSONObject?
        /// The embedded encoded rights expression metadata.
        public var embeddedEncodedRightsExpr: JSONObject?
        /// The embedded encoded rights expression language identifier.
        public var embeddedEncodedRightsExprLangID: JSONObject?
        /// The embedded encoded rights expression type.
        public var embeddedEncodedRightsExprType: JSONObject?
        /// The episode metadata.
        public var episode: JSONObject?
        /// The episode identifier.
        public var episodeIdentifier: JSONObject?
        /// The episode name.
        public var episodeName: JSONObject?
        /// The episode number.
        public var episodeNumber: JSONObject?
        /// The event metadata.
        public var event: JSONObject?
        /// The expiration date.
        public var expirationDate: JSONObject?
        /// The expiration time.
        public var expirationTime: JSONObject?
        /// The external metadata link.
        public var externalMetadataLink: JSONObject?
        /// The feed identifier.
        public var feedIdentifier: JSONObject?
        /// The fixture identifier.
        public var fixtureIdentifier: JSONObject?
        /// The GPS altitude metadata.
        public var gPSAltitude: JSONObject?
        /// The GPS latitude metadata.
        public var gPSLatitude: JSONObject?
        /// The GPS longitude metadata.
        public var gPSLongitude: JSONObject?
        /// The genre metadata.
        public var genre: JSONObject?
        /// The genre CV identifier.
        public var genreCvId: JSONObject?
        /// The genre CV term identifier.
        public var genreCvTermId: JSONObject?
        /// The genre CV term name.
        public var genreCvTermName: JSONObject?
        /// The refined genre CV term metadata.
        public var genreCvTermRefinedAbout: JSONObject?
        /// The headline metadata.
        public var headline: String?
        /// The IPTC last edited metadata.
        public var iPTCLastEdited: JSONObject?
        /// The identifier metadata.
        public var identifier: JSONObject?
        /// The orientation of the IPTC image.
        public var orientation: CGImagePropertyOrientation?
        /// The image type metadata.
        public var imageType: JSONObject?
        /// The keywords metadata.
        public var keywords: [String]?
        /// The language identifier.
        public var languageIdentifier: JSONObject?
        /// The linked encoded rights expression.
        public var linkedEncRightsExpr: JSONObject?
        /// The linked encoded rights expression metadata.
        public var linkedEncodedRightsExpr: JSONObject?
        /// The linked encoded rights expression language identifier.
        public var linkedEncodedRightsExprLangID: JSONObject?
        /// The linked encoded rights expression type.
        public var linkedEncodedRightsExprType: JSONObject?
        /// The created location metadata.
        public var locationCreated: JSONObject?
        /// The location identifier.
        public var locationId: JSONObject?
        /// The location name.
        public var locationName: JSONObject?
        /// The shown location metadata.
        public var locationShown: JSONObject?
        /// The maximum available height.
        public var maxAvailHeight: JSONObject?
        /// The maximum available width.
        public var maxAvailWidth: JSONObject?
        /// The model age metadata.
        public var modelAge: JSONObject?
        /// The object attribute reference.
        public var objectAttributeReference: JSONObject?
        /// The object cycle metadata.
        public var objectCycle: JSONObject?
        /// The object name.
        public var objectName: String?
        /// The object type reference.
        public var objectTypeReference: JSONObject?
        /// The organisation-in-image code.
        public var organisationInImageCode: JSONObject?
        /// The organisation-in-image name.
        public var organisationInImageName: JSONObject?
        /// The original transmission reference.
        public var originalTransmissionReference: String?
        /// The originating program.
        public var originatingProgram: JSONObject?
        /// The person-heard metadata.
        public var personHeard: JSONObject?
        /// The person-heard identifier.
        public var personHeardIdentifier: JSONObject?
        /// The person-heard name.
        public var personHeardName: JSONObject?
        /// The person-in-image metadata.
        public var personInImage: JSONObject?
        /// The person-in-image characteristic metadata.
        public var personInImageCharacteristic: JSONObject?
        /// The person-in-image CV term CV identifier.
        public var personInImageCvTermCvId: JSONObject?
        /// The person-in-image CV term identifier.
        public var personInImageCvTermId: JSONObject?
        /// The person-in-image CV term name.
        public var personInImageCvTermName: JSONObject?
        /// The refined person-in-image CV term metadata.
        public var personInImageCvTermRefinedAbout: JSONObject?
        /// The person-in-image description.
        public var personInImageDescription: JSONObject?
        /// The person-in-image identifier.
        public var personInImageId: JSONObject?
        /// The person-in-image name.
        public var personInImageName: JSONObject?
        /// The person-in-image details metadata.
        public var personInImageWDetails: JSONObject?
        /// The product-in-image metadata.
        public var productInImage: JSONObject?
        /// The product-in-image description.
        public var productInImageDescription: JSONObject?
        /// The product-in-image GTIN.
        public var productInImageGTIN: JSONObject?
        /// The product-in-image name.
        public var productInImageName: JSONObject?
        /// The program version.
        public var programVersion: JSONObject?
        /// The province or state metadata.
        public var provinceOrState: JSONObject?
        /// The province state metadata.
        public var provinceState: String?
        /// The publication event metadata.
        public var publicationEvent: JSONObject?
        /// The publication event date.
        public var publicationEventDate: JSONObject?
        /// The publication event identifier.
        public var publicationEventIdentifier: JSONObject?
        /// The publication event name.
        public var publicationEventName: JSONObject?
        /// The rating metadata.
        public var rating: JSONObject?
        /// The rating region metadata.
        public var ratingRatingRegion: JSONObject?
        /// The rating region city.
        public var ratingRegionCity: JSONObject?
        /// The rating region country code.
        public var ratingRegionCountryCode: JSONObject?
        /// The rating region country name.
        public var ratingRegionCountryName: JSONObject?
        /// The rating region GPS altitude.
        public var ratingRegionGPSAltitude: JSONObject?
        /// The rating region GPS latitude.
        public var ratingRegionGPSLatitude: JSONObject?
        /// The rating region GPS longitude.
        public var ratingRegionGPSLongitude: JSONObject?
        /// The rating region identifier.
        public var ratingRegionIdentifier: JSONObject?
        /// The rating region location identifier.
        public var ratingRegionLocationId: JSONObject?
        /// The rating region location name.
        public var ratingRegionLocationName: JSONObject?
        /// The rating region province state.
        public var ratingRegionProvinceState: JSONObject?
        /// The rating region sublocation.
        public var ratingRegionSublocation: JSONObject?
        /// The rating region world region.
        public var ratingRegionWorldRegion: JSONObject?
        /// The maximum rating scale value.
        public var ratingScaleMaxValue: JSONObject?
        /// The minimum rating scale value.
        public var ratingScaleMinValue: JSONObject?
        /// The rating source link.
        public var ratingSourceLink: JSONObject?
        /// The rating value.
        public var ratingValue: JSONObject?
        /// The rating value logo link.
        public var ratingValueLogoLink: JSONObject?
        /// The reference date.
        public var referenceDate: JSONObject?
        /// The reference number.
        public var referenceNumber: JSONObject?
        /// The reference service.
        public var referenceService: JSONObject?
        /// The registry entry role.
        public var registryEntryRole: JSONObject?
        /// The registry identifier.
        public var registryID: JSONObject?
        /// The registry item identifier.
        public var registryItemID: JSONObject?
        /// The registry organisation identifier.
        public var registryOrganisationID: JSONObject?
        /// The release date.
        public var releaseDate: JSONObject?
        /// The release-ready metadata.
        public var releaseReady: JSONObject?
        /// The release time.
        public var releaseTime: JSONObject?
        /// The scene metadata.
        public var scene: JSONObject?
        /// The season metadata.
        public var season: JSONObject?
        /// The season identifier.
        public var seasonIdentifier: JSONObject?
        /// The season name.
        public var seasonName: JSONObject?
        /// The season number.
        public var seasonNumber: JSONObject?
        /// The series metadata.
        public var series: JSONObject?
        /// The series identifier.
        public var seriesIdentifier: JSONObject?
        /// The series name.
        public var seriesName: JSONObject?
        /// The shown event metadata.
        public var shownEvent: JSONObject?
        /// The shown event identifier.
        public var shownEventIdentifier: JSONObject?
        /// The shown event name.
        public var shownEventName: JSONObject?
        /// The source metadata.
        public var source: String?
        /// The special instructions.
        public var specialInstructions: String?
        /// The star rating metadata.
        public var starRating: Double?
        /// The storyline identifier.
        public var storylineIdentifier: JSONObject?
        /// The stream-ready metadata.
        public var streamReady: JSONObject?
        /// The style period metadata.
        public var stylePeriod: JSONObject?
        /// The sublocation metadata.
        public var subLocation: JSONObject?
        /// The subject reference metadata.
        public var subjectReference: JSONObject?
        /// The alternate sublocation metadata.
        public var sublocation: JSONObject?
        /// The supplemental category metadata.
        public var supplementalCategory: JSONObject?
        /// The supply chain source metadata.
        public var supplyChainSource: JSONObject?
        /// The supply chain source identifier.
        public var supplyChainSourceIdentifier: JSONObject?
        /// The supply chain source name.
        public var supplyChainSourceName: JSONObject?
        /// The temporal coverage metadata.
        public var temporalCoverage: JSONObject?
        /// The temporal coverage start.
        public var temporalCoverageFrom: JSONObject?
        /// The temporal coverage end.
        public var temporalCoverageTo: JSONObject?
        /// The creation time.
        public var timeCreated: JSONObject?
        /// The transcript metadata.
        public var transcript: JSONObject?
        /// The transcript link metadata.
        public var transcriptLink: JSONObject?
        /// The transcript link target.
        public var transcriptLinkLink: JSONObject?
        /// The transcript link qualifier.
        public var transcriptLinkLinkQualifier: JSONObject?
        /// The urgency metadata.
        public var urgency: JSONObject?
        /// The usage terms metadata.
        public var usageTerms: String?
        /// The video bitrate metadata.
        public var videoBitrate: JSONObject?
        /// The video bitrate mode.
        public var videoBitrateMode: JSONObject?
        /// The video display aspect ratio.
        public var videoDisplayAspectRatio: JSONObject?
        /// The video encoding profile.
        public var videoEncodingProfile: JSONObject?
        /// The video shot type metadata.
        public var videoShotType: JSONObject?
        /// The video shot type identifier.
        public var videoShotTypeIdentifier: JSONObject?
        /// The video shot type name.
        public var videoShotTypeName: JSONObject?
        /// The video streams count.
        public var videoStreamsCount: JSONObject?
        /// The visual color metadata.
        public var visualColor: JSONObject?
        /// The workflow tag metadata.
        public var workflowTag: JSONObject?
        /// The workflow tag CV identifier.
        public var workflowTagCvId: JSONObject?
        /// The workflow tag CV term identifier.
        public var workflowTagCvTermId: JSONObject?
        /// The workflow tag CV term name.
        public var workflowTagCvTermName: JSONObject?
        /// The refined workflow tag CV term metadata.
        public var workflowTagCvTermRefinedAbout: JSONObject?
        /// The world region metadata.
        public var worldRegion: JSONObject?
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
