//
//  DataReloader.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/8/22.
//

import Foundation

/// Defines methods called for interface date refresh.
protocol DataReloader: AnyObject {
    
    /// Called when new sections are added
    /// - Returns: nothing
    func sectionAdded(indexSet: IndexSet) -> Void
    
    /// Called when the entire data needs to be reloaded.
    /// - Returns: nothing
    func reloadData() -> Void
    
    /// Reload specified sections.
    /// - Returns: nothing
    func reload(indexPaths: [IndexPath]) -> Void
}
