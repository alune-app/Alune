import Core
import UIKit

class AluneController : UIViewController {
    var containerView: UIView? = nil
    var imageView: AluneGameView? = nil
    
    var visualEffectView: UIVisualEffectView? = nil
    
    var settingsButton: UIButton? = nil,
        selectButton: UIButton? = nil,
        startButton: UIButton? = nil
    
    var leftThumbstickView: ThumbstickView? = nil,
        rightThumbstickView: ThumbstickView? = nil
    
    var upButton: UIButton? = nil,
        downButton: UIButton? = nil,
        leftButton: UIButton? = nil,
        rightButton: UIButton? = nil
    
    var crossButton: UIButton? = nil,
        circleButton: UIButton? = nil,
        triangleButton: UIButton? = nil,
        squareButton: UIButton? = nil
    
    var l1Button: UIButton? = nil,
        r1Button: UIButton? = nil,
        l2Button: UIButton? = nil,
        r2Button: UIButton? = nil
    
    var constraints: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint]) = ([], [])
    
    var bridgeSwift: AluneBridgeSwift
    var game: Game
    init(bridgeSwift: AluneBridgeSwift, game: Game) {
        self.bridgeSwift = bridgeSwift
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let bridgeSwift: AluneBridgeSwift = bridgeSwift
        
        containerView = UIView()
        guard let containerView else {
            return
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        imageView = bridgeSwift.renderingView()
        guard let imageView else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        imageView.framebufferOnly = true
        imageView.preferredFramesPerSecond = 60
        if #available(iOS 26, *) {
            imageView.clipsToBounds = true
            imageView.cornerConfiguration = .corners(radius: .fixed(16.0))
        } else {
            imageView.clipsToBounds = true
            imageView.layer.cornerCurve = .continuous
            imageView.layer.cornerRadius = 16.0
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            containerView.addSubview(imageView)
        } else {
            view.addSubview(imageView)
        }
        
        let settingsConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "ellipsis"), .medium)
        settingsButton = .button(with: settingsConfiguration,
                                 actions: ({ _ in }, { _ in }), UIMenu(children: [
                                    UIMenu(options: .displayInline, children: [
                                        UIDeferredMenuElement.uncached { completion in
                                            completion([
                                                UIAction(title: "Stop & Exit", image: UIImage(systemName: "stop"), attributes: .destructive) { _ in
                                                    let alertController: UIAlertController = UIAlertController(title: "Stop & Exit",
                                                                                                               message: "Are you sure you want to stop & exit? Unsaved progress will be lost",
                                                                                                               preferredStyle: .alert)
                                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                                                    alertController.addAction(UIAlertAction(title: "Stop & Exit", style: .destructive, handler: { _ in
                                                        self.bridgeSwift.stop()
                                                        self.dismiss(animated: true)
                                                    }))
                                                    self.present(alertController, animated: true)
                                                },
                                                UIAction(title: self.bridgeSwift.paused ? "Resume" : "Pause",
                                                         image: self.bridgeSwift.paused ? UIImage(systemName: "play") : UIImage(systemName: "pause")) { _ in
                                                             if self.bridgeSwift.paused {
                                                                 self.bridgeSwift.unpause()
                                                             } else {
                                                                 self.bridgeSwift.pause()
                                                             }
                                                         }
                                            ])
                                        }
                                    ])
                                 ]))
        guard let settingsButton else {
            return
        }
        view.addSubview(settingsButton)
        
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "minus"), .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .select, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .select, slot: .one)
        }))
        guard let selectButton else {
            return
        }
        view.addSubview(selectButton)
        
        let startConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "plus"), .medium)
        startButton = .button(with: startConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .start, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .start, slot: .one)
        }))
        guard let startButton else {
            return
        }
        view.addSubview(startButton)
        
        leftThumbstickView = ThumbstickView()
        guard let leftThumbstickView else {
            return
        }
        leftThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        leftThumbstickView.label?.text = "L3"
        leftThumbstickView.onChange = { point, dragging in
            if point == .zero && !dragging {
                bridgeSwift.press(button: .l3, slot: .one)
            } else {
                bridgeSwift.drag(thumbstick: .left, point: point, slot: .one)
            }
        }
        leftThumbstickView.onChangeEnded = {
            bridgeSwift.release(button: .l3, slot: .one)
        }
        view.addSubview(leftThumbstickView)
        
        rightThumbstickView = ThumbstickView()
        guard let rightThumbstickView else {
            return
        }
        rightThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        rightThumbstickView.label?.text = "R3"
        rightThumbstickView.onChange = { point, dragging in
            if point == .zero && !dragging {
                bridgeSwift.press(button: .r3, slot: .one)
            } else {
                bridgeSwift.drag(thumbstick: .right, point: point, slot: .one)
            }
        }
        rightThumbstickView.onChangeEnded = {
            bridgeSwift.release(button: .r3, slot: .one)
        }
        view.addSubview(rightThumbstickView)
        
        let upConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.up"))
        upButton = .button(with: upConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .up, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .up, slot: .one)
        }))
        guard let upButton else {
            return
        }
        view.addSubview(upButton)
        
        let downConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.down"))
        downButton = .button(with: downConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .down, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .down, slot: .one)
        }))
        guard let downButton else {
            return
        }
        view.addSubview(downButton)
        
        let leftConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.left"))
        leftButton = .button(with: leftConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .left, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .left, slot: .one)
        }))
        guard let leftButton else {
            return
        }
        view.addSubview(leftButton)
        
        let rightConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.right"))
        rightButton = .button(with: rightConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .right, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .right, slot: .one)
        }))
        guard let rightButton else {
            return
        }
        view.addSubview(rightButton)
        
        var crossConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "xmark"))
        crossConfiguration.baseBackgroundColor = .clear
        crossConfiguration.baseForegroundColor = .systemBlue
        crossButton = .button(with: crossConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .cross, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .cross, slot: .one)
        }))
        guard let crossButton else {
            return
        }
        view.addSubview(crossButton)
        
        var circleConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "circle"))
        circleConfiguration.baseBackgroundColor = .clear
        circleConfiguration.baseForegroundColor = .systemOrange
        circleButton = .button(with: circleConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .circle, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .circle, slot: .one)
        }))
        guard let circleButton else {
            return
        }
        view.addSubview(circleButton)
        
        var triangleConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "triangle"))
        triangleConfiguration.baseBackgroundColor = .clear
        triangleConfiguration.baseForegroundColor = .systemGreen
        triangleButton = .button(with: triangleConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .triangle, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .triangle, slot: .one)
        }))
        guard let triangleButton else {
            return
        }
        view.addSubview(triangleButton)
        
        var squareConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "square"))
        squareConfiguration.baseBackgroundColor = .clear
        squareConfiguration.baseForegroundColor = .systemPink
        squareButton = .button(with: squareConfiguration, actions: ({ _ in
            bridgeSwift.press(button: .square, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .square, slot: .one)
        }))
        guard let squareButton else {
            return
        }
        view.addSubview(squareButton)
        
        let l1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, .unspecified, "L1")
        l1Button = .button(with: l1Configuration, actions: ({ _ in
            bridgeSwift.press(button: .l1, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .l1, slot: .one)
        }))
        guard let l1Button else {
            return
        }
        view.addSubview(l1Button)
        
        let l2Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, .unspecified, "L2")
        l2Button = .button(with: l2Configuration, actions: ({ _ in
            bridgeSwift.press(button: .l2, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .l2, slot: .one)
        }))
        guard let l2Button else {
            return
        }
        view.addSubview(l2Button)
        
        let r1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, .unspecified, "R1")
        r1Button = .button(with: r1Configuration, actions: ({ _ in
            bridgeSwift.press(button: .r1, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .r1, slot: .one)
        }))
        guard let r1Button else {
            return
        }
        view.addSubview(r1Button)
        
        let r2Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, .unspecified, "R2")
        r2Button = .button(with: r2Configuration, actions: ({ _ in
            bridgeSwift.press(button: .r2, slot: .one)
        }, { _ in
            bridgeSwift.release(button: .r2, slot: .one)
        }))
        guard let r2Button else {
            return
        }
        view.addSubview(r2Button)
        
        if iPhone {
            constraints.portrait.append(contentsOf: [
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 20.0),
                imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: 20.0),
                imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -20.0),
                imageView.heightAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.widthAnchor,
                                                  multiplier: 3.0 / 4.0),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            constraints.landscape.append(contentsOf: [
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 20.0),
                imageView.bottomAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.topAnchor,
                                                  constant: -20.0),
                imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.heightAnchor,
                                                 multiplier: 4.0 / 3.0),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor,
                                                    constant: -20),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor,
                                                   constant: -20),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
        } else {
            constraints.portrait.append(contentsOf: [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                containerView.bottomAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.topAnchor, constant: -20),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                imageView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor, multiplier: 2 / 3),
                imageView.heightAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.widthAnchor,
                                                  multiplier: 3.0 / 4.0),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            constraints.landscape.append(contentsOf: [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                containerView.bottomAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.topAnchor, constant: -20),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                imageView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor,
                                               constant: 20),
                imageView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -20),
                imageView.widthAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.heightAnchor,
                                                 multiplier: 4.0 / 3.0),
                
                crossButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -20),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                startButton.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                startButton.trailingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                
                selectButton.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                selectButton.leadingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor)
            ])
        }
        
        switch interfaceOrientation() {
        case .portrait:
            view.addConstraints(constraints.portrait)
        case .landscapeLeft, .landscapeRight:
            view.addConstraints(constraints.landscape)
        default:
            view.addConstraints(constraints.portrait)
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait.union(.landscape)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in } completion: { context in
            switch self.interfaceOrientation() {
            case .portrait:
                self.view.removeConstraints(self.constraints.landscape)
                self.view.addConstraints(self.constraints.portrait)
            case .landscapeLeft, .landscapeRight:
                self.view.removeConstraints(self.constraints.portrait)
                self.view.addConstraints(self.constraints.landscape)
            default:
                break
            }
            
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !bridgeSwift.running {
            _ = bridgeSwift.insert(disc: game.details.name.appending(".\(game.details.`extension`)"))
            bridgeSwift.start()
        }
    }
}
