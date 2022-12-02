//
//  MarketProtocol.swift
//  OpenMarket
//
//  Created by Judy on 2022/12/02.
//

import UIKit

protocol MarketCollectionCell: UICollectionViewCell {
    func configureCell(with item: ProductItem,
                       _ cell: UICollectionViewCell,
                       _ indexPath: IndexPath,
                       _ collectionView: UICollectionView)
}
