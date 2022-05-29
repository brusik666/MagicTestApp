import Foundation

struct Playlist {
    let title: String?
    let videoIDs: [String]?
    let videos: [Video]?
    
    init?(with item: Item) {
        guard let title = item.snippet?.title else { return nil }
        self.title = title
        self.videos = nil
        self.videoIDs = nil
    }
}


