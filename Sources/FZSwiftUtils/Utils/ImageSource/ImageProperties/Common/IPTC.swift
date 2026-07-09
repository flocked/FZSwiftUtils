//
//  IPTC.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation
import ImageIO

public extension ImageProperties {
    struct IPTC: RawRepresentable {
        /// The raw values.
        public var rawValue: [CFString: Any]

        /// The artworks of the image.
        public var artworks: [Artwork]
        
        /// The action advised metadata.
        public var actionAdvised: [String]?
        /// The additional model information.
        public var additionalModelInfo: String?
        
        /// The audio bitrate metadata.
        public var audioBitrate: Double?
        /// The audio bitrate mode.
        public var audioBitrateMode: String?
        /// The audio channel count.
        public var audioChannelCount: Int?
        /// The byline metadata.
        public var byline: [String]?
        /// The byline title metadata.
        public var bylineTitle: [String]?
        /// The caption or abstract metadata.
        public var captionAbstract: String?
        /// The category metadata.
        public var category: String?
        /// The circa date created metadata.
        public var circaDateCreated: String?
        /// The city metadata.
        public var city: String?
        /// The contact metadata.
        public var contact: [String]?
        /// The container format metadata.
        public var containerFormats: [ContainerFormat]?
        /// The content location code.
        public var contentLocationCode: [String]?
        /// The content location name.
        public var contentLocationName: [String]?
        /// The contributor metadata.
        public var contributors: [Contributor]?
        /// The controlled vocabulary term.
        public var controlledVocabularyTerm: Any?
        /// The copyright notice.
        public var copyrightNotice: String?
        /// The copyright year.
        public var copyrightYear: Int?
        /// The primary location code.
        public var countryPrimaryLocationCode: String?
        /// The primary location name.
        public var countryPrimaryLocationName: String?
        /// The creator metadata.
        public var creators: [Creator]?
        /// The creator contact information.
        public var creatorContactInfo: CreatorContactInfo?
        /// The credit metadata.
        public var credit: String?
        /// The data-on-screen metadata.
        public var dataOnScreen: [TextRegion]?
        /// The creation date.
        public var dateCreated: Date?
        /// The digital creation date.
        public var digitalCreationDate: Date?
        /// The digital creation time.
        public var digitalCreationTime: String?
        /// The digital image GUID.
        public var digitalImageGUID: String?
        /// The digital source file type.
        public var digitalSourceFileType: String?
        /// The digital source type.
        public var digitalSourceType: String?
        /// The dopesheet metadata.
        public var dopesheet: String?
        /// The dopesheet link metadata.
        public var dopesheetLinks: [DopesheetLink]?
        /// The edit status.
        public var editStatus: String?
        /// The editorial update metadata.
        public var editorialUpdate: String?
        /// The episode metadata.
        public var episodes: [Episode]?
        /// The event metadata.
        public var event: String?
        /// The expiration date.
        public var expirationDate: Date?
        /// The expiration time.
        public var expirationTime: String?
        /// The external metadata link.
        public var externalMetadataLink: String?
        /// The feed identifier.
        public var feedIdentifier: String?
        /// The fixture identifier.
        public var fixtureIdentifier: [String]?
        /// The genre metadata.
        public var genres: [CVTermDetails]?
        /// The headline metadata.
        public var headline: String?
        /// The IPTC last edited metadata.
        public var iPTCLastEdited: Date?
        /// The orientation of the IPTC image.
        public var orientation: CGImagePropertyOrientation?
        /// The image type metadata.
        public var imageType: [String]?
        /// The keywords metadata.
        public var keywords: [String]?
        /// The language identifier.
        public var languageIdentifier: String?
        /// The created location metadata.
        public var locationsCreated: [Location]?
        /// The shown location metadata.
        public var locationsShown: [Location]?
        /// The maximum available height.
        public var maxAvailHeight: Int?
        /// The maximum available width.
        public var maxAvailWidth: Int?
        /// The model age metadata.
        public var modelAge: [Int]?
        /// The object attribute reference.
        public var objectAttributeReference: [String]?
        /// The object cycle metadata.
        public var objectCycle: String?
        /// The object name.
        public var objectName: String?
        /// The object type reference.
        public var objectTypeReference: String?
        /// The organisation-in-image code.
        public var organisationInImageCode: [String]?
        /// The organisation-in-image name.
        public var organisationInImageName: [String]?
        /// The original transmission reference.
        public var originalTransmissionReference: String?
        /// The originating program.
        public var originatingProgram: String?
        /// The person-heard metadata.
        public var personHeard: [PersonHeard]?
        /// The person-in-image metadata.
        public var personsInImage: [String]?
        /// The detailed person-in-image metadata.
        public var personsInImageDetails: [PersonInImage]?
        
