//
//  String+Extension.swift
//  OpenMarket
//
//  Created by Judy on 2022/11/23.
//

import UIKit.NSAttributedString

extension String {
    var addDiscountAttribute: NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        
        attributeString.addAttribute(.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, self.count))

        return attributeString
    }
}
