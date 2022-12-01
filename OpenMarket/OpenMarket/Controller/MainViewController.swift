//
//  File.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/15.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: Inner types
    enum Section: Hashable {
        case main
    }
    
    // MARK: Typealias
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductItem>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ProductItem>
    
    // MARK: Properties
    private var dataSource: DataSource! //= makeListDataSource()
    private var collectionView: UICollectionView!
    private var products: [ProductItem] = []
    
    // MARK: UI
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UIKit.UISegmentedControl(items: [ProductListType.list, ProductListType.grid])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        segmentedControl.layer.borderWidth = 1.0
        return segmentedControl
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        receivePageData()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        receivePageData()
        addAction()
        dataSource = makeListDataSource()
        collectionView.delegate = self
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createListLayout())
        view.addSubview(collectionView)
        
        let addProductBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(addProductButtonTapped))
        
        navigationItem.rightBarButtonItem = addProductBarButton
        navigationItem.titleView = segmentedControl
    }
    
    private func addAction() {
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
    
    @objc private func addProductButtonTapped() {
        guard let productVC = storyboard?.instantiateViewController(withIdentifier: "ProductViewController") else { return }
        self.navigationController?.pushViewController(productVC, animated: true)
    }
    
    // MARK: DataSource
    private func makeListDataSource() -> DataSource {
        let registration = UICollectionView.CellRegistration<MarketListCollectionViewCell, ProductItem>.init { cell, indexPath, item in
            cell.configureCell(with: item, cell, indexPath, self.collectionView)
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }
    
    private func makeGridDataSource() -> DataSource {
        let registration = UICollectionView.CellRegistration<MarketGridCollectionViewCell, ProductItem>.init { cell, indexPath, item in
            cell.configureCell(with: item, cell, indexPath, self.collectionView)
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }
    
    // MARK: Data & Snapshot
    private func applySnapshots() {
        var itemSnapshot = SnapShot()
        itemSnapshot.appendSections([.main])
        itemSnapshot.appendItems(products)
        dataSource.apply(itemSnapshot, animatingDifferences: false)
    }
    
    private func receivePageData() {
        guard let getRequest = RequestDirector().createGetRequest() else { return }
        
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
                    self.showAlert(title: "서버 통신 실패", message: "데이터를 받아오지 못했습니다.")
                }
            }
        }
    }
    
    private func decodeResult(_ data: Data) {
        do {
            let page = try DataManager().decode(type: Page.self, data: data)
            
            self.products = page.pages.map { ProductItem(product: $0 ) }
        } catch {
            DispatchQueue.main.async {
                self.showAlert(title: "데이터 변환 실패", message: "가져온 데이터를 읽을 수 없습니다.")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let failureAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        failureAlert.addAction(UIAlertAction(title: "확인", style: .default))
        present(failureAlert, animated: true)
    }
    
    // MARK: Layout
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

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailCollectionViewController") as? ProductDetailCollectionViewController else { return }
        detailVC.receiveProductInfo(number: products[indexPath.row].productID, name: products[indexPath.row].productName)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

fileprivate enum ProductListType {
    static let list = "LIST"
    static let grid = "GRID"
}