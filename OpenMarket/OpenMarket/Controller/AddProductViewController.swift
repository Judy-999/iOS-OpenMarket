//
//  ProductViewController.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/27.
//

import UIKit

class AddProductViewController: UIViewController {
    // MARK: Inner types
    private enum ViewMode {
        case add, edit
    }
    
    // MARK: Properties
    private let productView = AddProductView()
    private var dataSource: [UIImage] = []
    private var imagePicker: UIImagePickerController?
    private var multipartImages: [MutipartImage] = []
    private lazy var viewConstraint = productView.entireStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -260)
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
    }
    
    func changeToEditMode(data: DetailProduct, images: [String]) {
        productView.configure(data: data)
        productNumber = data.id
        images.forEach {
            guard let cachedImage = ImageCacheManager.shared.object(forKey: NSString(string: $0)) else { return }
            dataSource.append(cachedImage)
        }
        productView.collectionView.reloadData()
        viewMode = .edit
    }
    
    //MARK: configure
    private func configureUI() {
        let cancelBarButton = UIBarButtonItem(title: "Cancel",
                                              style: .plain,
                                              target: self,
                                              action: #selector(cancelButtonDidTapped))
        let doneBarButton = UIBarButtonItem(title: "Done",
                                            style: .plain,
                                            target: self,
                                            action: #selector(updateButtonDidTapped))
        
        switch viewMode {
        case .add:
            navigationItem.title = MarketInfo.addProductTitle
        case .edit:
            navigationItem.title = MarketInfo.editProductTitle
        }
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.setHidesBackButton(true, animated: false)
        
        if dataSource.isEmpty {
            guard let addImage = UIImage(systemName: "plus") else { return }
            dataSource.append(addImage)
            configureImagePicker()
        }
    }
    
    private func configureDelegate() {
        productView.collectionView.dataSource = self
        productView.collectionView.delegate = self
        productView.descriptionTextView.delegate = self
    }
    
    private func configureImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
    }
    
    //MARK: buttonAction
    @objc private func cancelButtonDidTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func updateButtonDidTapped() {
        let sessionManager = URLSessionManager(session: URLSession.shared)
        let multipartManager = MultipartManager()
        guard let requestProduct = productView.createRequestProduct() else { return }
        
        guard requestProduct.productName != "",
              requestProduct.price != 0,
              requestProduct.description != "" else {
            showAlert(title: "상품 등록 불가", message: "필수 항목을 입력해주십시오.\n(이름, 가격, 설명)")
            return
        }
        
        switch viewMode {
        case .add:
            postProduct(multipartManager, requestProduct, sessionManager)
        case .edit:
            patchProduct(multipartManager, requestProduct, sessionManager)
        }
    }
    
    private func patchProduct(_ multipartManager: MultipartManager, _ product: RequestProduct, _ sessionManager: URLSessionManager) {
        let patchProduct = multipartManager.convertToPatchProducct(product)
        guard let productNumber = productNumber else { return }
        guard let patchRequest = RequestDirector().createPatchRequest(productNumber: productNumber,
                                                             dataElement: patchProduct) else { return }
        
        sessionManager.dataTask(request: patchRequest) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .failure(_):
                self.showAlert(title: "실패", message: "상품의 정보를 수정할 수 없습니다.")
            }
        }
    }
    
    private func postProduct(_ multipartManager: MultipartManager, _ product: RequestProduct, _ sessionManager: URLSessionManager) {
        guard dataSource.count != 1 else {
            showAlert(title: "상품 등록 불가", message: "최소 1장 이상의 사진을 넣어주십시오.")
            return
        }
        
        let dataElement = multipartManager.createMultipartData(with: product, multipartImages)
        
        guard let postRequest = RequestDirector().createPostRequest(with: dataElement) else { return }
        
        sessionManager.dataTask(request: postRequest) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(_):
                self.showAlert(title: "서버 통신 실패", message: "데이터를 올리지 못했습니다.")
            }
        }
    }
}

//MARK: CollectionView's DataSource & Delegate
extension AddProductViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddProductCollectionViewCell.id, for: indexPath) as? AddProductCollectionViewCell ?? AddProductCollectionViewCell()
        cell.configureCell(image: dataSource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1 {
            guard let imagePickerCheck = imagePicker else { return }
            self.present(imagePickerCheck, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let failureAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            failureAlert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(failureAlert, animated: true)
        }
    }
}

//MARK: imagePickerController
extension AddProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage = UIImage()
        
        guard multipartImages.count != ProductImageInfo.numberOfMax else {
            picker.dismiss(animated: true, completion: nil)
            showAlert(title: "사진 등록 불가능", message: "사진은 최대 5장까지 가능합니다.")
            return
        }
        
        if let newImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = newImage
        } else if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = newImage
        }
        
        let resizedImage = compressImage(selectedImage)
        
        dataSource.insert(selectedImage, at: 0)
        multipartImages.append(MutipartImage(imageName: "\(dataSource.count - 1)번사진.\(resizedImage.fileExtension)", imageType: resizedImage.fileExtension, imageData: resizedImage))
        
        picker.dismiss(animated: true, completion: nil)
        
        productView.collectionView.reloadData()
    }
    
    private func compressImage(_ image: UIImage) -> Data {
        guard var imageData = image.jpegData(compressionQuality: 1.0) else { return Data() }
        var imageDataSize = imageData.count
        var scale = 0.9
        
        while imageDataSize >= ProductImageInfo.maximumCapacity * 1024 {
            imageData = image.jpegData(compressionQuality: scale) ?? Data()
            imageDataSize = imageData.count
            scale -= 0.1
        }
       
        return imageData
    }
}

//MARK: UITextView
extension AddProductViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewConstraint.isActive = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewConstraint.isActive = false
    }
}

//MARK: ImageDataType
extension Data {
    var fileExtension: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xFF:
            ext = "jpg"
        case 0x89:
            ext = "png"
        case 0xd8:
            ext = "jpeg"
        default:
            ext = "unknown"
        }
        return ext
    }
fileprivate enum MarketInfo {
    static let addProductTitle = "상품등록"
    static let editProductTitle = "상품수정"
}

fileprivate enum ProductImageInfo {
    static let numberOfMax = 5
    static let maximumCapacity = 300
}
