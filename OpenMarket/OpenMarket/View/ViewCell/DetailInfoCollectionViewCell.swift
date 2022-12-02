//
//  DetailInfoCollectionViewCell.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/08/02.
//

import UIKit

final class DetailInfoCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemRed
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 4
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
    func configureCell(with item: ProductInfoItem) {
        nameLabel.text = item.name
        stockLabel.text = "남은수량 : \(item.stock)"
        descriptionView.text = item.description
        
        if item.price == item.bargainPrice {
            self.priceLabel.text = item.price
            self.priceLabel.textColor = .systemGray
        } else {
            let price = item.price + "\n" + item.bargainPrice
            self.priceLabel.attributedText = price.addDiscountAttribute(with: item.price.count, item.bargainPrice.count)
        }
    }
    
    private func setupView() {
        addSubView()
        setupConstraints()
    }
    
    private func addSubView() {
        horizontalStackView.addArrangedSubview(nameLabel)
        horizontalStackView.addArrangedSubview(stockLabel)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(priceLabel)
        verticalStackView.addArrangedSubview(descriptionView)
        
        contentView.addSubview(verticalStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}
