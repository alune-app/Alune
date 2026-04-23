//
//  Core.swift
//  Core
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import Foundation

@objc public enum PS2Button : UInt32 {
    case up,
         right,
         down,
         left
    
    case triangle,
         circle,
         cross,
         square
    
    case select,
         start
    
    case l1,
         l2,
         r1,
         r2,
         l3,
         r3
    
    case analog,
         pressure
    
    case leftUp,
         leftRight,
         leftDown,
         leftLeft
    
    case rightUp,
         rightRight,
         rightDown,
         rightLeft
    
    var uint32: UInt32 {
        rawValue
    }
}

// 1 and 2 are really 0 and 1 but for sanity sake...
@objc public enum PS2GamepadSlot : UInt8 {
    case one,
         two
    
    var uint8: UInt8 {
        rawValue
    }
}

@objc public enum PS2ThumbstickSide : UInt32 {
    case left,
         right
    
    var uint32: UInt32 {
        rawValue
    }
}

public class AluneBridgeSwift {
    public static let shared: AluneBridgeSwift = AluneBridgeSwift()
    
    private let bridge: AluneBridge = AluneBridge.shared()
    
    public init() {}
    
    // MARK: View
    public func initializeRenderingView() {
        bridge.initialize()
    }
    
    public func renderingView() -> AluneGameView {
        bridge.renderingView()
    }
    
    // MARK: Input
    public func press(button: PS2Button, slot: PS2GamepadSlot) {
        bridge.press(button: button.uint32, slot: slot.uint8)
    }
    
    public func release(button: PS2Button, slot: PS2GamepadSlot) {
        bridge.release(button: button.uint32, slot: slot.uint8)
    }
    
    public func drag(thumbstick: PS2ThumbstickSide, point: CGPoint, slot: PS2GamepadSlot) {
        bridge.drag(thumbstick: thumbstick.uint32, point: point, slot: slot.uint8)
    }
    
    
    // MARK: Setup
    public func insert(bios: URL) {
        bridge.insert(bios: bios)
    }
    
    public func insert(disc: String) -> UInt32 {
        bridge.insert(disc: disc)
    }
    
    public func start() {
        bridge.start()
    }
    
    public func pause() {
        bridge.pause()
    }
    
    public func stop() {
        bridge.stop()
    }
    
    public func unpause() {
        bridge.unpause()
    }
    
    
    public var paused: Bool {
        bridge.paused()
    }
    
    public var running: Bool {
        bridge.running()
    }
    
    // MARK: Settings
    public func updateSettings() {
        bridge.updateSettings()
    }
}
