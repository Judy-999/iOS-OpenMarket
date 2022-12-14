//
//  RequestDirector.swift
//  OpenMarket
//
//  Created by Judy on 2022/10/19.
//

import Foundation

struct RequestDirector {
    private let builder: RequestBuilder
    
    init(_ builder: RequestBuilder = RequestBuilder()) {
        self.builder = builder
    }
    
    func createGetRequest(page: Int, itemCount: Int) -> MarketRequest? {
        let getRequest = builder.setMethod(.get)
            .setPath(URLPath.product)
            .setQuery([Query.page: page, Query.itemPerPage: itemCount])
            .buildRequest()
        
        return getRequest
    }
    
    func createGetDetailRequest(_ productNumber: Int) -> MarketRequest? {
        let getDetailRequest = builder.setMethod(.get)
            .setPath(URLPath.product + "/\(productNumber)")
            .buildRequest()
        
        return getDetailRequest
    }
    
    func createPostRequest(with dataElement: [MultipartData]) -> MarketRequest? {
        let boundary = "Boundary-\(UUID().uuidString)"
        let postRequest = builder.setMethod(.post)
            .setPath(URLPath.product)
            .setBody(MultipartManager.shared.makeBody(parameters: dataElement, boundary))
            .setHeaders(["Content-Type": "multipart/form-data; boundary=\(boundary)",
                         "identifier": VendorInfo.identifier])
            .buildRequest()

        return postRequest
    }
    
    func createPatchRequest(productNumber: Int, dataElement: Data) -> MarketRequest? {    
        let patchRequest = builder.setMethod(.patch)
            .setPath(URLPath.product + "/\(productNumber)")
            .setHeaders(["identifier": VendorInfo.identifier,
                         "Content-Type": "application/json"])
            .setBody(dataElement)
            .buildRequest()
        
        return patchRequest
    }
    
    func createDeleteURIRequest(vendorSecret: String, productNumber: Int) -> MarketRequest? {
        let parameters = "{\"secret\": \"\(vendorSecret)\"}"
        guard let postData = parameters.data(using: .utf8) else { return nil }
        
        let deleteURIRequest = builder.setMethod(.post)
            .setPath(URLPath.product + "/\(productNumber)/archived")
            .setHeaders(["Content-Type": "application/json",
                         "identifier": VendorInfo.identifier])
            .setBody(postData)
            .buildRequest()
        
        return deleteURIRequest
    }
    
    func createDeleteRequest(with deleteURI: Data) -> MarketRequest? {
        guard let deleteKey = String(data: deleteURI, encoding: .utf8) else { return nil }
        
        let deleteRequest = builder.setMethod(.delete)
            .setPath(deleteKey)
            .setHeaders(["identifier": VendorInfo.identifier])
            .buildRequest()
        
        return deleteRequest
    }
}
