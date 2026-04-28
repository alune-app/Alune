import Core
import UIKit

enum SettingsHeaders : String, CaseIterable {
    case jit = "JIT",
         core = "Core",
         cpu = "CPU",
         cpuRecompiler = "CPU Recompiler",
         gs = "GS",
         speedHacks = "Speed Hacks",
         destructive = "Destructive"
    
    var header: SettingHeader {
        switch self {
        case .jit:
            SettingHeader(text: rawValue, secondaryText: "Just-In-Time Compilation")
        case .core, .cpu, .cpuRecompiler, .speedHacks:
            SettingHeader(text: rawValue)
        case .gs:
            SettingHeader(text: rawValue, secondaryText: "Graphics Synthesizer")
        case .destructive:
            SettingHeader()
        }
    }
    
    static var allHeaders: [SettingHeader] { allCases.map { $0.header } }
}

enum SettingsItems : String, CaseIterable {
    case jit = "alune.v1.0.1.JIT"
    
    // Core
    case enableThreadPinning = "alune.v1.0.1.enableThreadPinning"
    
    // CPU
    case extraMemory = "alune.v1.0.1.extraMemory",
         coreType = "alune.v1.0.1.coreType",
         useARM64Dynarec = "alune.v1.0.1.useARM64Dynarec"
    
    // CPU Recompiler
    case enableEE = "alune.v1.0.1.enableEE",
         enableIOP = "alune.v1.0.1.enableIOP",
         enableEECache = "alune.v1.0.1.enableEECache",
         enableVU0 = "alune.v1.0.1.enableVU0",
         enableVU1 = "alune.v1.0.1.enableVU1",
         enableFastMem = "alune.v1.0.1.enableFastMem"
    
    // GS
    case enableVSync = "alune.v1.0.1.enableVSync",
         disableMailboxPresentation = "alune.v1.0.1.disableMailboxPresentation",
         vsyncQueueSize = "alune.v1.0.1.vsyncQueueSize",
         aspectRatio = "alune.v1.0.1.aspectRatio",
         renderer = "alune.v1.0.1.renderer"
    
    
    // Speed Hacks
    case eeCycleRate = "alune.v1.0.1.eeCycleRate",
         eeCycleSkip = "alune.v1.0.1.eeCycleSkip",
         fastCDVD = "alune.v1.0.1.fastCDVD",
         waitLoop = "alune.v1.0.1.waitLoop",
         vuFlagHack = "alune.v1.0.1.vuFlagHack",
         vuThread = "alune.v1.0.1.vuThread",
         vu1Instant = "alune.v1.0.1.vu1Instant",
         mtvu = "alune.v1.0.1.mtvu"
    
    // Destructive
    case resetSettings = "alune.v1.0.1.resetSettings"
    
    var section: String {
        switch self {
        case .jit:
            "JIT"
        case .enableThreadPinning:
            "EmuCore"
        case .extraMemory,
                .coreType,
                .useARM64Dynarec:
            "EmuCore/CPU"
        case .enableEE,
                .enableIOP,
                .enableEECache,
                .enableVU0,
                .enableVU1,
                .enableFastMem:
            "EmuCore/CPU/Recompiler"
        case .enableVSync,
                .disableMailboxPresentation,
                .vsyncQueueSize,
                .aspectRatio,
                .renderer:
            "EmuCore/GS"
        case .eeCycleRate,
                .eeCycleSkip,
                .fastCDVD,
                .waitLoop,
                .vuFlagHack,
                .vuThread,
                .vu1Instant,
                .mtvu:
            "EmuCore/Speedhacks"
        case .resetSettings:
            ""
        }
    }
    
