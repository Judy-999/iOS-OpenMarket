//
//  ParamManager.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/01.
//

import Foundation

struct ParamManager {
    func combineParamForPost(param: Param, imageParams: [ImageParam]) -> [MultipartData] {
        let description = param.description.replacingOccurrences(of: "\n", with: "\\n")
        let dataValue = """
                        {
                            "name": "\(param.productName)",
                            "price": \(param.price),
                            "discounted_price": \(param.discountedPrice),
                            "stock": \(param.stock),
                            "currency": "\(param.currency)",
                            "secret": "\(param.secret)",
                            "description": "\(description)"
                        }
                        """
        var multipartDatas: [MultipartData] = []
        let textData = MultipartData(dispositionName: "params",
                                     data: dataValue.data(using: .utf8),
                                     contentType: "application/json",
                                     fileName: nil)
        
        multipartDatas.append(textData)

        imageParams.forEach {
            let imageData = MultipartData(dispositionName: "images",
                                          data: $0.imageData,
                                          contentType: "image/" + $0.imageType,
                                          fileName: $0.imageName)
            multipartDatas.append(imageData)
        }

        return multipartDatas
    }
    
    func combineParamForPatch(param: Param) -> String {
        let dataElement = "{\"secret\": \"\(VendorInfo.secret)\", \"name\": \"\(param.productName)\", \"price\": \(param.price), \"discounted_price\": \(param.discountedPrice), \"stock\": \(param.stock), \"currency\": \"\(param.currency)\", \"description\": \"\(param.description)\"}"
        
        return dataElement
    }
}
