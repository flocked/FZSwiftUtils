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
        /// The About CV term metadata of the IPTC record.
        public var aboutCvTerm: JSONObject?
        /// The About CV term CV identifier of the IPTC record.
        public var aboutCvTermCvId: JSONObject?
        /// The About CV term identifier of the IPTC record.
        public var aboutCvTermId: JSONObject?
        /// The About CV term name of the IPTC record.
        public var aboutCvTermName: JSONObject?
        /// The refined About CV term metadata of the IPTC record.
        public var aboutCvTermRefinedAbout: JSONObject?
        /// The action advised metadata of the IPTC record.
        public var actionAdvised: JSONObject?
        /// The additional model information of the IPTC record.
        public var addlModelInfo: JSONObject?
        /// The artwork circa date created metadata of the IPTC record.
        public var artworkCircaDateCreated: JSONObject?
        /// The artwork content description of the IPTC record.
        public var artworkContentDescription: JSONObject?
        /// The artwork contribution description of the IPTC record.
        public var artworkContributionDescription: JSONObject?
        /// The artwork copyright notice of the IPTC record.
        public var artworkCopyrightNotice: JSONObject?
        /// The artwork copyright owner identifier of the IPTC record.
        public var artworkCopyrightOwnerID: JSONObject?
        /// The artwork copyright owner name of the IPTC record.
        public var artworkCopyrightOwnerName: JSONObject?
        /// The artwork creator metadata of the IPTC record.
        public var artworkCreator: JSONObject?
        /// The artwork creator identifier of the IPTC record.
        public var artworkCreatorID: JSONObject?
        /// The artwork creation date metadata of the IPTC record.
        public var artworkDateCreated: JSONObject?
        /// The artwork licensor identifier of the IPTC record.
        public var artworkLicensorID: JSONObject?
        /// The artwork licensor name of the IPTC record.
        public var artworkLicensorName: JSONObject?
        /// The artwork or object metadata of the IPTC record.
        public var artworkOrObject: JSONObject?
        /// The artwork physical description of the IPTC record.
        public var artworkPhysicalDescription: JSONObject?
        /// The artwork source metadata of the IPTC record.
        public var artworkSource: JSONObject?
        /// The artwork source inventory URL of the IPTC record.
        public var artworkSourceInvURL: JSONObject?
        /// The artwork source inventory number of the IPTC record.
        public var artworkSourceInventoryNo: JSONObject?
        /// The artwork style period of the IPTC record.
        public var artworkStylePeriod: JSONObject?
        /// The artwork title of the IPTC record.
        public var artworkTitle: JSONObject?
        /// The audio bitrate metadata of the IPTC record.
        public var audioBitrate: JSONObject?
        /// The audio bitrate mode of the IPTC record.
        public var audioBitrateMode: JSONObject?
        /// The audio channel count of the IPTC record.
        public var audioChannelCount: JSONObject?
        /// The byline metadata of the IPTC record.
        public var byline: JSONObject?
        /// The byline title metadata of the IPTC record.
        public var bylineTitle: JSONObject?
        /// The caption or abstract metadata of the IPTC record.
        public var captionAbstract: JSONObject?
        /// The category metadata of the IPTC record.
        public var category: JSONObject?
        /// The contact city address of the IPTC record.
        public var ciAdrCity: JSONObject?
        /// The contact country address of the IPTC record.
        public var ciAdrCtry: JSONObject?
        /// The contact extended address of the IPTC record.
        public var ciAdrExtadr: JSONObject?
        /// The contact postal code address of the IPTC record.
        public var ciAdrPcode: JSONObject?
        /// The contact region address of the IPTC record.
        public var ciAdrRegion: JSONObject?
        /// The contact work email of the IPTC record.
        public var ciEmailWork: JSONObject?
        /// The contact work telephone of the IPTC record.
        public var ciTelWork: JSONObject?
        /// The contact work URL of the IPTC record.
        public var ciUrlWork: JSONObject?
        /// The circa date created metadata of the IPTC record.
        public var circaDateCreated: JSONObject?
        /// The city metadata of the IPTC record.
        public var city: JSONObject?
        /// The contact metadata of the IPTC record.
        public var contact: JSONObject?
        /// The container format metadata of the IPTC record.
        public var containerFormat: JSONObject?
        /// The container format identifier of the IPTC record.
        public var containerFormatIdentifier: JSONObject?
        /// The container format name of the IPTC record.
        public var containerFormatName: JSONObject?
        /// The content location code of the IPTC record.
        public var contentLocationCode: JSONObject?
        /// The content location name of the IPTC record.
        public var contentLocationName: JSONObject?
        /// The contributor metadata of the IPTC record.
        public var contributor: JSONObject?
        /// The contributor identifier of the IPTC record.
        public var contributorIdentifier: JSONObject?
        /// The contributor name of the IPTC record.
        public var contributorName: JSONObject?
        /// The contributor role of the IPTC record.
        public var contributorRole: JSONObject?
        /// The controlled vocabulary term of the IPTC record.
        public var controlledVocabularyTerm: JSONObject?
        /// The copyright notice of the IPTC record.
        public var copyrightNotice: JSONObject?
        /// The copyright year of the IPTC record.
        public var copyrightYear: JSONObject?
        /// The primary location code of the IPTC record.
        public var countryPrimaryLocationCode: JSONObject?
        /// The primary location name of the IPTC record.
        public var countryPrimaryLocationName: JSONObject?
        /// The country code of the IPTC record.
        public var countryCode: JSONObject?
        /// The country name of the IPTC record.
        public var countryName: JSONObject?
        /// The creator metadata of the IPTC record.
        public var creator: JSONObject?
        /// The creator contact information of the IPTC record.
        public var creatorContactInfo: JSONObject?
        /// The creator identifier of the IPTC record.
        public var creatorIdentifier: JSONObject?
        /// The creator name of the IPTC record.
        public var creatorName: JSONObject?
        /// The creator role of the IPTC record.
        public var creatorRole: JSONObject?
        /// The credit metadata of the IPTC record.
        public var credit: JSONObject?
        /// The data-on-screen metadata of the IPTC record.
        public var dataOnScreen: JSONObject?
        /// The data-on-screen region metadata of the IPTC record.
        public var dataOnScreenRegion: JSONObject?
        /// The data-on-screen region depth of the IPTC record.
        public var dataOnScreenRegionD: JSONObject?
        /// The data-on-screen region height of the IPTC record.
        public var dataOnScreenRegionH: JSONObject?
        /// The data-on-screen region text of the IPTC record.
        public var dataOnScreenRegionText: JSONObject?
        /// The data-on-screen region unit of the IPTC record.
        public var dataOnScreenRegionUnit: JSONObject?
        /// The data-on-screen region width of the IPTC record.
        public var dataOnScreenRegionW: JSONObject?
        /// The data-on-screen region x position of the IPTC record.
        public var dataOnScreenRegionX: JSONObject?
        /// The data-on-screen region y position of the IPTC record.
        public var dataOnScreenRegionY: JSONObject?
        /// The creation date of the IPTC record.
        public var dateCreated: JSONObject?
        /// The digital creation date of the IPTC record.
        public var digitalCreationDate: JSONObject?
        /// The digital creation time of the IPTC record.
        public var digitalCreationTime: JSONObject?
        /// The digital image GUID of the IPTC record.
        public var digitalImageGUID: JSONObject?
        /// The digital source file type of the IPTC record.
        public var digitalSourceFileType: JSONObject?
        /// The digital source type of the IPTC record.
        public var digitalSourceType: JSONObject?
        /// The dopesheet metadata of the IPTC record.
        public var dopesheet: JSONObject?
        /// The dopesheet link metadata of the IPTC record.
        public var dopesheetLink: JSONObject?
        /// The dopesheet link target of the IPTC record.
        public var dopesheetLinkLink: JSONObject?
        /// The dopesheet link qualifier of the IPTC record.
        public var dopesheetLinkLinkQualifier: JSONObject?
        /// The edit status of the IPTC record.
        public var editStatus: JSONObject?
        /// The editorial update metadata of the IPTC record.
        public var editorialUpdate: JSONObject?
        /// The embedded encoded rights expression of the IPTC record.
        public var embdEncRightsExpr: JSONObject?
        /// The embedded encoded rights expression metadata of the IPTC record.
        public var embeddedEncodedRightsExpr: JSONObject?
        /// The embedded encoded rights expression language identifier of the IPTC record.
        public var embeddedEncodedRightsExprLangID: JSONObject?
        /// The embedded encoded rights expression type of the IPTC record.
        public var embeddedEncodedRightsExprType: JSONObject?
        /// The episode metadata of the IPTC record.
        public var episode: JSONObject?
        /// The episode identifier of the IPTC record.
        public var episodeIdentifier: JSONObject?
        /// The episode name of the IPTC record.
        public var episodeName: JSONObject?
        /// The episode number of the IPTC record.
        public var episodeNumber: JSONObject?
        /// The event metadata of the IPTC record.
        public var event: JSONObject?
        /// The expiration date of the IPTC record.
        public var expirationDate: JSONObject?
        /// The expiration time of the IPTC record.
        public var expirationTime: JSONObject?
        /// The external metadata link of the IPTC record.
        public var externalMetadataLink: JSONObject?
        /// The feed identifier of the IPTC record.
        public var feedIdentifier: JSONObject?
        /// The fixture identifier of the IPTC record.
        public var fixtureIdentifier: JSONObject?
        /// The GPS altitude metadata of the IPTC record.
        public var gPSAltitude: JSONObject?
        /// The GPS latitude metadata of the IPTC record.
        public var gPSLatitude: JSONObject?
        /// The GPS longitude metadata of the IPTC record.
        public var gPSLongitude: JSONObject?
        /// The genre metadata of the IPTC record.
        public var genre: JSONObject?
        /// The genre CV identifier of the IPTC record.
        public var genreCvId: JSONObject?
        /// The genre CV term identifier of the IPTC record.
        public var genreCvTermId: JSONObject?
        /// The genre CV term name of the IPTC record.
        public var genreCvTermName: JSONObject?
        /// The refined genre CV term metadata of the IPTC record.
        public var genreCvTermRefinedAbout: JSONObject?
        /// The headline metadata of the IPTC record.
        public var headline: JSONObject?
        /// The IPTC last edited metadata of the IPTC record.
        public var iPTCLastEdited: JSONObject?
        /// The identifier metadata of the IPTC record.
        public var identifier: JSONObject?
        /// The orientation of the IPTC image.
        public var orientation: CGImagePropertyOrientation?
        /// The image type metadata of the IPTC record.
        public var imageType: JSONObject?
        /// The keywords metadata of the IPTC record.
        public var keywords: JSONObject?
        /// The language identifier of the IPTC record.
        public var languageIdentifier: JSONObject?
        /// The linked encoded rights expression of the IPTC record.
        public var linkedEncRightsExpr: JSONObject?
        /// The linked encoded rights expression metadata of the IPTC record.
        public var linkedEncodedRightsExpr: JSONObject?
        /// The linked encoded rights expression language identifier of the IPTC record.
        public var linkedEncodedRightsExprLangID: JSONObject?
        /// The linked encoded rights expression type of the IPTC record.
        public var linkedEncodedRightsExprType: JSONObject?
        /// The created location metadata of the IPTC record.
        public var locationCreated: JSONObject?
        /// The location identifier of the IPTC record.
        public var locationId: JSONObject?
        /// The location name of the IPTC record.
        public var locationName: JSONObject?
        /// The shown location metadata of the IPTC record.
        public var locationShown: JSONObject?
        /// The maximum available height of the IPTC record.
        public var maxAvailHeight: JSONObject?
        /// The maximum available width of the IPTC record.
        public var maxAvailWidth: JSONObject?
        /// The model age metadata of the IPTC record.
        public var modelAge: JSONObject?
        /// The object attribute reference of the IPTC record.
        public var objectAttributeReference: JSONObject?
        /// The object cycle metadata of the IPTC record.
        public var objectCycle: JSONObject?
        /// The object name of the IPTC record.
        public var objectName: JSONObject?
        /// The object type reference of the IPTC record.
        public var objectTypeReference: JSONObject?
        /// The organisation-in-image code of the IPTC record.
        public var organisationInImageCode: JSONObject?
        /// The organisation-in-image name of the IPTC record.
        public var organisationInImageName: JSONObject?
        /// The original transmission reference of the IPTC record.
        public var originalTransmissionReference: JSONObject?
        /// The originating program of the IPTC record.
        public var originatingProgram: JSONObject?
        /// The person-heard metadata of the IPTC record.
        public var personHeard: JSONObject?
        /// The person-heard identifier of the IPTC record.
        public var personHeardIdentifier: JSONObject?
        /// The person-heard name of the IPTC record.
        public var personHeardName: JSONObject?
        /// The person-in-image metadata of the IPTC record.
        public var personInImage: JSONObject?
        /// The person-in-image characteristic metadata of the IPTC record.
        public var personInImageCharacteristic: JSONObject?
        /// The person-in-image CV term CV identifier of the IPTC record.
        public var personInImageCvTermCvId: JSONObject?
        /// The person-in-image CV term identifier of the IPTC record.
        public var personInImageCvTermId: JSONObject?
        /// The person-in-image CV term name of the IPTC record.
        public var personInImageCvTermName: JSONObject?
        /// The refined person-in-image CV term metadata of the IPTC record.
        public var personInImageCvTermRefinedAbout: JSONObject?
        /// The person-in-image description of the IPTC record.
        public var personInImageDescription: JSONObject?
        /// The person-in-image identifier of the IPTC record.
        public var personInImageId: JSONObject?
        /// The person-in-image name of the IPTC record.
        public var personInImageName: JSONObject?
        /// The person-in-image details metadata of the IPTC record.
        public var personInImageWDetails: JSONObject?
        /// The product-in-image metadata of the IPTC record.
        public var productInImage: JSONObject?
        /// The product-in-image description of the IPTC record.
        public var productInImageDescription: JSONObject?
        /// The product-in-image GTIN of the IPTC record.
        public var productInImageGTIN: JSONObject?
        /// The product-in-image name of the IPTC record.
        public var productInImageName: JSONObject?
        /// The program version of the IPTC record.
        public var programVersion: JSONObject?
        /// The province or state metadata of the IPTC record.
        public var provinceOrState: JSONObject?
        /// The province state metadata of the IPTC record.
        public var provinceState: JSONObject?
        /// The publication event metadata of the IPTC record.
        public var publicationEvent: JSONObject?
        /// The publication event date of the IPTC record.
        public var publicationEventDate: JSONObject?
        /// The publication event identifier of the IPTC record.
        public var publicationEventIdentifier: JSONObject?
        /// The publication event name of the IPTC record.
        public var publicationEventName: JSONObject?
        /// The rating metadata of the IPTC record.
        public var rating: JSONObject?
        /// The rating region metadata of the IPTC record.
        public var ratingRatingRegion: JSONObject?
        /// The rating region city of the IPTC record.
        public var ratingRegionCity: JSONObject?
        /// The rating region country code of the IPTC record.
        public var ratingRegionCountryCode: JSONObject?
        /// The rating region country name of the IPTC record.
        public var ratingRegionCountryName: JSONObject?
        /// The rating region GPS altitude of the IPTC record.
        public var ratingRegionGPSAltitude: JSONObject?
        /// The rating region GPS latitude of the IPTC record.
        public var ratingRegionGPSLatitude: JSONObject?
        /// The rating region GPS longitude of the IPTC record.
        public var ratingRegionGPSLongitude: JSONObject?
        /// The rating region identifier of the IPTC record.
        public var ratingRegionIdentifier: JSONObject?
        /// The rating region location identifier of the IPTC record.
        public var ratingRegionLocationId: JSONObject?
        /// The rating region location name of the IPTC record.
        public var ratingRegionLocationName: JSONObject?
        /// The rating region province state of the IPTC record.
        public var ratingRegionProvinceState: JSONObject?
        /// The rating region sublocation of the IPTC record.
        public var ratingRegionSublocation: JSONObject?
        /// The rating region world region of the IPTC record.
        public var ratingRegionWorldRegion: JSONObject?
        /// The maximum rating scale value of the IPTC record.
        public var ratingScaleMaxValue: JSONObject?
        /// The minimum rating scale value of the IPTC record.
        public var ratingScaleMinValue: JSONObject?
        /// The rating source link of the IPTC record.
        public var ratingSourceLink: JSONObject?
        /// The rating value of the IPTC record.
        public var ratingValue: JSONObject?
        /// The rating value logo link of the IPTC record.
        public var ratingValueLogoLink: JSONObject?
        /// The reference date of the IPTC record.
        public var referenceDate: JSONObject?
        /// The reference number of the IPTC record.
        public var referenceNumber: JSONObject?
        /// The reference service of the IPTC record.
        public var referenceService: JSONObject?
        /// The registry entry role of the IPTC record.
        public var registryEntryRole: JSONObject?
        /// The registry identifier of the IPTC record.
        public var registryID: JSONObject?
        /// The registry item identifier of the IPTC record.
        public var registryItemID: JSONObject?
        /// The registry organisation identifier of the IPTC record.
        public var registryOrganisationID: JSONObject?
        /// The release date of the IPTC record.
        public var releaseDate: JSONObject?
        /// The release-ready metadata of the IPTC record.
        public var releaseReady: JSONObject?
        /// The release time of the IPTC record.
        public var releaseTime: JSONObject?
        /// The scene metadata of the IPTC record.
        public var scene: JSONObject?
        /// The season metadata of the IPTC record.
        public var season: JSONObject?
        /// The season identifier of the IPTC record.
        public var seasonIdentifier: JSONObject?
        /// The season name of the IPTC record.
        public var seasonName: JSONObject?
        /// The season number of the IPTC record.
        public var seasonNumber: JSONObject?
        /// The series metadata of the IPTC record.
        public var series: JSONObject?
        /// The series identifier of the IPTC record.
        public var seriesIdentifier: JSONObject?
        /// The series name of the IPTC record.
        public var seriesName: JSONObject?
        /// The shown event metadata of the IPTC record.
        public var shownEvent: JSONObject?
        /// The shown event identifier of the IPTC record.
        public var shownEventIdentifier: JSONObject?
        /// The shown event name of the IPTC record.
        public var shownEventName: JSONObject?
        /// The source metadata of the IPTC record.
        public var source: JSONObject?
        /// The special instructions of the IPTC record.
        public var specialInstructions: JSONObject?
        /// The star rating metadata of the IPTC record.
        public var starRating: JSONObject?
        /// The storyline identifier of the IPTC record.
        public var storylineIdentifier: JSONObject?
        /// The stream-ready metadata of the IPTC record.
        public var streamReady: JSONObject?
        /// The style period metadata of the IPTC record.
        public var stylePeriod: JSONObject?
        /// The sublocation metadata of the IPTC record.
        public var subLocation: JSONObject?
        /// The subject reference metadata of the IPTC record.
        public var subjectReference: JSONObject?
        /// The alternate sublocation metadata of the IPTC record.
        public var sublocation: JSONObject?
        /// The supplemental category metadata of the IPTC record.
        public var supplementalCategory: JSONObject?
        /// The supply chain source metadata of the IPTC record.
        public var supplyChainSource: JSONObject?
        /// The supply chain source identifier of the IPTC record.
        public var supplyChainSourceIdentifier: JSONObject?
        /// The supply chain source name of the IPTC record.
        public var supplyChainSourceName: JSONObject?
        /// The temporal coverage metadata of the IPTC record.
        public var temporalCoverage: JSONObject?
        /// The temporal coverage start of the IPTC record.
        public var temporalCoverageFrom: JSONObject?
        /// The temporal coverage end of the IPTC record.
        public var temporalCoverageTo: JSONObject?
        /// The creation time of the IPTC record.
        public var timeCreated: JSONObject?
        /// The transcript metadata of the IPTC record.
        public var transcript: JSONObject?
        /// The transcript link metadata of the IPTC record.
        public var transcriptLink: JSONObject?
        /// The transcript link target of the IPTC record.
        public var transcriptLinkLink: JSONObject?
        /// The transcript link qualifier of the IPTC record.
        public var transcriptLinkLinkQualifier: JSONObject?
        /// The urgency metadata of the IPTC record.
        public var urgency: JSONObject?
        /// The usage terms metadata of the IPTC record.
        public var usageTerms: JSONObject?
        /// The video bitrate metadata of the IPTC record.
        public var videoBitrate: JSONObject?
        /// The video bitrate mode of the IPTC record.
        public var videoBitrateMode: JSONObject?
        /// The video display aspect ratio of the IPTC record.
        public var videoDisplayAspectRatio: JSONObject?
        /// The video encoding profile of the IPTC record.
        public var videoEncodingProfile: JSONObject?
        /// The video shot type metadata of the IPTC record.
        public var videoShotType: JSONObject?
        /// The video shot type identifier of the IPTC record.
        public var videoShotTypeIdentifier: JSONObject?
        /// The video shot type name of the IPTC record.
        public var videoShotTypeName: JSONObject?
        /// The video streams count of the IPTC record.
        public var videoStreamsCount: JSONObject?
        /// The visual color metadata of the IPTC record.
        public var visualColor: JSONObject?
        /// The workflow tag metadata of the IPTC record.
        public var workflowTag: JSONObject?
        /// The workflow tag CV identifier of the IPTC record.
        public var workflowTagCvId: JSONObject?
        /// The workflow tag CV term identifier of the IPTC record.
        public var workflowTagCvTermId: JSONObject?
        /// The workflow tag CV term name of the IPTC record.
        public var workflowTagCvTermName: JSONObject?
        /// The refined workflow tag CV term metadata of the IPTC record.
        public var workflowTagCvTermRefinedAbout: JSONObject?
        /// The world region metadata of the IPTC record.
        public var worldRegion: JSONObject?
        /// The writer or editor metadata of the IPTC record.
        public var writerEditor: JSONObject?

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
