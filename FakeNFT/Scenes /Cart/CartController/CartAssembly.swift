//
//  CartAssembly.swift
//  FakeNFT
//
//  Created by Irina Deeva on 05/06/24.
//

import UIKit

final class CartAssembly {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembly = servicesAssembler
    }

    func build() -> UIViewController {
        let cartPresenter = CartPresenter(
            orderService: servicesAssembly.orderService,
            nftByIdService: servicesAssembly.nftByIdService,
            payService: servicesAssembly.payService
        )

        let viewController = CartViewController(presenter: cartPresenter)

        cartPresenter.viewController = viewController

        return viewController
    }
}
