//
//  VideoCollectionViewCell.swift
//  MagicTestApp
//
//  Created by Brusik on 30.05.2022.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell, APIRequestControllerAvailable {
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoBannerImageView: UIImageView!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    func configure(title: String, urlString: String, viewCount: Int) {
        videoTitleLabel.text = title
        guard let url = URL(string: urlString) else { return }
        apiRequestController?.fetchImage(url: url, completion: { image in
            guard let image = image else {
                return
            }
            DispatchQueue.main.async {
                self.videoBannerImageView.image = image
            }
        })
        
    }
}