        /// The product-in-image metadata.
        public var productsInImage: [ProductInImage]?
        /// The program version.
        public var programVersion: String?
        /// The province or state metadata.
        public var provinceOrState: String?
        /// The publication event metadata.
        public var publicationEvents: [PublicationEvent]?
        /// The rating metadata.
        public var ratings: [Rating]?
        /// The reference date.
        public var referenceDate: Date?
        /// The reference number.
        public var referenceNumber: Any?
        /// The reference service.
        public var referenceService: Any?
        /// The registry entry role.
        public var registryEntryRole: String?
        /// The release date.
        public var releaseDate: Date?
        /// The release-ready metadata.
        public var isReleaseReady: Bool?
        /// The release time.
        public var releaseTime: String?
        /// The scene metadata.
        public var scene: [String]?
        /// The season metadata.
        public var seasons: [Season]?
        /// The series metadata.
        public var series: [Series]?
        /// The shown event metadata.
        public var shownEvents: [ShownEvent]?
        /// The source metadata.
        public var source: String?
        /// The special instructions.
        public var specialInstructions: String?
        /// The star rating metadata.
        public var starRating: Double?
        /// The storyline identifier.
        public var storylineIdentifier: String?
        /// The stream-ready metadata.
        public var isStreamReady: Bool?
        /// The style period metadata.
        public var stylePeriod: String?
        /// The sublocation metadata.
        public var subLocation: String?
        /// The subject reference metadata.
        public var subjectReference: [String]?
        /// The supplemental category metadata.
        public var supplementalCategory: [String]?
        /// The supply chain source metadata.
        public var supplyChainSources: [SupplyChainSource]?
        /// The temporal coverage metadata.
        public var temporalCoverage: String?
        /// The temporal coverage start.
        public var temporalCoverageFrom: String?
        /// The temporal coverage end.
        public var temporalCoverageTo: String?
        /// The creation time.
        public var timeCreated: String?
        /// The transcript metadata.
        public var transcript: String?
        /// The transcript link metadata.
        public var transcriptLinks: [TranscriptLink]?
        /// The urgency metadata.
        public var urgency: String?
        /// The usage terms metadata.
        public var usageTerms: String?
        /// The video bitrate metadata.
        public var videoBitrate: Double?
        /// The video bitrate mode.
        public var videoBitrateMode: String?
        /// The video display aspect ratio.
        public var videoDisplayAspectRatio: String?
        /// The video encoding profile.
        public var videoEncodingProfile: String?
        /// The video shot type metadata.
        public var videoShotTypes: [VideoShotType]?
        /// The video streams count.
        public var videoStreamsCount: Int?
        /// The visual color metadata.
        public var visualColor: String?
        /// The workflow tag metadata.
        public var workflowTags: [CVTermDetails]?
        /// The writer or editor metadata.
        public var writerEditor: [String]?
        /// The registry entries describing controlled vocabulary items and their defining organizations associated with the image metadata.
        public var registryEntries: [RegistryEntry]?
        /// The encoded rights expressions embedded directly within the image metadata.
        public var embeddedExpressions: [EncodedRightsExpression]?
        /// The encoded rights expressions referenced externally by the image metadata.
        public var linkedExpressions: [EncodedRightsExpression]?
        /// The controlled vocabulary terms describing what the image is about.
        public var aboutTerms: [CVTermDetails]?
        
