# π μ€ν λ§μΌ (OPEN MARKET) 

> νλ‘μ νΈ κΈ°κ°: 2022.10.11~2022.12.06
> μΌκ³° μμΉ΄λ°λ―Έμμ μ§νν `μ€νλ§μΌ` ν νλ‘μ νΈλ₯Ό λ¦¬ν©ν λ§ν λ²μ 

π [λ¦¬ν©ν λ§ μ  μ€νλ§μΌ μ½λ λ³΄λ¬κ°κΈ°](https://github.com/Judy-999/ios-open-market)
<br>

## πͺ§ λͺ©μ°¨
- [π€ μκ°](#-μκ°)
- [πΉοΈ κΈ°λ₯](#%EF%B8%8F-κΈ°λ₯)
- [π± μ€ννλ©΄](#μ€ννλ©΄)
- [π οΈ λ¦¬ν©ν λ§ λ΄μ©](#%EF%B8%8F-λ¦¬ν©ν λ§-λ΄μ©)
<br>

## π€ μκ°
| [Judy](https://github.com/Judy-999) |
|:---:|
|<img src="https://i.imgur.com/n304TQO.jpg" width="300" height="300" />|

<br>

## πΉοΈ κΈ°λ₯
- [x] μν λͺ©λ‘μ List, Grid ννλ‘ λ³Ό μ μμ΅λλ€.
- [x] μνμ λ±λ‘ν  μ μμ΅λλ€.
- [x] μνμ μμ ν  μ μμ΅λλ€.
- [x] μνμ μ­μ ν  μ μμ΅λλ€.
- [x] μνμ μμΈμ λ³΄λ₯Ό λ³Ό μ μμ΅λλ€.
<br>

## π±μ€ννλ©΄

| μν λͺ©λ‘ - List | μν λͺ©λ‘ - Grid | μν μμΈ μ λ³΄ |
|:---:|:---:|:---:|
![](https://i.imgur.com/zPq2MVG.jpg)| ![](https://i.imgur.com/qyA4o1p.jpg)| ![](https://i.imgur.com/oSQKrBQ.jpg) |

| μν λ±λ‘ | μν μμ  | μν μ­μ  | 
|:---:|:---:|:---:|
|![](https://i.imgur.com/x0SMglh.gif)|![](https://i.imgur.com/94LJMys.gif)| ![](https://i.imgur.com/s7073xV.gif)|

<br>

## κ΅¬μ‘°
### π² Tree
```swift
βββ Info.plist
βββ Application
β	βββ AppDelegate.swift
β	βββ SceneDelegate.swift
βββ Controller
β	βββ EditProductViewController.swift
β	βββ MainViewController.swift
β	βββ ProductInfoViewController.swift
βββ Extension
β	βββ Data+Extension.swift
β	βββ String+Extension.swift
β	βββ UICollectionView+Extension.swift
β	βββ URLSession+Extension.swift
βββ Model
β	βββ Currency.swift
β	βββ MarketNamespace.swift
β	βββ Product.swift
β	βββ ProductInfo.swift
β	βββ ProductItem.swift
β	βββ RequestProduct.swift
βββ Network
β	βββ APIRequest.swift
β	βββ Builder
β	β	βββ MultipartManager.swift
β	β	βββ RequestBuilder.swift
β	β	βββ RequestDirector.swift
β	βββ Model
β	β	βββ APINamespace.swift
β	β	βββ HTTPMethod.swift
β	β	βββ MarketRequest.swift
β	β	βββ MultipartData.swift
β	βββ URLSessionManager.swift
β	βββ URLSessionProtocol.swift
βββ Resources
β	βββ Assets.xcassets
β	β	βββ MockData.dataset
β	β		βββ Contents.json
β	β		βββ MockData.json
β	βββ Base.lproj
β		βββ LaunchScreen.storyboard
βββ Utility
β	βββ AlertManager.swift
β	βββ DataManager.swift
β	βββ ImageCacheManager.swift
β	βββ LoadingIndicator.swift
βββ View
	βββ EditProductView.swift
	βββ SessionImageView.swift
	βββ ViewCell
		βββ AddImageCollectionViewCell.swift
		βββ MarketCollectionCell.swift
		βββ MarketGridCollectionViewCell.swift
		βββ MarketListCollectionViewCell.swift
		βββ ProductImageCollectionViewCell.swift
 		βββ ProductInfoCollectionViewCell.swift
```
<br>

## π οΈ λ¦¬ν©ν λ§ λ΄μ©
### 1. λ€μμ€νμ΄μ€ λΆλ¦¬ λ° μ»¨λ²€μ ν΅μΌ
μλ¦Ό λλ UI νμ΄νμ μ¬μ©λλ λ¬Έμμ΄μ λλ μ μ κ°λ€μ Namespaceλ‘ λΆλ¦¬νμ΅λλ€. μ΅λν μ½λ μμ μ«μλ `""` ννλ‘ μ‘΄μ¬νμ§ μλλ‘ νκ³ , enumκ³Ό `static let`μ μ΄μ©ν΄ μλ―Έλ₯Ό ννν  μ μλλ‘ νμ΅λλ€.

<br>**Namespace μμ**
```swift
extension ProductInfoViewController {
    private enum Option {
        static let edit = "μμ "
        static let delete = "μ­μ "
        static let cancel = "μ·¨μ"
        static let confirm = "νμΈ"
    }
}
```

<br>λν ν΄λΉ Namespaceκ° νΉμ  λ·°μ»¨ λ΄λΆμμλ§ μ¬μ©λλ©΄ `private enum`μΌλ‘ κ΅¬νν΄ μ¬μ©μ μ ννμ΅λλ€.

μ»¨λ²€μ μ­μ μ½λκ° κΈΈμ΄μ§λ©΄ ν¨μμ λ§€κ°λ³μμ κ°νμ λ£κ³ , λ²νΌμ μ‘μ ν¨μλ `~~ButtonTapped`λ‘ ν΅μΌνλ λ± κ°λμ±κ³Ό ν΅μΌμ±μ μ κ²½μΌμ΅λλ€.
<br><br>

### 2. λ€νΈμνΉ μΆμν
κ°μ₯ λ¨Όμ  λ¦¬ν©ν λ§μ ν μμμ API λ€νΈμνΉ μ½λ μΆμνμλλ€. μ΄μ  μ½λλ `dataTask`λ₯Ό μ§μνλ `URLSessionManager`κ° **HTTP** μμ²­μ λ°λΌ  `postData`, `patchData`, `deleteData` λ± κ°κ°μ λ©μλλ₯Ό κ°μ§ ννμμ΅λλ€. λν **Request** μ­μ host URLμ κ³μ νλ μ½λ©μΌλ‘ λ£μ΄μ£Όλ λ°©μμ΄λΌ μλ‘μ΄ μμ²­μ΄ μκΈ°λ©΄ λμν  μ μμμ΅λλ€.

νμ₯μ±κ³Ό μ€λ³΅λ μ½λ λ¬Έμ λ₯Ό ν΄κ²°νκΈ° μν΄ `APIRequest`λΌλ protocolμ ν΅ν΄ Requestλ₯Ό μΆμννμ΅λλ€.
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

**URLRequest** κ΅¬μ±μ νμν μμλ₯Ό νλ‘νΌν°λ‘ κ°μ§κ² νκ³ , νλ‘ν μ½ κΈ°λ³Έ κ΅¬νμΌλ‘ **URLRequest**μ λ°ννλ μ°μ° νλ‘νΌν°λ₯Ό κ°μ§λλ‘ νμ΅λλ€. 

μ΄λ₯Ό ν΅ν΄ `APIRequest`μ μ±νν `MarketRequest` νμμ μμ±ν΄μ μ μ ν νλ‘νΌν°λ§ λ£μ΄μ£Όλ©΄ λ°λ‘ **URLRequest** μ¬μ©ν  μ μμ΅λλ€. λλΆμ΄ `URLSessionManager`μ `dataTask` λ©μλκ° `APIRequest` νμμ μ¬μ©νλλ‘ λ³κ²½νμ¬ μμ²­μ λ°λ₯Έ λ©μλλ₯Ό λ°λ‘ λ νμ μμ΄ `dataTask`λ§μΌλ‘λ λͺ¨λ  μμ²­μ μ²λ¦¬ν  μ μκ² λμμ΅λλ€.
<br><br>

### 3. Builder ν¨ν΄ μ μ©
`APIRequest`λ‘ μΆμνν κ²μ μ’μμ§λ§ λ§μ νλ‘νΌν°λ₯Ό κ°μ§κ³  μμ΄ μ¬μ©ν  λ μμ± μ½λκ° κ΅μ₯ν κΈΈμμ΅λλ€.

**μ¬μ© μμ**
```swift
let patchRequest = MarketRequest(method: .patch,
                                 baseURL: URLHost.url,
                                 path: URLPath.product + "/\(productNumber)",
                                 body: dataElement,
                                 headers: ["identifier": VendorInfo.identifier,
                                           "Content-Type": "application/json"])

sessionManager.dataTask(request: patchRequest) { result in
    // μλ΅
}
```
<br>

μ΄λ κ² μμ²­ν  λ λ§λ€ `MarketRequest`λ₯Ό μμ±νλ μ½λκ° κΈΈμ΄ κ°λμ±μ΄ λ¨μ΄μ§κ³  λ³΅μ‘ν΄ λ³΄μμ΅λλ€. ν΄λΉ λ¬Έμ λ₯Ό κ³ λ―Όνλ μ€ λ§μΉ¨ **Builder** λμμΈ ν¨ν΄μ κ³΅λΆνκ² λμλλ° μ ν©ν μν©μ΄λΌ μ μ©νμ΅λλ€.

`MarketRequest`λ₯Ό μμ±νλ `RequestBuilder` ν΄λμ€μ κ° νλ‘νΌν°λ₯Ό μ μ₯νλ λ©μλλ₯Ό κ΅¬ννμ΅λλ€. κ·Έλ¦¬κ³  `RequestBuilder`λ₯Ό ν΅ν΄ μμ£Ό μ¬μ©λλ Requestλ₯Ό μμ±νλ λ©μλλ₯Ό `RequestDirector`μ κ΅¬νν΄ κ°μ΄ μ¬μ©νμ΅λλ€.
<br>

**Builder ν¨ν΄ μ μ© ν μ¬μ© μμ**
```swift
guard let patchRequest = RequestDirector().createPatchRequest(productNumber: productNumber,
                                                              dataElement: patchProduct) else { return }

sessionManager.dataTask(request: patchRequest) { result in
    // μλ΅
}
```
<br>

νμν λ§€κ°λ³μλ§ μ λ¬ν΄μ£Όλ©΄ Directorλ₯Ό μ΄μ©ν΄ λ°λ‘ μνλ μμ²­μ κ°κ²°νκ² μμ±ν  μ μμ΅λλ€.
<br><br>

### 4. μνμ λ§μ§ μλ μ΄λ―Έμ§κ° λμ€λ λ¬Έμ  ν΄κ²° λ°©μ λ³κ²½
CollectionViewμ Cellμ΄ μ¬μ¬μ©λλ©΄μ μν μ΄λ―Έμ§ μμ²­μ΄ μμ΄κ² λ©λλ€. ν΄λΉ μμ²­μ λΉλκΈ°μ΄λ―λ‘ λ§μ§λ§μ λμ°©ν μ΄λ―Έμ§κ° ν΄λΉ μνμ μ΄λ―Έμ§κ° μλ μ μμ΅λλ€.

μ΄μ μλ μ΄ λ¬Έμ λ₯Ό μ΄λ―Έμ§λ₯Ό ν λΉνκΈ° μ μ μ΄λ―Έμ§λ₯Ό μμ²­νλ Cellκ³Ό νμ¬ Cellμ λΉκ΅νμ¬ μΌμΉλμ§ νμΈνμ¬ ν΄κ²°νμ΅λλ€.
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
		// μλ΅
        }
    }
```
<br>

μμ κ°μ λ°©μμΌλ‘ κ΅¬ννμκ³  μ λμμ νμ§λ§ μ΄λ―Έμ§λ₯Ό ν λΉνκΈ° μν΄ `UICollectionView`μ `UICollectionViewCell`μ μ§μ  μκ³  μμνλ κ²μ μ μ νμ§ μλ€κ³  μκ°νμ΅λλ€.

λ€λ₯Έ λ°©λ²μ μ°Ύμλ³΄λ μ€ κ²°κ΅­ μμ²­μ΄ μμ΄λ κ²μ΄ λ¬Έμ μ΄λ―λ‘ μ΄μ  μμ²­μ μ·¨μνλ©΄λμ§ μμκΉ μκ°νμ΅λλ€. `URLSessionDataTask`μ `cancel` λ©μλλ₯Ό νμ©νμ¬ Cellμ΄ μ¬μ¬μ©λ  λ μ¦,`prepareForReuse`κ° μ€νλ  λ μ΄μ  μμ²­μ μ·¨μνλλ‘ νμ΅λλ€. μ€ν¬λ‘€νλ©΄μ μ¬λ¬ μ΄λ―Έμ§κ° μμ²­λμ΄λ κ²°κ΅­ λͺ¨λ μ·¨μλκ³  λ§μ§λ§ μμ²­λ§ μ€νλμ΄ μ¬λ°λ₯Έ μ΄λ―Έμ§λ₯Ό λμΈ μ μμ΅λλ€.

<br>**μ΄μ  dataTaskλ₯Ό μ·¨μνλ λ©μλ**
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
μν νμ΄μ§λ₯Ό μμ²­ν  λ `νμ΄μ§ λ²νΈ`μ `μν κ°μ`λ₯Ό μΏΌλ¦¬λ‘ ν¨κ» μ λ¬ν©λλ€. λ§μ½ λ§μ§λ§ μνκΉμ§ μ€ν¬λ‘€νλ©΄ λ€μ νμ΄μ§λ₯Ό μμ²­ν΄μ κ³μ μν λͺ©λ‘μ λ³Ό μ μμ΄μΌ ν©λλ€.

`UIScrollViewDelegate`μ `scrollViewDidEndDragging(_:willDecelerate:)` λ©μλλ₯Ό μ¬μ©νμ΅λλ€. ν΄λΉ λ©μλλ μ€ν¬λ‘€ λ·°μμ λλκ·Έκ° λλλ©΄ νΈμΆλλ λ©μλλ‘ λ§μ½ λ μ΄μ μ€ν¬λ‘€ν λΆλΆμ΄ λ¨μμμ§ μμΌλ©΄ λ€μ νμ΄μ§λ₯Ό μμ²­νλλ‘ λ³κ²½νμ΅λλ€.

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

- `scrollView.contentOffset.y` : νμ¬ μ½νμΈ λ₯Ό λ³΄κ³  μλ μμΉ
- `scrollView.contentSize.height - scrollView.bounds.height` : μ€ν¬λ‘€λ·° ν¬κΈ°μμ μ½νμΈ  ν¬κΈ° λΊ λΆλΆ = μ€ν¬λ‘€ν  μ μλ μμΉ
<br>

### 6. κΈ°ν
- `MainViewController`μμ LISTμ GRIDμ λ°λ₯Έ DataSourceμ Layoutμ λ°ννλ λ©μλλ₯Ό νλλ‘ λ³ν©
- `ListCell`κ³Ό `GridCell`μ `MarketCollectionCell` νλ‘ν μ½λ‘ μΆμν λ° κΈ°λ³Έ κ΅¬ν
- ν€λ³΄λκ° νμ€νΈ λ·°λ₯Ό κ°λ¦¬μ§ μλλ‘ constraintλ₯Ό μ΄μ©ν λ°©λ²μμ `NotificationCenter`μ `UITextView`μ `UIEdgeInsets`μ λ³κ²½νλ λ°©λ²μΌλ‘ λ³κ²½
- μνμ μ΄λ―Έμ§κ° λ‘λλ  λ λ‘λ©λ·° μΆκ°
<br><br>


---

<details>
<summary> μ°Έκ³  λ§ν¬ </summary>
	
[kcharliek/MyAppStore](https://github.com/kcharliek/MyAppStore)<br> 
[λ¬΄ν μ€ν¬λ‘€ κ΅¬ννκΈ°](https://gyuios.tistory.com/139)<br>
[scrollViewDidEndDragging](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619436-scrollviewdidenddragging)<br>
[μ΄λ―Έμ§ λκΈ°ν](https://velog.io/@dev_jane/UICollectionView-%EC%85%80-%EC%9E%AC%EC%82%AC%EC%9A%A9-%EB%AC%B8%EC%A0%9C-%EB%B9%A0%EB%A5%B4%EA%B2%8C-%EC%8A%A4%ED%81%AC%EB%A1%A4%EC%8B%9C-%EC%9E%98%EB%AA%BB%EB%90%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80%EA%B0%80-%EB%82%98%ED%83%80%EB%82%98%EB%8A%94-%ED%98%84%EC%83%81)

	
</details>
