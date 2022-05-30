import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelSubscribersCount: UILabel!
    
    @IBOutlet weak var channelCoverImageView: UIImageView!
    
    override func layoutSubviews() {
        channelCoverImageView.layer.cornerRadius = 15
        channelCoverImageView.layer.masksToBounds = true
        
    }
}
