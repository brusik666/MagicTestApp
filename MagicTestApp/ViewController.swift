import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController, DataBaseAbailable, APIRequestControllerAvailable {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var playlistCollectionView: UICollectionView!
    
    @IBOutlet weak var playlist2CollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(UICollectionViewLayout.generateChannelLayout(view: view), animated: true)
        playlistCollectionView.setCollectionViewLayout(UICollectionViewLayout.generatePlaylist1Layout(view: view), animated: true)
        playlist2CollectionView.setCollectionViewLayout(UICollectionViewLayout.generatePlaylist2Layout(view: view), animated: true)
        
        
       dataBase?.channelsSubject.bind(to: collectionView.rx.items(cellIdentifier: "ChannelCell", cellType: ChannelCollectionViewCell.self)) { (row, channel, cell) in
            cell.channelSubscribersCount.text = channel.subscribersCount
            cell.channelTitleLabel.text = channel.title
            cell.channel = channel
            self.apiRequestController?.fetchImage(url: URL(string: channel.imageURLString!)!, completion: { image in
                guard let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    cell.channelCoverImageView.image = image
                }
            })
       }
        
        dataBase?.playlists1Subject.bind(to: playlistCollectionView.rx.items(cellIdentifier: "VideoCell", cellType: VideoCollectionViewCell.self)) { (row, video, cell) in
            cell.viewCountLabel.text = video.viewCount
            cell.videoTitleLabel.text = video.title
            cell.video = video
            
            self.apiRequestController?.fetchImage(url: URL(string: video.coverURLstring)!, completion: { image in
                guard let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    cell.videoBannerImageView.image = image
                }
            })
        }
        dataBase?.playlist2Subject.bind(to: playlist2CollectionView.rx.items(cellIdentifier: "VideoCell", cellType: VideoCollectionViewCell.self)) { (row, video, cell) in
            cell.viewCountLabel.text = video.viewCount
            cell.videoTitleLabel.text = video.title
            self.apiRequestController?.fetchImage(url: URL(string: video.coverURLstring)!, completion: { image in
                guard let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    cell.videoBannerImageView.image = image
                }
            })
        }
        
    }

}

