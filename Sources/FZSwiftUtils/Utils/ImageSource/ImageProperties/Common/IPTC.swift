//
//  IPTC.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct IPTC {
        /// The raw values.
        public let rawValue: [CFString: Any]

        /// The artworks of the image.
        public let artworks: [Artwork]
        
        /// The action advised metadata.
        public let actionAdvised: [String]?
        /// The additional model information.
        public let additionalModelInfo: String?
        
        /// The audio bitrate metadata.
        public let audioBitrate: Double?
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
        public let containerFormats: [ContainerFormat]?
        /// The content location code.
        public let contentLocationCode: [String]?
        /// The content location name.
        public let contentLocationName: [String]?
        /// The contributor metadata.
        public let contributors: [Contributor]?
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
        public let creators: [Creator]?
        /// The creator contact information.
        public let creatorContactInfo: CreatorContactInfo?
        /// The credit metadata.
        public let credit: String?
        /// The data-on-screen metadata.
        public let dataOnScreen: [TextRegion]?
        /// The creation date.
        public let dateCreated: Date?
        /// The digital creation date.
        public let digitalCreationDate: Date?
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
        public let dopesheetLinks: [DopesheetLink]?
        /// The edit status.
        public let editStatus: String?
        /// The editorial update metadata.
        public let editorialUpdate: String?
        /// The embedded encoded rights expression metadata.
        public let embeddedEncodedRightsExpr: String?
        /// The embedded encoded rights expression language identifier.
        public let embeddedEncodedRightsExprLangID: String?
        /// The embedded encoded rights expression type.
        public let embeddedEncodedRightsExprType: String?
        /// The episode metadata.
        public let episodes: [Episode]?
        /// The event metadata.
        public let event: String?
        /// The expiration date.
        public let expirationDate: Date?
        /// The expiration time.
        public let expirationTime: String?
        /// The external metadata link.
        public let externalMetadataLink: String?
        /// The feed identifier.
        public let feedIdentifier: String?
        /// The fixture identifier.
        public let fixtureIdentifier: [String]?
        /// The genre metadata.
        public let genres: [CVTermDetails]?
        /// The headline metadata.
        public let headline: String?
        /// The IPTC last edited metadata.
        public let iPTCLastEdited: String?
        /// The orientation of the IPTC image.
        public let orientation: CGImagePropertyOrientation?
        /// The image type metadata.
        public let imageType: [String]?
        /// The keywords metadata.
        public let keywords: [String]?
        /// The language identifier.
        public let languageIdentifier: String?
        /// The created location metadata.
        public let locationsCreated: [Location]?
        /// The shown location metadata.
        public let locationsShown: [Location]?
        /// The maximum available height.
        public let maxAvailHeight: Int?
        /// The maximum available width.
        public let maxAvailWidth: Int?
        /// The model age metadata.
        public let modelAge: [Int]?
        /// The object attribute reference.
        public let objectAttributeReference: [String]?
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
        public let personHeard: [PersonHeard]?
        /// The person-in-image metadata.
        public let personsInImage: [String]?
        /// The detailed person-in-image metadata.
        public let personsInImageDetails: [PersonInImage]?
        
        /// The product-in-image metadata.
        public let productsInImage: [ProductInImage]?
        /// The program version.
        public let programVersion: String?
        /// The province or state metadata.
        public let provinceOrState: String?
        /// The publication event metadata.
        public let publicationEvents: [PublicationEvent]?
        /// The rating metadata.
        public let ratings: [Rating]?
        /// The reference date.
        public let referenceDate: Date?
        /// The reference number.
        public let referenceNumber: Any?
        /// The reference service.
        public let referenceService: Any?
        /// The registry entry role.
        public let registryEntryRole: String?
        /// The release date.
        public let releaseDate: Date?
        /// The release-ready metadata.
        public let isReleaseReady: Bool?
        /// The release time.
        public let releaseTime: String?
        /// The scene metadata.
        public let scene: [String]?
        /// The season metadata.
        public let seasons: [Season]?
        /// The series metadata.
        public let series: [Series]?
        /// The shown event metadata.
        public let shownEvents: [ShownEvent]?
        /// The source metadata.
        public let source: String?
        /// The special instructions.
        public let specialInstructions: String?
        /// The star rating metadata.
        public let starRating: Double?
        /// The storyline identifier.
        public let storylineIdentifier: String?
        /// The stream-ready metadata.
        public let isStreamReady: Bool?
        /// The style period metadata.
        public let stylePeriod: String?
        /// The sublocation metadata.
        public let subLocation: String?
        /// The subject reference metadata.
        public let subjectReference: [String]?
        /// The supplemental category metadata.
        public let supplementalCategory: [String]?
        /// The supply chain source metadata.
        public let supplyChainSources: [SupplyChainSource]?
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
        public let transcriptLinks: [TranscriptLink]?
        /// The urgency metadata.
        public let urgency: String?
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
        public let videoShotTypes: [VideoShotType]?
        /// The video streams count.
        public let videoStreamsCount: Int?
        /// The visual color metadata.
        public let visualColor: String?
        /// The workflow tag metadata.
        public let workflowTags: [CVTermDetails]?
        /// The writer or editor metadata.
        public let writerEditor: [String]?
        /// The registry entries describing controlled vocabulary items and their defining organizations associated with the image metadata.
        public let registryEntries: [RegistryEntry]?
        /// The encoded rights expressions embedded directly within the image metadata.
        public let embeddedExpressions: [EncodedRightsExpression]?
        /// The encoded rights expressions referenced externally by the image metadata.
        public let linkedExpressions: [EncodedRightsExpression]?
        /// The controlled vocabulary terms describing what the image is about.
        public let aboutTerms: [CVTermDetails]?
        
        init(iptcData: [CFString: Any]) {
            rawValue = iptcData
            
            creatorContactInfo = iptcData[typed: kCGImagePropertyIPTCCreatorContactInfo].map(CreatorContactInfo.init)
                        
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtAboutCvTerm] {
                aboutTerms = values.map({CVTermDetails(rawValue: $0, type: "About")})
            } else {
                aboutTerms = nil
            }
            
            actionAdvised = iptcData[typed: kCGImagePropertyIPTCActionAdvised]
            additionalModelInfo = iptcData[typed: kCGImagePropertyIPTCExtAddlModelInfo]
            if let _artworks: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtArtworkOrObject] {
                artworks = _artworks.map(Artwork.init)
            } else {
                artworks = []
            }
          
            audioBitrate = iptcData[typed: kCGImagePropertyIPTCExtAudioBitrate]
            audioBitrateMode = iptcData[typed: kCGImagePropertyIPTCExtAudioBitrateMode]
            audioChannelCount = iptcData[typed: kCGImagePropertyIPTCExtAudioChannelCount]
            byline = iptcData[typed: kCGImagePropertyIPTCByline]
            bylineTitle = iptcData[typed: kCGImagePropertyIPTCBylineTitle]
            captionAbstract = iptcData[typed: kCGImagePropertyIPTCCaptionAbstract]
            category = iptcData[typed: kCGImagePropertyIPTCCategory]
            circaDateCreated = iptcData[typed: kCGImagePropertyIPTCExtCircaDateCreated]
            city = iptcData[typed: kCGImagePropertyIPTCCity]
            contact = iptcData[typed: kCGImagePropertyIPTCContact]
            if let formats: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtContainerFormat] {
               containerFormats = formats.map(ContainerFormat.init)
            } else {
                containerFormats = nil
            }
            contentLocationCode = iptcData[typed: kCGImagePropertyIPTCContentLocationCode]
            contentLocationName = iptcData[typed: kCGImagePropertyIPTCContentLocationName]
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtContributor] {
                contributors = values.map(Contributor.init)
            } else {
                contributors = nil
            }
            controlledVocabularyTerm = iptcData[kCGImagePropertyIPTCExtControlledVocabularyTerm]
            copyrightNotice = iptcData[typed: kCGImagePropertyIPTCCopyrightNotice]
            copyrightYear = iptcData[typed: kCGImagePropertyIPTCExtCopyrightYear]
            countryPrimaryLocationCode = iptcData[typed: kCGImagePropertyIPTCCountryPrimaryLocationCode]
            countryPrimaryLocationName = iptcData[typed: kCGImagePropertyIPTCCountryPrimaryLocationName]
            if let value: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtCreator] {
               creators = value.map(Creator.init)
            } else {
                creators = nil
            }
            credit = iptcData[typed: kCGImagePropertyIPTCCredit]
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtDataOnScreen] {
               dataOnScreen = values.map(TextRegion.init)
            } else {
                dataOnScreen = nil
            }
            dateCreated = iptcData[typed: kCGImagePropertyIPTCDateCreated, using: ImageProperties.dateFormatter]
            digitalCreationDate = iptcData[typed: kCGImagePropertyIPTCDigitalCreationDate, using: ImageProperties.dateFormatter]
            digitalCreationTime = iptcData[typed: kCGImagePropertyIPTCDigitalCreationTime]
            digitalImageGUID = iptcData[typed: kCGImagePropertyIPTCExtDigitalImageGUID]
            digitalSourceFileType = iptcData[typed: kCGImagePropertyIPTCExtDigitalSourceFileType]
            digitalSourceType = iptcData[typed: kCGImagePropertyIPTCExtDigitalSourceType]
            dopesheet = iptcData[typed: kCGImagePropertyIPTCExtDopesheet]
            if let links: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtDopesheetLink] {
               dopesheetLinks = links.map(DopesheetLink.init)
            } else {
                dopesheetLinks = nil
            }
            editStatus = iptcData[typed: kCGImagePropertyIPTCEditStatus]
            editorialUpdate = iptcData[typed: kCGImagePropertyIPTCEditorialUpdate]
            embeddedEncodedRightsExpr = iptcData[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExpr]
            embeddedEncodedRightsExprLangID = iptcData[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprLangID]
            embeddedEncodedRightsExprType = iptcData[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprType]
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtEpisode] {
               episodes = values.map(Episode.init)
            } else {
                episodes = nil
            }
            event = iptcData[typed: kCGImagePropertyIPTCExtEvent]
            expirationDate = iptcData[typed: kCGImagePropertyIPTCExpirationDate, using: ImageProperties.dateFormatter]
            expirationTime = iptcData[typed: kCGImagePropertyIPTCExpirationTime]
            externalMetadataLink = iptcData[typed: kCGImagePropertyIPTCExtExternalMetadataLink]
            feedIdentifier = iptcData[typed: kCGImagePropertyIPTCExtFeedIdentifier]
            fixtureIdentifier = iptcData[typed: kCGImagePropertyIPTCFixtureIdentifier]

            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtGenre] {
                genres = values.map({CVTermDetails(rawValue: $0, type: "Genre")})
            } else {
                genres = nil
            }
            headline = iptcData[typed: kCGImagePropertyIPTCHeadline]
            iPTCLastEdited = iptcData[typed: kCGImagePropertyIPTCExtIPTCLastEdited]
            
            orientation = iptcData[typed: kCGImagePropertyIPTCImageOrientation]
            imageType = iptcData[typed: kCGImagePropertyIPTCImageType]
            keywords = iptcData[typed: kCGImagePropertyIPTCKeywords]
            languageIdentifier = iptcData[typed: kCGImagePropertyIPTCLanguageIdentifier]
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtLinkedEncRightsExpr] {
               linkedExpressions = values.map(EncodedRightsExpression.init(rawValue:))
            } else {
                linkedExpressions = nil
            }
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtEmbdEncRightsExpr] {
                embeddedExpressions = values.map(EncodedRightsExpression.init(rawValue:))
            } else {
                embeddedExpressions = nil
            }
                        
            if let locations: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtLocationCreated] {
                locationsCreated = locations.map({Location(rawValue: $0)})
            } else {
                locationsCreated = nil
            }
            if let locations: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtLocationShown] {
               locationsShown = locations.map({Location(rawValue: $0)})
            } else {
                locationsShown = nil
            }

            maxAvailHeight = iptcData[typed: kCGImagePropertyIPTCExtMaxAvailHeight]
            maxAvailWidth = iptcData[typed: kCGImagePropertyIPTCExtMaxAvailWidth]
            modelAge = iptcData[typed: kCGImagePropertyIPTCExtModelAge]
            objectAttributeReference = iptcData[typed: kCGImagePropertyIPTCObjectAttributeReference]
            objectCycle = iptcData[typed: kCGImagePropertyIPTCObjectCycle]
            objectName = iptcData[typed: kCGImagePropertyIPTCObjectName]
            objectTypeReference = iptcData[typed: kCGImagePropertyIPTCObjectTypeReference]
            
            organisationInImageCode = iptcData[typed: kCGImagePropertyIPTCExtOrganisationInImageCode]
            organisationInImageName = iptcData[typed: kCGImagePropertyIPTCExtOrganisationInImageName]
            
            originalTransmissionReference = iptcData[typed: kCGImagePropertyIPTCOriginalTransmissionReference]
            originatingProgram = iptcData[typed: kCGImagePropertyIPTCOriginatingProgram]
            
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtPersonHeard] {
               personHeard = values.map(PersonHeard.init)
            } else {
                personHeard = nil
            }
            
            personsInImage = iptcData[typed: kCGImagePropertyIPTCExtPersonInImage]
            if let personDetails: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtPersonInImageWDetails] {
              personsInImageDetails = personDetails.map(PersonInImage.init)
            } else {
                personsInImageDetails = nil
            }
           
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtProductInImage] {
               productsInImage = values.map(ProductInImage.init)
            } else {
                productsInImage = nil
            }

            programVersion = iptcData[typed: kCGImagePropertyIPTCProgramVersion]
            provinceOrState = iptcData[typed: kCGImagePropertyIPTCProvinceState]
            if let events: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtPublicationEvent] {
                publicationEvents = events.map(PublicationEvent.init)
            } else {
                publicationEvents = nil
            }
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtRating] {
                ratings = values.map(Rating.init)
            } else {
                ratings = nil
            }
            referenceDate = iptcData[typed: kCGImagePropertyIPTCReferenceDate, using: ImageProperties.dateFormatter]
            referenceNumber = iptcData[kCGImagePropertyIPTCReferenceNumber]
            referenceService = iptcData[kCGImagePropertyIPTCReferenceService]
            registryEntryRole = iptcData[typed: kCGImagePropertyIPTCExtRegistryEntryRole]
            if let entries: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtRegistryID] {
                 registryEntries = entries.map(RegistryEntry.init)
            } else {
                registryEntries = nil
            }
            releaseDate = iptcData[typed: kCGImagePropertyIPTCReleaseDate, using: ImageProperties.dateFormatter]
            isReleaseReady = iptcData[typed: kCGImagePropertyIPTCExtReleaseReady]
            releaseTime = iptcData[typed: kCGImagePropertyIPTCReleaseTime]
            scene = iptcData[typed: kCGImagePropertyIPTCScene]
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtSeason] {
                seasons = values.map(Season.init)
            } else {
                seasons = nil
            }
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtSeries] {
                series = values.map(Series.init)
            } else {
                series = nil
            }
            if let events: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtShownEvent] {
                shownEvents = events.map(ShownEvent.init)
            } else {
                shownEvents = nil
            }
            source = iptcData[typed: kCGImagePropertyIPTCSource]
            specialInstructions = iptcData[typed: kCGImagePropertyIPTCSpecialInstructions]
            starRating = iptcData[typed: kCGImagePropertyIPTCStarRating]
            storylineIdentifier = iptcData[typed: kCGImagePropertyIPTCExtStorylineIdentifier]
            isStreamReady = iptcData[typed: kCGImagePropertyIPTCExtStreamReady]
            stylePeriod = iptcData[typed: kCGImagePropertyIPTCExtStylePeriod]
            subLocation = iptcData[typed: kCGImagePropertyIPTCSubLocation]
            subjectReference = iptcData[typed: kCGImagePropertyIPTCSubjectReference]
            supplementalCategory = iptcData[typed: kCGImagePropertyIPTCSupplementalCategory]
            timeCreated = iptcData[typed: kCGImagePropertyIPTCTimeCreated]
            urgency = iptcData[typed: kCGImagePropertyIPTCUrgency]
            usageTerms = iptcData[typed: kCGImagePropertyIPTCRightsUsageTerms]
            writerEditor = iptcData[typed: kCGImagePropertyIPTCWriterEditor]
          
            if let sources: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtSupplyChainSource] {
               supplyChainSources = sources.map(SupplyChainSource.init)
            } else {
                supplyChainSources = nil
            }
 
            temporalCoverage = iptcData[typed: kCGImagePropertyIPTCExtTemporalCoverage]
            temporalCoverageFrom = iptcData[typed: kCGImagePropertyIPTCExtTemporalCoverageFrom]
            temporalCoverageTo = iptcData[typed: kCGImagePropertyIPTCExtTemporalCoverageTo]
            
            transcript = iptcData[typed: kCGImagePropertyIPTCExtTranscript]
            if let links: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtTranscriptLink] {
               transcriptLinks = links.map(TranscriptLink.init)
            } else {
                transcriptLinks = nil
            }
            videoBitrate = iptcData[typed: kCGImagePropertyIPTCExtVideoBitrate]
            videoBitrateMode = iptcData[typed: kCGImagePropertyIPTCExtVideoBitrateMode]
            videoDisplayAspectRatio = iptcData[typed: kCGImagePropertyIPTCExtVideoDisplayAspectRatio]
            videoEncodingProfile = iptcData[typed: kCGImagePropertyIPTCExtVideoEncodingProfile]
            if let values: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtVideoShotType] {
               videoShotTypes = values.map(VideoShotType.init)
            } else {
                videoShotTypes = nil
            }
            videoStreamsCount = iptcData[typed: kCGImagePropertyIPTCExtVideoStreamsCount]
            visualColor = iptcData[typed: kCGImagePropertyIPTCExtVisualColor]
            if let tags: [[CFString: Any]] = iptcData[typed: kCGImagePropertyIPTCExtWorkflowTag] {
                workflowTags = tags.map({CVTermDetails(rawValue: $0, type: "WorkflowTag")})
            } else {
                workflowTags = nil
            }
        }

    }
}

