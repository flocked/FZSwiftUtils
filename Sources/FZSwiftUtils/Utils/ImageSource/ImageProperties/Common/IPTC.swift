//
//  IPTC.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageSource.ImageProperties {
    struct IPTC {
        /// The raw values.
        public let rawValues: [CFString: Any]

        /// The artworks of the image.
        public let artworks: [Artwork]
        
        /// The About CV term metadata.
        public let aboutCvTerm: Any?
        /// The About CV term CV identifier.
        public let aboutCvTermCvId: String?
        /// The About CV term identifier.
        public let aboutCvTermId: String?
        /// The About CV term name.
        public let aboutCvTermName: String?
        /// The refined About CV term metadata.
        public let aboutCvTermRefinedAbout: String?
        /// The action advised metadata.
        public let actionAdvised: Any?
        /// The additional model information.
        public let addlModelInfo: String?
        
        /// The audio bitrate metadata.
        public let audioBitrate: Any?
        /// The audio bitrate mode.
        public let audioBitrateMode: String?
        /// The audio channel count.
        public let audioChannelCount: Int?
        /// The byline metadata.
        public let byline: [String]?
        /// The byline title metadata.
        public let bylineTitle: [String]?
        /// The caption or abstract metadata.
        public let captionAbstract: String?
        /// The category metadata.
        public let category: String?
        /// The circa date created metadata.
        public let circaDateCreated: String?
        /// The city metadata.
        public let city: String?
        /// The contact metadata.
        public let contact: [String]?
        /// The container format metadata.
        public let containerFormat: String?
        /// The container format identifier.
        public let containerFormatIdentifier: String?
        /// The container format name.
        public let containerFormatName: String?
        /// The content location code.
        public let contentLocationCode: [String]?
        /// The content location name.
        public let contentLocationName: [String]?
        /// The contributor metadata.
        public let contributor: Any?
        /// The contributor identifier.
        public let contributorIdentifier: Any?
        /// The contributor name.
        public let contributorName: Any?
        /// The contributor role.
        public let contributorRole: Any?
        /// The controlled vocabulary term.
        public let controlledVocabularyTerm: Any?
        /// The copyright notice.
        public let copyrightNotice: String?
        /// The copyright year.
        public let copyrightYear: Int?
        /// The primary location code.
        public let countryPrimaryLocationCode: String?
        /// The primary location name.
        public let countryPrimaryLocationName: String?
        /// The creator metadata.
        public let creator: Any?
        /// The creator contact information.
        public let creatorContactInfo: CreatorContactInfo?
        /// The creator identifier.
        public let creatorIdentifier: String?
        /// The creator name.
        public let creatorName: String?
        /// The creator role.
        public let creatorRole: String?
        /// The credit metadata.
        public let credit: String?
        /// The data-on-screen metadata.
        public let dataOnScreen: String?
        /// The data-on-screen region metadata.
        public let dataOnScreenRegion: Any?
        /// The data-on-screen region depth.
        public let dataOnScreenRegionD: Any?
        /// The data-on-screen region height.
        public let dataOnScreenRegionH: Any?
        /// The data-on-screen region text.
        public let dataOnScreenRegionText: Any?
        /// The data-on-screen region unit.
        public let dataOnScreenRegionUnit: Any?
        /// The data-on-screen region width.
        public let dataOnScreenRegionW: Any?
        /// The data-on-screen region x position.
        public let dataOnScreenRegionX: Any?
        /// The data-on-screen region y position.
        public let dataOnScreenRegionY: Any?
        /// The creation date.
        public let dateCreated: String?
        /// The digital creation date.
        public let digitalCreationDate: String?
        /// The digital creation time.
        public let digitalCreationTime: String?
        /// The digital image GUID.
        public let digitalImageGUID: String?
        /// The digital source file type.
        public let digitalSourceFileType: String?
        /// The digital source type.
        public let digitalSourceType: String?
        /// The dopesheet metadata.
        public let dopesheet: String?
        /// The dopesheet link metadata.
        public let dopesheetLink: String?
        /// The dopesheet link target.
        public let dopesheetLinkLink: String?
        /// The dopesheet link qualifier.
        public let dopesheetLinkLinkQualifier: String?
        /// The edit status.
        public let editStatus: String?
        /// The editorial update metadata.
        public let editorialUpdate: String?
        /// The embedded encoded rights expression.
        public let embdEncRightsExpr: String?
        /// The embedded encoded rights expression metadata.
        public let embeddedEncodedRightsExpr: String?
        /// The embedded encoded rights expression language identifier.
        public let embeddedEncodedRightsExprLangID: String?
        /// The embedded encoded rights expression type.
        public let embeddedEncodedRightsExprType: String?
        /// The episode metadata.
        public let episode: Any?
        /// The episode identifier.
        public let episodeIdentifier: String?
        /// The episode name.
        public let episodeName: String?
        /// The episode number.
        public let episodeNumber: Any?
        /// The event metadata.
        public let event: Any?
        /// The expiration date.
        public let expirationDate: String?
        /// The expiration time.
        public let expirationTime: String?
        /// The external metadata link.
        public let externalMetadataLink: String?
        /// The feed identifier.
        public let feedIdentifier: String?
        /// The fixture identifier.
        public let fixtureIdentifier: Any?
        /// The genre metadata.
        public let genre: Any?
        /// The genre CV identifier.
        public let genreCvId: String?
        /// The genre CV term identifier.
        public let genreCvTermId: String?
        /// The genre CV term name.
        public let genreCvTermName: String?
        /// The refined genre CV term metadata.
        public let genreCvTermRefinedAbout: String?
        /// The headline metadata.
        public let headline: String?
        /// The IPTC last edited metadata.
        public let iPTCLastEdited: String?
        /// The orientation of the IPTC image.
        public let orientation: CGImagePropertyOrientation?
        /// The image type metadata.
        public let imageType: Any?
        /// The keywords metadata.
        public let keywords: [String]?
        /// The language identifier.
        public let languageIdentifier: String?
        /// The linked encoded rights expression.
        public let linkedEncRightsExpr: String?
        /// The linked encoded rights expression metadata.
        public let linkedEncodedRightsExpr: String?
        /// The linked encoded rights expression language identifier.
        public let linkedEncodedRightsExprLangID: String?
        /// The linked encoded rights expression type.
        public let linkedEncodedRightsExprType: String?
        /// The created location metadata.
        public let locationsCreated: [Location]?
        /// The shown location metadata.
        public let locationsShown: [Location]?
        /// The maximum available height.
        public let maxAvailHeight: Int?
        /// The maximum available width.
        public let maxAvailWidth: Int?
        /// The model age metadata.
        public let modelAge: Int?
        /// The object attribute reference.
        public let objectAttributeReference: Any?
        /// The object cycle metadata.
        public let objectCycle: String?
        /// The object name.
        public let objectName: String?
        /// The object type reference.
        public let objectTypeReference: String?
        /// The organisation-in-image code.
        public let organisationInImageCode: [String]?
        /// The organisation-in-image name.
        public let organisationInImageName: [String]?
        /// The original transmission reference.
        public let originalTransmissionReference: String?
        /// The originating program.
        public let originatingProgram: String?
        /// The person-heard metadata.
        public let personHeard: Any?
        /// The person-heard identifier.
        public let personHeardIdentifier: String?
        /// The person-heard name.
        public let personHeardName: String?
        /// The person-in-image metadata.
        public let personInImage: Any?
        /// The person-in-image characteristic metadata.
        public let personInImageCharacteristic: Any?
        /// The person-in-image CV term CV identifier.
        public let personInImageCvTermCvId: Any?
        /// The person-in-image CV term identifier.
        public let personInImageCvTermId: Any?
        /// The person-in-image CV term name.
        public let personInImageCvTermName: Any?
        /// The refined person-in-image CV term metadata.
        public let personInImageCvTermRefinedAbout: Any?
        /// The person-in-image description.
        public let personInImageDescription: String?
        /// The person-in-image identifier.
        public let personInImageId: String?
        /// The person-in-image name.
        public let personInImageName: String?
        /// The person-in-image details metadata.
        public let personInImageWDetails: Any?
        /// The product-in-image metadata.
        public let productInImage: Any?
        /// The product-in-image description.
        public let productInImageDescription: String?
        /// The product-in-image GTIN.
        public let productInImageGTIN: String?
        /// The product-in-image name.
        public let productInImageName: String?
        /// The program version.
        public let programVersion: String?
        /// The province or state metadata.
        public let provinceOrState: String?
        /// The publication event metadata.
        public let publicationEvent: Any?
        /// The publication event date.
        public let publicationEventDate: String?
        /// The publication event identifier.
        public let publicationEventIdentifier: String?
        /// The publication event name.
        public let publicationEventName: String?
        /// The rating metadata.
        public let rating: Any?
        /// The rating region metadata.
        public let ratingRatingRegion: Any?
        /// The rating region city.
        public let ratingRegionCity: String?
        /// The rating region country code.
        public let ratingRegionCountryCode: String?
        /// The rating region country name.
        public let ratingRegionCountryName: String?
        /// The rating region GPS altitude.
        public let ratingRegionGPSAltitude: Double?
        /// The rating region GPS latitude.
        public let ratingRegionGPSLatitude: Double?
        /// The rating region GPS longitude.
        public let ratingRegionGPSLongitude: Double?
        /// The rating region identifier.
        public let ratingRegionIdentifier: String?
        /// The rating region location identifier.
        public let ratingRegionLocationId: String?
        /// The rating region location name.
        public let ratingRegionLocationName: String?
        /// The rating region province state.
        public let ratingRegionProvinceState: String?
        /// The rating region sublocation.
        public let ratingRegionSublocation: String?
        /// The rating region world region.
        public let ratingRegionWorldRegion: String?
        /// The maximum rating scale value.
        public let ratingScaleMaxValue: Double?
        /// The minimum rating scale value.
        public let ratingScaleMinValue: Double?
        /// The rating source link.
        public let ratingSourceLink: String?
        /// The rating value.
        public let ratingValue: Double?
        /// The rating value logo link.
        public let ratingValueLogoLink: String?
        /// The reference date.
        public let referenceDate: String?
        /// The reference number.
        public let referenceNumber: Any?
        /// The reference service.
        public let referenceService: Any?
        /// The registry entry role.
        public let registryEntryRole: String?
        /// The registry identifier.
        public let registryID: String?
        /// The registry item identifier.
        public let registryItemID: String?
        /// The registry organisation identifier.
        public let registryOrganisationID: String?
        /// The release date.
        public let releaseDate: String?
        /// The release-ready metadata.
        public let releaseReady: Any?
        /// The release time.
        public let releaseTime: String?
        /// The scene metadata.
        public let scene: [String]?
        /// The season metadata.
        public let season: Any?
        /// The season identifier.
        public let seasonIdentifier: String?
        /// The season name.
        public let seasonName: String?
        /// The season number.
        public let seasonNumber: Int?
        /// The series metadata.
        public let series: Any?
        /// The series identifier.
        public let seriesIdentifier: String?
        /// The series name.
        public let seriesName: String?
        /// The shown event metadata.
        public let shownEvent: Any?
        /// The shown event identifier.
        public let shownEventIdentifier: String?
        /// The shown event name.
        public let shownEventName: String?
        /// The source metadata.
        public let source: String?
        /// The special instructions.
        public let specialInstructions: String?
        /// The star rating metadata.
        public let starRating: Double?
        /// The storyline identifier.
        public let storylineIdentifier: String?
        /// The stream-ready metadata.
        public let streamReady: Any?
        /// The style period metadata.
        public let stylePeriod: String?
        /// The sublocation metadata.
        public let subLocation: String?
        /// The subject reference metadata.
        public let subjectReference: [String]?
        /// The supplemental category metadata.
        public let supplementalCategory: [String]?
        /// The supply chain source metadata.
        public let supplyChainSource: Any?
        /// The supply chain source identifier.
        public let supplyChainSourceIdentifier: String?
        /// The supply chain source name.
        public let supplyChainSourceName: String?
        /// The temporal coverage metadata.
        public let temporalCoverage: String?
        /// The temporal coverage start.
        public let temporalCoverageFrom: String?
        /// The temporal coverage end.
        public let temporalCoverageTo: String?
        /// The creation time.
        public let timeCreated: String?
        /// The transcript metadata.
        public let transcript: String?
        /// The transcript link metadata.
        public let transcriptLink: String?
        /// The transcript link target.
        public let transcriptLinkLink: String?
        /// The transcript link qualifier.
        public let transcriptLinkLinkQualifier: String?
        /// The urgency metadata.
        public let urgency: Any?
        /// The usage terms metadata.
        public let usageTerms: String?
        /// The video bitrate metadata.
        public let videoBitrate: Double?
        /// The video bitrate mode.
        public let videoBitrateMode: String?
        /// The video display aspect ratio.
        public let videoDisplayAspectRatio: String?
        /// The video encoding profile.
        public let videoEncodingProfile: String?
        /// The video shot type metadata.
        public let videoShotType: Any?
        /// The video shot type identifier.
        public let videoShotTypeIdentifier: String?
        /// The video shot type name.
        public let videoShotTypeName: String?
        /// The video streams count.
        public let videoStreamsCount: Int?
        /// The visual color metadata.
        public let visualColor: Any?
        /// The workflow tag metadata.
        public let workflowTag: Any?
        /// The workflow tag CV identifier.
        public let workflowTagCvId: String?
        /// The workflow tag CV term identifier.
        public let workflowTagCvTermId: String?
        /// The workflow tag CV term name.
        public let workflowTagCvTermName: String?
        /// The refined workflow tag CV term metadata.
        public let workflowTagCvTermRefinedAbout: String?
        /// The writer or editor metadata.
        public let writerEditor: [String]?
        
        /// The creators contact info.
        public struct CreatorContactInfo {
            /// The raw values.
            public let rawValues: [CFString: Any]
            /// The address of the creator.
            public let address: String?
            /// The city of the creator.
            public let city: String?
            /// The country of the creator.
            public let country: String?
            /// The postal code of the creator.
            public let postalCode: String?
            /// The state/province of the creator.
            public let stateProvince: String?
            /// The email addresses of the creator.
            public let emailAddresses: String?
            /// The phone numbers of the creator.
            public let phoneNumbers: String?
            /// The websites of the creator.
            public let websites: String?
            
            init(rawValues: [CFString: Any]) {
                self.rawValues = rawValues
                city = rawValues[typed: kCGImagePropertyIPTCContactInfoCity]
                country = rawValues[typed: kCGImagePropertyIPTCContactInfoCountry]
                address = rawValues[typed: kCGImagePropertyIPTCContactInfoAddress]
                postalCode = rawValues[typed: kCGImagePropertyIPTCContactInfoPostalCode]
                stateProvince = rawValues[typed: kCGImagePropertyIPTCContactInfoStateProvince]
                emailAddresses = rawValues[typed: kCGImagePropertyIPTCContactInfoEmails]
                phoneNumbers = rawValues[typed: kCGImagePropertyIPTCContactInfoPhones]
                websites = rawValues[typed: kCGImagePropertyIPTCContactInfoWebURLs]
            }
        }
        
        /// Information about a location.
        public struct Location: Hashable, Sendable {
            /// A human-readable name for the location.
            public let name: String?
            /// The sublocation of the location.
            public let sublocation: String?
            /// The province or state of the location.
            public let provinceState: String?
            /// The country name of the location.
            public let country: String?
            /// The ISO country code of the location.
            public let countryCode: String?
            /// The city name of the location.
            public let city: String?
            /// The broader world region (e.g. "Europe", "Asia").
            public let worldRegion: String?
            /// The GPS latitude in decimal degrees.
            public let gpsLatitude: Double?
            /// The GPS longitude in decimal degrees.
            public let gpsLongitude: Double?
            /// The GPS altitude in decimal degrees.
            public let gpsAltitude: Double?
            /// The identifier of the location.
            public let identifier: String?
            
            /// The alternative identifier of the location.
            public let identifierAlt: String?
            
            public let countryPrimaryLocationCode: String?

             init(rawValues: [CFString: Any]) {

                self.name = rawValues[typed: kCGImagePropertyIPTCExtLocationLocationName]
                self.sublocation = rawValues[typed: kCGImagePropertyIPTCExtLocationSublocation]
                self.provinceState = rawValues[typed: kCGImagePropertyIPTCExtLocationProvinceState]
                self.country = rawValues[typed: kCGImagePropertyIPTCExtLocationCountryName]
                self.countryCode = rawValues[typed: kCGImagePropertyIPTCExtLocationCountryCode]
                 self.city = rawValues[typed: "City" as CFString]

                self.worldRegion = rawValues[typed: kCGImagePropertyIPTCExtLocationWorldRegion]
                self.gpsLatitude = rawValues[typed: kCGImagePropertyIPTCExtLocationGPSLatitude]
                self.gpsLongitude = rawValues[typed: kCGImagePropertyIPTCExtLocationGPSLongitude]
                self.gpsAltitude = rawValues[typed: kCGImagePropertyIPTCExtLocationGPSAltitude]
                self.identifier = rawValues[typed: kCGImagePropertyIPTCExtLocationIdentifier]
                self.identifierAlt = rawValues[typed: kCGImagePropertyIPTCExtLocationLocationId]
                 self.countryPrimaryLocationCode = rawValues[typed: "Country/PrimaryLocationCode" as CFString]
            }
        }
        
        public struct Artwork {
            /// The creator or artist of the artwork.
            public let creator: String?
            /// The date the artwork was created.
            public let dateCreated: String?
            /// The circa date the artwork was created.
            public let circaDateCreated: String?
            /// The source of the artwork.
            public let source: String?
            /// The copyright notice of the artwork.
            public let copyrightNotice: String?
            /// The copyright owner of the artwork.
            public let copyrightOwner: String?
            /// The copyright owne identifier of the artwork.
            public let copyrightOwnerID: String?
            /// The content description of the artwork.
            public let contentDescription: String?
            /// The inventory number assigned by the source.
            public let sourceInventoryNumber: String?
            /// The inventory URL assigned by the source.
            public let sourceInventoryURL: String?
            /// A description of the artwork’s physical appearance.
            public let physicalDescription: String?
            /// The creator’s identifier (e.g. VIAF, ULAN).
            public let creatorID: String?
            /// The style or period of the artwork.
            public let stylePeriod: String?
            /// The contribution description of the artwork.
            public let contributionDescription: String?
            /// The licensor name of the artwork.
            public let licensorName: String?
            /// The licensor ID of the artwork.
            public let licensorID: String?
            /// The raw values.
            public let rawValues: [CFString: Any]
            
            /*
             /// A unique identifier for the artwork.
             public let artworkOrObjectID: String?
             /// The title of the artwork.
             public let title: String?
             /// The current owner of the artwork.
             public let currentOwner: String?
             */
    
            public init(rawValues: [CFString: Any]) {
                self.rawValues = rawValues
                
                contentDescription = rawValues[typed: kCGImagePropertyIPTCExtArtworkContentDescription]
                creator = rawValues[typed: kCGImagePropertyIPTCExtArtworkCreator]
                creatorID = rawValues[typed: kCGImagePropertyIPTCExtArtworkCreatorID]
                source = rawValues[typed: kCGImagePropertyIPTCExtArtworkSource]
                sourceInventoryNumber = rawValues[typed: kCGImagePropertyIPTCExtArtworkSourceInventoryNo]
                sourceInventoryURL = rawValues[typed: kCGImagePropertyIPTCExtArtworkSourceInvURL]
                stylePeriod = rawValues[typed: kCGImagePropertyIPTCExtArtworkStylePeriod]
                dateCreated = rawValues[typed: kCGImagePropertyIPTCExtArtworkDateCreated]
                circaDateCreated = rawValues[typed: kCGImagePropertyIPTCExtArtworkCircaDateCreated]
                physicalDescription = rawValues[typed: kCGImagePropertyIPTCExtArtworkPhysicalDescription]
                copyrightNotice = rawValues[typed: kCGImagePropertyIPTCExtArtworkCopyrightNotice]
                copyrightOwner = rawValues[typed: kCGImagePropertyIPTCExtArtworkCopyrightOwnerName]
                copyrightOwnerID = rawValues[typed: kCGImagePropertyIPTCExtArtworkCopyrightOwnerID]
                contributionDescription = rawValues[typed: kCGImagePropertyIPTCExtArtworkContributionDescription]
                licensorName = rawValues[typed: kCGImagePropertyIPTCExtArtworkLicensorName]
                licensorID = rawValues[typed: kCGImagePropertyIPTCExtArtworkLicensorID]
            }
        }
        
        init(iptcData: [CFString: Any]) {
            rawValues = iptcData
            
            creatorContactInfo = iptcData[typed: kCGImagePropertyIPTCCreatorContactInfo].map(CreatorContactInfo.init)
            aboutCvTerm = iptcData[kCGImagePropertyIPTCExtAboutCvTerm]
            aboutCvTermCvId = iptcData[typed: kCGImagePropertyIPTCExtAboutCvTermCvId]
            aboutCvTermId = iptcData[typed: kCGImagePropertyIPTCExtAboutCvTermId]
            aboutCvTermName = iptcData[typed: kCGImagePropertyIPTCExtAboutCvTermName]
            aboutCvTermRefinedAbout = iptcData[typed: kCGImagePropertyIPTCExtAboutCvTermRefinedAbout]
            actionAdvised = iptcData[kCGImagePropertyIPTCActionAdvised]
            addlModelInfo = iptcData[typed: kCGImagePropertyIPTCExtAddlModelInfo]
            
            if let _artworks: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtArtworkOrObject] {
                artworks = _artworks.map(Artwork.init)
            } else {
                artworks = []
            }
          
            audioBitrate = iptcData[kCGImagePropertyIPTCExtAudioBitrate]
            audioBitrateMode = iptcData[typed: kCGImagePropertyIPTCExtAudioBitrateMode]
            audioChannelCount = iptcData[typed: kCGImagePropertyIPTCExtAudioChannelCount]
            byline = iptcData[typed: kCGImagePropertyIPTCByline]
            bylineTitle = iptcData[typed: kCGImagePropertyIPTCBylineTitle]
            captionAbstract = iptcData[typed: kCGImagePropertyIPTCCaptionAbstract]
            category = iptcData[typed: kCGImagePropertyIPTCCategory]
            circaDateCreated = iptcData[typed: kCGImagePropertyIPTCExtCircaDateCreated]
            city = iptcData[typed: kCGImagePropertyIPTCCity]
            contact = iptcData[typed: kCGImagePropertyIPTCContact]
            containerFormat = iptcData[typed: kCGImagePropertyIPTCExtContainerFormat]
            containerFormatIdentifier = iptcData[typed: kCGImagePropertyIPTCExtContainerFormatIdentifier]
            containerFormatName = iptcData[typed: kCGImagePropertyIPTCExtContainerFormatName]
            contentLocationCode = iptcData[typed: kCGImagePropertyIPTCContentLocationCode]
            contentLocationName = iptcData[typed: kCGImagePropertyIPTCContentLocationName]
            contributor = iptcData[kCGImagePropertyIPTCExtContributor]
            contributorIdentifier = iptcData[kCGImagePropertyIPTCExtContributorIdentifier]
            contributorName = iptcData[kCGImagePropertyIPTCExtContributorName]
            contributorRole = iptcData[kCGImagePropertyIPTCExtContributorRole]
            controlledVocabularyTerm = iptcData[kCGImagePropertyIPTCExtControlledVocabularyTerm]
            copyrightNotice = iptcData[typed: kCGImagePropertyIPTCCopyrightNotice]
            copyrightYear = iptcData[typed: kCGImagePropertyIPTCExtCopyrightYear]
            countryPrimaryLocationCode = iptcData[typed: kCGImagePropertyIPTCCountryPrimaryLocationCode]
            countryPrimaryLocationName = iptcData[typed: kCGImagePropertyIPTCCountryPrimaryLocationName]
            creator = iptcData[kCGImagePropertyIPTCExtCreator]
            creatorIdentifier = iptcData[typed: kCGImagePropertyIPTCExtCreatorIdentifier]
            creatorName = iptcData[typed: kCGImagePropertyIPTCExtCreatorName]
            creatorRole = iptcData[typed: kCGImagePropertyIPTCExtCreatorRole]
            credit = iptcData[typed: kCGImagePropertyIPTCCredit]
            dataOnScreen = iptcData[typed: kCGImagePropertyIPTCExtDataOnScreen]
            dataOnScreenRegion = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegion]
            dataOnScreenRegionD = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionD]
            dataOnScreenRegionH = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionH]
            dataOnScreenRegionText = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionText]
            dataOnScreenRegionUnit = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionUnit]
            dataOnScreenRegionW = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionW]
            dataOnScreenRegionX = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionX]
            dataOnScreenRegionY = iptcData[kCGImagePropertyIPTCExtDataOnScreenRegionY]
            dateCreated = iptcData[typed: kCGImagePropertyIPTCDateCreated]
            digitalCreationDate = iptcData[typed: kCGImagePropertyIPTCDigitalCreationDate]
            digitalCreationTime = iptcData[typed: kCGImagePropertyIPTCDigitalCreationTime]
            digitalImageGUID = iptcData[typed: kCGImagePropertyIPTCExtDigitalImageGUID]
            digitalSourceFileType = iptcData[typed: kCGImagePropertyIPTCExtDigitalSourceFileType]
            digitalSourceType = iptcData[typed: kCGImagePropertyIPTCExtDigitalSourceType]
            dopesheet = iptcData[typed: kCGImagePropertyIPTCExtDopesheet]
            dopesheetLink = iptcData[typed: kCGImagePropertyIPTCExtDopesheetLink]
            dopesheetLinkLink = iptcData[typed: kCGImagePropertyIPTCExtDopesheetLinkLink]
            dopesheetLinkLinkQualifier = iptcData[typed: kCGImagePropertyIPTCExtDopesheetLinkLinkQualifier]
            editStatus = iptcData[typed: kCGImagePropertyIPTCEditStatus]
            editorialUpdate = iptcData[typed: kCGImagePropertyIPTCEditorialUpdate]
            embdEncRightsExpr = iptcData[typed: kCGImagePropertyIPTCExtEmbdEncRightsExpr]
            embeddedEncodedRightsExpr = iptcData[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExpr]
            embeddedEncodedRightsExprLangID = iptcData[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprLangID]
            embeddedEncodedRightsExprType = iptcData[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprType]
            episode = iptcData[kCGImagePropertyIPTCExtEpisode]
            episodeIdentifier = iptcData[typed: kCGImagePropertyIPTCExtEpisodeIdentifier]
            episodeName = iptcData[typed: kCGImagePropertyIPTCExtEpisodeName]
            episodeNumber = iptcData[kCGImagePropertyIPTCExtEpisodeNumber]
            event = iptcData[kCGImagePropertyIPTCExtEvent]
            expirationDate = iptcData[typed: kCGImagePropertyIPTCExpirationDate]
            expirationTime = iptcData[typed: kCGImagePropertyIPTCExpirationTime]
            externalMetadataLink = iptcData[typed: kCGImagePropertyIPTCExtExternalMetadataLink]
            feedIdentifier = iptcData[typed: kCGImagePropertyIPTCExtFeedIdentifier]
            fixtureIdentifier = iptcData[kCGImagePropertyIPTCFixtureIdentifier]

            genre = iptcData[kCGImagePropertyIPTCExtGenre]
            genreCvId = iptcData[typed: kCGImagePropertyIPTCExtGenreCvId]
            genreCvTermId = iptcData[typed: kCGImagePropertyIPTCExtGenreCvTermId]
            genreCvTermName = iptcData[typed: kCGImagePropertyIPTCExtGenreCvTermName]
            genreCvTermRefinedAbout = iptcData[typed: kCGImagePropertyIPTCExtGenreCvTermRefinedAbout]
            headline = iptcData[typed: kCGImagePropertyIPTCHeadline]
            iPTCLastEdited = iptcData[typed: kCGImagePropertyIPTCExtIPTCLastEdited]
            
            orientation = iptcData[typed: kCGImagePropertyIPTCImageOrientation]
            imageType = iptcData[kCGImagePropertyIPTCImageType]
            keywords = iptcData[typed: kCGImagePropertyIPTCKeywords]
            languageIdentifier = iptcData[typed: kCGImagePropertyIPTCLanguageIdentifier]
            linkedEncRightsExpr = iptcData[typed: kCGImagePropertyIPTCExtLinkedEncRightsExpr]
            linkedEncodedRightsExpr = iptcData[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExpr]
            linkedEncodedRightsExprLangID = iptcData[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExprLangID]
            linkedEncodedRightsExprType = iptcData[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExprType]
            
            if let locations: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtLocationCreated] {
                locationsCreated = locations.map(Location.init(rawValues:))
            } else {
                locationsCreated = nil
            }
            if let locations: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtLocationShown] {
               locationsShown = locations.map(Location.init(rawValues:))
            } else {
                locationsShown = nil
            }

            maxAvailHeight = iptcData[typed: kCGImagePropertyIPTCExtMaxAvailHeight]
            maxAvailWidth = iptcData[typed: kCGImagePropertyIPTCExtMaxAvailWidth]
            modelAge = iptcData[typed: kCGImagePropertyIPTCExtModelAge]
            objectAttributeReference = iptcData[kCGImagePropertyIPTCObjectAttributeReference]
            objectCycle = iptcData[typed: kCGImagePropertyIPTCObjectCycle]
            objectName = iptcData[typed: kCGImagePropertyIPTCObjectName]
            objectTypeReference = iptcData[typed: kCGImagePropertyIPTCObjectTypeReference]
            
            organisationInImageCode = iptcData[typed: kCGImagePropertyIPTCExtOrganisationInImageCode]
            organisationInImageName = iptcData[typed: kCGImagePropertyIPTCExtOrganisationInImageName]
            
            
            originalTransmissionReference = iptcData[typed: kCGImagePropertyIPTCOriginalTransmissionReference]
            originatingProgram = iptcData[typed: kCGImagePropertyIPTCOriginatingProgram]
            personHeard = iptcData[kCGImagePropertyIPTCExtPersonHeard]
            personHeardIdentifier = iptcData[typed: kCGImagePropertyIPTCExtPersonHeardIdentifier]
            personHeardName = iptcData[typed: kCGImagePropertyIPTCExtPersonHeardName]
            personInImage = iptcData[kCGImagePropertyIPTCExtPersonInImage]
            personInImageCharacteristic = iptcData[kCGImagePropertyIPTCExtPersonInImageCharacteristic]
            personInImageCvTermCvId = iptcData[kCGImagePropertyIPTCExtPersonInImageCvTermCvId]
            personInImageCvTermId = iptcData[kCGImagePropertyIPTCExtPersonInImageCvTermId]
            personInImageCvTermName = iptcData[kCGImagePropertyIPTCExtPersonInImageCvTermName]
            personInImageCvTermRefinedAbout = iptcData[kCGImagePropertyIPTCExtPersonInImageCvTermRefinedAbout]
            personInImageDescription = iptcData[typed: kCGImagePropertyIPTCExtPersonInImageDescription]
            personInImageId = iptcData[typed: kCGImagePropertyIPTCExtPersonInImageId]
            personInImageName = iptcData[typed: kCGImagePropertyIPTCExtPersonInImageName]
            personInImageWDetails = iptcData[kCGImagePropertyIPTCExtPersonInImageWDetails]
            productInImage = iptcData[kCGImagePropertyIPTCExtProductInImage]
            productInImageDescription = iptcData[typed: kCGImagePropertyIPTCExtProductInImageDescription]
            productInImageGTIN = iptcData[typed: kCGImagePropertyIPTCExtProductInImageGTIN]
            productInImageName = iptcData[typed: kCGImagePropertyIPTCExtProductInImageName]
            programVersion = iptcData[typed: kCGImagePropertyIPTCProgramVersion]
            provinceOrState = iptcData[typed: kCGImagePropertyIPTCProvinceState]
            publicationEvent = iptcData[kCGImagePropertyIPTCExtPublicationEvent]
            publicationEventDate = iptcData[typed: kCGImagePropertyIPTCExtPublicationEventDate]
            publicationEventIdentifier = iptcData[typed: kCGImagePropertyIPTCExtPublicationEventIdentifier]
            publicationEventName = iptcData[typed: kCGImagePropertyIPTCExtPublicationEventName]
            rating = iptcData[kCGImagePropertyIPTCExtRating]
            ratingRatingRegion = iptcData[kCGImagePropertyIPTCExtRatingRatingRegion]
            ratingRegionCity = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionCity]
            ratingRegionCountryCode = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionCountryCode]
            ratingRegionCountryName = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionCountryName]
            ratingRegionGPSAltitude = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionGPSAltitude]
            ratingRegionGPSLatitude = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionGPSLatitude]
            ratingRegionGPSLongitude = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionGPSLongitude]
            ratingRegionIdentifier = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionIdentifier]
            ratingRegionLocationId = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionLocationId]
            ratingRegionLocationName = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionLocationName]
            ratingRegionProvinceState = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionProvinceState]
            ratingRegionSublocation = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionSublocation]
            ratingRegionWorldRegion = iptcData[typed: kCGImagePropertyIPTCExtRatingRegionWorldRegion]
            ratingScaleMaxValue = iptcData[typed: kCGImagePropertyIPTCExtRatingScaleMaxValue]
            ratingScaleMinValue = iptcData[typed: kCGImagePropertyIPTCExtRatingScaleMinValue]
            ratingSourceLink = iptcData[typed: kCGImagePropertyIPTCExtRatingSourceLink]
            ratingValue = iptcData[typed: kCGImagePropertyIPTCExtRatingValue]
            ratingValueLogoLink = iptcData[typed: kCGImagePropertyIPTCExtRatingValueLogoLink]
            referenceDate = iptcData[typed: kCGImagePropertyIPTCReferenceDate]
            referenceNumber = iptcData[kCGImagePropertyIPTCReferenceNumber]
            referenceService = iptcData[kCGImagePropertyIPTCReferenceService]
            registryEntryRole = iptcData[typed: kCGImagePropertyIPTCExtRegistryEntryRole]
            registryID = iptcData[typed: kCGImagePropertyIPTCExtRegistryID]
            registryItemID = iptcData[typed: kCGImagePropertyIPTCExtRegistryItemID]
            registryOrganisationID = iptcData[typed: kCGImagePropertyIPTCExtRegistryOrganisationID]
            releaseDate = iptcData[typed: kCGImagePropertyIPTCReleaseDate]
            releaseReady = iptcData[kCGImagePropertyIPTCExtReleaseReady]
            releaseTime = iptcData[typed: kCGImagePropertyIPTCReleaseTime]
            scene = iptcData[typed: kCGImagePropertyIPTCScene]
            season = iptcData[kCGImagePropertyIPTCExtSeason]
            seasonIdentifier = iptcData[typed: kCGImagePropertyIPTCExtSeasonIdentifier]
            seasonName = iptcData[typed: kCGImagePropertyIPTCExtSeasonName]
            seasonNumber = iptcData[typed: kCGImagePropertyIPTCExtSeasonNumber]
            series = iptcData[kCGImagePropertyIPTCExtSeries]
            seriesIdentifier = iptcData[typed: kCGImagePropertyIPTCExtSeriesIdentifier]
            seriesName = iptcData[typed: kCGImagePropertyIPTCExtSeriesName]
            shownEvent = iptcData[kCGImagePropertyIPTCExtShownEvent]
            shownEventIdentifier = iptcData[typed: kCGImagePropertyIPTCExtShownEventIdentifier]
            shownEventName = iptcData[typed: kCGImagePropertyIPTCExtShownEventName]
            source = iptcData[typed: kCGImagePropertyIPTCSource]
            specialInstructions = iptcData[typed: kCGImagePropertyIPTCSpecialInstructions]
            starRating = iptcData[typed: kCGImagePropertyIPTCStarRating]
            storylineIdentifier = iptcData[typed: kCGImagePropertyIPTCExtStorylineIdentifier]
            streamReady = iptcData[kCGImagePropertyIPTCExtStreamReady]
            stylePeriod = iptcData[typed: kCGImagePropertyIPTCExtStylePeriod]
            subLocation = iptcData[typed: kCGImagePropertyIPTCSubLocation]
            subjectReference = iptcData[typed: kCGImagePropertyIPTCSubjectReference]
            supplementalCategory = iptcData[typed: kCGImagePropertyIPTCSupplementalCategory]
            timeCreated = iptcData[typed: kCGImagePropertyIPTCTimeCreated]
            urgency = iptcData[kCGImagePropertyIPTCUrgency]
            usageTerms = iptcData[typed: kCGImagePropertyIPTCRightsUsageTerms]
            writerEditor = iptcData[typed: kCGImagePropertyIPTCWriterEditor]
            
            supplyChainSource = iptcData[kCGImagePropertyIPTCExtSupplyChainSource]
            supplyChainSourceIdentifier = iptcData[typed: kCGImagePropertyIPTCExtSupplyChainSourceIdentifier]
            supplyChainSourceName = iptcData[typed: kCGImagePropertyIPTCExtSupplyChainSourceName]
            temporalCoverage = iptcData[typed: kCGImagePropertyIPTCExtTemporalCoverage]
            temporalCoverageFrom = iptcData[typed: kCGImagePropertyIPTCExtTemporalCoverageFrom]
            temporalCoverageTo = iptcData[typed: kCGImagePropertyIPTCExtTemporalCoverageTo]

            
            transcript = iptcData[typed: kCGImagePropertyIPTCExtTranscript]
            transcriptLink = iptcData[typed: kCGImagePropertyIPTCExtTranscriptLink]
            transcriptLinkLink = iptcData[typed: kCGImagePropertyIPTCExtTranscriptLinkLink]
            transcriptLinkLinkQualifier = iptcData[typed: kCGImagePropertyIPTCExtTranscriptLinkLinkQualifier]

            videoBitrate = iptcData[typed: kCGImagePropertyIPTCExtVideoBitrate]
            videoBitrateMode = iptcData[typed: kCGImagePropertyIPTCExtVideoBitrateMode]
            videoDisplayAspectRatio = iptcData[typed: kCGImagePropertyIPTCExtVideoDisplayAspectRatio]
            videoEncodingProfile = iptcData[typed: kCGImagePropertyIPTCExtVideoEncodingProfile]
            videoShotType = iptcData[kCGImagePropertyIPTCExtVideoShotType]
            videoShotTypeIdentifier = iptcData[typed: kCGImagePropertyIPTCExtVideoShotTypeIdentifier]
            videoShotTypeName = iptcData[typed: kCGImagePropertyIPTCExtVideoShotTypeName]
            videoStreamsCount = iptcData[typed: kCGImagePropertyIPTCExtVideoStreamsCount]
            visualColor = iptcData[kCGImagePropertyIPTCExtVisualColor]
            workflowTag = iptcData[kCGImagePropertyIPTCExtWorkflowTag]
            workflowTagCvId = iptcData[typed: kCGImagePropertyIPTCExtWorkflowTagCvId]
            workflowTagCvTermId = iptcData[typed: kCGImagePropertyIPTCExtWorkflowTagCvTermId]
            workflowTagCvTermName = iptcData[typed: kCGImagePropertyIPTCExtWorkflowTagCvTermName]
            workflowTagCvTermRefinedAbout = iptcData[typed: kCGImagePropertyIPTCExtWorkflowTagCvTermRefinedAbout]
        }

    }
}
