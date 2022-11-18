//
//  Param.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/28.
//

import UIKit

struct RequestProduct: Encodable {
    let productName: String
    let price: Double
    let discountedPrice: Double
    let currency: String
    let stock: Int
    let description: String
    let secret: String = VendorInfo.secret
    
    private enum CodingKeys: String, CodingKey {
        case price, currency, stock, description, secret
        case productName = "name"
        case discountedPrice = "discounted_price"
    }
}

struct MutipartImage {
    let imageName: String
    let imageType: String
    let imageData: Data
}
