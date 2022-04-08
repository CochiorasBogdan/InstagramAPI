//
//  InstagramAPI.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/6/22.
//

import Foundation
import Moya

/// Format response data to JSON string.
/// - Parameter data: server response data
/// - Returns: resulting JSON string.
private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

/// Global provider for the API.
let InstagramAPIProvider = MoyaProvider<InstagramAPI>(plugins: [
    NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
                                             logOptions: .verbose))
])

/// API requests definitions.
public enum InstagramAPI {
    /// Retrieve most recent paginated media files, limited by the specified number of items.
    case getMedia(limit: Int)
    /// Retrieve media items from an pagination `next` type URL.
    case getNextMedia(page: URL)
    /// Retrieve album media for the specified album media id.
    case getMediaChildren(id: String)
}

/// API requests target.
extension InstagramAPI: TargetType {
    
    /// Request headers.
    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    /// Base URL for requests.
    public var baseURL: URL {
        switch self {
        case .getMedia(_): fallthrough
        case .getMediaChildren(_):
            return URL(string: "https://graph.instagram.com")!
        case .getNextMedia(let page):
            return page
        
        }
    }
    
    /// Path to be added to the `baseURL`.
    public var path: String {
        switch self {
        case .getMedia(_): return "me/media"
        case .getNextMedia(_): return ""
        case .getMediaChildren(let id): return "\(id)/children"
        }
    }
    
    /// Final request task.
    public var task: Task {
        switch self {
        case .getMedia(let limit):
            // get all possible data for media
            let parameters = [
                "fields": [
                    "id",
                    "caption",
                    "media_type",
                    "media_url",
                    "permalink",
                    "thumbnail_url",
                    "timestamp",
                    "username"
                ].joined(separator: ","),
                "access_token": K.InstagramToken,
                "limit": "\(limit)"
            ]
            // check if access token was set
            assert(((parameters["access_token"])?.isEmpty ?? true) == false,
                   "Instagram 'me' access token not specified, please set K.InstagramToken from Constants.swift")
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.default)
        case .getMediaChildren(_):
            // get all possible data for albums
            let parameters = [
                "fields": [
                    "id",
                    "media_type",
                    "media_url",
                    "permalink",
                    "thumbnail_url",
                    "timestamp",
                    "username"
                ].joined(separator: ","),
                "access_token": K.InstagramToken,
            ]
            // check if access token was set
            assert(((parameters["access_token"])?.isEmpty ?? true) == false,
                   "Instagram 'me' access token not specified, please set K.InstagramToken from Constants.swift")
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.default)
        case .getNextMedia(_):
            return .requestPlain
        }
    }
    
    /// Codes to be considered valid.
    public var validationType: ValidationType {
        return .successCodes
    }
        
    /// Sample data for mock testing.
    public var sampleData: Data {
        return Data()
    }
    
    /// HTTP method of request.
    public var method: Moya.Method {
        switch self {
        case .getMedia: return .get
        case .getNextMedia(_): return .get
        case .getMediaChildren(_): return .get
        }
    }
}