extension ImageProperties.IPTC {
    /// The creators contact info.
    public struct CreatorContactInfo {
        /// The raw values.
        public let rawValue: [CFString: Any]
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
        
        init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            city = rawValue[typed: kCGImagePropertyIPTCContactInfoCity]
            country = rawValue[typed: kCGImagePropertyIPTCContactInfoCountry]
            address = rawValue[typed: kCGImagePropertyIPTCContactInfoAddress]
            postalCode = rawValue[typed: kCGImagePropertyIPTCContactInfoPostalCode]
            stateProvince = rawValue[typed: kCGImagePropertyIPTCContactInfoStateProvince]
            emailAddresses = rawValue[typed: kCGImagePropertyIPTCContactInfoEmails]
            phoneNumbers = rawValue[typed: kCGImagePropertyIPTCContactInfoPhones]
            websites = rawValue[typed: kCGImagePropertyIPTCContactInfoWebURLs]
        }
    }
    
    /// Information about a location.
    public struct Location: Hashable, Sendable {
        /// A human-readable name for the location.
        public let name: [String]?
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
        public let gpsLatitude: String?
        /// The GPS longitude in decimal degrees.
        public let gpsLongitude: String?
        /// The GPS altitude in decimal degrees.
        public let gpsAltitude: String?
        /// The identifier of the location.
        public let identifiers: [String]?
        
        /// The alternative identifier of the location.
        public let locationIDs: [String]?
        
        public let countryPrimaryLocationCode: String?
                
        init(rawValue: [CFString: Any], isRating: Bool = false) {
            let rating = (isRating ? "RatingRegion" : "") as CFString
            city = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionCity]
            countryCode = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionCountryCode]
            country = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionCountryName]
            gpsAltitude = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionGPSAltitude]
            gpsLatitude = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionGPSLatitude]
            gpsLongitude = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionGPSLongitude]
            identifiers = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionIdentifier]
            locationIDs = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionLocationId]
            name = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionLocationName]
            provinceState = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionProvinceState]
            sublocation = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionSublocation]
            worldRegion = rawValue[typed: rating + kCGImagePropertyIPTCExtRatingRegionWorldRegion]
            countryPrimaryLocationCode = rawValue[typed: rating + ("Country/PrimaryLocationCode" as CFString)]
        }
    }
    
    public struct Artwork {
        /// The creator or artist of the artwork.
        public let creator: String?
        /// The date the artwork was created.
        public let dateCreated: Date?
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
        public let rawValue: [CFString: Any]
        
        /*
         /// A unique identifier for the artwork.
         public let artworkOrObjectID: String?
         /// The title of the artwork.
         public let title: String?
         /// The current owner of the artwork.
         public let currentOwner: String?
         */

        init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            
            contentDescription = rawValue[typed: kCGImagePropertyIPTCExtArtworkContentDescription]
            creator = rawValue[typed: kCGImagePropertyIPTCExtArtworkCreator]
            creatorID = rawValue[typed: kCGImagePropertyIPTCExtArtworkCreatorID]
            source = rawValue[typed: kCGImagePropertyIPTCExtArtworkSource]
            sourceInventoryNumber = rawValue[typed: kCGImagePropertyIPTCExtArtworkSourceInventoryNo]
            sourceInventoryURL = rawValue[typed: kCGImagePropertyIPTCExtArtworkSourceInvURL]
            stylePeriod = rawValue[typed: kCGImagePropertyIPTCExtArtworkStylePeriod]
            dateCreated = rawValue[typed: kCGImagePropertyIPTCExtArtworkDateCreated, using: ImageProperties.dateFormatter]
            circaDateCreated = rawValue[typed: kCGImagePropertyIPTCExtArtworkCircaDateCreated]
            physicalDescription = rawValue[typed: kCGImagePropertyIPTCExtArtworkPhysicalDescription]
            copyrightNotice = rawValue[typed: kCGImagePropertyIPTCExtArtworkCopyrightNotice]
            copyrightOwner = rawValue[typed: kCGImagePropertyIPTCExtArtworkCopyrightOwnerName]
            copyrightOwnerID = rawValue[typed: kCGImagePropertyIPTCExtArtworkCopyrightOwnerID]
            contributionDescription = rawValue[typed: kCGImagePropertyIPTCExtArtworkContributionDescription]
            licensorName = rawValue[typed: kCGImagePropertyIPTCExtArtworkLicensorName]
            licensorID = rawValue[typed: kCGImagePropertyIPTCExtArtworkLicensorID]
        }
    }
    
    /// Represents a single IPTC Extension registry reference describing a controlled vocabulary entry and its defining authority.
    public struct RegistryEntry {
        /// The identifier of the registry item that defines the referenced concept or controlled vocabulary entry.
        public let itemID: String?
        /// The identifier of the organization or authority that maintains the registry referenced by the item ID.
        public let organisationID: String?
        
        init(rawValue: [CFString: Any]) {
            itemID = rawValue[typed: kCGImagePropertyIPTCExtRegistryItemID]
            organisationID = rawValue[typed: kCGImagePropertyIPTCExtRegistryOrganisationID]
        }
    }
    
    /// Represents a machine-readable rights expression, either embedded in metadata or linked externally.
    public struct EncodedRightsExpression {
        /// The encoded rights expression or a reference to it depending on context.
        public let value: String?
        /// The language identifier describing the human-readable components of the expression.
        public let languageID: String?
        /// The type or format of the encoded rights expression defining how it should be interpreted.
        public let type: String?
        
        init(rawValue: [CFString: Any]) {
            value = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExpr]
            languageID = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExprLangID]
            type = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExprType]
        }
    }
    
    /// Represents a controlled vocabulary term describing what the image is about.
    public struct CVTermDetails {
        /// The identifier of the controlled vocabulary defining the term.
        public let cvID: String?
        /// The identifier of the term within the controlled vocabulary.
        public let id: String?
        /// The human-readable name of the term.
        public let name: String?
        /// A refinement providing a more specific semantic description of the term.
        public let refinedAbout: String?
        
        init(rawValue: [CFString: Any], type: String) {
            let type = type as CFString
            cvID = rawValue[typed: type + ("CvId" as CFString)]
            id = rawValue[typed: type + ("TermId" as CFString)]
            name = rawValue[typed: type + ("TermName" as CFString)]
            refinedAbout = rawValue[typed: type + ("TermRefinedAbout" as CFString)]
        }
    }
    
    /// Represents a person depicted in the image with structured IPTC Extension details.
    public struct PersonInImage {
        /// The names of the person shown in the image.
        public let names: [String]?
        /// Descriptions providing additional information about the person.
        public let descriptions: [String]?
        /// Identifiers referencing the person in external or internal systems.
        public let identifiers: [String]?
        /// Controlled vocabulary terms describing characteristics of the person.
        public let characteristics: [CVTermDetails]?
        
        init(rawValue: [CFString: Any]) {
            names = rawValue[typed: kCGImagePropertyIPTCExtPersonInImageName]
            descriptions = rawValue[typed: kCGImagePropertyIPTCExtPersonInImageDescription]
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtPersonInImageId]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtPersonInImageCharacteristic] {
                characteristics = values.map({CVTermDetails(rawValue: $0, type: "PersonInImage")})
            } else {
                characteristics = nil
            }
        }
    }
    
    /// Represents a person or organization that contributed to the image.
    public struct Contributor {
        /// The identifiers referencing the contributor in external or internal systems.
        public let identifiers: [String]?
        /// The names of the contributor.
        public let names: [String]?
        /// The roles describing how the contributor participated in creating or producing the image.
        public let roles: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtContributorIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtContributorName]
            roles = rawValue[typed: kCGImagePropertyIPTCExtContributorRole]
        }
    }
    
    /// Represents a person or organization that contributed to the image.
    public struct Creator {
        /// The identifiers referencing the contributor in external or internal systems.
        public let identifiers: [String]?
        /// The names of the contributor.
        public let names: [String]?
        /// The roles describing how the contributor participated in creating or producing the image.
        public let roles: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtCreatorIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtCreatorName]
            roles = rawValue[typed: kCGImagePropertyIPTCExtCreatorRole]
        }
    }
    
    /// Represents a rating applied to the image.
    public struct Rating {
        /// The rated regions where this rating applies.
        public let regions: [Location]?
        /// The maximum value of the rating scale.
        public let scaleMaximumValue: String?
        /// The minimum value of the rating scale.
        public let scaleMinimumValue: String?
        /// The link identifying the source of the rating.
        public let sourceLink: String?
        /// The rating value assigned to the image.
        public let value: String?
        /// The link to a logo representing the rating value or rating system.
        public let valueLogoLink: String?
        
        init(rawValue: [CFString: Any]) {
            scaleMaximumValue = rawValue[typed: kCGImagePropertyIPTCExtRatingScaleMaxValue]
            scaleMinimumValue = rawValue[typed: kCGImagePropertyIPTCExtRatingScaleMinValue]
            sourceLink = rawValue[typed: kCGImagePropertyIPTCExtRatingSourceLink]
            value = rawValue[typed: kCGImagePropertyIPTCExtRatingValue]
            valueLogoLink = rawValue[typed: kCGImagePropertyIPTCExtRatingValueLogoLink]
            if let regions: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtRatingRatingRegion] {
                self.regions = regions.map({Location(rawValue: $0, isRating: true)})
            } else {
                regions = nil
            }
        }
    }
    
    /// Represents data or text displayed on screen within the image.
    public struct TextRegion {
        /// The text displayed in the region.
        public let text: String?
        /// The region of the text.
        public let region: Region?
        
        init(rawValue: [CFString: Any]) {
            text = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionText]
            if let values: [CFString: Any] = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegion] {
                region = Region(rawValue: values)
            } else {
                region = nil
            }
        }
        
        /// Represents a region on screen where data or text is displayed.
        public struct Region {
            /// The horizontal position of the region.
            public let x: Double?
            /// The vertical position of the region.
            public let y: Double?
            /// The width of the region.
            public let width: Double?
            /// The height of the region.
            public let height: Double?
            /// The optional depth or z-order of the region.
            public let depth: Double?
            /// The coordinate unit used for the region.
            public let unit: String?
            
            init(rawValue: [CFString: Any]) {
                depth = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionD]
                unit = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionUnit]
                width = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionW]
                height = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionH]
                x = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionX]
                y = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreenRegionY]
            }
        }
    }
    
    /// Represents an event depicted in the image.
    public struct ShownEvent {
        /// The identifiers referencing the event in external or internal systems.
        public let identifiers: [String]?
        /// The names of the event.
        public let names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtShownEventIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtShownEventName]
        }
    }
    
    /// Represents a source in the content supply chain of the image.
    public struct SupplyChainSource {
        /// The identifiers referencing the source in external or internal systems.
        public let identifiers: [String]?
        /// The names of the source.
        public let names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtSupplyChainSourceIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtSupplyChainSourceName]
        }
    }
    
    /// Represents a series associated with the image.
    public struct Series {
        /// The identifiers referencing the series in external or internal systems.
        public let identifiers: [String]?
        /// The names of the series.
        public let names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtSeriesIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtSeriesName]
        }
    }
    
    /// Represents a container format of the image or associated media.
    public struct ContainerFormat {
        /// The identifiers referencing the container format.
        public let identifiers: [String]?
        /// The names of the container format.
        public let names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtContainerFormatIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtContainerFormatName]
        }
    }
    
    /// Represents a person who is heard in the image or associated media.
    public struct PersonHeard {
        /// The identifiers referencing the person in external or internal systems.
        public let identifiers: [String]?
        /// The names of the person.
        public let names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtPersonHeardIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtPersonHeardName]
        }
    }
    
    /// Represents a video shot type describing the framing or composition of the content.
    public struct VideoShotType {
        /// The identifiers referencing the shot type in external or controlled vocabularies.
        public let identifiers: [String]?
        /// The human-readable names of the shot type.
        public let names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtVideoShotTypeIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtVideoShotTypeName]
        }
    }
    
    /// Represents a product depicted in the image.
    public struct ProductInImage {
        /// The names of the product.
        public let names: [String]?
        /// Descriptions providing additional information about the product.
        public let descriptions: [String]?
        /// The global trade item numbers identifying the product.
        public let gtins: [String]?
        
        init(rawValue: [CFString: Any]) {
            descriptions = rawValue[typed: kCGImagePropertyIPTCExtProductInImageDescription]
            gtins = rawValue[typed: kCGImagePropertyIPTCExtProductInImageGTIN]
            names = rawValue[typed: kCGImagePropertyIPTCExtProductInImageName]
        }
    }
    
    /// Represents a publication event associated with the image.
    public struct PublicationEvent {
        /// The identifiers referencing the publication event.
        public let identifiers: [String]?
        /// The names of the publication event.
        public let names: [String]?
        /// The dates of the publication event.
        public let dates: [Date]?
        
        init(rawValue: [CFString: Any]) {
            if let strings: [String] = rawValue[typed: kCGImagePropertyIPTCExtPublicationEventDate] {
                dates = strings.compactMap({ ImageProperties.dateFormatter.date(from: $0) })
            } else {
                dates = nil
            }
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtPublicationEventIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtPublicationEventName]
        }
    }
    
    /// Represents a link to an external transcript.
    public struct TranscriptLink {
        /// The links referencing the transcript.
        public let links: [String]?
        /// Qualifiers describing the type of transcript.
        public let qualifiers: [String]?
        
        init(rawValue: [CFString: Any]) {
            links = rawValue[typed: kCGImagePropertyIPTCExtTranscriptLinkLink]
            qualifiers = rawValue[typed: kCGImagePropertyIPTCExtTranscriptLinkLinkQualifier]
        }
    }
    
    /// Represents a link to a dopesheet describing timing or production details.
    public struct DopesheetLink {
        /// The links referencing the dopesheet.
        public let links: [String]?
        /// Qualifiers describing the type of dopesheet.
        public let qualifiers: [String]?

        init(rawValue: [CFString: Any]) {
            links = rawValue[typed: kCGImagePropertyIPTCExtDopesheetLinkLink]
            qualifiers = rawValue[typed: kCGImagePropertyIPTCExtDopesheetLinkLinkQualifier]
        }
    }
    
    /// Represents an episode associated with the image.
    public struct Episode {
        /// The identifiers referencing the episode in external or internal systems.
        public let identifiers: [String]?
        /// The names of the episode.
        public let names: [String]?
        /// The numbers identifying the episode.
        public let numbers: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtEpisodeIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtEpisodeName]
            numbers = rawValue[typed: kCGImagePropertyIPTCExtEpisodeNumber]
        }
    }
    
    /// Represents a season associated with the image.
    public struct Season {
        /// The identifiers referencing the season in external or internal systems.
        public let identifiers: [String]?
        /// The names of the season.
        public let names: [String]?
        /// The numbers identifying the season.
        public let numbers: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtSeasonIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtSeasonName]
            numbers = rawValue[typed: kCGImagePropertyIPTCExtSeasonNumber]
        }
    }
}

extension CFString {
    static func + (lhs: CFString, rhs: CFString) -> CFString {
        ((lhs as String) + (rhs as String)) as CFString
    }
}
