//
//  ProductViewController.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/27.
//

import UIKit

final class EditProductViewController: UIViewController {
    // MARK: Inner types
    private enum ViewMode {
        case add, edit
    }
    
    // MARK: Properties
    private let productView = EditProductView()
    private var imageDataSource: [UIImage] = []
    private lazy var imagePicker = UIImagePickerController()
    private var viewMode: ViewMode = .add
    private var productNumber: Int?
    
    override func loadView() {
        super.loadView()
        view = productView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDelegate()
        configureNotificationCenter()
    }
    
    func changeToEditMode(with data: ProductInfo, _ images: [String]) {
        productView.configure(with: data)
        productNumber = data.id
        images.forEach {
            guard let cachedImage = ImageCacheManager.shared.object(forKey: NSString(string: $0)) else { return }
            imageDataSource.append(cachedImage)
        }
        productView.collectionView.reloadData()
        viewMode = .edit
    }
    
    //MARK: configure
    private func configureUI() {
        let cancelBarButton = UIBarButtonItem(title: "Cancel",
                                              style: .plain,
                                              target: self,
                                              action: #selector(cancelButtonDidTap))
        let doneBarButton = UIBarButtonItem(title: "Done",
                                            style: .plain,
                                            target: self,
                                            action: #selector(doneButtonTapped))
        
        switch viewMode {
        case .add:
            navigationItem.title = MarketInfo.addProductTitle
        case .edit:
            navigationItem.title = MarketInfo.editProductTitle
        }
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.setHidesBackButton(true, animated: false)
        
        if imageDataSource.isEmpty {
            guard let addImage = UIImage(systemName: "plus") else { return }
            imageDataSource.append(addImage)
            configureImagePicker()
        }
    }
    
    private func configureDelegate() {
        productView.collectionView.dataSource = self
        productView.collectionView.delegate = self
    }
    
    private func configureImagePicker() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    private func configureNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        productView.adjustContentInset(height: keyboardFrame.size.height)
    }
    
    @objc private func keyboardWillHide() {
        productView.adjustContentInset(height: 0)
    }
    
    //MARK: buttonAction
    @objc private func cancelButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        let sessionManager = URLSessionManager()
        guard let requestProduct = productView.createRequestProduct() else { return }
        
        guard requestProduct.productName.isEmpty == false,
              requestProduct.description.isEmpty == false,
              requestProduct.price != Double.zero else {
            AlertManager(self).showAlert(.unavailableProduct)
            return
        }
        
        switch viewMode {
        case .add:
            postProduct(requestProduct, sessionManager)
        case .edit:
            patchProduct(requestProduct, sessionManager)
        }
    }
    
    private func patchProduct(_ product: RequestProduct, _ sessionManager: URLSessionManager) {
        let patchProduct = MultipartManager.shared.convertToPatchProducct(product)
        guard let productNumber = productNumber,
              let patchRequest = RequestDirector().createPatchRequest(productNumber: productNumber,
                                                                      dataElement: patchProduct) else { return }
        
        sessionManager.dataTask(request: patchRequest) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    AlertManager(self).showAlert(.patchFailure)
                }
                
            }
        }
    }
    
    private func postProduct(_ product: RequestProduct, _ sessionManager: URLSessionManager) {
        let images = Array(imageDataSource[1..<imageDataSource.count])
        
        guard images.isEmpty == false else {
            AlertManager(self).showAlert(.nonExistentImage)
            return
        }
        
        let dataElement = MultipartManager.shared.createMultipartData(with: product, images)
        
        guard let postRequest = RequestDirector().createPostRequest(with: dataElement) else { return }
        
        sessionManager.dataTask(request: postRequest) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    AlertManager(self).showAlert(.postFailure)
                }
            }
        }
    }
}

//MARK: CollectionView's DataSource & Delegate
extension EditProductViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.imageDataSource.count
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AddImageCollectionViewCell.self,
                                                      for: indexPath)
        cell.configure(with: imageDataSource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == Int.zero {
            self.present(imagePicker, animated: true)
        }
    }
}

//MARK: imagePickerController
extension EditProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard imageDataSource.count != ProductImageInfo.numberOfMax + 1 else {
            picker.dismiss(animated: true, completion: nil)
            AlertManager(self).showAlert(.exceededNumberOfImages)
            return
        }
        
        var selectedImage = UIImage()
        
        if let newImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = newImage
        } else if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = newImage
        }

        imageDataSource.insert(selectedImage, at: imageDataSource.count)
        productView.collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: Namespace
extension EditProductViewController {
    private enum MarketInfo {
        static let addProductTitle = "상품등록"
        static let editProductTitle = "상품수정"
    }
}
