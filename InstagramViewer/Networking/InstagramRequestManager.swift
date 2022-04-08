//
//  InstagramRequestManager.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/6/22.
//

import Foundation
import UIKit

/// Handles requests to the Instagram API.
struct InstagramRequestManager {
    /// Wrapper for server response types.
    enum Response<SuccessResponse, FailureResponse> {
        case success(SuccessResponse)
        case failure(FailureResponse)
    }
    
    private init() {}
    
    /// Retrieves media ids from server.
    /// - Parameter completion: server response data or error.
    static func getMedia(completion: @escaping (Response<MediaRequestResponse, Error>) -> Void) {
        InstagramAPIProvider.request(InstagramAPI.getMedia(limit: 1)) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                do {
                    let response = try response.map(MediaRequestResponse.self,
                                                    using: MediaRequestResponse.decoder)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Retrieve media data from specified url.
    /// - Parameters:
    ///   - url: the URL of the next media page.
    ///   - completion: server response data or error.
    static func getNextMediaPage(for url: URL, completion: @escaping (Response<MediaRequestResponse, Error>) -> Void) {
        InstagramAPIProvider.request(InstagramAPI.getNextMedia(page: url)) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                do {
                    let response = try response.map(MediaRequestResponse.self,
                                                    using: MediaRequestResponse.decoder)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Retrieve media contained in an album.
    /// - Parameters:
    ///   - id: identifier of the album for which to retrieve the media children.
    ///   - completion: server response data or error.
    static func getMediaChildren(for id: String, completion: @escaping (Response<MediaRequestResponse, Error>) -> Void) {
        InstagramAPIProvider.request(InstagramAPI.getMediaChildren(id: id)) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                do {
                    let response = try response.map(MediaRequestResponse.self,
                                                    using: MediaRequestResponse.decoder)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
}
