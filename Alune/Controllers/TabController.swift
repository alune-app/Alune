import Core
import UIKit

class TabController : UITabBarController {
    var bridgeSwift: AluneBridgeSwift
    init(bridgeSwift: AluneBridgeSwift) {
        self.bridgeSwift = bridgeSwift
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let viewController: GamesController = GamesController(collectionViewLayout: LayoutManager.shared.library, bridgeSwift: bridgeSwift)
        viewController.tabBarItem = UITabBarItem(title: "Games", image: UIImage(systemName: "opticaldisc.fill"), tag: 0)
        
        let viewController2: SettingsController = SettingsController(bridgeSwift: bridgeSwift)
        viewController2.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 1)
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
        let navigationController2: UINavigationController = UINavigationController(rootViewController: viewController2)
        
        viewControllers = [
            navigationController,
            navigationController2
        ]
    }
}
