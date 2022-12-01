//
//  SessionImageView.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/01.
//

import UIKit

class SessionImageView: UIImageView {
    func configureImage(url: String, _ cell: UICollectionViewCell, _ indexPath: IndexPath, _ collectionView: UICollectionView) {
        let cachedKey = NSString(string: url)
        
        guard let imageRequest = RequestBuilder().setMethod(.get)
            .setBaseURL(url)
            .setPath("")
            .buildRequest() else { return }
                
        URLSessionManager().dataTask(request: imageRequest) { result in
            switch result {
            case .success(let data):
                guard let imageData = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    ImageCacheManager.shared.setObject(imageData, forKey: cachedKey)
                    guard indexPath == collectionView.indexPath(for: cell) else { return }
                    self.image = imageData
                }
            case .failure(_):
                print("서버 통신 실패")
            }
        }
    }
}
