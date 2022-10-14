//
// /Users/zzbae/Desktop/Yagom Career Starter Camp 6기/ios-open-market/OpenMarket/OpenMarket File.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/11.
//

import Foundation

struct Page: Decodable {
    let pageNumber: Int
    let itemsPerPage: Int
    let totalCount: Int
    let offset: Int
    let limit: Int
    let pages: [Product]
    let lastPage: Int
    let hasNext: Bool
    let hasPrevious: Bool
    
    private enum CodingKeys: String, CodingKey {
        case itemsPerPage, totalCount, offset, limit, pages, lastPage, hasNext
        case pageNumber = "pageNo"
        case hasPrevious = "hasPrev"
    }
}

struct Product: Decodable {
    let id: Int
    let vendorId: Int
    let vendorName: String
    let name: String
    let description: String
    let thumbnail: String
    let currency: Currency
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String
    let issuedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, vendorName, name, description, thumbnail, currency, price, stock
        case vendorId = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}