    var key: String {
        switch self {
        case .enableThreadPinning:
            "EnableThreadPinning"
        case .extraMemory:
            "ExtraMemory"
        case .coreType:
            "CoreType"
        case .useARM64Dynarec:
            "UseArm64Dynarec"
        case .enableEE:
            "EnableEE"
        case .enableIOP:
            "EnableIOP"
        case .enableEECache:
            "EnableEECache"
        case .enableVU0:
            "EnableVU0"
        case .enableVU1:
            "EnableVU1"
        case .enableFastMem:
            "EnableFastmem"
        case .enableVSync:
            "VsyncEnable"
        case .disableMailboxPresentation:
            "DisableMailboxPresentation"
        case .vsyncQueueSize:
            "VsyncQueueSize"
        case .aspectRatio:
            "AspectRatio"
        case .renderer:
            "Renderer"
        case .eeCycleRate:
            "EECycleRate"
        case .eeCycleSkip:
            "EECycleSkip"
        case .fastCDVD:
            "fastCDVD"
        case .waitLoop:
            "WaitLoop"
        case .vuFlagHack:
            "vuFlagHack"
        case .vuThread:
            "vuThread"
        case .vu1Instant:
            "vu1Instant"
        case .mtvu:
            "MTVU"
        case .jit,
                .resetSettings:
            ""
        }
    }
    
    var title: String {
        switch self {
        case .jit:
            "STATUS"
            
        case .enableThreadPinning:
            "Enable Thread Pinning"
            
        case .extraMemory:
            "Extra Memory"
        case .coreType:
            "Core Type"
        case .useARM64Dynarec:
            "Use ARM64 Dynarec"
            
        case .enableEE:
            "Enable EE"
        case .enableIOP:
            "Enable IOP"
        case .enableEECache:
            "Enable EE Cache"
        case .enableVU0:
            "Enable VU0"
        case .enableVU1:
            "Enable VU1"
        case .enableFastMem:
            "Enable Fast Memory"
            
        case .enableVSync:
            "Enable VSync"
        case .disableMailboxPresentation:
            "Disable Mailbox Presentation"
        case .vsyncQueueSize:
            "VSync Queue Size"
        case .aspectRatio:
            "Aspect Ratio"
        case .renderer:
            "Renderer"
            
        case .eeCycleRate:
            "EE Cycle Rate"
        case .eeCycleSkip:
            "EE Cycle Skip"
        case .fastCDVD:
            "Fast CDVD"
        case .waitLoop:
            "Wait Loop"
        case .vuFlagHack:
            "VU Fast Hack"
        case .vuThread:
            "VU Thread"
        case .vu1Instant:
            "VU1 Instant"
        case .mtvu:
            "MTVU"
            
        case .resetSettings:
            "Reset Settings"
        }
    }
    
    var secondaryTitle: String? {
        switch self {
        case .jit:
            ""
            
        case .enableThreadPinning:
            ""
            
        case .extraMemory:
            ""
        case .coreType:
            ""
        case .useARM64Dynarec:
            "Requires JIT"
            
        case .enableEE:
            "Requires JIT"
        case .enableIOP:
            "Requires JIT"
        case .enableEECache:
            ""
        case .enableVU0:
            "Requires JIT"
        case .enableVU1:
            "Requires JIT"
        case .enableFastMem:
            ""
            
        case .enableVSync:
            ""
        case .disableMailboxPresentation:
            ""
        case .vsyncQueueSize:
            ""
        case .aspectRatio:
            ""
        case .renderer:
            ""
            
        case .eeCycleRate:
            ""
        case .eeCycleSkip:
            ""
        case .fastCDVD:
            ""
        case .waitLoop:
            ""
        case .vuFlagHack:
            ""
        case .vuThread:
            ""
        case .vu1Instant:
            ""
        case .mtvu:
            ""
            
        case .resetSettings:
            ""
        }
    }
    
    var details: String? {
        switch self {
        case .jit:
            ""
            
        case .enableThreadPinning:
            ""
            
        case .extraMemory:
            ""
        case .coreType:
            ""
        case .useARM64Dynarec:
            ""
            
        case .enableEE:
            ""
        case .enableIOP:
            ""
        case .enableEECache:
            ""
        case .enableVU0:
            ""
        case .enableVU1:
            ""
        case .enableFastMem:
            ""
            
        case .enableVSync:
            ""
        case .disableMailboxPresentation:
            ""
        case .vsyncQueueSize:
            ""
        case .aspectRatio:
            ""
        case .renderer:
            ""
            
        case .eeCycleRate:
            ""
        case .eeCycleSkip:
            ""
        case .fastCDVD:
            ""
        case .waitLoop:
            ""
        case .vuFlagHack:
            ""
        case .vuThread:
            ""
        case .vu1Instant:
            ""
        case .mtvu:
            ""
            
        case .resetSettings:
            ""
        }
    }
    
