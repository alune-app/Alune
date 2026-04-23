import Core
import GameController
import UIKit

extension UIViewController {
    var iPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func interfaceOrientation() -> UIInterfaceOrientation {
        guard let window = view.window, let windowScene = window.windowScene else {
            if UIDevice.current.orientation.isPortrait {
                return .portrait
            } else {
                if UIDevice.current.orientation == .landscapeLeft {
                    return .landscapeLeft
                } else {
                    return .landscapeRight
                }
            }
        }
        
        return windowScene.interfaceOrientation
    }
}

class GamesController: UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, Game>? = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    
    let fileManager: FileManager = FileManager.default
    
    var bridgeSwift: AluneBridgeSwift
    init(collectionViewLayout layout: UICollectionViewLayout, bridgeSwift: AluneBridgeSwift) {
        self.bridgeSwift = bridgeSwift
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController: UINavigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = "Games"
        }
        navigationItem.title = "Games"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { action in
                if let refreshControl: UIRefreshControl = action.sender as? UIRefreshControl {
                    refreshControl.beginRefreshing()
                    
                    Task {
                        await self.populate()
                    }
                    
                    refreshControl.endRefreshing()
                }
            })
        
        let headerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader ) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let dataSource: UICollectionViewDiffableDataSource = self.dataSource,
               let letter: String = dataSource.sectionIdentifier(for: indexPath.section) {
                contentConfiguration.text = letter
            }
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        let cellRegistration: UICollectionView.CellRegistration<Cell, Game> = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.set(game: itemIdentifier, controller: self)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary( using: headerCellRegistration, for: indexPath)
        }
        
        snapshot = NSDiffableDataSourceSnapshot()
        
        Task {
            await populate()
        }
        
        if let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let biosDirectoryURL: URL = documentDirectoryURL.appendingPathComponent("bios")
            
            do {
                let contents: [URL] = try FileManager.default.contentsOfDirectory(at: biosDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                let binFileURLs: [URL] = contents.filter { content in content.pathExtension.lowercased() == "bin" }
                if let binFileURL: URL = binFileURLs.first {
                    bridgeSwift.insert(bios: binFileURL)
                }
            } catch {
                print(#file, #function, #line, error, error.localizedDescription)
            }
        }
    }
    
    var gamesManager: GamesManager = GamesManager()
    func populate() async {
        guard let dataSource, var snapshot else {
            return
        }
        
        let (games, letters): ([Game], [String]) = await gamesManager.games()
        
        snapshot.appendSections(letters)
        snapshot.sectionIdentifiers.forEach { letter in
            snapshot.appendItems(games.filter { game in game.details.name.prefix(1).uppercased() == letter }, toSection: letter)
        }
        
        if #available(iOS 26, *) {
            navigationItem.largeSubtitle = "\(games.count) game\(games.count == 1 ? "" : "s") available"
            navigationItem.subtitle = navigationItem.largeSubtitle
        }
        
        await dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let dataSource, let game: Game = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let viewController: AluneController = AluneController(bridgeSwift: bridgeSwift, game: game)
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
