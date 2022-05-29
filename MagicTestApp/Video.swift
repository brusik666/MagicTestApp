import Foundation

struct Video {
    let title: String
    let coverURLstring: String
    let viewCount: Int
    
    init? (with item: Item){
        
        guard let title = item.snippet?.title,
              let coverURLstring = item.snippet?.thumbnails?.defaultt?.url,
              let viewCount = item.statistics?.viewCount else { return nil }
        
        self.title = title
        self.coverURLstring = coverURLstring
        self.viewCount = Int(viewCount)!
    }
}
