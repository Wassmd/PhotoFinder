import Foundation
import PhotoFinderShared
import RxSwift
import RxCocoa

class PhotoDownloadServiceMock: PhotoDownloadServiceProtocol {

        
    // MARK: Inner Types
    
    let calledCount = CalledCount()
    var returnValue = ReturnValue()
    
    struct CalledCount {
        
    }
    
    struct ReturnValue {
        var photosSingle: Single<PhotosDetail> = Observable.empty().asSingle()
    }
    
    func downloadPhotos(with searchText: String, pageNumber: String) -> Single<PhotosDetail> {
        return returnValue.photosSingle
    }
}
