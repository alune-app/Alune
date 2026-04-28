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
        window.tintColor = .systemIndigo
        window.makeKeyAndVisible()
        
        extractAndCopyResourcesFolder()
        
        bridgeSwift.initializeRenderingView()
        
        if let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let biosDirectoryURL: URL = documentDirectoryURL.appending(component: "bios")
            do {
                let contents: [URL] = try FileManager.default.contentsOfDirectory(at: biosDirectoryURL,
                                                                                  includingPropertiesForKeys: nil,
                                                                                  options: .skipsHiddenFiles)
                let binFileURLs: [URL] = contents.filter { content in content.pathExtension.lowercased() == "bin" }
                if let binFileURL: URL = binFileURLs.first {
                    bridgeSwift.insert(bios: binFileURL)
                }
            } catch {
                print(#file, #function, #line, error, error.localizedDescription)
            }
            
            
            let isosDirectoryURL: URL = documentDirectoryURL.appending(component: "isos")
            if !FileManager.default.fileExists(atPath: isosDirectoryURL.path) {
                do {
                    try FileManager.default.createDirectory(at: isosDirectoryURL, withIntermediateDirectories: false)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
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
