//
//  File.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/15.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: Inner types
    private enum Section: Hashable {
        case main
    }
    
    // MARK: Typealias
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductItem>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ProductItem>
    
    // MARK: Properties
    private lazy var dataSource = makeDataSource(for: .list)
    private var collectionView: UICollectionView!
    private var products: [ProductItem] = []
    private var itemSnapshot = SnapShot()
    private var pageOffset = 1
    
    // MARK: UI
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UIKit.UISegmentedControl(items: [LayoutType.list.name,
                                                                LayoutType.grid.name])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        receivePageData(isUpdate: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addAction()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: createLayout(for: .list))
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureUI() {
        configureCollectionView()
        
        let addProductBarButton = UIBarButtonItem(image: MarketImage.add,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(addProductButtonTapped))
        
        navigationItem.rightBarButtonItem = addProductBarButton
        navigationItem.titleView = segmentedControl
    }
    
    private func addAction() {
        segmentedControl.addTarget(self,
                                   action: #selector(indexChanged),
                                   for: .valueChanged)
    }
    
    @objc private func indexChanged(segmentedControl: UISegmentedControl) {
        guard let layoutType = LayoutType(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        
        dataSource = makeDataSource(for: layoutType)
        collectionView.collectionViewLayout = createLayout(for: layoutType)
        receivePageData(isUpdate: true)
    }
    
    @objc private func addProductButtonTapped() {
        let editViewController = EditProductViewController()
        self.navigationController?.pushViewController(editViewController, animated: true)
    }
    
    // MARK: DataSource
    private func makeDataSource(for layout: LayoutType) -> DataSource {
        let listRegistration = UICollectionView.CellRegistration<MarketListCollectionViewCell, ProductItem>.init { cell, indexPath, item in
            cell.configure(with: item)
        }
        
        let gridRegistration = UICollectionView.CellRegistration<MarketGridCollectionViewCell, ProductItem>.init { cell, indexPath, item in
            cell.configure(with: item)
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            switch layout {
            case .list:
                return collectionView.dequeueConfiguredReusableCell(using: listRegistration,
                                                                    for: indexPath,
                                                                    item: item)
            case .grid:
                return collectionView.dequeueConfiguredReusableCell(using: gridRegistration,
                                                                    for: indexPath,
                                                                    item: item)
            }
        }
    }
    
    // MARK: Data & Snapshot
    private func applySnapshots() {
        itemSnapshot.deleteAllItems()
        itemSnapshot.appendSections([.main])
        itemSnapshot.appendItems(products)
        dataSource.apply(itemSnapshot, animatingDifferences: false)
    }
    
    private func receivePageData(isUpdate: Bool = false, _ page: Int = 1, itemCount: Int = 50) {
        guard let getRequest = RequestDirector().createGetRequest(page: page,
                                                                  itemCount: itemCount) else { return }
        if isUpdate {
            products.removeAll()
        }
        
        LoadingIndicator.showLoading(on: view)
        URLSessionManager().dataTask(request: getRequest) { result in
            switch result {
            case .success(let data):
                self.decodeResult(data)
                
                DispatchQueue.main.async {
                    self.applySnapshots()
                    LoadingIndicator.hideLoading(on: self.view)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    AlertManager(self).showAlert(.networkFailure)
                }
            }
        }
    }
    
    private func decodeResult(_ data: Data) {
        do {
            let page = try DataManager().decode(type: Page.self, data: data)
            
            let receivedPage = page.pages.map { ProductItem(product: $0) }
            self.products.append(contentsOf: receivedPage)
            
        } catch {
            DispatchQueue.main.async {
                AlertManager(self).showAlert(.decodingFailure)
            }
        }
    }
    
    // MARK: Layout
    private func createLayout(for layout: LayoutType) -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(layout.groupSizeHeight))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: layout.spacing,
                                                     leading: layout.spacing,
                                                     bottom: layout.spacing,
                                                     trailing: layout.spacing)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize,
                                                       subitem: item,
                                                       count: layout.groupCount)
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productInfoViewController = ProductInfoViewController()
        productInfoViewController.receiveProductInfo(number: products[indexPath.row].id,
                                                     name: products[indexPath.row].name)
        self.navigationController?.pushViewController(productInfoViewController, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let presentScrollOffset = scrollView.contentOffset.y
        let scrollSpace = scrollView.contentSize.height - scrollView.bounds.height
        
        if presentScrollOffset > scrollSpace {
            pageOffset += 1
            receivePageData(pageOffset)
        }
    }
}

//MARK: Namespace
extension MainViewController {
    private enum LayoutType: Int {
        case list
        case grid
        
        var name: String {
            switch self {
            case .list:
                return "LIST"
            case .grid:
                return "GRID"
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .list:
                return 0
            case .grid:
                return 5
            }
        }
        
        var groupSizeHeight: CGFloat {
            switch self {
            case .list:
                return 1/10
            case .grid:
                return 3/10
            }
        }
        
        var groupCount: Int {
            switch self {
            case .list:
                return 1
            case .grid:
                return 2
            }
        }
    }
}
