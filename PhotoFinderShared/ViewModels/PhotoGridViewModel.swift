import UIKit
import RxSwift
import RxCocoa

open class PhotoGridViewModel {
    
    
    // MARK: - InnerTypes
    
    private enum Contansts {
        static let initialPageNumber = "1"
    }
    
    // MARK: - Properties
    // MARK: Immutables
    
    private let disposeBag = DisposeBag()
    private var photosRelay = BehaviorRelay<[Photo]>(value: [])
    private let errorRelay = PublishRelay<String>()
    
    private let downloadService: PhotoDownloadServiceProtocol
    
    public var photosRelayObserver: Observable<[Photo]> {
        return photosRelay.skip(1).asObservable()
    }
    public var errorRelayObserver: Observable<String> {
        return errorRelay.asObservable()
    }
    
    // MARK: Mutable
    
    var scheduler: SchedulerType
    private var isDownloadInProgress = false
    private var pageNumber: String = Contansts.initialPageNumber
    var searchText: String = "Sunflower"
    
    // MARK: - Initializer
    
    public init(with scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background), downloadService: PhotoDownloadServiceProtocol = PhotoDownloadService()) {
        self.scheduler = scheduler
        self.downloadService = downloadService
    }
    
    
    // MARK: Action
    
    public func downloadPhotos() {
        guard !isDownloadInProgress else { return }
        isDownloadInProgress = true
        
        downloadService.downloadPhotos(with: searchText, pageNumber: pageNumber)
            .subscribeOn(scheduler)
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { _ in self.isDownloadInProgress = false }, onError: { _ in self.isDownloadInProgress = false })
            .subscribe(onSuccess: { [weak self] in
                self?.handleSuccess(with: $0)
                }, onError: { [weak self] in
                    self?.handleError(error: $0)
            })
            .disposed(by: disposeBag)
    }
    
    func resetAndDownload(for newSeachText: String) {
        pageNumber = Contansts.initialPageNumber
        photosRelay.accept([])
        searchText = newSeachText
        
        downloadPhotos()
    }
    
    // MARK: - Datasource
    
    public func numberOfPhotos(at section: Int) -> Int {
        return photosRelay.value.count
    }
    
    public func photoObject(at indexPath: IndexPath) -> Photo? {
        return photosRelay.value[safe: indexPath.item]
    }
    
    public var allPhoto: [Photo] {
        return photosRelay.value
    }
    
    
    // MARK: - Helpers
    
    private func handleSuccess(with photoDetail: PhotosDetail) {
        photosRelay.accept(self.photosRelay.value + photoDetail.photos.photo)
        increasePageNumer(previousPageNumber: photoDetail.photos.page)
    }
    
    private func increasePageNumer(previousPageNumber: Int) {
        pageNumber = "\(previousPageNumber + 1)"
    }
    
    private func handleError(error: Error) {
        errorRelay.accept(error.localizedDescription)
    }
    
    open func initialItemSize(for viewWidth: CGFloat) -> CGSize {
        fatalError("Must be implemented by subclass")
    }
    
    func shouldStartNextPageDownload(indexPaths: [IndexPath]) -> Bool {
        return indexPaths.contains { $0.row >= photosRelay.value.count - 1 }
    }
}
