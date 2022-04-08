//
//  ViewController.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/6/22.
//

import UIKit
import Kingfisher
import RxSwift

final class ListVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    private let viewModel = ListVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        viewModel.reloader = self
        collectionView.register(UINib(nibName: PhotoCollectionCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        collectionView.register(UINib(nibName: AlbumCollectionViewCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
        
        
        collectionView.collectionViewLayout = makeLayout()
        
        viewModel.initialDataLoad()

        // error handling
        var errorVisible = false
        viewModel.errorDriver.asDriver()
            .drive(onNext: { [weak self] error in
                guard let self = self,
                      let error = error,
                !errorVisible else {
                    return
                }
                errorVisible = true
                let alert = UIAlertController(title: "Unknown error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK",
                                           style: .default) { _ in
                    errorVisible = false
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}

/// Delegate definitions.
extension ListVC: UICollectionViewDelegate {
    
    
}

/// DataSource definitions.
extension ListVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let media = viewModel.media(for: indexPath) else {
            assertionFailure("Should not get here")
            return UICollectionViewCell()
        }
        
        let cell: UICollectionViewCell
        switch media.mediaType {
        case .carouselAlbum:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionViewCell.identifier,
                                                          for: indexPath)
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier,
                                                          for: indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // trigger data prefetching
        viewModel.loadMore()
        
        guard let media = viewModel.media(for: indexPath) else {
            return
        }
        switch cell {
        case let cell as PhotoCollectionCell:
            cell.imageURL = media.mediaUrl
            cell.dateLabel.text = media.dateText
        case let cell as AlbumCollectionViewCell:
            cell.media = viewModel.childrenImagesFor(mediaId: media.id)
            viewModel.fetchChildrenForMedia(id: media.id)
        default:
            assertionFailure("Not handled")
            break
        }
    }
}

/// Helper methods.
extension ListVC {
    
    /// Create collection layout
    /// - Returns: the horizontal layout.
    func makeLayout() -> UICollectionViewLayout {
        let collecetionLayout: UICollectionViewLayout = {
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                            leading: 10,
                                                            bottom: 10,
                                                            trailing: 10)
            section.interGroupSpacing = 10
            return UICollectionViewCompositionalLayout(section: section)
        }()
        return collecetionLayout
    }
}

extension ListVC: DataReloader {
    
    /// Handle section insertion
    /// - Parameter indexSet: section that were inserted.
    func sectionAdded(indexSet: IndexSet) {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.insertSections(indexSet)
        }
    }
    
    /// Handle data reload.
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    /// Handle indexPath reload.
    /// - Parameter indexPaths: indexPaths to reload.
    func reload(indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            // if there is a random crash just use self?.collectionView.reloadData(), didn't have time to investigate the issue
            self?.collectionView.reloadItems(at: indexPaths)
//            self?.collectionView.reloadData()
        }
    }
    
}
