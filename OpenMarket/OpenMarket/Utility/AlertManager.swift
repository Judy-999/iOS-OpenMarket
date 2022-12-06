//
//  AlertManager.swift
//  OpenMarket
//
//  Created by Judy on 2022/12/05.
//

import UIKit

struct AlertManager {
    private let viewController: UIViewController
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(_ alertType: AlertType) {
        let alert = UIAlertController(title: alertType.title,
                                      message: alertType.message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인",
                                      style: .default))
        viewController.present(alert, animated: true)
    }
}

enum AlertType {
    case networkFailure
    case decodingFailure
    case unavailableProduct
    case exceededNumberOfImages
    case patchFailure
    case nonExistentImage
    case postFailure
    case deleteFailure
    case confirmPassword
    case incorrectPassword
    
    var title: String {
        switch self {
        case .networkFailure:
            return "서버 통신 실패"
        case .decodingFailure:
            return "데이터 변환 실패"
        case .unavailableProduct:
            return "상품 등록 불가"
        case .exceededNumberOfImages:
            return "사진 등록 불가"
        case .patchFailure:
            return "상품 수정 실패"
        case .nonExistentImage:
            return "상품 등록 불가"
        case .postFailure:
            return "상품 등록 실패"
        case .deleteFailure:
            return "상품 삭제 실패"
        case .confirmPassword:
            return "비밀번호 확인"
        case .incorrectPassword:
            return "상품 삭제 실패"
        }
    }
    
    var message: String {
        switch self {
        case .networkFailure:
            return "상품 데이터를 받아오지 못했습니다."
        case .decodingFailure:
            return "상품 데이터를 읽을 수 없습니다."
        case .unavailableProduct:
            return "필수 항목을 입력해주십시오.\n(이름, 가격, 설명)"
        case .exceededNumberOfImages:
            return "사진은 최대 \(ProductImageInfo.numberOfMax)장까지 가능합니다."
        case .patchFailure:
            return "상품의 정보를 수정할 수 없습니다."
        case .nonExistentImage:
            return "최소 1장 이상의 사진을 넣어주세요."
        case .postFailure:
            return "상품을 등록을 실패했습니다."
        case .deleteFailure:
            return "상품을 삭제하지 못했습니다."
        case .confirmPassword:
            return "비밀번호를 입력해주세요."
        case .incorrectPassword:
            return "비밀번호가 일치하지 않습니다."
        }
    }
}

