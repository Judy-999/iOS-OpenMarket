    typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductItem>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ProductItem>
        URLSessionManager().dataTask(request: getRequest) { result in