    func setting(bridgeSwift: AluneBridgeSwift, _ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .jit:
            TapSetting(key: key,
                       section: section,
                       title: title.replacingOccurrences(of: "STATUS", with: bridgeSwift.jitAvailable ? "Activated" : "Tap to Activate"),
                       details: details,
                       color: bridgeSwift.jitAvailable ? .systemGreen : .systemOrange,
                       handler: { controller in
                
            }, delegate: delegate)
            
        case .enableThreadPinning,
                .extraMemory, .useARM64Dynarec,
                .enableEE, .enableIOP, .enableEECache, .enableVU0, .enableVU1, .enableFastMem,
                .enableVSync, .disableMailboxPresentation,
                .fastCDVD, .waitLoop, .vuFlagHack, .vuThread, .vu1Instant, .mtvu:
            BoolSetting(key: key,
                        section: section,
                        title: title,
                        details: details,
                        secondaryTitle: secondaryTitle,
                        value: bridgeSwift.getBoolSetting(for: section, key: key),
                        delegate: delegate)
        case .coreType:
            SelectionSetting(key: key,
                             section: section,
                             title: title,
                             details: details,
                             secondaryTitle: secondaryTitle,
                             values: [
                                "Recompiler" : 0,
                                "Interpreter" : 1,
                                "ARM64 Dynarec" : 2
                             ],
                             selectedValue: bridgeSwift.getIntSetting(for: section, key: key),
                             action: {},
                             delegate: delegate)
        case .vsyncQueueSize:
            StepperSetting(key: key,
                           section: section,
                           title: title,
                           details: details,
                           min: 2,
                           max: 8,
                           value: bridgeSwift.getDoubleSetting(for: section, key: key),
                           delegate: delegate)
        case .eeCycleRate,
                .eeCycleSkip:
            StepperSetting(key: key,
                           section: section,
                           title: title,
                           details: details,
                           min: -2,
                           max: 2,
                           value: bridgeSwift.getDoubleSetting(for: section, key: key),
                           delegate: delegate)
        case .aspectRatio:
            SelectionSetting(key: key,
                             section: section,
                             title: title,
                             details: details,
                             secondaryTitle: secondaryTitle,
                             values: [
                                "Stretch" : "Stretch",
                                "Auto 4:3/3:2" : "Auto 4:3/3:2",
                                "4:3" : "4:3",
                                "16:9" : "16:9",
                                "10:7" : "10:7"
                             ],
                             selectedValue: bridgeSwift.getStringSetting(for: section, key: key),
                             action: {},
                             delegate: delegate)
        case .renderer:
            SelectionSetting(key: key,
                             section: section,
                             title: title,
                             details: details,
                             secondaryTitle: secondaryTitle,
                             values: [
                                "Metal" : 17,
                                "Vulkan" : 14
                             ],
                             selectedValue: bridgeSwift.getIntSetting(for: section, key: key),
                             action: {},
                             delegate: delegate)
        case .resetSettings:
            TapSetting(key: key,
                       section: section,
                       title: title,
                       details: details,
                       color: .systemRed,
                       handler: { controller in
                guard let controller: SettingsController = controller as? SettingsController else {
                    return
                }
                
                bridgeSwift.resetSettings()
                Task { @MainActor in
                    controller.populate()
                }
            }, delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [SettingsItems] {
        switch header {
        case .jit:
            [.jit]
        case .core:
            [.enableThreadPinning]
        case .cpu:
            [.extraMemory, .useARM64Dynarec, .coreType]
        case .cpuRecompiler:
            [.enableEE, .enableIOP, .enableEECache, .enableVU0, .enableVU1, .enableFastMem]
        case .gs:
            [.enableVSync, .disableMailboxPresentation, .vsyncQueueSize, .aspectRatio, .renderer]
        case .speedHacks:
            [.eeCycleRate, .eeCycleSkip, .fastCDVD, .waitLoop, .vuFlagHack, .vuThread, .vu1Instant, .mtvu]
        case .destructive:
            [.resetSettings]
        }
    }
}

class SettingsController : UIViewController, UICollectionViewDelegate {
    var dataSource: UICollectionViewDiffableDataSource<SettingsHeaders, AnyHashableSendable>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, AnyHashableSendable>! = nil
    
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
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = "Settings"
        } else {
            navigationItem.title = "Settings"
        }
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        var configuration: UICollectionLayoutListConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard let dataSource = self.dataSource, let item: BaseSetting = dataSource.itemIdentifier(for: indexPath) as? BaseSetting else {
                return UISwipeActionsConfiguration()
            }
            
            let informationContextualAction: UIContextualAction = UIContextualAction(style: .normal, title: nil, handler: { action, view, performed in
                let alertController: UIAlertController = UIAlertController(title: item.title, message: item.details, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in
                    performed(true)
                })
                // alertController.preferredAction = alertController.actions.first
                self.present(alertController, animated: true)
            })
            informationContextualAction.image = UIImage(systemName: "info")
            
