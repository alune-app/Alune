import Foundation

func extractGameID(from systemCNF: Data) -> String? {
    guard let text = String(data: systemCNF, encoding: .ascii) else {
        return nil
    }

    let pattern = #"(S[CL][A-Z]{2}_[0-9]{3}\.[0-9]{2})"#

    if let range = text.range(of: pattern, options: .regularExpression) {
        let id = String(text[range])
        return id
    }

    return nil
}

func getPS2GameID(from isoData: Data) -> String? {
    let iso = ISO9660(data: isoData)

    guard let (lba, size) = iso.findSystemCNF() else {
        return nil
    }

    let cnfData = iso.readFile(lba: lba, size: size)
    return extractGameID(from: cnfData)
}
