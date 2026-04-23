//
//  ThumbstickView.swift
//  Alune
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import UIKit

class ThumbstickView : UIView, UIGestureRecognizerDelegate {
    var label: UILabel? = nil
    
    var isDragging: Bool = false
    
    var deadZone: CGFloat = 0.15
    var onChange: ((CGPoint, Bool) -> Void)?
    var onChangeEnded: (() -> Void)?
    private(set) var normalizedPoint: CGPoint = .zero {
        didSet {
            onChange?(normalizedPoint, isDragging)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView: UIImageView = UIImageView(image: UIImage(systemName: "app.background.dotted")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: .secondarySystemBackground)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(imageView, belowSubview: self)
        
        label = UILabel()
        guard let label else {
            return
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        label.textColor = .label
        addSubview(label)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 2 / 3, 1.0] as [NSNumber]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds

        layer.mask = gradient
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        update(with: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        update(with: touches)
        isDragging = true
        if isDragging && normalizedPoint != .zero {
            onChangeEnded?()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        normalizedPoint = .zero
        isDragging = false
        onChangeEnded?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        normalizedPoint = .zero
        isDragging = false
        onChangeEnded?()
    }
    
    private func update(with touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        
        normalizedPoint = normalize(location: touch.location(in: self))
    }
    
    private func normalize(location: CGPoint) -> CGPoint {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else {
            return .zero
        }
        
        var x = (location.x / w) * 2 - 1
        var y = (location.y / h) * 2 - 1
        
        x = clamp(x)
        y = clamp(y)
        
        let magnitude = sqrt(x * x + y * y)
        guard magnitude > deadZone else {
            return .zero
        }
        
        let scaled = (magnitude - deadZone) / (1 - deadZone)
        let scale = scaled / magnitude
        
        return CGPoint(x: x * scale, y: y * scale)
    }
    
    private func clamp(_ v: CGFloat) -> CGFloat {
        min(max(v, -1), 1)
    }
}
