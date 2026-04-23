//
//  GameDetails.swift
//  Alune
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import Foundation

class GameDetails: Codable {
    let `extension`: String
    var id, name, size: String
    let url: URL

    init(url: URL) {
        `extension` = url.pathExtension
        id = UUID().uuidString
        name = url.deletingPathExtension().lastPathComponent
        size = "Unknown KB"
        self.url = url
    }
}
