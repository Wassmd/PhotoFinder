import UIKit
import PhotoFinderShared

private enum PhotoGridSteps: CoordinateTo {
    case showDetail(indexPath: IndexPath, photos: [Photo])
    case showAlert(String)
}

class PhotoGridCoordinator: Coordinatable {
    
    
    // MARK: - Properties
    // MARK: Immutable
    
    let uniqueId: UUID
    private var window: UIWindow?
    private let navigationController: UINavigationController
    
    
    // MARK: - Mutable
    
    var deallocatable: CoordinatorDeallocatable?
    var childCoordinators = [UUID: Coordinatable]()
    
    private lazy var photoGridPhoneViewModel = PhotoGridPhoneViewModel()
    private(set) lazy var photoGridViewController: PhotoGridPhoneViewController = {
        let controller = PhotoGridPhoneViewController(
            viewModel: photoGridPhoneViewModel,
            coordinatorDelegate: self)
        
        return controller
    }()
    
    
    // MARK: - Initializers
    
    init(uniqueId: UUID,
         deallocatable: CoordinatorDeallocatable? = nil,
         window: UIWindow?,
         navigationController: UINavigationController = UINavigationController()) {
        self.uniqueId = uniqueId
        self.deallocatable = deallocatable
        self.navigationController = navigationController
        self.window = window
    }
    
    
    // MARK: Protocol Conformance
    // MARK: Coordinatable
    
    func coordinate(to step: CoordinateTo) {
        guard let step = step as? PhotoGridSteps else {
            return
        }
        switch step {
        case .showDetail(let indexPath, let photos):
            showPhotoDetail(at: indexPath, photos: photos)
        case .showAlert(let message):
            showErrorOrInformativeAlert(with: message)
        }
    }
    
    func start() {
        guard let window = window else { fatalError("window is not set") }
        
        navigationController.setViewControllers([photoGridViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
    }
    
    
    // MARK: - Transitions
    
    private func showPhotoDetail(at indexPath: IndexPath, photos: [Photo]) {
        let viewModel = PhotoDetailViewModel(with: indexPath, photos: photos)
        let controller = PhotoDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showErrorOrInformativeAlert(with message: String) {
        guard photoGridViewController.presentedViewController == nil else { return }
        
        UIAlertController.showErrorAlert(message: message, presentedBy: photoGridViewController)
    }
}

extension PhotoGridCoordinator: PhotoGridViewControllerDelegate {
    func showErrorAlert(with message: String) {
        coordinate(to: PhotoGridSteps.showAlert(message))
    }
    
    func showDetail(at indexPath: IndexPath, photos: [Photo]) {
        coordinate(to: PhotoGridSteps.showDetail(indexPath: indexPath, photos: photos))
    }
}
