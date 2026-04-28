import Core
import GameController
import UIKit
import UniformTypeIdentifiers

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
    
    enum FileImportType : String {
        case bios = "bios"
        case isos = "isos"
    }
    
    var fileImportType: FileImportType = .bios
    
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
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), menu: UIMenu(preferredElementSize: .medium,
                                                                                                             children: [
            UIAction(title: "BIOS", image: UIImage(systemName: "arrow.down.document.fill")) { action in
                self.fileImportType = .bios
                
                let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.item],
                                                                                                              asCopy: true)
                documentPickerController.delegate = self
                self.present(documentPickerController, animated: true)
            },
            UIAction(title: "DISC", image: UIImage(systemName: "opticaldisc.fill")) { action in
                self.fileImportType = .isos
                
                let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.item],
                                                                                                              asCopy: true)
                documentPickerController.delegate = self
                documentPickerController.allowsMultipleSelection = true
                self.present(documentPickerController, animated: true)
            }
        ]))
        navigationItem.style = .browser
        navigationItem.title = "Games"
        view.backgroundColor = .systemBackground
        
        collectionView.alwaysBounceVertical = true
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

extension GamesController : UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let documentDirectoryURL: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            Task {
                await urls.asyncForEach { url in
                    let destinationURL: URL = documentDirectoryURL
                        .appending(component: fileImportType.rawValue)
                        .appending(component: url.lastPathComponent)
                    
                    do {
                        try self.fileManager.copyItem(at: url, to: destinationURL)
                    } catch {
                        print(#file, #function, #line, error, error.localizedDescription)
                    }
                }
                
                await populate()
            }
        }
        
        controller.dismiss(animated: true)
    }
}
