//
//  BaseGame.swift
//  Alune
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import Foundation

class BaseGame : Codable, Comparable, Hashable, @unchecked Sendable {
    var id: UUID = UUID()
    let name: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BaseGame, rhs: BaseGame) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: BaseGame, rhs: BaseGame) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }

    init(details: GameDetails) {
        name = details.name
    }
}
