//
//  Item.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/15.
//

import UIKit

struct ProductItem: Hashable {
    let productID: Int
    let productImage: String
    let productName: String
    let price: String
    let bargainPrice: String
    let stock: String
    
    init(product: Product) {
        self.productID = product.id
        self.productName = product.name
        self.price = product.currency.rawValue + " " + product.price.devidePrice
        self.bargainPrice = product.currency.rawValue + " " + product.bargainPrice.devidePrice
        self.stock = String(product.stock)
        self.productImage = product.thumbnail
    }
}

struct ProductInfoItem: Hashable {
    let productName: String
    let price: String
    let bargainPrice: String
    let stock: String
    let description: String
    let thumbnailURL: String
    
    init(product: ProductInfo) {
        self.productName = product.name
        self.price = product.currency.rawValue + " " + product.price.devidePrice
        self.bargainPrice = product.currency.rawValue + " " + product.bargainPrice.devidePrice
        self.stock = String(product.stock)
        self.description = product.description ?? ""
        self.thumbnailURL = product.thumbnail 
    }

    init(detailItem: ProductInfoItem, imageURL: String) {
        self.productName = detailItem.productName
        self.price = detailItem.price
        self.bargainPrice = detailItem.bargainPrice
        self.stock = detailItem.stock
        self.description = detailItem.description
        self.thumbnailURL = imageURL
    }
}

fileprivate extension Double {
    var devidePrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for: self) ?? ""
    }
}
