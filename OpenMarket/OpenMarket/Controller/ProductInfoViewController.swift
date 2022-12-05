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
        
        let editProductBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(editProductButtonTapped))
        
        let backBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
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
        let editAction = UIAlertAction(title: "수정", style: .default) { _ in
            self.convertToEditView()
        }
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.deleteAfterCheckSecret()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        [editAction, deleteAction, cancelAction].forEach {
            editAlert.addAction($0)
        }
        
        present(editAlert, animated: true)
    }
    
    private func deleteAfterCheckSecret() {
        let checkAlert = UIAlertController(title: "비밀번호 확인", message: "비밀번호를 입력해주세요.", preferredStyle: .alert)
        checkAlert.addTextField()
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [self] _ in
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
                            self.showAlert(title: "서버 통신 실패", message: "상품을 삭제하지 못했습니다.")
                        }
                    }
                case .failure(_):
                    self.showAlert(title: "상품 삭제 실패", message: "비밀번호가 일치하지 않습니다.")
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
                    self.showAlert(title: "서버 통신 실패", message: "데이터를 받아오지 못했습니다.")
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
                self.showAlert(title: "데이터 변환 실패", message: "가져온 데이터를 읽을 수 없습니다.")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let failureAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        failureAlert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(failureAlert, animated: true)
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

