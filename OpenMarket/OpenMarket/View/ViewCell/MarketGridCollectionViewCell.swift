//
//  MarketGridCollectionViewCell.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/19.
//

import UIKit

final class MarketGridCollectionViewCell: UICollectionViewCell, MarketCollectionCell {
    // MARK: - Properties
    let imageView: SessionImageView = {
        let imageView = SessionImageView()
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemGray
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
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
    private func setupView() {
        addSubView()
        setupConstraints()
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.systemGray3.cgColor
    }
    
    private func addSubView() {
        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(priceLabel)
        verticalStackView.addArrangedSubview(bargainPriceLabel)
        verticalStackView.addArrangedSubview(stockLabel)
        
        contentView.addSubview(verticalStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 8),
            verticalStackView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -8),
            verticalStackView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -8),
            verticalStackView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            imageView.heightAnchor
                .constraint(equalTo: contentView.heightAnchor, multiplier: 0.58)
        ])
    }

    override func prepareForReuse(){
        super.prepareForReuse()
        imageView.cancelImageLoding()
        stockLabel.textColor = .systemGray
        bargainPriceLabel.isHidden = true
    }
}
