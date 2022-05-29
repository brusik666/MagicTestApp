import Foundation
import RxCocoa
import RxSwift
import RxDataSources

struct YoutubeChannel {
    let title: String?
    let imageURLString: String?
    let subscribersCount: String?
    let uploads: String?
    var videos: [Video] = []
    init?(with youtubeServiceItem: Item) {
        guard let channelTitle = youtubeServiceItem.brandingSettings?.channel?.title,
              let imageURLString = youtubeServiceItem.brandingSettings?.image?.bannerExternalUrl,
              let subscribersCount = youtubeServiceItem.statistics?.subscriberCount,
              let uploads = youtubeServiceItem.contentDetails?.relatedPlaylists?.uploads else { return nil }
        
        self.title = channelTitle
        self.imageURLString = imageURLString
        self.subscribersCount = subscribersCount
        self.uploads = uploads
    }
}

struct SectionOfChannels: SectionModelType {
    
    
    
    typealias Item = YoutubeChannel
    
    var header: String
    var items: [Item]
    
    init(original: SectionOfChannels, items: [YoutubeChannel]) {
        self = original
        self.items = items
    }
}


