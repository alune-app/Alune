//
//  SceneDelegate.swift
//  Alune
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import Core
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow? = nil

    let bridgeSwift: AluneBridgeSwift = AluneBridgeSwift()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene: UIWindowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)
        guard let window: UIWindow else {
            return
        }
        window.rootViewController = TabController(bridgeSwift: bridgeSwift)
        window.tintColor = .systemBlue
        window.makeKeyAndVisible()
        
        configureDefaultUserDefaults()
        extractAndCopyResourcesFolder()
        
        bridgeSwift.initializeRenderingView()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        bridgeSwift.unpause()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        bridgeSwift.pause()
    }
    
    fileprivate func configureDefaultUserDefaults() {
        let defaults: [String : Any] = [
            // CPU
            "extraMemory" : false,
            "coreType" : 0,
            "useARM64Dynarec" : false,
            "extraSparseMemory" : true,
            
            // CPU Recompiler
            "enableEE" : false,
            "enableIOP" : false,
            "enableEECache" : false,
            "enableVU0" : false,
            "enableVU1" : false,
            "enableFastMem" : true,
            
            // GS
            "enableVSync" : false,
            "disableMailboxPresentation" : false,
            "vsyncQueueSize" : 2,
            "aspectRatio" : 2,
            
            // Speed Hacks
            "fastCDVD" : false,
            "waitLoop" : false,
            "vuFlagHack" : false,
            "vuThread" : false,
            "vu1Instant" : false,
            "mtvu" : false
            
        ]
        
        defaults.forEach { key, value in
            if UserDefaults.standard.value(forKey: "alune.v1.0.1.\(key)") == nil {
                UserDefaults.standard.set(value, forKey: "alune.v1.0.1.\(key)")
            }
        }
    }
    
    fileprivate func extractAndCopyResourcesFolder() {
        if let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let resourcesDirectoryURL: URL = documentDirectoryURL.appending(component: "resources")
            if let resourcesZipURL: URL = Bundle.main.url(forResource: "resources", withExtension: "zip") {
                unzip_file(resourcesZipURL.path, resourcesDirectoryURL.path)
                
                do {
                    try FileManager.default.removeItem(at: resourcesDirectoryURL.appending(component: "__MACOSX"))
                } catch {
                    print(#file, #function, #line, error, error.localizedDescription)
                }
            }
        }
    }
}
