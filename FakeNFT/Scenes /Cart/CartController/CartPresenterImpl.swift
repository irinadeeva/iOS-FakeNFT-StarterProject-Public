//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by Ольга Чушева on 06.05.2024.
//

import Foundation

protocol CartPresenter {
    var cartContent: [Nft] { get set}
    var viewController: CartViewControllerProtocol? { get set}

    func totalPrice() -> String
    func count() -> Int
    func loadOrder()
    func setOrder()
    func getNft(with index: Int) -> Nft
    func sortCart(filter: CartFilter.FilterBy)
    func getOrderService() -> OrderServiceProtocol
    func getPayService() -> PayServiceProtocol
}

final class CartPresenterImpl: CartPresenter {

    weak var viewController: CartViewControllerProtocol?
    private var orderService: OrderServiceProtocol
    private var nftService: NftByIdServiceProtocol
    private var payService: PayServiceProtocol
    private var userDefaults = UserDefaults.standard
    private let filterKey = "filter"

    private var currentFilter: CartFilter.FilterBy {
        get {
            let id = userDefaults.integer(forKey: filterKey)
            return CartFilter.FilterBy(rawValue: id) ?? .id
        }
        set {
            userDefaults.setValue(newValue.rawValue, forKey: filterKey)
        }
    }

    var cartContent: [Nft] = []

    init(orderService: OrderServiceProtocol, nftService: NftByIdServiceProtocol, payService: PayServiceProtocol) {
        self.orderService = orderService
        self.nftService = nftService
        self.payService = payService
        self.orderService.cartPresenter = self
    }

    func totalPrice() -> String {
        var price: Double = 0
        for nft in cartContent {
            price += nft.price
        }
        let moneyText = String(NSString(format: "%.2f", price))
        return moneyText
    }

    func count() -> Int {
        let count: Int = cartContent.count
        return count
    }

    func loadOrder() {
        viewController?.startLoadIndicator()
        orderService.loadOrder { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let order):

                    if !order.nfts.isEmpty {

                        self.loadNft(with: order.nfts)

                    } else {
                        self.viewController?.stopLoadIndicator()
                        self.viewController?.updateCart()
                    }
                case .failure:
                    self.viewController?.stopLoadIndicator()
                    // TODO: add error alert
                }
            }
        }
    }

    private func loadNft(with ids: [String]) {
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let nft):

                    let contains = self.cartContent.contains { model in
                        return model.id == nft.id
                    }

                    if !contains {
                        self.cartContent.append(nft)
                    }

                case .failure:
                    self.viewController?.stopLoadIndicator()
                    // TODO: add error alert
                }

                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.sortCart(filter: self.currentFilter)
            self.viewController?.updateCart()
            self.viewController?.stopLoadIndicator()
        }
    }

    func setOrder() {
        let order = self.orderService.nftsStorage
        self.cartContent = order

        viewController?.updateCartTable()
    }

    func getNft(with index: Int) -> Nft {
        cartContent[index]
    }

    func sortCart(filter: CartFilter.FilterBy) {
        currentFilter = filter
        cartContent = cartContent.sorted(by: CartFilter.filter[currentFilter] ?? CartFilter.filterById)
    }

    func getOrderService() -> any OrderServiceProtocol {
        orderService
    }

    func getPayService() -> any PayServiceProtocol {
        payService
    }

    @objc private func didCartSorted(_ notification: Notification) {
        let orderUnsorted = orderService.nftsStorage.compactMap { Nft(nft: $0) }
        cartContent = orderUnsorted.sorted(by: CartFilter.filter[currentFilter] ?? CartFilter.filterById )
    }

}
