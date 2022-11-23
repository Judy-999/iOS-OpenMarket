//
//  MarketGridCollectionViewCell.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/19.
//

import UIKit

final class MarketGridCollectionViewCell: UICollectionViewCell {
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
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    func configureCell(with item: Item, _ cell: UICollectionViewCell, _ indexPath: IndexPath, _ collectionView: UICollectionView) {
        self.nameLabel.text = item.productName
        
        if item.price == item.bargainPrice {
            self.priceLabel.text = item.price
            self.priceLabel.textColor = .systemGray
        } else {
            let price = item.price + "\n" + item.bargainPrice
            self.priceLabel.attributedText = price.addDiscountAttribute(with: item.price.count, item.bargainPrice.count)
        }
        
        if item.stock != "0" {
            self.stockLabel.text = "잔여수량 : " + item.stock
        } else {
            self.stockLabel.text = "품절"
            self.stockLabel.textColor = .systemOrange
        }
        
        if let cachedImage = ImageCacheManager.shared.object(forKey: NSString(string: item.productImage)) {
            imageView.image = cachedImage
        } else {
            imageView.configureImage(url: item.productImage, cell, indexPath, collectionView)
        }
    }
    
    private func arrangeSubView() {
        priceLabel.textAlignment = .center
        
        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(priceLabel)
        verticalStackView.addArrangedSubview(stockLabel)
        
        contentView.addSubview(verticalStackView)
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.systemGray3.cgColor
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.58)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        arrangeSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func prepareForReuse(){
        super.prepareForReuse()
        stockLabel.textColor = .systemGray
        priceLabel.textColor = .systemRed
    }
}
