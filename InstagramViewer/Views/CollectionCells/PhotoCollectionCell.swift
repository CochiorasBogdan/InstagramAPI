//
//  PhotoCollectionCell.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/7/22.
//

import UIKit
import Kingfisher

/// Cell used to display an image element and a title.
final class PhotoCollectionCell: UICollectionViewCell {

    static let identifier = "PhotoCollectionCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    /// Image to be loaded.
    var imageURL: URL? {
        didSet {
            imageView.kf.setImage(with: imageURL) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(_):
                    // do nothing
                    break
                case .success(let imageResult):
                    // update aspect ratio to respect image aspect ratio
                    let imageSize = imageResult.image.size
                    self.imageViewAspectRatioConstraint.constant = imageSize.height / imageSize.width
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset data
        imageURL = nil
        dateLabel.text = nil
    }
}
