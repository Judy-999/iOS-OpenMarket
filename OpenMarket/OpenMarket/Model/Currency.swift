//
//  Currency.swift
//  OpenMarket
//
//  Created by 주디, 재재 on 2022/07/11.
//

enum Currency: String, Codable {
    case krw = "KRW"
    case usd = "USD"
}

extension Currency {
    var index: Int {
        switch self {
        case .krw:
            return 0
        case .usd:
            return 1
        }
    }
    
    static func indexToCurreny(_ index: Int) -> String? {
        switch index {
        case 0:
            return Currency.krw.rawValue
        case 1:
            return Currency.usd.rawValue
        default:
            return nil
        }
    }
}
