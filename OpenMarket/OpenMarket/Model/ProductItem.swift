//
//  Item.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/15.
//

import UIKit

struct ProductItem: Hashable {
    let id: Int
    let thumbnailURL: String
    let name: String
    let price: String
    let bargainPrice: String
    let stock: String
    
    init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.price = product.currency.rawValue + " " + product.price.devidePrice
        self.bargainPrice = product.currency.rawValue + " " + product.bargainPrice.devidePrice
        self.stock = String(product.stock)
        self.thumbnailURL = product.thumbnail
    }
}

struct ProductInfoItem: Hashable {
    let name: String
    let price: String
    let bargainPrice: String
    let stock: String
    let description: String
    let thumbnailURL: String
    
    init(product: ProductInfo) {
        self.name = product.name
        self.price = product.currency.rawValue + " " + product.price.devidePrice
        self.bargainPrice = product.currency.rawValue + " " + product.bargainPrice.devidePrice
        self.stock = String(product.stock)
        self.description = product.description ?? ""
        self.thumbnailURL = product.thumbnail 
    }

    init(detailItem: ProductInfoItem, imageURL: String) {
        self.name = detailItem.name
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
