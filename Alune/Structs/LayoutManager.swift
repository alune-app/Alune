//
//  LayoutManager.swift
//  Alune
//
//  Created by Jarrod Norwell on 23/4/2026.
//

import UIKit

@MainActor
struct LayoutManager {
    static let shared: LayoutManager = LayoutManager()
    
    var library: UICollectionViewCompositionalLayout {
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.interSectionSpacing = 20
        
        return .init(sectionProvider: { sectionIndex, layoutEnvironment in
            switch UIDevice.current.userInterfaceIdiom {
            case .pad: iPadLibrary(layoutEnvironment, sectionIndex)
            case .phone: iPhoneLibrary(layoutEnvironment, sectionIndex)
            default:
                nil
            }
        }, configuration: configuration)
    }
    
    func iPadLibrary(_ layoutEnvironment: NSCollectionLayoutEnvironment, _ sectionIndex: Int) -> NSCollectionLayoutSection? {
        let itemCount: Int = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? 4 : 5
        
        let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1 / .init(itemCount)), heightDimension: .estimated(300)))
        
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), repeatingSubitem: item, count: itemCount)
        group.interItemSpacing = .fixed(20)
        
        let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.pinToVisibleBounds = true
        
        let section: NSCollectionLayoutSection = .init(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 20
        
        return section
    }
    
    func iPhoneLibrary(_ layoutEnvironment: NSCollectionLayoutEnvironment, _ sectionIndex: Int) -> NSCollectionLayoutSection? {
        let itemCount: Int = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? 2 : 4
        
        let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1 / .init(itemCount)), heightDimension: .estimated(300)))
        
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), repeatingSubitem: item, count: itemCount)
        group.interItemSpacing = .fixed(20)
        
        let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.pinToVisibleBounds = true
        
        let section: NSCollectionLayoutSection = .init(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 20
        
        return section
    }
}
