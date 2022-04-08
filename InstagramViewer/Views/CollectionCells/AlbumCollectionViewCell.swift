//
//  AlbumCollectionViewCell.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/7/22.
//

import UIKit

/// Handles layout of multiple horizontal photos with timed scrolling.
final class AlbumCollectionViewCell: UICollectionViewCell {

    static let identifier = "AlbumCollectionViewCell"

    /// Used to track when user scrolls on the album to stop auto scrolling.
    private lazy var tapGesture: TouchInterceptorGesture = {
        let temp = TouchInterceptorGesture()
        temp.touchesBeganCallback = { [unowned self] (_,_) in
            self.timer = nil
        }
        return temp
    }()
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    /// Last row index where timer scolled.
    private var lastScrollIndex: Int = 0
    /// Timer that scrolls automatically.
    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    /// Images used to populate the horizontal collection
    var media: [MediaRequestResponse.Media] = [] {
        didSet {
            albumCollectionView.reloadData()
            if media.count > 1 {
                // set a timer that scrolls through pictures to see the album photos.
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] timer in
                    guard let self = self else {
                        return
                    }
                    
                    let totalItems = self.albumCollectionView.numberOfItems(inSection: 0)
                    
                    guard totalItems != 0 else {
                        // don't scroll if there are no pictures after a possible data refresh
                        timer.invalidate()
                        return
                    }
                    // scroll to next item if any or first item
                    let nextScrollIndex = self.lastScrollIndex + 1
                    let scrollIndexPath = IndexPath(row: nextScrollIndex >= totalItems ? 0 : nextScrollIndex,
                                                    section: 0)
                    self.lastScrollIndex = scrollIndexPath.row
                    self.albumCollectionView.scrollToItem(at: scrollIndexPath,
                                                          at: .centeredHorizontally,
                                                          animated: true)
                })
            } else {
                timer = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // configure album collection
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        
        albumCollectionView.register(UINib(nibName: PhotoCollectionCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        albumCollectionView.collectionViewLayout = makeLayout()
        
        contentView.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset data
        media = []
        timer = nil
        lastScrollIndex = 0
    }
}

extension AlbumCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier,
                                                      for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        switch cell {
            case let cell as PhotoCollectionCell:
            let media = media[indexPath.row]
            cell.imageURL = media.mediaUrl
            cell.dateLabel.text = media.dateText
        default:
            assertionFailure("Not handled")
            break
        }
    }
}

extension AlbumCollectionViewCell: UICollectionViewDelegate {
    
}

extension AlbumCollectionViewCell: UIGestureRecognizerDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        timer = nil
    }
}

extension AlbumCollectionViewCell {
    
    /// Create collection layout.
    /// - Returns: the collection  layout.
    func makeLayout() -> UICollectionViewLayout {
        let collecetionLayout: UICollectionViewLayout = {
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitem: item, count: 1)
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                            leading: 10,
                                                            bottom: 10,
                                                            trailing: 10)
            section.interGroupSpacing = 10
 
            let layout = UICollectionViewCompositionalLayout(section: section)
            let configuration = UICollectionViewCompositionalLayoutConfiguration()
            configuration.scrollDirection = .horizontal
            layout.configuration = configuration
            return layout
        }()
        return collecetionLayout
    }
}
