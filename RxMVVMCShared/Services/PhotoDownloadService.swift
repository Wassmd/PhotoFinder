import Foundation
import RxSwift
import EndPointLoader

public protocol PhotoDownloadServiceProtocol {
    func downloadPhotos(with searchText: String, pageNumber: String) -> Single<PhotosDetail>
}

public final class PhotoDownloadService: PhotoDownloadServiceProtocol {
    
    
    private enum Constants {
        static let timeoutInterval: Double = 5.0
        static let statusOk = "ok"
    }
    
    enum PhotoDownloadServiceError: Error {
        case statusFail(cause: Error?)
    }
    
    
    private let loader: Loader
    private let jsonDecoder: JSONDecoder
    
    public init(loader: Loader = Loader(),
                jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.loader = loader
        self.jsonDecoder = jsonDecoder
    }
    
    public func downloadPhotos(with searchText: String, pageNumber: String) -> Single<PhotosDetail> {
        let queryParameters = prepareQueryWithChangingParamters(with: searchText, pageNumber: pageNumber)
        
        return Single.create { [weak self] observer in
            guard let self = self else { return  Disposables.create() }
            
            self.loader.get(URL.baseEndpoint, ignoreCache: true, json: queryParameters, timeoutInterval: Constants.timeoutInterval) { result in
                switch result {
                case .success(let data):
                    do {
                        let photoDetail = try self.jsonDecoder.decode(PhotosDetail.self, from: data)
                        log.debug("status: \(photoDetail.stat)")
                        photoDetail.stat == Constants.statusOk ?
                            observer(.success(photoDetail)) :
                            observer(.error(PhotoDownloadServiceError.statusFail(cause: nil)))
                        
                    } catch {
                        log.debug("error while creating models:\(error)")
                        observer(.error(error))
                    }
                case .failure(let error):
                    log.debug(error)
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    private func prepareQueryWithChangingParamters(with searchText: String, pageNumber: String) -> JSON {
        var urlQuery = URL.prepareFixedMetaDataForURLComponent
        urlQuery[URL.Constants.searchTextKey] = searchText
        urlQuery[URL.Constants.pageKey] = pageNumber
        
        return urlQuery
    }
}
