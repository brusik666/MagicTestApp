import Foundation
import UIKit
import RxSwift
import RxCocoa

class ApiRequestController {

    private let videoBaseUrl = URL(string: "https://youtube.googleapis.com/youtube/v3/videos?part=statistics&part=snippet&id=HW-lXjOyUWo&key=AIzaSyDvBE_sgfl8bHMZ9iNY4jQIhvo_BQO5uG0")
    private let myYoutubeApiKey = "AIzaSyDvBE_sgfl8bHMZ9iNY4jQIhvo_BQO5uG0"
    private let jsonDecoder = JSONDecoder()
    private let baseYoutubeApiURL = URL(string: "https://youtube.googleapis.com/youtube/v3")!
    
    
    
    func fetchMergedData(with ids: [String]) -> Observable<YoutubeAPIService> {
        let urls = createURL(with: ids)
        return Observable.merge(urls.map { self.fetchData(with: $0!) })
    }
    
    func fetchData(with url: URL) -> Observable<YoutubeAPIService> {
        return Observable.create { observer -> Disposable in
            
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data,
                      let youtubeApiService = try? self.jsonDecoder.decode(YoutubeAPIService.self, from: data) else { return }
                observer.onNext(youtubeApiService)
                observer.onCompleted()
                
            }
            task.resume()
            return Disposables.create {}
        }
    }
    
    
    
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}

extension ApiRequestController {
    
    private func createURL(with itemID: [String]) -> [URL?] {
        let firstID = itemID.first!
        if firstID.contains("UC")  {
            return createURLforChannels(with: itemID)
        } else if firstID.contains("PL") || firstID.contains("UU") {
            return createPlaylistsURls(with: itemID)
        } else {
            return createURLForVideo(with: itemID)
        }
        
    }
    
    private func createURLforChannels(with channelIDs: [String]) -> [URL?] {
        let queryItemsDict: [String: Any] = [
            "part": ["contentDetails", "statistics", "brandingSettings", "snippet"],
            "id": channelIDs,
            "key": myYoutubeApiKey
        ]
        var urlComponents = URLComponents(url: baseYoutubeApiURL.appendingPathComponent("channels"), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = mapQueryItems(with: queryItemsDict)
        return [urlComponents?.url]
    }
    
    
    private func createURLsForPlaylist(with playlistIDs: [String]) -> [URL?] {
        
        //At first we need url for Playlist and then url for PlaylistItems
        let playlistQueryItemsDict: [String: Any] = [
            "part": "snippet",
            "id": playlistIDs,
            "key": myYoutubeApiKey,
            "maxResults": "10"
        ]
        var playlistUrlComponents = URLComponents(url: baseYoutubeApiURL.appendingPathComponent("playlists"), resolvingAgainstBaseURL: false)
        playlistUrlComponents?.queryItems = mapQueryItems(with: playlistQueryItemsDict)
        
        return [playlistUrlComponents?.url]

    }
    
    private func createURLsForPlaylistItems(with playlistIDs: [String]) -> [URL?] {
        let urls: [URL?] = playlistIDs.map { id in
            let playlistItemsQueryItemsDict: [String: Any] = [
                "part": "snippet",
                "playlistId": id,
                "key": myYoutubeApiKey,
                "maxResults": "10"
            ]
            var playlistItemsUrlComponents = URLComponents(url: baseYoutubeApiURL.appendingPathComponent("playlistItems"), resolvingAgainstBaseURL: false)
            playlistItemsUrlComponents?.queryItems = mapQueryItems(with: playlistItemsQueryItemsDict)
            return playlistItemsUrlComponents?.url
        }
        return urls
    }
    
    func createPlaylistsURls(with id:  [String]) -> [URL?] {
        let urls = createURLsForPlaylist(with: id) + createURLsForPlaylistItems(with: id)
        return urls
    }
    
    private func createURLForVideo(with videoIDs: [String]) -> [URL?] {
        let queryItemsDict: [String: Any] = [
            "part": ["snippet", "statistics"],
            "id": videoIDs,
            "key": myYoutubeApiKey,
            "maxResults": "20"
        ]
        
        var urlComponents = URLComponents(url: baseYoutubeApiURL.appendingPathComponent("videos"), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = mapQueryItems(with: queryItemsDict)
        return [urlComponents?.url]
        
        
    }
    
    private func mapQueryItems(with dict: [String: Any]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for (key, value) in dict {
            if let multipleValues = value as? [String] {
                queryItems.append(contentsOf: multipleValues.map{ URLQueryItem(name: key, value: $0) })
            } else {
                queryItems.append(URLQueryItem(name: key, value: value as? String))
            }
        }
        return queryItems
    }
    
    
}

