import UIKit
import UniformTypeIdentifiers

class Cell : UICollectionViewCell {
    var visualEffectView: UIVisualEffectView? = nil
    var containerView: UIView? = nil

    var imageView: UIImageView? = nil
    var textLabel: UILabel? = nil,
        secondaryTextLabel: UILabel? = nil
    var optionsButton: UIButton? = nil

    var hasCustomArtwork: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 26.0, *) {
            visualEffectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
            guard let visualEffectView else {
                return
            }
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(visualEffectView)

            visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            visualEffectView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.414 / 1.0)
                .isActive = true
        } else {
            containerView = UIView()
            guard let containerView else {
                return
            }
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = .secondarySystemBackground
            addSubview(containerView)

            containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            containerView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.414 / 1.0)
                .isActive = true
        }

        guard let viewForSubviews: UIView = visualEffectView?.contentView ?? containerView else {
            return
        }

        imageView = .init()
        guard let imageView else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if #unavailable(iOS 26) {
            imageView.backgroundColor = .tertiarySystemBackground
        }
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        addSubview(imageView)

        let constant: CGFloat = if #available(iOS 26, *) { 8 } else { 4 }

        imageView.topAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.topAnchor, constant: constant).isActive = true
        imageView.leadingAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.leadingAnchor, constant: constant).isActive = true
        imageView.bottomAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.bottomAnchor, constant: -constant).isActive = true
        imageView.trailingAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.trailingAnchor, constant: -constant).isActive = true

        textLabel = .init()
        guard let textLabel else {
            return
        }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        textLabel.textColor = .label
        addSubview(textLabel)

        textLabel.topAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.leadingAnchor).isActive = true
        textLabel.trailingAnchor.constraint(lessThanOrEqualTo: viewForSubviews.safeAreaLayoutGuide.trailingAnchor).isActive = true

        secondaryTextLabel = .init()
        guard let secondaryTextLabel else {
            return
        }
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        secondaryTextLabel.textColor = .secondaryLabel
        addSubview(secondaryTextLabel)

        secondaryTextLabel.topAnchor.constraint(equalTo: textLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
        secondaryTextLabel.leadingAnchor.constraint(equalTo: viewForSubviews.safeAreaLayoutGuide.leadingAnchor).isActive = true
        secondaryTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        secondaryTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: viewForSubviews.safeAreaLayoutGuide.trailingAnchor).isActive = true

        var configuration: UIButton.Configuration = if #available(iOS 26, *) {
            .glass()
        } else {
            .filled()
        }
        if #unavailable(iOS 26) {
            configuration.baseBackgroundColor = .secondarySystemBackground.withAlphaComponent(1 / 3)
            configuration.baseForegroundColor = .label
        }
        configuration.buttonSize = .medium
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(scale: .medium))

        optionsButton = .init(configuration: configuration)
        guard let optionsButton else {
            return
        }
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.showsMenuAsPrimaryAction = true
        if #unavailable(iOS 26) {
            optionsButton.layer.shadowColor = UIColor.black.cgColor
            optionsButton.layer.shadowOpacity = 1 / 4
            optionsButton.layer.shadowRadius = 20
            optionsButton.layer.shadowOffset = .init(width: 0, height: 10)
        }
        addSubview(optionsButton)

        if #available(iOS 26, *) {
            optionsButton.centerXAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -10.0 + (constant / 2)).isActive = true
            optionsButton.centerYAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.topAnchor,
                                                   constant: 10.0 + (constant / 2)).isActive = true
        } else {
            optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let viewForSubview: UIView = visualEffectView ?? containerView, let imageView,
            let optionsButton
        else {
            return
        }

        if #available(iOS 26.0, *) {
            applyCutout(from: optionsButton, to: imageView, expandBy: 8)

            viewForSubview.cornerConfiguration = .corners(radius: .fixed(optionsButton.frame.height + 10.0))
            imageView.layer.cornerRadius = optionsButton.frame.height + 10.0 - 8.0
        } else {
            viewForSubview.layer.cornerRadius = optionsButton.frame.height / 2.0 + 20.0
            imageView.layer.cornerRadius = viewForSubview.layer.cornerRadius - 4.0
        }
    }

    var game: Game? = nil
    func set(game: Game, controller: UIViewController) {
        self.game = game
        guard let imageView, let textLabel, let secondaryTextLabel, let optionsButton else {
            return
        }

        guard let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let artworkDirectoryURL: URL = documentDirectoryURL.appending(component: "covers")
        let imageURL: URL = artworkDirectoryURL.appending(component: "\(game.details.name.lowercased()).png")
        let fileExists = FileManager.default.fileExists(atPath: imageURL.path)
        hasCustomArtwork = fileExists
        if fileExists {
            imageView.image = UIImage(contentsOfFile: imageURL.path)
        } else {
            Task {
                let formattedID: String = game.details.id
                    .replacingOccurrences(of: "_", with: "-")
                    .replacingOccurrences(of: ".", with: "")

                if let boxartURL: URL = URL(string: "https://raw.githubusercontent.com/xlenore/ps2-covers/main/covers/default/\(formattedID).jpg") {
                    let (data, _) = try await URLSession.shared.data(from: boxartURL)
                    imageView.image = UIImage(data: data)
                    
                    do {
                        try data.write(to: imageURL)
                    } catch {
                        print(#file, #function, #line, error, error.localizedDescription)
                    }
                }
            }
        }

        textLabel.text = game.details.name
        secondaryTextLabel.text = game.details.size

        optionsButton.menu = .init(children: [
            UIMenu(
                title: "Artwork", image: .init(systemName: "photo"),
                children: [
                    UIDeferredMenuElement.uncached { completion in
                        let fileExists = FileManager.default.fileExists(atPath: imageURL.path)

                        var elements: [UIMenuElement] = [
                            UIAction(title: "Import", image: .init(systemName: "arrow.down.circle")) { _ in
                                let imagePickerController: UIImagePickerController = .init()
                                // imagePickerController.allowsEditing = true
                                imagePickerController.delegate = self
                                imagePickerController.mediaTypes = [UTType.image.identifier]
                                imagePickerController.modalPresentationStyle = .fullScreen
                                controller.present(imagePickerController, animated: true)
                            }
                        ]

                        if fileExists {
                            elements.append(UIAction(title: "Delete", image: .init(systemName: "minus.circle"), attributes: .destructive) { _ in
                                    Task {
                                        try FileManager.default.removeItem(at: imageURL)
                                        self.hasCustomArtwork = false
                                        guard let controller = controller as? GamesController else {
                                            return
                                        }

                                        await controller.populate()
                                    }
                                })
                        }

                        completion(elements)
                    }
                ]),
            UIAction(title: "Delete", image: .init(systemName: "minus.circle"), attributes: .destructive) { _ in
                    let alertController: UIAlertController = .init(
                        title: "Delete \"\(game.details.name)\"?",
                        message: "",
                        preferredStyle: .alert)
                    alertController.addAction(.init(title: "Dismiss", style: .cancel))
                    alertController.addAction(
                        .init(
                            title: "Delete", style: .destructive,
                            handler: { _ in
                                let task = Task {
                                    try FileManager.default.removeItem(at: game.details.url)
                                    guard let controller = controller as? GamesController else {
                                        return
                                    }

                                    await controller.populate()
                                }

                                Task {
                                    switch await task.result {
                                    case .success:
                                        break
                                    case .failure(let error):
                                        print(#function, #line, error.localizedDescription)
                                    }
                                }
                            }))
                    controller.present(alertController, animated: true)
                },
        ])
    }
}

extension Cell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] ) {
        guard let image: UIImage = info[.originalImage] as? UIImage else {
            return
        }

        guard let imageView, let game else {
            return
        }

        guard let documentDirectoryURL: URL = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first else {
            return
        }

        let artworkDirectoryURL: URL = documentDirectoryURL.appending(component: "covers")
        let url: URL = artworkDirectoryURL.appending( component: "\(game.details.name.lowercased()).png")
        Task {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            if let data = image.pngData() {
                try data.write(to: url)
            }

            let fileExists = FileManager.default.fileExists(atPath: url.path)
            hasCustomArtwork = fileExists
            if fileExists {
                imageView.image = .init(contentsOfFile: url.path)
            }

            picker.dismiss(animated: true)
        }
    }
}
