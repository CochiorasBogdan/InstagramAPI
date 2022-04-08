//
//  MediaRequestResponse.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/6/22.
//

import Foundation

/// Media response definition.
struct MediaRequestResponse: SelfDecodable {
    let data: [Media]?
    let paging: Paging?
        
    /// Default decoder to be used for `MediaRequestResponse` decoding.
    static var decoder: JSONDecoder {
        let temp = JSONDecoder()
        temp.keyDecodingStrategy = .convertFromSnakeCase
        temp.dateDecodingStrategy = .formatted(.iso8601Full)
        return temp
    }
    
    enum CodingKeys: String, CodingKey {
        case data
        case paging
    }
}

/// Media definition.
extension MediaRequestResponse {
    struct Media: Decodable {
        enum MediaType: String, Decodable {
            case image = "IMAGE"
            case video = "VIDEO"
            case carouselAlbum = "CAROUSEL_ALBUM"
        }
        
        let id: String
        let caption: String?
        let mediaType: MediaType?
        let mediaUrl: URL?
        let permalink: URL?
        let timestamp: Date?
        let username: String?
        
        var dateText: String? {
            guard let timestamp = timestamp else {
                return nil
            }

            // format date text for UI
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return formatter.string(from: timestamp)
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case caption
            case mediaType
            case mediaUrl
            case permalink
            case timestamp
            case username
        }
    }
}

/// Paging definition.
extension MediaRequestResponse {
    struct Paging: Decodable {
        struct Cursors: Decodable {
            let before: String?
            let after: String?
            
            enum CodingKeys: String, CodingKey {
                case before
                case after
            }
        }
        let cursors: Cursors?
        let next: URL?
        
        enum CodingKeys: String, CodingKey {
            case cursors
            case next
        }
    }
}
