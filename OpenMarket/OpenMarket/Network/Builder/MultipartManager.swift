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
        let firstBoundary = "--\(boundary)\r\n"
        let lastBoundary = "--\(boundary)--\r\n"
        
        for param in parameters {
            let disposition = "Content-Disposition:form-data; name=\"\(param.dispositionName)\""
            let space = "\r\n"
            let contentType = "Content-Type: \(param.contentType)\r\n\r\n"
            guard let value = param.data else { return nil }
            
            body.appendData(firstBoundary)
            body.appendData(disposition)
            
            if let name = param.fileName {
                body.appendData("; filename=\"\(name)\"")
            }
            
            body.appendData(space)
            body.appendData(contentType)
            body.append(value)
            body.appendData(space)
        }
        
        body.appendData(lastBoundary)
        
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
        
        images.enumerated().forEach {
            let resizedImage = compressImage($0.1)
            
            let multipartImageData = MultipartData(dispositionName: "images",
                                                   data: resizedImage,
                                                   contentType: "image/" + resizedImage.fileExtension,
                                                   fileName: "\($0.0)번 사진.\(resizedImage.fileExtension)")
            
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
