# 🛍 오픈 마켓 (OPEN MARKET) 

> 프로젝트 기간: 2022.10.11~2022.12.06
> 야곰 아카데미에서 진행한 `오픈마켓` 팀 프로젝트를 리팩토링한 버전

👉 [리팩토링 전 오픈마켓 코드 보러가기](https://github.com/Judy-999/ios-open-market)
<br>

## 🪧 목차
- [👤 소개](#-소개)
- [🕹️ 기능](#%EF%B8%8F-기능)
- [📱 실행화면](#실행화면)
- [🛠️ 리팩토링 내용](#%EF%B8%8F-리팩토링-내용)
<br>

## 👤 소개
| [Judy](https://github.com/Judy-999) |
|:---:|
|<img src="https://i.imgur.com/n304TQO.jpg" width="300" height="300" />|

<br>

## 🕹️ 기능
- [x] 상품 목록을 List, Grid 형태로 볼 수 있습니다.
- [x] 상품을 등록할 수 있습니다.
- [x] 상품을 수정할 수 있습니다.
- [x] 상품을 삭제할 수 있습니다.
- [x] 상품의 상세정보를 볼 수 있습니다.
<br>

## 📱실행화면

| 상품 목록 - List | 상품 목록 - Grid | 상품 상세 정보 |
|:---:|:---:|:---:|
![](https://i.imgur.com/zPq2MVG.jpg)| ![](https://i.imgur.com/qyA4o1p.jpg)| ![](https://i.imgur.com/oSQKrBQ.jpg) |

| 상품 등록 | 상품 수정 | 상품 삭제 | 
|:---:|:---:|:---:|
|![](https://i.imgur.com/x0SMglh.gif)|![](https://i.imgur.com/94LJMys.gif)| ![](https://i.imgur.com/s7073xV.gif)|

<br>

## 구조
### 🌲 Tree
```swift
├── Info.plist
├── Application
│	├── AppDelegate.swift
│	└── SceneDelegate.swift
├── Controller
│	├── EditProductViewController.swift
│	├── MainViewController.swift
│	└── ProductInfoViewController.swift
├── Extension
│	├── Data+Extension.swift
│	├── String+Extension.swift
│	├── UICollectionView+Extension.swift
│	└── URLSession+Extension.swift
├── Model
│	├── Currency.swift
│	├── MarketNamespace.swift
│	├── Product.swift
│	├── ProductInfo.swift
│	├── ProductItem.swift
│	└── RequestProduct.swift
├── Network
│	├── APIRequest.swift
│	├── Builder
│	│	├── MultipartManager.swift
│	│	├── RequestBuilder.swift
│	│	└── RequestDirector.swift
│	├── Model
│	│	├── APINamespace.swift
│	│	├── HTTPMethod.swift
│	│	├── MarketRequest.swift
│	│	└── MultipartData.swift
│	├── URLSessionManager.swift
│	└── URLSessionProtocol.swift
├── Resources
│	├── Assets.xcassets
│	│	└── MockData.dataset
│	│		├── Contents.json
│	│		└── MockData.json
│	└── Base.lproj
│		└── LaunchScreen.storyboard
├── Utility
│	├── AlertManager.swift
│	├── DataManager.swift
│	├── ImageCacheManager.swift
│	└── LoadingIndicator.swift
└── View
	├── EditProductView.swift
	├── SessionImageView.swift
	└── ViewCell
		├── AddImageCollectionViewCell.swift
		├── MarketCollectionCell.swift
		├── MarketGridCollectionViewCell.swift
		├── MarketListCollectionViewCell.swift
		├── ProductImageCollectionViewCell.swift
 		└── ProductInfoCollectionViewCell.swift
```
<br>

## 🛠️ 리팩토링 내용
### 1. 네임스페이스 분리 및 컨벤션 통일
알림 또는 UI 타이틀에 사용되는 문자열을 또는 정수 값들을 Namespace로 분리했습니다. 최대한 코드 상에 숫자나 `""` 형태로 존재하지 않도록 하고, enum과 `static let`을 이용해 의미를 표현할 수 있도록 했습니다.

<br>**Namespace 예시**
```swift
extension ProductInfoViewController {
    private enum Option {
        static let edit = "수정"
        static let delete = "삭제"
        static let cancel = "취소"
        static let confirm = "확인"
    }
}
```

<br>또한 해당 Namespace가 특정 뷰컨 내부에서만 사용되면 `private enum`으로 구현해 사용을 제한했습니다.

컨벤션 역시 코드가 길어지면 함수의 매개변수에 개행을 넣고, 버튼의 액션 함수는 `~~ButtonTapped`로 통일하는 등 가독성과 통일성에 신경썼습니다.
<br><br>

### 2. 네트워킹 추상화
가장 먼저 리팩토링을 한 작업은 API 네트워킹 코드 추상화입니다. 이전 코드는 `dataTask`를 지원하는 `URLSessionManager`가 **HTTP** 요청에 따라  `postData`, `patchData`, `deleteData` 등 각각의 메서드를 가진 형태였습니다. 또한 **Request** 역시 host URL을 계속 하드 코딩으로 넣어주는 방식이라 새로운 요청이 생기면 대응할 수 없었습니다.

확장성과 중복된 코드 문제를 해결하기 위해 `APIRequest`라는 protocol을 통해 Request를 추상화했습니다.
<br>

```swift
protocol APIRequest {
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var query: [String: Any]? { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
}
```
<br>

**URLRequest** 구성에 필요한 요소를 프로퍼티로 가지게 하고, 프로토콜 기본 구현으로 **URLRequest**을 반환하는 연산 프로퍼티를 가지도록 했습니다. 

이를 통해 `APIRequest`을 채택한 `MarketRequest` 타입을 생성해서 적절한 프로퍼티만 넣어주면 바로 **URLRequest** 사용할 수 있습니다. 더불어 `URLSessionManager`의 `dataTask` 메서드가 `APIRequest` 타입을 사용하도록 변경하여 요청에 따른 메서드를 따로 둘 필요 없이 `dataTask`만으로도 모든 요청을 처리할 수 있게 되었습니다.
<br><br>

### 3. Builder 패턴 적용
`APIRequest`로 추상화한 것은 좋았지만 많은 프로퍼티를 가지고 있어 사용할 때 생성 코드가 굉장히 길었습니다.

**사용 예시**
```swift
let patchRequest = MarketRequest(method: .patch,
                                 baseURL: URLHost.url,
                                 path: URLPath.product + "/\(productNumber)",
                                 body: dataElement,
                                 headers: ["identifier": VendorInfo.identifier,
                                           "Content-Type": "application/json"])

sessionManager.dataTask(request: patchRequest) { result in
    // 생략
}
```
<br>

이렇게 요청할 때 마다 `MarketRequest`를 생성하는 코드가 길어 가독성이 떨어지고 복잡해 보였습니다. 해당 문제를 고민하던 중 마침 **Builder** 디자인 패턴을 공부하게 되었는데 적합한 상황이라 적용했습니다.

`MarketRequest`를 생성하는 `RequestBuilder` 클래스에 각 프로퍼티를 저장하는 메서드를 구현했습니다. 그리고 `RequestBuilder`를 통해 자주 사용되는 Request를 생성하는 메서드를 `RequestDirector`에 구현해 같이 사용했습니다.
<br>

**Builder 패턴 적용 후 사용 예시**
```swift
guard let patchRequest = RequestDirector().createPatchRequest(productNumber: productNumber,
                                                              dataElement: patchProduct) else { return }

sessionManager.dataTask(request: patchRequest) { result in
    // 생략
}
```
<br>

필요한 매개변수만 전달해주면 Director를 이용해 바로 원하는 요청을 간결하게 생성할 수 있습니다.
<br><br>

### 4. 상품에 맞지 않는 이미지가 나오는 문제 해결 방식 변경
CollectionView의 Cell이 재사용되면서 상품 이미지 요청이 쌓이게 됩니다. 해당 요청은 비동기이므로 마지막에 도착한 이미지가 해당 상품의 이미지가 아닐 수 있습니다.

이전에는 이 문제를 이미지를 할당하기 전에 이미지를 요청했던 Cell과 현재 Cell을 비교하여 일치는지 확인하여 해결했습니다.
<br>

```swift
func configureImage(url: String, _ cell: UICollectionViewCell, _ indexPath: IndexPath, _ collectionView: UICollectionView) {
        sessionManager.receiveData(baseURL: url) { result in
            switch result {
            case .success(let data):
                guard let imageData = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    guard indexPath == collectionView.indexPath(for: cell) else { return }
                    self.image = imageData
                }
		// 생략
        }
    }
```
<br>

위와 같은 방식으로 구현하였고 잘 동작은 했지만 이미지를 할당하기 위해 `UICollectionView`와 `UICollectionViewCell`을 직접 알고 작업하는 것은 적절하지 않다고 생각했습니다.

다른 방법을 찾아보던 중 결국 요청이 쌓이는 것이 문제이므로 이전 요청을 취소하면되지 않을까 생각했습니다. `URLSessionDataTask`의 `cancel` 메서드를 활용하여 Cell이 재사용될 때 즉,`prepareForReuse`가 실행될 때 이전 요청을 취소하도록 했습니다. 스크롤하면서 여러 이미지가 요청되어도 결국 모두 취소되고 마지막 요청만 실행되어 올바른 이미지를 띄울 수 있습니다.

<br>**이전 dataTask를 취소하는 메서드**
```swift
class SessionImageView: UIImageView {
    var imageDataTask: URLSessionDataTask?
    
    func cancelImageLoding() {
        self.image = UIImage()
        imageDataTask?.cancel()
        imageDataTask = nil
    }
}
```
<br><br>

### 5. Pagenation
상품 페이지를 요청할 때 `페이지 번호`와 `상품 개수`를 쿼리로 함께 전달합니다. 만약 마지막 상품까지 스크롤하면 다음 페이지를 요청해서 계속 상품 목록을 볼 수 있어야 합니다.

`UIScrollViewDelegate`의 `scrollViewDidEndDragging(_:willDecelerate:)` 메서드를 사용했습니다. 해당 메서드는 스크롤 뷰에서 드래그가 끝나면 호출되는 메서드로 만약 더 이상 스크롤한 부분이 남아있지 않으면 다음 페이지를 요청하도록 변경했습니다.

```swift
func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let presentScrollOffset = scrollView.contentOffset.y
    let scrollSpace = scrollView.contentSize.height - scrollView.bounds.height
    
    if presentScrollOffset > scrollSpace {
        pageOffset += 1
        receivePageData(pageOffset)
    }
}
```

- `scrollView.contentOffset.y` : 현재 콘텐츠를 보고 있는 위치
- `scrollView.contentSize.height - scrollView.bounds.height` : 스크롤뷰 크기에서 콘텐츠 크기 뺀 부분 = 스크롤할 수 있는 위치
<br>

### 6. 기타
- `MainViewController`에서 LIST와 GRID에 따른 DataSource와 Layout을 반환하는 메서드를 하나로 병합
- `ListCell`과 `GridCell`을 `MarketCollectionCell` 프로토콜로 추상화 및 기본 구현
- 키보드가 텍스트 뷰를 가리지 않도록 constraint를 이용한 방법에서 `NotificationCenter`와 `UITextView`의 `UIEdgeInsets`을 변경하는 방법으로 변경
- 상품의 이미지가 로드될 때 로딩뷰 추가
<br><br>


---

<details>
<summary> 참고 링크 </summary>
	
[kcharliek/MyAppStore](https://github.com/kcharliek/MyAppStore)<br> 
[무한 스크롤 구현하기](https://gyuios.tistory.com/139)<br>
[scrollViewDidEndDragging](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619436-scrollviewdidenddragging)<br>
[이미지 동기화](https://velog.io/@dev_jane/UICollectionView-%EC%85%80-%EC%9E%AC%EC%82%AC%EC%9A%A9-%EB%AC%B8%EC%A0%9C-%EB%B9%A0%EB%A5%B4%EA%B2%8C-%EC%8A%A4%ED%81%AC%EB%A1%A4%EC%8B%9C-%EC%9E%98%EB%AA%BB%EB%90%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80%EA%B0%80-%EB%82%98%ED%83%80%EB%82%98%EB%8A%94-%ED%98%84%EC%83%81)

	
</details>
