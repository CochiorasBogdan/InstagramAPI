//
//  ListVM.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/7/22.
//

import Foundation
import RxSwift
import RxCocoa

final class ListVM: Paginator {
    
    weak var reloader: DataReloader?
    
    private var pages: [MediaRequestResponse] = []
    private var childrenMedia: [String: [MediaRequestResponse.Media]] = [:]
    
    private var childrenThatAreLoading = Set<String>()
    
    private let isLoading = BehaviorRelay<Bool>(value: false)
    var isLoadingDriver: Driver<Bool> {
        return isLoading.asDriver()
    }
    
    private let serverError = BehaviorRelay<Error?>(value: nil)
    var errorDriver: Driver<Error?> {
        return serverError.asDriver()
    }
    
    var prefetchCount: Int {
        return 2
    }
    
    var canLoadMore: Bool {
        guard let lastPage = pages.last else {
            // no pages loaded so no requests were made
            return true
        }
        // has a next page to load
        return lastPage.paging?.next != nil
    }
    
    func initialDataLoad() {
        guard !isLoading.value else {
            return
        }
        isLoading.accept(true)
        InstagramRequestManager.getMedia { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .failure(let error):
                self.serverError.accept(error)
            case .success(let response):
                self.pages = [response]
                // reload data since all data needs to be reset to first page
                self.reloader?.reloadData()
            }
            self.isLoading.accept(false)
        }
    }
    
    func loadMore() {
        guard !isLoading.value,
        canLoadMore,
        let nextPageURL = pages.last?.paging?.next else {
            return
        }
        isLoading.accept(true)
        InstagramRequestManager.getNextMediaPage(for: nextPageURL) { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .failure(let error):
                self.serverError.accept(error)
            case .success(let response):
                self.pages.append(response)
                // reload data since all data needs to be reset to first page
                self.reloader?.sectionAdded(indexSet: IndexSet(integer: self.pages.count - 1))
            }
            self.isLoading.accept(false)
        }
    }
    
    func fetchChildrenForMedia(id: String) {
        // check data is not already fetched
        if childrenMedia[id] != nil {
            return
        }
        
        guard !childrenThatAreLoading.contains(id) else {
            return
        }
        childrenThatAreLoading.insert(id)
        InstagramRequestManager.getMediaChildren(for: id) { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .failure(let error):
                self.serverError.accept(error)
            case .success(let response):
                // store children data by id
                if let data = response.data {
                    self.childrenMedia[id] = data
                    // reload media with album images
                    if let indexPath = self.indexPathFor(mediaId: id) {
                        self.reloader?.reload(indexPaths: [indexPath])
                    }
                }
            }
            // remove id from loading ids
            self.childrenThatAreLoading.remove(id)
        }
        
    }
    func indexPathFor(mediaId: String) -> IndexPath? {
        for (section, page) in pages.enumerated() {
            if let index = page.data?.firstIndex(where: {$0.id == mediaId}) {
                return IndexPath(row: index, section: section)
            }
        }
        return nil
    }
    
    func media(for indexPath: IndexPath) -> MediaRequestResponse.Media? {
        let page = pages[indexPath.section]
        return page.data?[indexPath.row]
    }
    
    func childrenImagesFor(mediaId: String) -> [MediaRequestResponse.Media] {
        guard let children = childrenMedia[mediaId] else {
            return []
        }
        return children
    }
    
    func numberOfSections() -> Int {
        return pages.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        let page = pages[section]
        return page.data?.count ?? 0
    }
    
    func canPrefetch(currentIndexPath: IndexPath) -> Bool {
        let lastSectionIndex = numberOfSections() - 1
        // chck if current index is in final section
        guard lastSectionIndex >= 0,
              currentIndexPath.section == lastSectionIndex else {
            return false
        }
        // check if row is after last index for prefetch
        return currentIndexPath.row > numberOfRows(in: lastSectionIndex) - prefetchCount
    }
    
    func reloadData() {
        reloader?.reloadData()
    }
    
    func sectionAdded(indexSet: IndexSet) {
        reloader?.sectionAdded(indexSet: indexSet)
    }
    
    func reload(indexPaths: [IndexPath]) {
        reloader?.reload(indexPaths: indexPaths)
    }
}
