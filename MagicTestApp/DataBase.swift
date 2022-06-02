import Foundation
import UIKit
import RxCocoa
import RxSwift
import WebKit

class DataBase: APIRequestControllerAvailable {
    
// MARK: - URLs and data for search in youtube API
    private let disposeBag = DisposeBag()
    private let youtubeChannelsIDs = ["UCEuOwB9vSL1oPKGNdONB4ig", "UCq19-LqvG35A-30oyAiPiqA", "UCNgjBASMIxygr65gJs9IyUA", "UCY2qt3dw2TQJxvBrDiYGHdQ"]
    private let youtubePlaylistsIDs = ["PL1343579D67ED4740", "PL6305F709EB481224"]
    
// MARK: - Variables

    var channelsSubject = BehaviorRelay<[YoutubeChannel]>(value: [])
    var playlists1Subject = BehaviorRelay<[Video]>(value: [])
    var playlist2Subject = BehaviorRelay<[Video]>(value: [])
    
}

// MARK: - Functions
extension DataBase {
    
    private func loadChannelsData() {
        apiRequestController?.fetchMergedData(with: youtubeChannelsIDs)
            .subscribe(onNext: { [weak self] youtubeChannelsService in
                youtubeChannelsService.items.forEach({ item in
                    guard let channel = YoutubeChannel(with: item),
                        let self = self else { return }
                    let newValue = self.channelsSubject.value + [channel]
                    self.channelsSubject.accept(newValue)
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func loadPlaylistsData() {
        guard let urls = apiRequestController?.createURLsForPlaylistItems(with: youtubePlaylistsIDs) else { return }
        urls.forEach { url in
            apiRequestController?.fetchData(with: url!).subscribe(onNext: { youtubeServiceApi in
                youtubeServiceApi.items.forEach { item in
                    let videoID = item.snippet?.resourceId?.videoId
                    DispatchQueue.main.async {
                        guard let url1 = self.apiRequestController?.createURLForVideo(with: videoID!) else { return }
                        self.apiRequestController?.fetchData(with: url1).subscribe(onNext: { youtubeApiService in
                            for item in youtubeApiService.items {
                                guard var video = Video(with: item) else { return }
                                video.id = videoID
                                
                                if video.title.hasPrefix("Gor") {
                                    let newValue = self.playlists1Subject.value + [video]
                                    self.playlists1Subject.accept(newValue)
                                } else {
                                    let newValue = self.playlist2Subject.value + [video]
                                    self.playlist2Subject.accept(newValue)
                                }
                            }
                        }).disposed(by: self.disposeBag)
                    }
                }
            })
            .disposed(by: disposeBag)
        }
    }
    
    
    func loadAllData() {
        loadChannelsData()
        loadPlaylistsData()
    }
}

