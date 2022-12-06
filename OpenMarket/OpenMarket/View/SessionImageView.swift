//
//  SessionImageView.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/01.
//

import UIKit

class SessionImageView: UIImageView {
    var imageDataTask: URLSessionDataTask?
    
    func cancelImageLoding() {
        self.image = UIImage()
        imageDataTask?.cancel()
        imageDataTask = nil
    }
    
    func configureImage(with imageURL: String) {
        let cachedKey = NSString(string: imageURL)
        
        if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
        } else {
            loadImage(with: imageURL, key: cachedKey)
        }
    }
    
    private func loadImage(with imageURL: String, key: NSString) {
        guard let imageURL = URL(string: imageURL) else { return }
        let imageRequest = URLRequest(url: imageURL)
                
        LoadingIndicator.showLoading(on: self)
        imageDataTask = URLSession.shared.dataTask(with: imageRequest) { data, _, error in
            if let data = data {
                guard let imageData = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    self.image = imageData
                    LoadingIndicator.hideLoading(on: self)
                }
                
                ImageCacheManager.shared.setObject(imageData, forKey: key)
            }
        }
        
        imageDataTask?.resume()
    }
}
