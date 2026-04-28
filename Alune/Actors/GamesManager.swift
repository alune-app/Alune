import Core
import Foundation

import Foundation

let sectorSize = 2048

func readSector(_ fh: FileHandle, _ sector: UInt32, _ count: Int = 1) -> Data {
    try! fh.seek(toOffset: UInt64(sector) * UInt64(sectorSize))
    return try! fh.read(upToCount: sectorSize * count)!
}

func getRootDirectoryRecord(_ pvd: Data) -> (lba: UInt32, size: UInt32) {
    let rootOffset = 156

    return pvd.withUnsafeBytes { ptr in
        let base = ptr.baseAddress!

        let lba = base.load(fromByteOffset: rootOffset + 2, as: UInt32.self)
        let size = base.load(fromByteOffset: rootOffset + 10, as: UInt32.self)

        return (lba: lba.littleEndian, size: size.littleEndian)
    }
}

func findSystemCNF(_ dirData: Data) -> (lba: UInt32, size: UInt32)? {
    var offset = 0

    return dirData.withUnsafeBytes { ptr in
        let base = ptr.baseAddress!

        while offset < dirData.count {
            let length = Int(base.load(fromByteOffset: offset, as: UInt8.self))
            if length == 0 {
                offset = ((offset / sectorSize) + 1) * sectorSize
                continue
            }

            let nameLen = Int(base.load(fromByteOffset: offset + 32, as: UInt8.self))
            let namePtr = base + offset + 33

            let name = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: namePtr),
                              length: nameLen,
                              encoding: .ascii,
                              freeWhenDone: false)!

            if name.uppercased().contains("SYSTEM.CNF") {
                let lba = base.load(fromByteOffset: offset + 2, as: UInt32.self)
                let size = base.load(fromByteOffset: offset + 10, as: UInt32.self)
                return (lba.littleEndian, size.littleEndian)
            }

            offset += length
        }

        return nil
    }
}

func extractSerial(from systemCnf: Data) -> String? {
    guard let text = String(data: systemCnf, encoding: .ascii) else { return nil }

    guard let range = text.range(of: "cdrom0:\\") else { return nil }

    let start = range.upperBound
    let end = text[start...].firstIndex(of: ";") ?? text.endIndex

    return String(text[start..<end])
}

func getPS2Serial(from isoPath: String) -> String? {
    let fh = try! FileHandle(forReadingFrom: URL(fileURLWithPath: isoPath))

    // Step 1: Read PVD (sector 16)
    let pvd = readSector(fh, 16)

    // Step 2: Root directory
    let root = getRootDirectoryRecord(pvd)

    // Step 3: Read root directory
    let dirData = readSector(fh, root.lba, Int(root.size) / sectorSize + 1)

    // Step 4: Find SYSTEM.CNF
    guard let system = findSystemCNF(dirData) else { return nil }

    // Step 5: Read SYSTEM.CNF
    let systemData = readSector(fh, system.lba, Int(system.size) / sectorSize + 1)

    // Step 6: Extract serial
    return extractSerial(from: systemData)
}

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
                                // let data: Data = try Data(contentsOf: url)
                                // game.details.id = serial(url.path)
                                if let identifier: String = getPS2Serial(from: url.path) {
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
                        } else if ["bin", "chd", "cue", "elf"].contains(url.pathExtension.lowercased()) {
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
