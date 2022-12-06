//
//  AddProductView.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/27.
//

import UIKit

final class EditProductView: UIView {
    // MARK: - Properties
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 120)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        view.register(cellWithClass: AddImageCollectionViewCell.self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productNameTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = ProductInput.name
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.keyboardType = .default
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let priceTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = ProductInput.price
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.keyboardType = .numberPad
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let discountedPriceTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = ProductInput.discount
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.keyboardType = .numberPad
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let stockTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = ProductInput.stock
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.keyboardType = .numberPad
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UIKit.UISegmentedControl(items: [Currency.krw.rawValue,
                                                                Currency.usd.rawValue])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .subheadline)
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.borderWidth = 1
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        textView.keyboardDismissMode = .onDrag
        return textView
    }()
    
    private let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Methods
    func createRequestProduct() -> RequestProduct? {
        guard let name = productNameTextfield.text,
              let priceText = priceTextfield.text,
              let discountedPriceText = discountedPriceTextfield.text,
              let stockText = stockTextfield.text,
              let currency = Currency.indexToCurreny(segmentedControl.selectedSegmentIndex),
              let descriptionText = descriptionTextView.text else { return nil }

        let price = Double(priceText) ?? 0
        let discountedPrice = Double(discountedPriceText) ?? 0
        let stock = Int(stockText) ?? 0
        let requestProuct = RequestProduct(productName: name,
                                           price: price,
                                           discountedPrice: discountedPrice,
                                           currency: currency,
                                           stock: stock,
                                           description: descriptionText)
        
        return requestProuct
    }
    
    func configure(with data: ProductInfo) {
        productNameTextfield.text = data.name
        priceTextfield.text = data.price.convertToString
        discountedPriceTextfield.text = data.discountedPrice.convertToString
        stockTextfield.text = String(data.stock)
        descriptionTextView.text = data.description
        segmentedControl.selectedSegmentIndex = data.currency.index
    }
    
    func adjustContentInset(height: CGFloat) {
        self.descriptionTextView.contentInset.bottom = height
    }
    
    private func setupView() {
        addSubView()
        setupConstraints()
    }
    
    private func addSubView() {
        self.backgroundColor = .systemBackground
        
        priceStackView.addArrangedSubview(priceTextfield)
        priceStackView.addArrangedSubview(segmentedControl)
        
        infoStackView.addArrangedSubview(productNameTextfield)
        infoStackView.addArrangedSubview(priceStackView)
        infoStackView.addArrangedSubview(discountedPriceTextfield)
        infoStackView.addArrangedSubview(stockTextfield)
        
        entireStackView.addArrangedSubview(collectionView)
        entireStackView.addArrangedSubview(infoStackView)
        entireStackView.addArrangedSubview(descriptionTextView)
        
        self.addSubview(entireStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            entireStackView.leadingAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            entireStackView.trailingAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            entireStackView.topAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            entireStackView.bottomAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            collectionView.heightAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
            segmentedControl.widthAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            infoStackView.heightAnchor
                .constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
        ])
    }
}

extension EditProductView {
    private enum ProductInput {
        static let name = "상품명"
        static let price = "상품 가격"
        static let discount = "할인 금액"
        static let stock = "재고 수량"
    }
}

fileprivate extension Double {
    var convertToString: String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(self))
        }
        
        return String(self)
    }
}
