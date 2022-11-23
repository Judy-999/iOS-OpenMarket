//
//  String+Extension.swift
//  OpenMarket
//
//  Created by Judy on 2022/11/23.
//

import UIKit.NSAttributedString

extension String {
    func addDiscountAttribute(with priceCount: Int, _ bargainPriceCount: Int) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        
        attributeString.addAttribute(.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, priceCount))
        
        attributeString.addAttribute(.foregroundColor,
                                     value: UIColor.systemGray,
                                     range: NSMakeRange(priceCount + 1, bargainPriceCount))
        
        return attributeString
    }
}
