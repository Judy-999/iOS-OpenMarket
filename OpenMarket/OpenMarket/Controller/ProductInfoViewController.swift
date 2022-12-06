//
//  ProductDetailCollectionViewController.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/02.
//

import UIKit

final class ProductInfoViewController: UIViewController {
    // MARK: Inner types
    private enum Section: Int ,Hashable {
        case image, info
    }
    
    // MARK: Typealias
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductInfoItem>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ProductInfoItem>
    
    // MARK: Properties
    private lazy var dataSource = makeDataSource()
    private var collectionView: UICollectionView!
    private var productInfo: ProductInfo?
    private var images: [String] = []
    private var productNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        receiveDetailData()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
    }
    
    private func configureUI() {
        configureCollectionView()
        
        let editProductBarButton = UIBarButtonItem(image: MarketImage.option,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(editProductButtonTapped))
        
        let backBarButton = UIBarButtonItem(image: MarketImage.back,
                                            style: .plain,
                                            target: self,
                                            action: #selector(backBarButtonTapped))
        
        navigationItem.rightBarButtonItem = editProductBarButton
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc private func backBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editProductButtonTapped() {
        let editAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: Option.edit, style: .default) { _ in
            self.convertToEditView()
        }
        
        let deleteAction = UIAlertAction(title: Option.delete, style: .destructive) { _ in
            self.deleteAfterCheckSecret()
        }
        
        let cancelAction = UIAlertAction(title: Option.cancel, style: .cancel)
        
        [editAction, deleteAction, cancelAction].forEach {
            editAlert.addAction($0)
        }
        
        present(editAlert, animated: true)
    }
    
    private func deleteAfterCheckSecret() {
        let checkAlert = UIAlertController(title: AlertType.confirmPassword.title,
                                           message: AlertType.confirmPassword.message,
                                           preferredStyle: .alert)
        checkAlert.addTextField()
        
        let confirmAction = UIAlertAction(title: Option.confirm, style: .default) { [self] _ in
            let sessionManager = URLSessionManager()
            guard let inputSecret = checkAlert.textFields?.first?.text,
                  let productNumber = productNumber,
                  let deleteURIRequest = RequestDirector().createDeleteURIRequest(vendorSecret: inputSecret,
                                                                                  productNumber: productNumber) else { return }
            
            sessionManager.dataTask(request: deleteURIRequest) { result in
                switch result {
                case .success(let data):
                    guard let deleteRequest = RequestDirector().createDeleteRequest(with: data) else { return }
                    
                    sessionManager.dataTask(request: deleteRequest) { result in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        case .failure(_):
                            DispatchQueue.main.async {
                                AlertManager(self).showAlert(.deleteFailure)
                            }
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        AlertManager(self).showAlert(.incorrectPassword)
                    }
                }
            }
        }
        checkAlert.addAction(confirmAction)
        present(checkAlert, animated: true)
    }
    
    private func convertToEditView() {
        let editProductViewController = EditProductViewController()
        guard let productInfo = productInfo else { return }
        editProductViewController.changeToEditMode(with: productInfo, images)
        navigationController?.pushViewController(editProductViewController, animated: true)
    }
    
    func receiveProductInfo(number: Int, name: String) {
        navigationItem.title = name
        productNumber = number
    }
    
    // MARK: DataSource
    private func makeDataSource() -> DataSource {
        let infoRegistration = UICollectionView.CellRegistration<ProductInfoCollectionViewCell, ProductInfoItem>.init { cell, indexPath, item in
            cell.configure(with: item)
        }
        
        let imageRegistration = UICollectionView.CellRegistration<ProductImageCollectionViewCell, ProductInfoItem>.init { cell, indexPath, item in
            cell.configure(with: item.thumbnailURL,
                           number: "\(indexPath.row+1)/\(self.images.count)")
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            
            switch section {
            case .image:
                return collectionView.dequeueConfiguredReusableCell(using: imageRegistration,
                                                                    for: indexPath, item: item)
            case .info:
                return collectionView.dequeueConfiguredReusableCell(using: infoRegistration,
                                                                    for: indexPath, item: item)
            }
        }
    }
    
    // MARK: Data & Snapshot
    private func receiveDetailData() {
        let sessionManager = URLSessionManager()
        
        guard let productNumber = productNumber,
              let productDetailRequest = RequestDirector().createGetDetailRequest(productNumber) else { return }
        
        LoadingIndicator.showLoading(on: view)
        sessionManager.dataTask(request: productDetailRequest) { result in
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
    
    private func applySnapshots() {
        guard let productInfo = productInfo else {  return }
        let detailProductItem = ProductInfoItem(product: productInfo)
        var detailImages: [ProductInfoItem] = []
        var itemSnapshot = SnapShot()
        
        images.forEach {
            detailImages.append(ProductInfoItem(detailItem: detailProductItem, imageURL: $0))
        }
        itemSnapshot.appendSections([.image, .info])
        itemSnapshot.appendItems(detailImages , toSection: .image)
        itemSnapshot.appendItems([detailProductItem], toSection: .info)
        
        dataSource.apply(itemSnapshot, animatingDifferences: false)
    }
    
    private func decodeResult(_ data: Data) {
        do {
            self.productInfo = try DataManager().decode(type: ProductInfo.self, data: data)
            guard let productInfo = productInfo else {  return }
            self.images = productInfo.images.map { $0.url }
        } catch {
            DispatchQueue.main.async {
                AlertManager(self).showAlert(.decodingFailure)
            }
        }
    }
    
    // MARK: Layout
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            
            switch sectionKind {
            case .image:
                let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: layoutSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(0.45))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
            case .info:
                let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: layoutSize)
                let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(0.55))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize,
                                                               subitem: item,
                                                               count: 1)

                section = NSCollectionLayoutSection(group: group)
            }
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension ProductInfoViewController {
    private enum Option {
        static let edit = "수정"
        static let delete = "삭제"
        static let cancel = "취소"
        static let confirm = "확인"
    }
}
