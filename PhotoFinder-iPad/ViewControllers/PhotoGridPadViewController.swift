import UIKit
import PhotoFinderShared

@objcMembers
class PhotoGridPadViewController: PhotoGridViewController<PhotoGridCell>, UICollectionViewDragDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dragDelegate = self
    }
    
    // MARK: - Protocol Conformance
    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print("inside itemsForBeginning view")
        return []
    }
}
