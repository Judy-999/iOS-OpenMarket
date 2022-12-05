//
//  Data+Extension.swift
//  OpenMarket
//
//  Created by Judy on 2022/11/23.
//

import Foundation

extension Data {
    var fileExtension: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xFF:
            ext = "jpg"
        case 0x89:
            ext = "png"
        case 0xd8:
            ext = "jpeg"
        default:
            ext = "unknown"
        }
        return ext
    }
    
    mutating func appendData(_ stringData: String) {
        if let data = stringData.data(using: .utf8) {
            self.append(data)
        }
    }
}
