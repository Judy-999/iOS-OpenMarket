//
//  MarketListCollectionViewCell.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/18.
//

import UIKit

final class MarketListCollectionViewCell: UICollectionViewCell, MarketCollectionCell {
    // MARK: - Properties
    private let imageView: SessionImageView = {
        let imageView = SessionImageView()
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemRed
        label.numberOfLines = 2
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemGray
        return label
    }()
    
    private let accessaryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "greaterthan")
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let subHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Methods
    func configureCell(with item: ProductItem, _ cell: UICollectionViewCell, _ indexPath: IndexPath, _ collectionView: UICollectionView) {
        self.nameLabel.text = item.name
        
        if item.price == item.bargainPrice {
            self.priceLabel.text = item.price
            self.priceLabel.textColor = .systemGray
        } else {
            let price = item.price + " " + item.bargainPrice
            self.priceLabel.attributedText = price.addDiscountAttribute(with: item.price.count, item.bargainPrice.count)
        }
        
        if item.stock != "0" {
            self.stockLabel.text = "잔여수량 : " + item.stock
        } else {
            self.stockLabel.text = "품절"
            self.stockLabel.textColor = .systemOrange
        }
        
        if let cachedImage = ImageCacheManager.shared.object(forKey: NSString(string: item.thumbnailURL)) {
            imageView.image = cachedImage
        } else {
            imageView.configureImage(url: item.thumbnailURL, cell, indexPath, collectionView)
        }
    }
    
    private func setupView() {
        addSubView()
        setupConstraints()
        self.contentView.layer.addBottomBorder()
    }
    
    private func addSubView() {
        stockLabel.textAlignment = .right
        
        subHorizontalStackView.addArrangedSubview(stockLabel)
        subHorizontalStackView.addArrangedSubview(accessaryImageView)
        
        horizontalStackView.addArrangedSubview(nameLabel)
        horizontalStackView.addArrangedSubview(subHorizontalStackView)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(priceLabel)
        
        entireStackView.addArrangedSubview(imageView)
        entireStackView.addArrangedSubview(verticalStackView)
        
        contentView.addSubview(entireStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            entireStackView.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 5),
            entireStackView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -5),
            entireStackView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -10),
            entireStackView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 5),
            
            imageView.widthAnchor
                .constraint(equalTo: imageView.heightAnchor, multiplier: 1),
            
            accessaryImageView.widthAnchor
                .constraint(equalTo: contentView.heightAnchor, multiplier: 0.2)
        ])
    }
        
    override func prepareForReuse(){
        super.prepareForReuse()
        stockLabel.textColor = .systemGray
        priceLabel.textColor = .systemRed
    }
}

fileprivate extension CALayer {
    func addBottomBorder() {
        let border = CALayer()
        
        border.backgroundColor = UIColor.systemGray3.cgColor
        border.frame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
        
        self.addSublayer(border)
    }
}
