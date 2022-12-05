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
    
    // MARK: UI
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UIKit.UISegmentedControl(items: [LayoutType.list.name,
                                                                LayoutType.grid.name])
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        receivePageData()
        addAction()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: createLayout(for: .list))
        collectionView.delegate = self
        collectionView.register(cellWithClass: MarketListCollectionViewCell.self)
        collectionView.register(cellWithClass: MarketGridCollectionViewCell.self)
        view.addSubview(collectionView)
    }
    
    private func configureUI() {
        configureCollectionView()
        
        let addProductBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
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
        receivePageData()
    }
    
    @objc private func addProductButtonTapped() {
        let editViewController = EditProductViewController()
        self.navigationController?.pushViewController(editViewController, animated: true)
    }
    
    // MARK: DataSource
    private func makeDataSource(for layout: LayoutType) -> DataSource {
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell: MarketCollectionCell
            
            switch layout {
            case .list:
                cell = collectionView.dequeueReusableCell(withClass: MarketListCollectionViewCell.self,
                                                          for: indexPath)
            case .grid:
                cell = collectionView.dequeueReusableCell(withClass: MarketGridCollectionViewCell.self,
                                                          for: indexPath)
            }
            
            cell.configure(with: item)
            
            return cell
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
                return 0.08
            case .grid:
                return 0.35
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
