import Foundation

struct YoutubeAPIService: Codable {
    let items: [Item]
}

extension YoutubeAPIService {
    init(data: Data) throws {
        self = try JSONDecoder().decode(YoutubeAPIService.self, from: data)
    }
}

struct Item: Codable {
    
    let contentDetails: ContentDetails?
    let statistics: Statistics?
    let brandingSettings: BrandingSettings?
    let snippet: Snippet?

}

struct Snippet: Codable {
    let title: String?
    let resourceId: ResourceID?
    let thumbnails: Thumbnails?
}

struct Thumbnails: Codable {
    let maxres: Default?
    let defaultt: Default?
    let standart: Default?
    let medium: Default?
    
    private enum CodingKeys: String, CodingKey {
        case defaultt = "default"
        case maxres
        case standart
        case medium
    }
}

struct Default: Codable {
    let url: String?
    let width, height: Int?
}

struct ResourceID: Codable {
    let videoId: String
}

struct BrandingSettings: Codable {
    let channel: Channel?
    let image: BannerImage?
}

struct Channel: Codable {
    let title: String?
}

struct BannerImage: Codable {
    let bannerExternalUrl: String?
}

struct ContentDetails: Codable {
    let relatedPlaylists: RelatedPlaylists?
}

struct RelatedPlaylists: Codable {
    let likes, uploads: String?
}

struct Statistics: Codable {
    let viewCount, subscriberCount: String?
}