            return if let details: String = item.details, !details.isEmpty {
                UISwipeActionsConfiguration(actions: [
                    informationContextualAction
                ])
            } else {
                nil
            }
        }
        
        let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                collectionViewLayout: UICollectionViewCompositionalLayout.list(using: configuration))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section].header.text
            contentConfiguration.secondaryText = self.snapshot.sectionIdentifiers[indexPath.section].header.secondaryText
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        let selectionCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SelectionSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = itemIdentifier.title
            cell.contentConfiguration = contentConfiguration
            
            let children: [UIMenuElement] = switch itemIdentifier.values {
            case let stringInt as [String : Int]:
                stringInt.reduce(into: [UIAction](), { partialResult, element in
                    var state: UIMenuElement.State = .off
                    if let selectedValue = itemIdentifier.selectedValue as? Int {
                        state = element.value == selectedValue ? .on : .off
                    }
                    
                    partialResult.append(.init(title: element.key, state: state, handler: { _ in
                        itemIdentifier.selectedValue = element.value
                        if let delegate = itemIdentifier.delegate {
                            delegate.didChangeSetting(at: indexPath)
                        }
                    }))
                })
            case let stringString as [String : String]:
                stringString.reduce(into: [UIAction](), { partialResult, element in
                    var state: UIMenuElement.State = .off
                    if let selectedValue = itemIdentifier.selectedValue as? String {
                        state = element.value == selectedValue ? .on : .off
                    }
                    
                    partialResult.append(.init(title: element.key, state: state, handler: { _ in
                        itemIdentifier.selectedValue = element.value
                        if let delegate = itemIdentifier.delegate {
                            delegate.didChangeSetting(at: indexPath)
                        }
                    }))
                })
            default:
                []
            }
            
            var title = "Automatic"
            if let selectedValue = itemIdentifier.selectedValue {
                switch selectedValue {
                case let intValue as Int:
                    if let values = itemIdentifier.values as? [String : Int] {
                        title = values.first(where: { $0.value == intValue })?.key ?? title
                    }
                case let stringValue as String:
                    if let values = itemIdentifier.values as? [String : String] {
                        title = values.first(where: { $0.value == stringValue })?.key ?? title
                    }
                default:
                    break
                }
            }
            
            cell.accessories = [
                UICellAccessory.label(text: title),
                UICellAccessory.popUpMenu(UIMenu(children: children.sorted(by: { $0.title < $1.title })))
            ]
        }
        
        let boolCell: UICollectionView.CellRegistration<UICollectionViewListCell, BoolSetting> = CellManager.Settings.boolCell
        let inputNumberCell: UICollectionView.CellRegistration<UICollectionViewListCell, InputNumberSetting> = CellManager.Settings.inputNumberCell
        let inputStringCell: UICollectionView.CellRegistration<UICollectionViewListCell, InputStringSetting> = CellManager.Settings.inputStringCell
        let stepperCell: UICollectionView.CellRegistration<UICollectionViewListCell, StepperSetting> = CellManager.Settings.stepperCell
        let tapCell: UICollectionView.CellRegistration<UICollectionViewListCell, TapSetting> = CellManager.Settings.tapCell
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let boolSetting as BoolSetting:
                collectionView.dequeueConfiguredReusableCell(using: boolCell, for: indexPath, item: boolSetting)
            case let inputNumberSetting as InputNumberSetting:
                collectionView.dequeueConfiguredReusableCell(using: inputNumberCell, for: indexPath, item: inputNumberSetting)
            case let inputStringSetting as InputStringSetting:
                collectionView.dequeueConfiguredReusableCell(using: inputStringCell, for: indexPath, item: inputStringSetting)
            case let selectionSetting as SelectionSetting:
                collectionView.dequeueConfiguredReusableCell(using: selectionCellRegistration, for: indexPath, item: selectionSetting)
            case let stepperSetting as StepperSetting:
                collectionView.dequeueConfiguredReusableCell(using: stepperCell, for: indexPath, item: stepperSetting)
            case let tapSetting as TapSetting:
                collectionView.dequeueConfiguredReusableCell(using: tapCell, for: indexPath, item: tapSetting)
            default:
                nil
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        
        populate()
    }
    
    func populate() {
        snapshot = .init()
        snapshot.appendSections(SettingsHeaders.allCases)
        snapshot.sectionIdentifiers.forEach { header in
            snapshot.appendItems(SettingsItems.settings(header).map { $0.setting(bridgeSwift: bridgeSwift, self) }, toSection: header)
        }
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch dataSource.itemIdentifier(for: indexPath) {
        case let inputSetting as InputNumberSetting:
            let alertController = UIAlertController(title: inputSetting.title,
                                                    message: "Min: \(Int(inputSetting.min)), Max: \(Int(inputSetting.max))",
                                                    preferredStyle: .alert)
            alertController.addTextField {
                $0.keyboardType = .numberPad
            }
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text as? NSString else {
                    return
                }
                
                UserDefaults.standard.set(value.doubleValue, forKey: inputSetting.key)
                if let delegate = inputSetting.delegate {
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            present(alertController, animated: true)
        case let inputSetting as InputStringSetting:
            let alertController = UIAlertController(title: inputSetting.title,
                                                    message: inputSetting.details,
                                                    preferredStyle: .alert)
            alertController.addTextField {
                $0.placeholder = inputSetting.placeholder
            }
            
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text else {
                    return
                }
                
                UserDefaults.standard.set(value, forKey: inputSetting.key)
                if let delegate = inputSetting.delegate {
                    inputSetting.action()
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            present(alertController, animated: true)
        case let tapSetting as TapSetting:
            tapSetting.handler(self)
        default:
            break
        }
    }
}

extension SettingsController : @MainActor SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath) {
        guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[indexPath.item]
        
