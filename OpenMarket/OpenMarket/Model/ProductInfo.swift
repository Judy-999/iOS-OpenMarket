//
//  DetailProduct.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/02.
//

import Foundation

struct ProductInfo: Decodable {
    let id: Int
    let vendorId: Int
    let name: String
    let thumbnail: String
    let currency: Currency
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String
    let issuedAt: String
    let description: String?
    let vendors: Vendor
    let images: [ProductImage]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, thumbnail, currency, price, stock, vendors, images
        case vendorId = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}

struct Vendor: Decodable {
    let name: String
    let id: Int
}

struct ProductImage: Decodable {
    let id: Int
    let url: String
    let thumbnailURL: String
    let issuedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, url
        case thumbnailURL = "thumbnail_url"
        case issuedAt = "issued_at"
    }
}
