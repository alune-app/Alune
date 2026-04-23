//
//  SettingHeader.swift
//  SettingsKit
//
//  Created by Jarrod Norwell on 14/1/2025.
//

import Foundation

public class SettingHeader : AnyHashableSendable, @unchecked Sendable {
    public var text: String? = nil
    public var secondaryText: String? = nil
    
    public init(text: String? = nil, secondaryText: String? = nil) {
        self.text = text
        self.secondaryText = secondaryText
    }
}
