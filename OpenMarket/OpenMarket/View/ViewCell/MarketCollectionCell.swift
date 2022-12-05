//
//  MarketProtocol.swift
//  OpenMarket
//
//  Created by Judy on 2022/12/02.
//

import UIKit

protocol MarketCollectionCell: UICollectionViewCell {
    var nameLabel: UILabel { get }
    var priceLabel: UILabel { get }
    var bargainPriceLabel: UILabel { get }
    var stockLabel: UILabel { get }
    var imageView: SessionImageView { get }
    func configure(with item: ProductItem)
}

extension MarketCollectionCell {
    func configure(with item: ProductItem) {
        nameLabel.text = item.name
        priceLabel.text = item.price
        
        if item.bargainPrice != item.price {
            bargainPriceLabel.isHidden = false
            bargainPriceLabel.attributedText = item.bargainPrice.addDiscountAttribute
        }
        
        if item.stock != "0" {
            stockLabel.text = "잔여수량 : \(item.stock)"
        } else {
            stockLabel.text = "품절"
            stockLabel.textColor = .systemOrange
        }
        
        imageView.configureImage(with: item.thumbnailURL)
    }
}
