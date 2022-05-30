import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController, DataBaseAbailable, APIRequestControllerAvailable {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.register(ChannelCollectionViewCell.self, forSupplementaryViewOfKind: "cell", withReuseIdentifier: "ChannelCell")
        
        
        dataBase?.channelsSubject.bind(to: collectionView.rx.items(cellIdentifier: "ChannelCell", cellType: ChannelCollectionViewCell.self)) { (row, channel, cell) in
            cell.channelSubscribersCount.text = channel.subscribersCount
            cell.channelTitleLabel.text = channel.title
            self.apiRequestController?.fetchImage(url: URL(string: channel.imageURLString!)!, completion: { image in
                guard let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    cell.channelCoverImageView.image = image
                }
            })
        }
        
        
        
    }
    
    
    func generateLayout() -> UICollectionViewLayout {
        let spacing = CGFloat(20)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(view.bounds.height/3.5))
        let group = NSCollectionLayoutGroup.horizontal (layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

}

