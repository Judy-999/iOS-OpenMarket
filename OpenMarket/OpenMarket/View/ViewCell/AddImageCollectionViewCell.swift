//
//  AddProductViewCell.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/27.
//

import UIKit

final class AddImageCollectionViewCell: UICollectionViewCell {
    private let productImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConstraints()
    }
    
    // MARK: - Methods
    private func setupConstraints() {
        self.contentView.addSubview(productImage)

        NSLayoutConstraint.activate([
            productImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            productImage.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            productImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            productImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
        ])
    }

    func configure(with image: UIImage) {
        productImage.image = image
    }
}
