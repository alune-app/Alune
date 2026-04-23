import Foundation

typealias AnyRangeReplaceableCollection<T> = any RangeReplaceableCollection<T>
extension RangeReplaceableCollection where Element == Game {
    mutating func appendUnique(_ element: Element) {
        if !contains(where: { game in game.name == element.name }) {
            append(element)
        }
    }
}

extension RangeReplaceableCollection where Element == String {
    mutating func appendUnique(_ element: Element) {
        if !contains(where: { letter in letter == element }) {
            append(element)
        }
    }
}
