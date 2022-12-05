//
//  MarketProtocol.swift
//  OpenMarket
//
//  Created by Judy on 2022/12/02.
//

import UIKit

protocol MarketCollectionCell: UICollectionViewCell {
    func configure(with item: ProductItem)
}
