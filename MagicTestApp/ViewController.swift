import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import youtube_ios_player_helper

class ViewController: UIViewController, DataBaseAbailable, APIRequestControllerAvailable, YTPlayerViewDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var playlistCollectionView: UICollectionView!
    
    @IBOutlet weak var hidePlayerButton: UIButton!
    @IBOutlet weak var playlist2CollectionView: UICollectionView!
    @IBOutlet weak var youTubePlayerView: YTPlayerView!
    @IBOutlet weak var youtubePlayerViewContainer: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songViewCountLabel: UILabel!
    @IBOutlet weak var youtubePlayerContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var songDurationSlider: UISlider!
    var isPlayerHidden = true
    var isplayerPlaying = BehaviorRelay<Bool>(value: false)
    

    

    
    private let playerVars = [
        "autoplay": 1,
        "controls": 0,
        "iv_load_policy": 3,
        "rel": 0,
        "showinfo": 0,
        "modestbranding": 1,
        "disablekb": 1,
        "playsinline": 1,
        "autohide": 1
    ]
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        youTubePlayerView.delegate = self
        youTubePlayerView.isUserInteractionEnabled = false
        
        setAllCollectionViewsLayout()
        let gradiendLayer = CAGradientLayer()
        gradiendLayer.frame = view.bounds
        gradiendLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        youtubePlayerViewContainer.layer.insertSublayer(gradiendLayer, at: 0)
        
        bindAllDataToCollectionViews()
        configureChannelCellSelectionHandling()
        configurePlaylistCellSelectionHandling()
        configurePlaylist2CellSelectionHandling()
        setupPlayerRX()
        

    }
    
    private func setAllCollectionViewsLayout() {
        collectionView.setCollectionViewLayout(UICollectionViewLayout.generateChannelLayout(view: collectionView), animated: true)
        playlistCollectionView.setCollectionViewLayout(UICollectionViewLayout.generatePlaylist1Layout(view: view), animated: true)
        playlist2CollectionView.setCollectionViewLayout(UICollectionViewLayout.generatePlaylist2Layout(view: view), animated: true)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
    }
    
    
    
    private func setupPlayerRX() {
        isplayerPlaying.asObservable().subscribe { isPlaying in
            switch isPlaying.element {
            case false:
                self.playButton.isSelected = false
            default:
                self.playButton.isSelected = true
            }
        }.disposed(by: disposeBag)

    }
    
    private func bindAllDataToCollectionViews() {
        bindChannelsToCollectionView()
        bindPlayList1CollectionView()
        bindPlaylist2CollectionView()
    }
    
    private func bindChannelsToCollectionView() {
        dataBase?.channelsSubject.bind(to: collectionView.rx.items(cellIdentifier: "ChannelCell", cellType: ChannelCollectionViewCell.self)) { (row, channel, cell) in
             cell.channelSubscribersCount.text = "\(channel.subscribersCount ?? "") подписчика"
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
        
        }.disposed(by: disposeBag)
    }
    
    private func configureChannelCellSelectionHandling() {
        collectionView.rx.modelSelected(YoutubeChannel.self)
            .subscribe { channel in
                self.songDurationSlider.value = 0
                self.animatePlayerView()
                guard let uploads = channel.element?.uploads else { return }
                self.youTubePlayerView.load(withPlaylistId: uploads, playerVars: self.playerVars)
                self.playerViewDidBecomeReady(self.youTubePlayerView)
            }
            .disposed(by: disposeBag)
    }
    
    private func configurePlaylistCellSelectionHandling() {
        playlistCollectionView.rx.modelSelected(Video.self)
            .subscribe { video in
                
                self.songDurationSlider.value = 0
                self.animatePlayerView()

                guard let videoID = video.element?.id else { return }
                self.youTubePlayerView.load(withVideoId: videoID, playerVars: self.playerVars)
                self.songTitleLabel.text = video.element?.title
                self.songViewCountLabel.text = "\(video.element?.viewCount ?? "") просмотра"
                self.playerViewDidBecomeReady(self.youTubePlayerView)
                self.isplayerPlaying.accept(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configurePlaylist2CellSelectionHandling() {
        playlist2CollectionView.rx.modelSelected(Video.self)
            .subscribe { video in
                
                self.songDurationSlider.value = 0
                self.animatePlayerView()
                guard let videoID = video.element?.id else { return }
                self.youTubePlayerView.load(withVideoId: videoID, playerVars: self.playerVars)
                self.songTitleLabel.text = video.element?.title
                self.songViewCountLabel.text = "\(video.element?.viewCount ?? "") просмотра"
                self.playerViewDidBecomeReady(self.youTubePlayerView)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindPlayList1CollectionView() {
        dataBase?.playlists1Subject.bind(to: playlistCollectionView.rx.items(cellIdentifier: "VideoCell", cellType: VideoCollectionViewCell.self)) { (row, video, cell) in
            cell.viewCountLabel.text = video.viewCount + " просмотра"
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
        .disposed(by: disposeBag)
    }
    
    
    private func bindPlaylist2CollectionView() {
        dataBase?.playlist2Subject.bind(to: playlist2CollectionView.rx.items(cellIdentifier: "VideoCell", cellType: VideoCollectionViewCell.self)) { (row, video, cell) in
            cell.viewCountLabel.text = video.viewCount + " просмотра"
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
        .disposed(by: disposeBag)
    }
    
    private func animatePlayerView() {
        if youtubePlayerContainerTopConstraint.constant == 16 {
            youtubePlayerContainerTopConstraint.constant = 755
        } else {
            youtubePlayerContainerTopConstraint.constant = 16
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func hideOpenPlayer(_ sender: Any) {
        animatePlayerView()
        isPlayerHidden.toggle()
        guard let img1 = UIImage(named: "Close_Open_Reversed.png"),
              let img2 = UIImage(named: "Close_Open.png") else { return }
        if isPlayerHidden {
            hidePlayerButton.setImage(img1, for: .normal)
        } else {
            hidePlayerButton.setImage(img2, for: .normal)
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            youTubePlayerView.playVideo()
        } else {
            youTubePlayerView.pauseVideo()
        }
        
    }
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        youTubePlayerView.nextVideo()
    }
    @IBAction func previousButtonTapped(_ sender: UIButton) {
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        youTubePlayerView.duration { time, error in
            let seekToTime = Float(time) * sender.value
            self.youTubePlayerView.seek(toSeconds: seekToTime, allowSeekAhead: true)

        }
    }
    
    
    
    private func playVideo(withID id: String) {
        
        self.youTubePlayerView.load(withVideoId: id)
        playerViewDidBecomeReady(youTubePlayerView)
        
    }
    
    internal func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        youTubePlayerView.playVideo()
        
        
    }
    internal func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        youTubePlayerView.duration { duration, error in
            let progress = playTime / Float(duration)
            self.songDurationSlider.value = progress
        }
    }
    
    
    
}

