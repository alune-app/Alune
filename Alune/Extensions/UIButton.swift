import UIKit

typealias Actions = (touchDown: (UIAction) async -> Void, touchUpInside: (UIAction) async -> Void)

extension UIButton {
    static func button(with configuration: Configuration, actions: Actions, _ menu: UIMenu? = nil) -> UIButton {
        let button: UIButton = .init(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let menu {
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        } else {
            button.addAction(UIAction { action in
                Task {
                    await actions.touchDown(action)
                }
            }, for: .touchDown)
            button.addAction(UIAction { action in
                Task {
                    await actions.touchUpInside(action)
                }
            }, for: .touchUpInside)
            button.addAction(UIAction { action in
                Task {
                    await actions.touchUpInside(action)
                }
            }, for: .touchUpOutside)
        }
        
        if #unavailable(iOS 26) {
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 1 / 5
            button.layer.shadowRadius = 20
            button.layer.shadowOffset = .init(width: 0, height: 10)
        }
        
        return button
    }
}

@available(iOS 26, *)
extension UIButton.Configuration {
    static func glassConfiguration(_ size: Size, _ cornerStyle: CornerStyle, _ image: UIImage? = nil, _ scale: UIImage.SymbolScale = .large,
                                   _ title: String? = nil) -> UIButton.Configuration {
        var configuration: UIButton.Configuration = .prominentGlass()
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .label
        configuration.buttonSize = size
        configuration.cornerStyle = cornerStyle
        configuration.image = image?
            .applyingSymbolConfiguration(.init(scale: scale))?
            .applyingSymbolConfiguration(.init(weight: .bold))
        if let title {
            configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([
                .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
            ]))
        }
        
        return configuration
    }
}

extension UIButton.Configuration {
    static func filledConfiguration(_ size: Size, _ cornerStyle: CornerStyle,_ image: UIImage? = nil, _ scale: UIImage.SymbolScale = .large,
                                    _ title: String? = nil) -> UIButton.Configuration {
        var configuration: UIButton.Configuration = .filled()
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.buttonSize = size
        configuration.cornerStyle = cornerStyle
        configuration.image = image?
            .applyingSymbolConfiguration(.init(scale: scale))?
            .applyingSymbolConfiguration(.init(weight: .bold))
        if let title {
            configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([
                .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
            ]))
        }
        
        return configuration
    }
}

extension UIButton.Configuration {
    static func configuration(_ size: Size, _ cornerStyle: CornerStyle, _ image: UIImage? = nil, _ scale: UIImage.SymbolScale = .large,
                              _ title: String? = nil) -> UIButton.Configuration {
        if #available(iOS 26, *) {
            glassConfiguration(size, cornerStyle, image, scale, title)
        } else {
            filledConfiguration(size, cornerStyle, image, scale, title)
        }
    }
}
