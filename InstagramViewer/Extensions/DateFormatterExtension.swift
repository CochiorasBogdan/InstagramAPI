//
//  DateFormatterExtensions.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/7/22.
//

import Foundation

extension DateFormatter {
    
    /// ISO date formatter.
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
}
