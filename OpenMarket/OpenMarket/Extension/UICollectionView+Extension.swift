//
//  UICollectionView+Extension.swift
//  OpenMarket
//
//  Created by Judy on 2022/12/02.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T ?? T.init()
    }
    
    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }
}
