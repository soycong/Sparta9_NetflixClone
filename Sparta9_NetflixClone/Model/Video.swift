//
//  Video.swift
//  Sparta9_NetflixClone
//
//  Created by seohuibaek on 12/26/24.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let key: String?
    let site: String?
    let type: String?
}
