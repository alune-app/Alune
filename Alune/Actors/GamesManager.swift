import Core
import Foundation

actor GamesManager {
    func games() async -> ([Game], [String]) {
        var games: AnyRangeReplaceableCollection<Game> = []
        var letters: AnyRangeReplaceableCollection<String> = []

        if let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let isosSubdirectoryURL: URL = documentDirectoryURL.appending(component: "isos")
            if let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(at: isosSubdirectoryURL,
                                                                                                includingPropertiesForKeys: nil,
                                                                                                options: .skipsHiddenFiles) {
                await enumerator.asyncForEach { element in
                    if let url: URL = element as? URL {
                        let game: Game = Game(url: url)

                        if url.pathExtension.lowercased() == "iso" {
                            do {
                                let data: Data = try Data(contentsOf: url)
                                // game.details.id = serial(url.path)
                                if let identifier: String = getPS2GameID(from: data) {
                                    game.details.id = identifier
                                }

                                let attributes: [FileAttributeKey: Any] = try FileManager.default.attributesOfItem(atPath: url.path)
                                if let size: NSNumber = attributes[.size] as? NSNumber {
                                    game.details.size = ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
                                }

                                games.appendUnique(game)
                                letters.appendUnique(game.details.name.prefix(1).uppercased())
                            } catch {
                                print(#file, #function, #line, error, error.localizedDescription)
                            }
                        } else if url.pathExtension.lowercased() == "elf" {
                            do {
                                let attributes: [FileAttributeKey: Any] = try FileManager.default.attributesOfItem(atPath: url.path)
                                if let size: NSNumber = attributes[.size] as? NSNumber {
                                    game.details.size = ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
                                }

                                games.appendUnique(game)
                                letters.appendUnique(game.details.name.prefix(1).uppercased())
                            } catch {
                                print(#file, #function, #line, error, error.localizedDescription)
                            }
                        }
                    }
                }
            }

            return (games.sorted(), letters.sorted())
        } else {
            return ([], [])
        }
    }
}
