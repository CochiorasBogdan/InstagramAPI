//
//  SelfDecodable.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/6/22.
//

import Foundation

/// Defines helpers for decoding the class.
protocol SelfDecodable: Decodable {
    
    /// Decoder to be used for decoding the implementing class.
    static var decoder: JSONDecoder { get }
}
