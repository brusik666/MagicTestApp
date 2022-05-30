import Foundation

struct Playlist {
    let title: String?
    var videoIDs: [String]?
    var videos: [Video]?
    
    init?(with item: Item) {
        guard let title = item.snippet?.title else { return nil }
        self.title = title
        self.videos = nil
        self.videoIDs = nil
    }
}


