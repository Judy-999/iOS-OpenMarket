//
//  ParamManager.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/01.
//

import Foundation

struct ParamManager {
    func combineParamForPost(param: Param, imageParams: [ImageParam]) -> [[String : Any]]{
        let description = param.description.replacingOccurrences(of: "\n", with: "\\n")
         
        let dataElement: [[String : Any]] = [
            [
                "key": "params",
                "value": """
                        {
                            "name": "\(param.productName)",
                            "price": \(param.price),
                            "discounted_price": \(param.discountedPrice),
                            "stock": \(param.stock),
                            "currency": "\(param.currency)",
                            "secret": "\(param.secret)",
                            "descriptions": "\(description)"
                        }
                        """,
                "type": "text"
            ],
            [
                "key": "images",
                "images": imageParams
            ]
        ]
        
        return dataElement
    }
    
    func combineParamForPatch(param: Param) -> String {
        let dataElement = "{\"secret\": \"\(VendorInfo.secret)\", \"name\": \"\(param.productName)\", \"price\": \(param.price), \"discounted_price\": \(param.discountedPrice), \"stock\": \(param.stock), \"currency\": \"\(param.currency)\", \"description\": \"\(param.description)\"}"
        
        return dataElement
    }
}
