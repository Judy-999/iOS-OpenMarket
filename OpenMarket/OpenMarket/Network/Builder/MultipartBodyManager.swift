//
//  MarketBodyManager.swift
//  OpenMarket
//
//  Created by Judy on 2022/10/31.
//

import Foundation

struct MultipartBodyManager {
    func makeBody(parameters: [[String : Any]], _ boundary: String) -> Data? {
        var body = Data()
        
        for param in parameters {
            guard let paramName = param["key"] as? String else { return nil }
            let paramType = param["type"] as? String
            
            guard let boundary = "--\(boundary)\r\n".data(using: .utf8),
                  let disposition = "Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8) else { return nil }
            if paramType == "text"{
                guard let paramValue = param["value"] as? String,
                      let value = "\r\n\r\n\(paramValue)\r\n".data(using: .utf8) else { return nil }
                print(paramValue)
                body.append(contentsOf: boundary)
                body.append(contentsOf: disposition)
                body.append(contentsOf: value)
            } else {
                guard let imageParams = param["images"] as? [ImageParam] else { return nil }
                
                for param in imageParams {
                    guard let fileName = "; filename=\"\(param.imageName)\"\r\n".data(using: .utf8),
                          let contentType = "Content-Type: image/\(param.imageType)\r\n\r\n".data(using: .utf8),
                          let space = "\r\n".data(using: .utf8) else { return nil }
                    
                    body.append(contentsOf: boundary)
                    body.append(contentsOf: disposition)
                    body.append(contentsOf: fileName)
                    body.append(contentsOf: contentType)
                    body.append(contentsOf: param.imageData)
                    body.append(contentsOf: space)
                }
            }
        }
        
        guard let lastBoundary = "--\(boundary)--\r\n".data(using: .utf8) else { return nil }
        body.append(contentsOf: lastBoundary)

        return body
    }
}
