//
//  DetailImageCollectionViewCell.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/02.
//

import UIKit

final class ProductImageCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let imageView: SessionImageView = {
        let image = SessionImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let imageNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let entireStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Methods
    func configure(with imageURL: String, number: String) {
        imageNumberLabel.text = number
        imageView.configureImage(with: imageURL)
    }
    
    private func setupView() {
        addSubView()
        setupConstraints()
    }
    
    private func addSubView() {
        entireStackView.addArrangedSubview(imageView)
        entireStackView.addArrangedSubview(imageNumberLabel)
        
        contentView.addSubview(entireStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            entireStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            entireStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            entireStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            entireStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 9/10)
        ])
    }
}
