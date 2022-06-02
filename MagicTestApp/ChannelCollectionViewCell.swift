import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelSubscribersCount: UILabel!
    
    @IBOutlet weak var channelCoverImageView: UIImageView!
    
    var channel: YoutubeChannel!

    override func layoutSubviews() {
        channelCoverImageView.layer.cornerRadius = 15
        channelCoverImageView.layer.masksToBounds = true
        
    }
    
    override func prepareForReuse() {
        channelCoverImageView.image = nil
    }
}
