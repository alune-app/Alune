import Foundation

struct ISO9660 {
    let data: Data

    private let sectorSize: Int = 2048

    func readSector(_ lba: UInt32, count: UInt32 = 1) -> Data {
        let offset = Int(lba) * sectorSize
        let size = Int(count) * sectorSize
        return data.subdata(in: offset..<(offset + size))
    }

    func findSystemCNF() -> (lba: UInt32, size: UInt32)? {
        return data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) -> (lba: UInt32, size: UInt32)? in
            guard let base = raw.baseAddress else { return nil }

            // Helpers for unaligned reads
            func u32(_ ptr: UnsafeRawPointer, _ offset: Int) -> UInt32 {
                ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
            }

            func u8(_ ptr: UnsafeRawPointer, _ offset: Int) -> UInt8 {
                ptr.loadUnaligned(fromByteOffset: offset, as: UInt8.self)
            }

            // Primary Volume Descriptor (sector 16)
            let pvdOffset = 16 * sectorSize
            let root = base.advanced(by: pvdOffset + 156)

            let rootLBA  = UInt32(littleEndian: u32(root, 2))
            let rootSize = UInt32(littleEndian: u32(root, 10))

            // Read root directory
            let dirData = readSector(rootLBA, count: (rootSize + 2047) / 2048)

            return dirData.withUnsafeBytes { (dirRaw: UnsafeRawBufferPointer) -> (lba: UInt32, size: UInt32)? in
                guard let dirBase = dirRaw.baseAddress else { return nil }

                var offset = 0
                let totalSize = dirData.count

                while offset < totalSize {
                    let length = Int(u8(dirBase, offset))

                    // Move to next sector if padding
                    if length == 0 {
                        offset = ((offset / 2048) + 1) * 2048
                        continue
                    }

                    let record = dirBase.advanced(by: offset)

                    let extentLBA = UInt32(littleEndian: u32(record, 2))
                    let fileSize  = UInt32(littleEndian: u32(record, 10))
                    let nameLen   = Int(u8(record, 32))

                    let namePtr = record.advanced(by: 33)

                    // Safely construct string
                    let name = String(bytes: UnsafeRawBufferPointer(start: namePtr, count: nameLen),
                                      encoding: .ascii) ?? ""

                    // ISO9660 filenames often include version suffix like ";1"
                    let cleanName = name.split(separator: ";").first.map(String.init) ?? name

                    if cleanName.caseInsensitiveCompare("SYSTEM.CNF") == .orderedSame {
                        return (extentLBA, fileSize)
                    }

                    offset += length
                }

                return nil
            }
        }
    }

    func readFile(lba: UInt32, size: UInt32) -> Data {
        let sectorCount = (size + 2047) / 2048
        return readSector(lba, count: sectorCount).prefix(Int(size))
    }
}
