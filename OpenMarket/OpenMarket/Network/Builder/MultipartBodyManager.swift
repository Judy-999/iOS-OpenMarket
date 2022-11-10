//
//  MarketBodyManager.swift
//  OpenMarket
//
//  Created by Judy on 2022/10/31.
//

import Foundation

struct MultipartBodyManager {
    func makeBody(parameters: [MultipartData], _ boundary: String) -> Data? {
        var body = Data()

        guard let fristBoundary = "--\(boundary)\r\n".data(using: .utf8) else { return nil }

        for param in parameters {
            guard let disposition = "Content-Disposition:form-data; name=\"\(param.dispositionName)\"".data(using: .utf8),
                  let value = param.data,
                  let space = "\r\n".data(using: .utf8),
                  let contentType = "Content-Type: \(param.contentType)\r\n\r\n".data(using: .utf8) else { return nil }

            body.append(contentsOf: fristBoundary)
            body.append(contentsOf: disposition)

            if let fileName = param.fileName {
                guard let fileName = "; filename=\"\(fileName)\"".data(using: .utf8) else { return nil }
                body.append(contentsOf: fileName)
            }
            
            body.append(contentsOf: space)
            body.append(contentsOf: contentType)
            body.append(contentsOf: value)
            body.append(contentsOf: space)
        }

        guard let lastBoundary = "--\(boundary)--\r\n".data(using: .utf8) else { return nil }
        body.append(contentsOf: lastBoundary)
        
        return body
    }
}
