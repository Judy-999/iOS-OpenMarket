//
//  APIRequest.swift
//  OpenMarket
//
//  Created by Judy on 2022/10/18.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum URLHost {
    static let url = "https://openmarket.yagom-academy.kr"
}

enum URLPath: String {
    case healthChecker = "/healthChecker"
    case product = "/api/products"
}

protocol APIRequest {
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var query: [String: Any] { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
}

struct MarketRequest: APIRequest {
    var method: HTTPMethod
    var baseURL: String
    var path: String
    var query: [String: Any]
    var body: Data?
    var headers: [String: String]?
}

extension APIRequest {
    var url: URL? {
        var urlComponents = URLComponents(string: baseURL + path)
        
        urlComponents?.queryItems = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        return urlComponents?.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpBody = body
        urlRequest.httpMethod = method.rawValue
        headers?.forEach { field, value  in
            urlRequest.addValue(value, forHTTPHeaderField: field)
        }
        
        return urlRequest
    }
}

extension APIRequest {
    private func makeBody(parameters: [[String : Any]], boundary: String) -> Data? {
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
