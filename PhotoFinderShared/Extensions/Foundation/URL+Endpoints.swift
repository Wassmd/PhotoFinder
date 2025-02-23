import Foundation

extension URL {
    
    enum Constants {
        static let apiKey = "api_key"
        static let apiKeyValue = "43753f3c6af7101d0078a6d016154662"
        static let methodkey = "method"
        static let methodValue = "flickr.photos.search"
        static let searchText = "leopard"
        static let contentTypeKey = "content_type"
        static let formatKey = "format"
        static let json = "json"
        static let nojsoncallbackKey = "nojsoncallback"
        static let nojsoncallbackValue = "1"
        static let safeSearchKey = "safe_search"
        static let safeSearchValue = "1"
        static let perPageKey = "per_page"
        static let perPageValue = "100"
        static let pageKey = "page"
        static let searchTextKey = "text"
    }
    
    typealias JSON = [String: Any]
    static let baseEndpoint: URL  = URL(string: "https://api.flickr.com/services/rest/")!
 
    static var prepareFixedMetaDataForURLComponent: JSON {
        return [Constants.methodkey: Constants.methodValue,
                Constants.apiKey: Constants.apiKeyValue,
                Constants.contentTypeKey: Constants.json,
                Constants.formatKey: Constants.json,
                Constants.safeSearchKey: Constants.safeSearchValue,
                Constants.nojsoncallbackKey: Constants.nojsoncallbackValue,
                Constants.perPageKey: Constants.perPageValue]
    }
}
