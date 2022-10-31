//
//  MarketRequest.swift
//  OpenMarket
//
//  Created by Judy on 2022/10/31.
//

import Foundation

struct MarketRequest: APIRequest {
    var method: HTTPMethod
    var baseURL: String
    var path: String
    var query: [String: Any]?
    var body: Data?
    var headers: [String: String]?
}