        switch item {
        case let boolSetting as BoolSetting:
            bridgeSwift.setBoolSetting(for: boolSetting.section, key: boolSetting.key, value: boolSetting.value)
            boolSetting.value = bridgeSwift.getBoolSetting(for: boolSetting.section, key: boolSetting.key)
        case let inputNumberSetting as InputNumberSetting:
            inputNumberSetting.value = UserDefaults.standard.double(forKey: inputNumberSetting.key)
        case let inputStringSetting as InputStringSetting:
            inputStringSetting.value = UserDefaults.standard.string(forKey: inputStringSetting.key)
        case let stepperSetting as StepperSetting:
            bridgeSwift.setDoubleSetting(for: stepperSetting.section, key: stepperSetting.key, value: stepperSetting.value)
            stepperSetting.value = bridgeSwift.getDoubleSetting(for: stepperSetting.section, key: stepperSetting.key)
        case let selectionSetting as SelectionSetting:
            if let selectedValue = selectionSetting.selectedValue as? Int {
                bridgeSwift.setIntSetting(for: selectionSetting.section, key: selectionSetting.key, value: selectedValue)
                selectionSetting.selectedValue = bridgeSwift.getIntSetting(for: selectionSetting.section, key: selectionSetting.key)
            } else if let selectedValue = selectionSetting.selectedValue as? String {
                bridgeSwift.setStringSetting(for: selectionSetting.section, key: selectionSetting.key, value: selectedValue)
                selectionSetting.selectedValue = bridgeSwift.getStringSetting(for: selectionSetting.section, key: selectionSetting.key)
            }
        default:
            break
        }
        
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
