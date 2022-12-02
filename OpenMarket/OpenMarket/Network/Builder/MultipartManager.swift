//
//  MarketBodyManager.swift
//  OpenMarket
//
//  Created by Judy on 2022/10/31.
//

import UIKit

class MultipartManager {
    static let shared = MultipartManager()
    
    private init() {}
    
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

extension MultipartManager {
    func createMultipartData(with product: RequestProduct, _ images: [UIImage]) -> [MultipartData] {
        return convertToMultipartData(product) + convertToMultipartImage(images)
    }
    
    func convertToPatchProducct(_ product: RequestProduct) -> Data {
        var patchData: Data
        
        do {
            patchData = try DataManager().encode(data: product)
        } catch {
            patchData = Data()
        }
        
        return patchData
    }
    
    private func convertToMultipartData(_ product: RequestProduct) -> [MultipartData] {
        var data: Data
        
        do {
            data = try DataManager().encode(data: product)
        } catch {
            data = Data()
        }
     
        let productData = MultipartData(dispositionName: "params",
                                     data: data,
                                     contentType: "application/json",
                                     fileName: nil)
        
        return [productData]
    }
    
    private func convertToMultipartImage(_ images: [UIImage]) -> [MultipartData] {
        var multipartImageDatas: [MultipartData] = []
        
        images.forEach {
            let resizedImage = compressImage($0)
            
            let multipartImageData = MultipartData(dispositionName: "images",
                                          data: resizedImage,
                                          contentType: "image/" + resizedImage.fileExtension,
                                          fileName: "사진.\(resizedImage.fileExtension)")
            
            multipartImageDatas.append(multipartImageData)
        }
        
        return multipartImageDatas
    }
    
    private func compressImage(_ image: UIImage) -> Data {
        guard var imageData = image.jpegData(compressionQuality: 1.0) else { return Data() }
        var imageDataSize = imageData.count
        var scale = 0.9
        
        while imageDataSize >= ProductImageInfo.maximumCapacity * 1024 {
            imageData = image.jpegData(compressionQuality: scale) ?? Data()
            imageDataSize = imageData.count
            scale -= 0.1
        }
        
        return imageData
    }
}

enum ProductImageInfo {
    static let numberOfMax = 5
    static let maximumCapacity = 300
}
