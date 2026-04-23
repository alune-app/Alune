//
//  Game.swift
//  Alune
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import Foundation

class Game : BaseGame, @unchecked Sendable {
    var details: GameDetails

    init(url: URL) {
        details = GameDetails(url: url)
        super.init(details: details)
    }

    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
