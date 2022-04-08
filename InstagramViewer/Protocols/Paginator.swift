//
//  Paginator.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/8/22.
//

import Foundation
import RxCocoa

/// Defines helper methods for pagination handling and interaction.
protocol Paginator {
    
    /// Used to observe data fetching for UI updateing.
    var isLoadingDriver: Driver<Bool> { get }
    
    /// Used to establish if there is more data to be fetch for paging.
    var canLoadMore: Bool { get }
    
    /// Used to update the interface in case of errors.
    var errorDriver: Driver<Error?> { get }
    
    ///  Number of items before last item of the list where to start prefetching data.
    var prefetchCount: Int { get }
    
    /// Used to load initial data, calling this should remove old existing data on refresh.
    func initialDataLoad() -> Void
    
    /// Called to load more pages of data after initial load.
    func loadMore() -> Void
    
    /// Establishes if there is more data to be fetched.
    func canPrefetch(currentIndexPath: IndexPath) -> Bool
}
