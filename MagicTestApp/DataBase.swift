import Foundation
import UIKit
import RxCocoa
import RxSwift
import WebKit

class DataBase: APIRequestControllerAvailable {
    
// MARK: - URLs and data for search in youtube API
    private let disposeBag = DisposeBag()
    private let youtubeChannelsIDs = ["UCEuOwB9vSL1oPKGNdONB4ig", "UCq19-LqvG35A-30oyAiPiqA", "UCNgjBASMIxygr65gJs9IyUA", "UCY2qt3dw2TQJxvBrDiYGHdQ"]
    private let youtubePlaylistsIDs = ["PLH0h8qdlkagpu1Lw6PnVK5TEMzHnRsgCN", "PL6305F709EB481224"]
    
// MARK: - Variables
    var channels = [YoutubeChannel?]()
    var playlists = [Playlist]()
    var videos = [Video?]()
    var videoIDs = [String]()
    var channelsSubject = BehaviorRelay<[YoutubeChannel]>(value: [])
    var playlistsSubject = BehaviorRelay<[Playlist]>(value: [])
    
    
    
}

// MARK: - Functions
extension DataBase {
    
    func loadChannelsData() {
        apiRequestController?.fetchMergedData(with: youtubeChannelsIDs)
            .subscribe(onNext: { [weak self] youtubeChannelsService in
                youtubeChannelsService.items.forEach({ item in
                    guard let channel = YoutubeChannel(with: item),
                        let self = self else { return }
                    let newValue = self.channelsSubject.value + [channel]
                    self.channelsSubject.accept(newValue)
                    
                })
            }, onCompleted: {
                self.channels.forEach { channel in
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func getVideos(with videoIDs: [String]) {
        apiRequestController?.fetchMergedData(with: videoIDs).subscribe(onNext: { youtubeVideoService in
            youtubeVideoService.items.forEach { item in
                let video = Video(with: item)
                self.videos.append(video)
              //  print("Dobavleno video \(video?.title). Vsego dobavleno \(self.videos.count) video")
            }
        }, onCompleted: {
            //print(self.videos.count)
            //print(self.playlists.count)
            //print(self.channels.count)
        })
        .disposed(by: disposeBag)
        
    }
    
    
    
    
    
    
    private func fetchPlaylistsData() {
        apiRequestController?.fetchMergedData(with: youtubePlaylistsIDs).subscribe(onNext: { youtubePlatlistsService in
            for item in youtubePlatlistsService.items {
                if item.snippet?.resourceId == nil {
                    guard let playList = Playlist(with: item) else { continue }
                    self.playlists.append(playList)
                } else {
                    guard let videoID = item.snippet?.resourceId?.videoId else { continue }
                    DispatchQueue.main.async {
                        self.getVideos(with: [videoID])
                    }
                    
                }
            }
        }, onCompleted: {
            print(self.playlists.count)
            
        }).disposed(by: disposeBag)
        
    }
    
    func loadAllData() {
        loadChannelsData()
        //fetchPlaylistsData()
        guard let urls = apiRequestController?.createURLsForPlaylistItems(with: youtubePlaylistsIDs) else { return }
        var videoIDs: [[String]] = []
        urls.forEach { url in
            apiRequestController?.fetchData(with: url!).subscribe(onNext: { youtubeServiceApi in
                let videos1 = youtubeServiceApi.items.map {$0.snippet?.resourceId?.videoId}
                var unwrappedVideos1 = [String]()
                videos1.forEach { id in
                    guard let id = id else { return }
                    print(id)
                    unwrappedVideos1.append(id)
                }
                videoIDs.append(unwrappedVideos1)
                print(unwrappedVideos1.count)
                
            })
        }
        guard let playListUrls = apiRequestController?.createURLsForPlaylist(with: youtubePlaylistsIDs) else { return }
        print("zagruzka started")
        var playlists = [Playlist]()
        playListUrls.forEach { url in
            apiRequestController?.fetchData(with: url!).subscribe(onNext: { youtubeApiService in
                guard let playlist = Playlist(with: youtubeApiService.items.first!) else { return }
                playlists.append(playlist)
            }, onCompleted: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    print(videoIDs.count)
                }
               // playlists[0].videoIDs = videoIDs[0]
               // playlists[1].videoIDs = videoIDs[1]
                for playlist in playlists {
               //     print(playlist.title)
                 //   print(playlist.videoIDs)
                }
            })
        }
        
        
    }
}