        public init(rawValue: [CFString: Any]) {
            self.rawValue = rawValue
            
            creatorContactInfo = rawValue[typed: kCGImagePropertyIPTCCreatorContactInfo].map(CreatorContactInfo.init)
                        
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtAboutCvTerm] {
                aboutTerms = values.map({CVTermDetails(rawValue: $0, type: "About")})
            } else {
                aboutTerms = nil
            }
            
            actionAdvised = rawValue[typed: kCGImagePropertyIPTCActionAdvised]
            additionalModelInfo = rawValue[typed: kCGImagePropertyIPTCExtAddlModelInfo]
            if let _artworks: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtArtworkOrObject] {
                artworks = _artworks.map(Artwork.init)
            } else {
                artworks = []
            }
          
            audioBitrate = rawValue[typed: kCGImagePropertyIPTCExtAudioBitrate]
            audioBitrateMode = rawValue[typed: kCGImagePropertyIPTCExtAudioBitrateMode]
            audioChannelCount = rawValue[typed: kCGImagePropertyIPTCExtAudioChannelCount]
            byline = rawValue[typed: kCGImagePropertyIPTCByline]
            bylineTitle = rawValue[typed: kCGImagePropertyIPTCBylineTitle]
            captionAbstract = rawValue[typed: kCGImagePropertyIPTCCaptionAbstract]
            category = rawValue[typed: kCGImagePropertyIPTCCategory]
            circaDateCreated = rawValue[typed: kCGImagePropertyIPTCExtCircaDateCreated]
            city = rawValue[typed: kCGImagePropertyIPTCCity]
            contact = rawValue[typed: kCGImagePropertyIPTCContact]
            if let formats: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtContainerFormat] {
               containerFormats = formats.map(ContainerFormat.init)
            } else {
                containerFormats = nil
            }
            contentLocationCode = rawValue[typed: kCGImagePropertyIPTCContentLocationCode]
            contentLocationName = rawValue[typed: kCGImagePropertyIPTCContentLocationName]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtContributor] {
                contributors = values.map(Contributor.init)
            } else {
                contributors = nil
            }
            controlledVocabularyTerm = rawValue[kCGImagePropertyIPTCExtControlledVocabularyTerm]
            copyrightNotice = rawValue[typed: kCGImagePropertyIPTCCopyrightNotice]
            copyrightYear = rawValue[typed: kCGImagePropertyIPTCExtCopyrightYear]
            countryPrimaryLocationCode = rawValue[typed: kCGImagePropertyIPTCCountryPrimaryLocationCode]
            countryPrimaryLocationName = rawValue[typed: kCGImagePropertyIPTCCountryPrimaryLocationName]
            if let value: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtCreator] {
               creators = value.map(Creator.init)
            } else {
                creators = nil
            }
            credit = rawValue[typed: kCGImagePropertyIPTCCredit]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtDataOnScreen] {
               dataOnScreen = values.map(TextRegion.init)
            } else {
                dataOnScreen = nil
            }
            dateCreated = rawValue[typed: kCGImagePropertyIPTCDateCreated, using: ImageProperties.dateFormatter]
            digitalCreationDate = rawValue[typed: kCGImagePropertyIPTCDigitalCreationDate, using: ImageProperties.dateFormatter]
            digitalCreationTime = rawValue[typed: kCGImagePropertyIPTCDigitalCreationTime]
            digitalImageGUID = rawValue[typed: kCGImagePropertyIPTCExtDigitalImageGUID]
            digitalSourceFileType = rawValue[typed: kCGImagePropertyIPTCExtDigitalSourceFileType]
            digitalSourceType = rawValue[typed: kCGImagePropertyIPTCExtDigitalSourceType]
            dopesheet = rawValue[typed: kCGImagePropertyIPTCExtDopesheet]
            if let links: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtDopesheetLink] {
               dopesheetLinks = links.map(DopesheetLink.init)
            } else {
                dopesheetLinks = nil
            }
            editStatus = rawValue[typed: kCGImagePropertyIPTCEditStatus]
            editorialUpdate = rawValue[typed: kCGImagePropertyIPTCEditorialUpdate]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtEpisode] {
               episodes = values.map(Episode.init)
            } else {
                episodes = nil
            }
            event = rawValue[typed: kCGImagePropertyIPTCExtEvent]
            expirationDate = rawValue[typed: kCGImagePropertyIPTCExpirationDate, using: ImageProperties.dateFormatter]
            expirationTime = rawValue[typed: kCGImagePropertyIPTCExpirationTime]
            externalMetadataLink = rawValue[typed: kCGImagePropertyIPTCExtExternalMetadataLink]
            feedIdentifier = rawValue[typed: kCGImagePropertyIPTCExtFeedIdentifier]
            fixtureIdentifier = rawValue[typed: kCGImagePropertyIPTCFixtureIdentifier]

            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtGenre] {
                genres = values.map({CVTermDetails(rawValue: $0, type: "Genre")})
            } else {
                genres = nil
            }
            headline = rawValue[typed: kCGImagePropertyIPTCHeadline]
            iPTCLastEdited = rawValue[typed: kCGImagePropertyIPTCExtIPTCLastEdited, using: ImageProperties.dateFormatter]
            
            orientation = rawValue[typed: kCGImagePropertyIPTCImageOrientation]
            imageType = rawValue[typed: kCGImagePropertyIPTCImageType]
            keywords = rawValue[typed: kCGImagePropertyIPTCKeywords]
            languageIdentifier = rawValue[typed: kCGImagePropertyIPTCLanguageIdentifier]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncRightsExpr] {
               linkedExpressions = values.map(EncodedRightsExpression.init(rawValue:))
            } else {
                linkedExpressions = nil
            }
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtEmbdEncRightsExpr] {
                embeddedExpressions = values.map(EncodedRightsExpression.init(embedded:))
            } else {
                embeddedExpressions = nil
            }
                        
            if let locations: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtLocationCreated] {
                locationsCreated = locations.map({Location(rawValue: $0)})
            } else {
                locationsCreated = nil
            }
            if let locations: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtLocationShown] {
               locationsShown = locations.map({Location(rawValue: $0)})
            } else {
                locationsShown = nil
            }

            maxAvailHeight = rawValue[typed: kCGImagePropertyIPTCExtMaxAvailHeight]
            maxAvailWidth = rawValue[typed: kCGImagePropertyIPTCExtMaxAvailWidth]
            modelAge = rawValue[typed: kCGImagePropertyIPTCExtModelAge]
            objectAttributeReference = rawValue[typed: kCGImagePropertyIPTCObjectAttributeReference]
            objectCycle = rawValue[typed: kCGImagePropertyIPTCObjectCycle]
            objectName = rawValue[typed: kCGImagePropertyIPTCObjectName]
            objectTypeReference = rawValue[typed: kCGImagePropertyIPTCObjectTypeReference]
            
            organisationInImageCode = rawValue[typed: kCGImagePropertyIPTCExtOrganisationInImageCode]
            organisationInImageName = rawValue[typed: kCGImagePropertyIPTCExtOrganisationInImageName]
            
            originalTransmissionReference = rawValue[typed: kCGImagePropertyIPTCOriginalTransmissionReference]
            originatingProgram = rawValue[typed: kCGImagePropertyIPTCOriginatingProgram]
            
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtPersonHeard] {
               personHeard = values.map(PersonHeard.init)
            } else {
                personHeard = nil
            }
            
            personsInImage = rawValue[typed: kCGImagePropertyIPTCExtPersonInImage]
            if let personDetails: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtPersonInImageWDetails] {
              personsInImageDetails = personDetails.map(PersonInImage.init)
            } else {
                personsInImageDetails = nil
            }
           
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtProductInImage] {
               productsInImage = values.map(ProductInImage.init)
            } else {
                productsInImage = nil
            }

            programVersion = rawValue[typed: kCGImagePropertyIPTCProgramVersion]
            provinceOrState = rawValue[typed: kCGImagePropertyIPTCProvinceState]
            if let events: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtPublicationEvent] {
                publicationEvents = events.map(PublicationEvent.init)
            } else {
                publicationEvents = nil
            }
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtRating] {
                ratings = values.map(Rating.init)
            } else {
                ratings = nil
            }
            referenceDate = rawValue[typed: kCGImagePropertyIPTCReferenceDate, using: ImageProperties.dateFormatter]
            referenceNumber = rawValue[kCGImagePropertyIPTCReferenceNumber]
            referenceService = rawValue[kCGImagePropertyIPTCReferenceService]
            registryEntryRole = rawValue[typed: kCGImagePropertyIPTCExtRegistryEntryRole]
            if let entries: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtRegistryID] {
                 registryEntries = entries.map(RegistryEntry.init)
            } else {
                registryEntries = nil
            }
            releaseDate = rawValue[typed: kCGImagePropertyIPTCReleaseDate, using: ImageProperties.dateFormatter]
            isReleaseReady = rawValue[typed: kCGImagePropertyIPTCExtReleaseReady]
            releaseTime = rawValue[typed: kCGImagePropertyIPTCReleaseTime]
            scene = rawValue[typed: kCGImagePropertyIPTCScene]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtSeason] {
                seasons = values.map(Season.init)
            } else {
                seasons = nil
            }
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtSeries] {
                series = values.map(Series.init)
            } else {
                series = nil
            }
            if let events: [String] = rawValue[typed: kCGImagePropertyIPTCExtShownEvent] {
                shownEvents = events.map(ShownEvent.init)
            } else if let events: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtShownEvent] {
                shownEvents = events.map(ShownEvent.init)
            } else {
                shownEvents = nil
            }
            source = rawValue[typed: kCGImagePropertyIPTCSource]
            specialInstructions = rawValue[typed: kCGImagePropertyIPTCSpecialInstructions]
            starRating = rawValue[typed: kCGImagePropertyIPTCStarRating]
            storylineIdentifier = rawValue[typed: kCGImagePropertyIPTCExtStorylineIdentifier]
            isStreamReady = rawValue[typed: kCGImagePropertyIPTCExtStreamReady]
            stylePeriod = rawValue[typed: kCGImagePropertyIPTCExtStylePeriod]
            subLocation = rawValue[typed: kCGImagePropertyIPTCSubLocation]
            subjectReference = rawValue[typed: kCGImagePropertyIPTCSubjectReference]
            supplementalCategory = rawValue[typed: kCGImagePropertyIPTCSupplementalCategory]
            timeCreated = rawValue[typed: kCGImagePropertyIPTCTimeCreated]
            urgency = rawValue[typed: kCGImagePropertyIPTCUrgency]
            usageTerms = rawValue[typed: kCGImagePropertyIPTCRightsUsageTerms]
            writerEditor = rawValue[typed: kCGImagePropertyIPTCWriterEditor]
          
            if let sources: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtSupplyChainSource] {
               supplyChainSources = sources.map(SupplyChainSource.init)
            } else {
                supplyChainSources = nil
            }
 
            temporalCoverage = rawValue[typed: kCGImagePropertyIPTCExtTemporalCoverage]
            temporalCoverageFrom = rawValue[typed: kCGImagePropertyIPTCExtTemporalCoverageFrom]
            temporalCoverageTo = rawValue[typed: kCGImagePropertyIPTCExtTemporalCoverageTo]
            
            transcript = rawValue[typed: kCGImagePropertyIPTCExtTranscript]
            if let links: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtTranscriptLink] {
               transcriptLinks = links.map(TranscriptLink.init)
            } else {
                transcriptLinks = nil
            }
            videoBitrate = rawValue[typed: kCGImagePropertyIPTCExtVideoBitrate]
            videoBitrateMode = rawValue[typed: kCGImagePropertyIPTCExtVideoBitrateMode]
            videoDisplayAspectRatio = rawValue[typed: kCGImagePropertyIPTCExtVideoDisplayAspectRatio]
            videoEncodingProfile = rawValue[typed: kCGImagePropertyIPTCExtVideoEncodingProfile]
            if let values: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtVideoShotType] {
               videoShotTypes = values.map(VideoShotType.init)
            } else {
                videoShotTypes = nil
            }
            videoStreamsCount = rawValue[typed: kCGImagePropertyIPTCExtVideoStreamsCount]
            visualColor = rawValue[typed: kCGImagePropertyIPTCExtVisualColor]
            if let tags: [[CFString: Any]] = rawValue[typed: kCGImagePropertyIPTCExtWorkflowTag] {
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
        public var rawValue: [CFString: Any]
        /// The address of the creator.
        public var address: String?
        /// The city of the creator.
        public var city: String?
        /// The country of the creator.
        public var country: String?
        /// The postal code of the creator.
        public var postalCode: String?
        /// The state/province of the creator.
        public var stateProvince: String?
        /// The email addresses of the creator.
        public var emailAddresses: String?
        /// The phone numbers of the creator.
        public var phoneNumbers: String?
        /// The websites of the creator.
        public var websites: String?
        
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
        public var name: [String]?
        /// The sublocation of the location.
        public var sublocation: String?
        /// The province or state of the location.
        public var provinceState: String?
        /// The country name of the location.
        public var country: String?
        /// The ISO country code of the location.
        public var countryCode: String?
        /// The city name of the location.
        public var city: String?
        /// The broader world region (e.g. "Europe", "Asia").
        public var worldRegion: String?
        /// The GPS latitude in decimal degrees.
        public var gpsLatitude: String?
        /// The GPS longitude in decimal degrees.
        public var gpsLongitude: String?
        /// The GPS altitude in decimal degrees.
        public var gpsAltitude: String?
        /// The identifier of the location.
        public var identifiers: [String]?
        
        /// The alternative identifier of the location.
        public var locationIDs: [String]?
        
        public var countryPrimaryLocationCode: String?
                
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
        public var creator: String?
        /// The date the artwork was created.
        public var dateCreated: Date?
        /// The circa date the artwork was created.
        public var circaDateCreated: String?
        /// The source of the artwork.
        public var source: String?
        /// The copyright notice of the artwork.
        public var copyrightNotice: String?
        /// The copyright owner of the artwork.
        public var copyrightOwner: String?
        /// The copyright owne identifier of the artwork.
        public var copyrightOwnerID: String?
        /// The content description of the artwork.
        public var contentDescription: String?
        /// The inventory number assigned by the source.
        public var sourceInventoryNumber: String?
        /// The inventory URL assigned by the source.
        public var sourceInventoryURL: String?
        /// A description of the artwork’s physical appearance.
        public var physicalDescription: String?
        /// The creator’s identifier (e.g. VIAF, ULAN).
        public var creatorID: String?
        /// The style or period of the artwork.
        public var stylePeriod: String?
        /// The contribution description of the artwork.
        public var contributionDescription: String?
        /// The licensor name of the artwork.
        public var licensorName: String?
        /// The licensor ID of the artwork.
        public var licensorID: String?
        /// The raw values.
        public var rawValue: [CFString: Any]
        
        /*
         /// A unique identifier for the artwork.
         public var artworkOrObjectID: String?
         /// The title of the artwork.
         public var title: String?
         /// The current owner of the artwork.
         public var currentOwner: String?
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
        public var itemID: String?
        /// The identifier of the organization or authority that maintains the registry referenced by the item ID.
        public var organisationID: String?
        
        init(rawValue: [CFString: Any]) {
            itemID = rawValue[typed: kCGImagePropertyIPTCExtRegistryItemID]
            organisationID = rawValue[typed: kCGImagePropertyIPTCExtRegistryOrganisationID]
        }
    }
    
    /// Represents a machine-readable rights expression, either embedded in metadata or linked externally.
    public struct EncodedRightsExpression {
        /// The encoded rights expression or a reference to it depending on context.
        public var value: String?
        /// The language identifier describing the human-readable components of the expression.
        public var languageID: String?
        /// The type or format of the encoded rights expression defining how it should be interpreted.
        public var type: String?
        
        init(rawValue: [CFString: Any]) {
            value = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExpr]
            languageID = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExprLangID]
            type = rawValue[typed: kCGImagePropertyIPTCExtLinkedEncodedRightsExprType]
        }
        
        init(embedded: [CFString: Any]) {
            value = embedded[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExpr]
            languageID = embedded[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprLangID]
            type = embedded[typed: kCGImagePropertyIPTCExtEmbeddedEncodedRightsExprType]
        }
    }
    
    /// Represents a controlled vocabulary term describing what the image is about.
    public struct CVTermDetails {
        /// The identifier of the controlled vocabulary defining the term.
        public var cvID: String?
        /// The identifier of the term within the controlled vocabulary.
        public var id: String?
        /// The human-readable name of the term.
        public var name: String?
        /// A refinement providing a more specific semantic description of the term.
        public var refinedAbout: String?
        
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
        public var names: [String]?
        /// Descriptions providing additional information about the person.
        public var descriptions: [String]?
        /// Identifiers referencing the person in external or internal systems.
        public var identifiers: [String]?
        /// Controlled vocabulary terms describing characteristics of the person.
        public var characteristics: [CVTermDetails]?
        
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
        public var identifiers: [String]?
        /// The names of the contributor.
        public var names: [String]?
        /// The roles describing how the contributor participated in creating or producing the image.
        public var roles: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtContributorIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtContributorName]
            roles = rawValue[typed: kCGImagePropertyIPTCExtContributorRole]
        }
    }
    
    /// Represents a person or organization that contributed to the image.
    public struct Creator {
        /// The identifiers referencing the contributor in external or internal systems.
        public var identifiers: [String]?
        /// The names of the contributor.
        public var names: [String]?
        /// The roles describing how the contributor participated in creating or producing the image.
        public var roles: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtCreatorIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtCreatorName]
            roles = rawValue[typed: kCGImagePropertyIPTCExtCreatorRole]
        }
    }
    
    /// Represents a rating applied to the image.
    public struct Rating {
        /// The rated regions where this rating applies.
        public var regions: [Location]?
        /// The maximum value of the rating scale.
        public var scaleMaximumValue: String?
        /// The minimum value of the rating scale.
        public var scaleMinimumValue: String?
        /// The link identifying the source of the rating.
        public var sourceLink: String?
        /// The rating value assigned to the image.
        public var value: String?
        /// The link to a logo representing the rating value or rating system.
        public var valueLogoLink: String?
        
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
        public var text: String?
        /// The region of the text.
        public var region: Region?
        
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
            public var x: Double?
            /// The vertical position of the region.
            public var y: Double?
            /// The width of the region.
            public var width: Double?
            /// The height of the region.
            public var height: Double?
            /// The optional depth or z-order of the region.
            public var depth: Double?
            /// The coordinate unit used for the region.
            public var unit: String?
            
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
        public var identifiers: [String]?
        /// The names of the event.
        public var names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtShownEventIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtShownEventName]
        }
        
        init(rawValue: String) {
            names = [rawValue]
            identifiers = nil
        }
    }
    
    /// Represents a source in the content supply chain of the image.
    public struct SupplyChainSource {
        /// The identifiers referencing the source in external or internal systems.
        public var identifiers: [String]?
        /// The names of the source.
        public var names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtSupplyChainSourceIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtSupplyChainSourceName]
        }
    }
    
    /// Represents a series associated with the image.
    public struct Series {
        /// The identifiers referencing the series in external or internal systems.
        public var identifiers: [String]?
        /// The names of the series.
        public var names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtSeriesIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtSeriesName]
        }
    }
    
    /// Represents a container format of the image or associated media.
    public struct ContainerFormat {
        /// The identifiers referencing the container format.
        public var identifiers: [String]?
        /// The names of the container format.
        public var names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtContainerFormatIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtContainerFormatName]
        }
    }
    
    /// Represents a person who is heard in the image or associated media.
    public struct PersonHeard {
        /// The identifiers referencing the person in external or internal systems.
        public var identifiers: [String]?
        /// The names of the person.
        public var names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtPersonHeardIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtPersonHeardName]
        }
    }
    
    /// Represents a video shot type describing the framing or composition of the content.
    public struct VideoShotType {
        /// The identifiers referencing the shot type in external or controlled vocabularies.
        public var identifiers: [String]?
        /// The human-readable names of the shot type.
        public var names: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtVideoShotTypeIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtVideoShotTypeName]
        }
    }
    
    /// Represents a product depicted in the image.
    public struct ProductInImage {
        /// The names of the product.
        public var names: [String]?
        /// Descriptions providing additional information about the product.
        public var descriptions: [String]?
        /// The global trade item numbers identifying the product.
        public var gtins: [String]?
        
        init(rawValue: [CFString: Any]) {
            descriptions = rawValue[typed: kCGImagePropertyIPTCExtProductInImageDescription]
            gtins = rawValue[typed: kCGImagePropertyIPTCExtProductInImageGTIN]
            names = rawValue[typed: kCGImagePropertyIPTCExtProductInImageName]
        }
    }
    
    /// Represents a publication event associated with the image.
    public struct PublicationEvent {
        /// The identifiers referencing the publication event.
        public var identifiers: [String]?
        /// The names of the publication event.
        public var names: [String]?
        /// The dates of the publication event.
        public var dates: [Date]?
        
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
        public var links: [String]?
        /// Qualifiers describing the type of transcript.
        public var qualifiers: [String]?
        
        init(rawValue: [CFString: Any]) {
            links = rawValue[typed: kCGImagePropertyIPTCExtTranscriptLinkLink]
            qualifiers = rawValue[typed: kCGImagePropertyIPTCExtTranscriptLinkLinkQualifier]
        }
    }
    
    /// Represents a link to a dopesheet describing timing or production details.
    public struct DopesheetLink {
        /// The links referencing the dopesheet.
        public var links: [String]?
        /// Qualifiers describing the type of dopesheet.
        public var qualifiers: [String]?

        init(rawValue: [CFString: Any]) {
            links = rawValue[typed: kCGImagePropertyIPTCExtDopesheetLinkLink]
            qualifiers = rawValue[typed: kCGImagePropertyIPTCExtDopesheetLinkLinkQualifier]
        }
    }
    
    /// Represents an episode associated with the image.
    public struct Episode {
        /// The identifiers referencing the episode in external or internal systems.
        public var identifiers: [String]?
        /// The names of the episode.
        public var names: [String]?
        /// The numbers identifying the episode.
        public var numbers: [String]?
        
        init(rawValue: [CFString: Any]) {
            identifiers = rawValue[typed: kCGImagePropertyIPTCExtEpisodeIdentifier]
            names = rawValue[typed: kCGImagePropertyIPTCExtEpisodeName]
            numbers = rawValue[typed: kCGImagePropertyIPTCExtEpisodeNumber]
        }
    }
    
    /// Represents a season associated with the image.
    public struct Season {
        /// The identifiers referencing the season in external or internal systems.
        public var identifiers: [String]?
        /// The names of the season.
        public var names: [String]?
        /// The numbers identifying the season.
        public var numbers: [String]?
        
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
