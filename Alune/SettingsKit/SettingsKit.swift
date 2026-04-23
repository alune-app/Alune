// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public actor SettingsKit {
    public init() {}
    
    public func blank() -> BlankSetting {
        .init(key: "",
              title: "")
    }
    
    public func bool(key: String,
                     title: String,
                     details: String? = nil,
                     secondaryTitle: String? = nil,
                     isEnabled: Bool = true,
                     value: Bool,
                     delegate: (any SettingDelegate)? = nil) -> BoolSetting {
        .init(key: key,
              title: title,
              details: details,
              secondaryTitle: secondaryTitle,
              isEnabled: isEnabled,
              value: value,
              delegate: delegate)
    }
    
    public func inputNumber(key: String,
                            title: String,
                            details: String? = nil,
                            min: Double,
                            max: Double,
                            value: Double,
                            delegate: (any SettingDelegate)? = nil) -> InputNumberSetting {
        .init(key: key,
              title: title,
              details: details,
              min: min,
              max: max,
              value: value,
              delegate: delegate)
    }
    
    public func inputString(key: String,
                            title: String,
                            details: String? = nil,
                            placeholder: String? = nil,
                            value: String? = nil,
                            action: @escaping () -> Void,
                            delegate: (any SettingDelegate)? = nil) -> InputStringSetting {
        .init(key: key,
              title: title,
              details: details,
              placeholder: placeholder,
              value: value,
              action: action,
              delegate: delegate)
    }
    
    public func segmented(key: String,
                          title: String,
                          details: String? = nil,
                          values: [String : Any],
                          selectedValue: Any? = nil,
                          action: @escaping () -> Void,
                          delegate: (any SettingDelegate)? = nil) -> SelectionSetting {
        .init(key: key,
              title: title,
              details: details,
              values: values,
              selectedValue: selectedValue,
              action: action,
              delegate: delegate)
    }
    
    public func selection(key: String,
                          title: String,
                          details: String? = nil,
                          values: [String : Any],
                          selectedValue: Any? = nil,
                          action: @escaping () -> Void,
                          delegate: (any SettingDelegate)? = nil) -> SelectionSetting {
        .init(key: key,
              title: title,
              details: details,
              values: values,
              selectedValue: selectedValue,
              action: action,
              delegate: delegate)
    }
    
    public func slider(key: String,
                       title: String,
                       details: String? = nil,
                       minImage: UIImage? = nil,
                       maxImage: UIImage? = nil,
                       min: Double,
                       max: Double,
                       value: Double,
                       delegate: (any SettingDelegate)? = nil) -> SliderSetting {
        .init(key: key,
              title: title,
              details: details,
              minImage: minImage,
              maxImage: maxImage,
              min: min,
              max: max,
              value: value,
              delegate: delegate)
    }
    
    public func stepper(key: String,
                        title: String,
                        details: String? = nil,
                        min: Double,
                        max: Double,
                        value: Double,
                        delegate: (any SettingDelegate)? = nil) -> StepperSetting {
        .init(key: key,
              title: title,
              details: details,
              min: min,
              max: max,
              value: value,
              delegate: delegate)
    }
    
    public func tap(key: String,
                    title: String,
                    details: String? = nil,
                    handler: @escaping (UIViewController) -> Void,
                    delegate: (any SettingDelegate)? = nil) -> TapSetting {
        .init(key: key,
              title: title,
              details: details,
              handler: handler,
              delegate: delegate)
    }
}
