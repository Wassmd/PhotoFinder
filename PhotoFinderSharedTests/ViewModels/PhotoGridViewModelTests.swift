import XCTest
import Nimble
import RxSwift
import RxTest
@testable import PhotoFinderShared

class PhotoGridViewModelTests: XCTestCase {
    
    private var viewModel: PhotoGridViewModel!
    private var photoDownloadService: PhotoDownloadServiceMock!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        photoDownloadService = PhotoDownloadServiceMock()
        viewModel = PhotoGridViewModel(with: scheduler, downloadService: photoDownloadService)
    }
    
    func testDownloadPhotos() {
        let photo1 = Photo(id: "1", owner: "someOwner1", secret: "someSecret1", server: "someServer1", farm: 11, title: "someTitle1")
        let photo2 = Photo(id: "2", owner: "someOwner2", secret: "someSecret2", server: "someServer2", farm: 22, title: "someTitle2")
        let photo3 = Photo(id: "3", owner: "someOwner3", secret: "someSecret3", server: "someServer3", farm: 33, title: "someTitle33")
        let photosArray = [photo1, photo2, photo3]
        let photos = Photos(page: 1, pages: 100, perpage: 10, total: "100", photo: photosArray)
        let photoDetail = PhotosDetail(photos: photos, stat: "ok")
        
        let observable = viewModel.photosRelayObserver
        let observer = scheduler.createObserver([Photo].self)
        let disposeBag = DisposeBag()
        
        scheduler.scheduleAt(0) {
            disposeBag.insert([
                observable.subscribe(observer)
                ])
        }
        photoDownloadService.returnValue.photosSingle = Single.just(photoDetail)
        
        scheduler.start()
        viewModel.downloadPhotos()
        scheduler.advanceTo(30)
        
        let photosRecieved = observer.events.first?.value.element
        expect(photosRecieved?.count).to(equal(3))
    }
}
