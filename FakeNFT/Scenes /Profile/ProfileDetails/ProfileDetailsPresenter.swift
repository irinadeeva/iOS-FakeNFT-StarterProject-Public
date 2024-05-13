//
//  ProfileViewPresenter.swift
//  FakeNFT
//
//  Created by Irina Deeva on 03/05/24.
//

import Foundation

// MARK: - Protocol

protocol ProfilePresenter {
    func viewDidLoad()
    func fetchTitleForCell(with indexPath: IndexPath) -> String
}

// MARK: - State

enum ProfileDetailState {
    case initial, loading, failed(Error), data(Profile)
}

final class ProfileDetailsPresenterImpl: ProfilePresenter {

    // MARK: - Properties

    weak var view: ProfileDetailsView?
    private let input: ProfileInput
    private let service: ProfileService
    private var state = ProfileDetailState.initial {
        didSet {
            stateDidChanged()
        }
    }
    private var userNFTsIds: [UUID]?

    // MARK: - Init

    init(input: ProfileInput, service: ProfileService) {
        self.input = input
        self.service = service
    }

    // MARK: - Functions

    func viewDidLoad() {
        state = .loading
    }

    func fetchTitleForCell(with indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return "Мои NFT (\(userNFTsIds?.count ?? 0))"
        case 1:
            // TODO: add counted
            return "Избранные NFT (0)"
        case 2:
            return "О разработчике"
        default:
            return ""
        }
    }

    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
            loadProfile()
        case .data(let profile):
            userNFTsIds = profile.nftIds
            view?.fetchProfileDetails(profile)
            view?.hideLoading()
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }

    private func loadProfile() {
        service.loadProfile(id: input.id) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.state = .data(profile)
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = NSLocalizedString("Error.network", comment: "")
        default:
            message = NSLocalizedString("Error.unknown", comment: "")
        }

        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.state = .loading
       }
    }
}
