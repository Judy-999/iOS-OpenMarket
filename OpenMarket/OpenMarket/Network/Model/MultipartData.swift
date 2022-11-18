//
//  MultipartData.swift
//  OpenMarket
//
//  Created by Judy on 2022/11/10.
//

import Foundation

struct MultipartData {
    let dispositionName: String
    let data: Data?
    let contentType: String
    let fileName: String?
}
