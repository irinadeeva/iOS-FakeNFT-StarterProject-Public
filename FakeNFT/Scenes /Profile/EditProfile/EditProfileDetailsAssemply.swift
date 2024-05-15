//
//  EditDetailAssemply.swift
//  FakeNFT
//
//  Created by Irina Deeva on 09/05/24.
//

import UIKit

public final class EditProfileDetailsAssembly {

    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    public func build() -> UIViewController {
        let presenter = EditProfileDetailsPresenterImpl(
            service: servicesAssembler.profileService
        )

        let viewController = EditProfileDetailsViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }
}
