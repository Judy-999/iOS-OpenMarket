//
//  File.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/15.
//

import UIKit

final class MarketCollectionViewController: UICollectionViewController {
    enum Section: Hashable {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    lazy var dataSource = makeListDataSource()
    private var items: [Item] = []
    private let sessionManager = URLSessionManager(session: URLSession.shared)
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UIKit.UISegmentedControl(items: ["LIST", "GRID"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        segmentedControl.layer.borderWidth = 1.0
        return segmentedControl
    }()
    
    private let barbutton: UIBarButtonItem = {
        let addButton = UIBarButtonItem()
        addButton.image = UIImage(systemName: "plus")
        return addButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedControl
        navigationItem.rightBarButtonItem = barbutton
        collectionView.collectionViewLayout = createListLayout()
        receivePageData()
        segmentedControl.addTarget(self, action: #selector(indexChanged), for: .valueChanged)
    }
    
    @objc private func indexChanged(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            collectionView.collectionViewLayout = createListLayout()
            dataSource = makeListDataSource()
            receivePageData()
        } else {
            collectionView.collectionViewLayout = createGridLayout()
            dataSource = makeGridDataSource()
            receivePageData()
        }
    }
}

extension MarketCollectionViewController {
    private func createListLayout() -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(0.08))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize,
                                                       subitem: item,
                                                       count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 1
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createGridLayout() -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(0.35))
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize,
                                                       subitem: item,
                                                       count: 2)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension MarketCollectionViewController {
    private func makeListDataSource() -> DataSource {
        let registration = UICollectionView.CellRegistration<MarketListCollectionViewCell, Item>.init { cell, indexPath, item in
            cell.configureCell(with: item)
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }
    
    private func makeGridDataSource() -> DataSource {
        let registration = UICollectionView.CellRegistration<MarketGridCollectionViewCell, Item>.init { cell, indexPath, item in
            cell.configureCell(with: item)
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }
}
 
extension MarketCollectionViewController {
    private func applySnapshots() {
        var itemSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        itemSnapshot.appendSections([.main])
        itemSnapshot.appendItems(items)
        dataSource.apply(itemSnapshot, animatingDifferences: false)
    }
    
    private func receivePageData() {
        let subURL = SubURL().pageURL(number: 1, countOfItems: 20)
        
        LoadingIndicator.showLoading(on: view)
        sessionManager.receiveData(baseURL: subURL) { result in
            switch result {
            case .success(let data):
                guard let page = DataDecoder().decode(type: Page.self, data: data) else { return }
                
                self.items = page.pages.map {
                    Item(product: $0 )
                }
                
                DispatchQueue.main.async {
                    self.applySnapshots()
                    LoadingIndicator.hideLoading(on: self.view)
                }
            case .failure(_):
                print("서버 통신 실패")
            }
        }
    }
}