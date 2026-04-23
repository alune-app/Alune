//
//  SettingTypes.swift
//  SettingsKit
//
//  Created by Jarrod Norwell on 14/1/2025.
//

import Foundation
import UIKit

public class AnyHashableSendable : Hashable, @unchecked Sendable {
    var id: UUID = .init()
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyHashableSendable, rhs: AnyHashableSendable) -> Bool {
        lhs.id == rhs.id
    }
}

public class BaseSetting : AnyHashableSendable, @unchecked Sendable {
    public let key, title: String
    public var details: String? = nil,
               secondaryTitle: String? = nil
    public var delegate: SettingDelegate? = nil
    
    public init(key: String,
                title: String,
                details: String? = nil,
                secondaryTitle: String? = nil,
                delegate: (any SettingDelegate)? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.secondaryTitle = secondaryTitle
        self.delegate = delegate
    }
}

/*
 MARK: BlankSetting
 Used to add whitespace between settings
 */
public class BlankSetting : BaseSetting, @unchecked Sendable {}

/*
 MARK: BoolSetting
 Used to toggle something off or on
 */
public class BoolSetting : BaseSetting, @unchecked Sendable {
    public var isEnabled, value: Bool
    
    public init(key: String,
                title: String,
                details: String? = nil,
                secondaryTitle: String? = nil,
                isEnabled: Bool = true,
                value: Bool,
                delegate: (any SettingDelegate)? = nil) {
        self.isEnabled = isEnabled
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   secondaryTitle: secondaryTitle,
                   delegate: delegate)
    }
}

/*
 MARK: InputNumberSetting
 Used to input a number
 */
public class InputNumberSetting : BaseSetting, @unchecked Sendable {
    public let min, max: Double
    public var isEnabled: Bool
    public var value: Double
    
    public init(key: String,
                title: String,
                details: String? = nil,
                secondaryTitle: String? = nil,
                isEnabled: Bool = true,
                min: Double,
                max: Double,
                value: Double,
                delegate: (any SettingDelegate)? = nil) {
        self.min = min
        self.max = max
        self.isEnabled = isEnabled
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   secondaryTitle: secondaryTitle,
                   delegate: delegate)
    }
}

/*
 MARK: InputStringSetting
 Used to input a string
 */
public class InputStringSetting : BaseSetting, @unchecked Sendable {
    public var placeholder: String? = nil, value: String? = nil
    public let action: () -> Void
    
    public init(key: String,
                title: String,
                details: String? = nil,
                placeholder: String? = nil,
                value: String? = nil,
                action: @escaping () -> Void,
                delegate: (any SettingDelegate)? = nil) {
        self.placeholder = placeholder
        self.value = value
        self.action = action
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

/*
 MARK: SegmentedSetting
 Used to select from a list of values
 */
public class SegmentedSetting : BaseSetting, @unchecked Sendable {
    public let values: [String : Any]
    public var selectedValue: Any? = nil
    public var action: (UIViewController) -> Void
    
    public init(key: String,
                title: String,
                details: String? = nil,
                values: [String : Any],
                selectedValue: Any? = nil,
                action: @escaping (UIViewController) -> Void,
                delegate: (any SettingDelegate)? = nil) {
        self.values = values
        self.selectedValue = selectedValue
        self.action = action
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

/*
 MARK: SelectionSetting
 Used to select from a list of values
 */
public class SelectionSetting : BaseSetting, @unchecked Sendable {
    public let values: [String : Any]
    public var selectedValue: Any? = nil
    public var action: () -> Void
    
    public init(key: String,
                title: String,
                details: String? = nil,
                secondaryTitle: String? = nil,
                values: [String : Any],
                selectedValue: Any? = nil,
                action: @escaping () -> Void,
                delegate: (any SettingDelegate)? = nil) {
        self.values = values
        self.selectedValue = selectedValue
        self.action = action
        super.init(key: key,
                   title: title,
                   details: details,
                   secondaryTitle: secondaryTitle,
                   delegate: delegate)
    }
}

/*
 MARK: SliderSetting
 Used to slide to a value
 */
public class SliderSetting : BaseSetting, @unchecked Sendable {
    public var minImage: UIImage? = nil, maxImage: UIImage? = nil
    public let min, max: Double
    public var value: Double
    
    public init(key: String,
                title: String,
                details: String? = nil,
                minImage: UIImage? = nil,
                maxImage: UIImage? = nil,
                min: Double,
                max: Double,
                value: Double,
                delegate: (any SettingDelegate)? = nil) {
        self.minImage = minImage
        self.maxImage = maxImage
        self.min = min
        self.max = max
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

/*
 MARK: StepperSetting
 Used to step a value
 */
public class StepperSetting : BaseSetting, @unchecked Sendable {
    public let min, max: Double
    public var value: Double
    
    public init(key: String,
                title: String,
                details: String? = nil,
                min: Double,
                max: Double,
                value: Double,
                delegate: (any SettingDelegate)? = nil) {
        self.min = min
        self.max = max
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

public class TapSetting : BaseSetting, @unchecked Sendable {
    public var color: UIColor
    public var handler: (UIViewController) -> Void
    
    public init(key: String,
                title: String,
                details: String? = nil,
                color: UIColor = .systemBlue,
                handler: @escaping (UIViewController) -> Void,
                delegate: (any SettingDelegate)? = nil) {
        self.color = color
        self.handler = handler
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}
