//
//  LivePlayerViewModel.swift
//  
//
//  Created by Sacha DSO on 19/11/2021.
//

import Foundation
import SwiftUI
import Live
import Combine

public class LivePlayerViewModel: ObservableObject {

	@Published public var episode: Episode
	let productRepository: ProductRepository?
	let liveRepository: LiveRepository
	@Published public var products: [Product]
	@Published public var currentlyFeaturedProducts: [Product]
	@Published var showProducts = false
	//    @Published var showCurrentlyFeaturedProducts = false
	private var cancellables = Set<AnyCancellable>()

	public init(episode: Episode,
							liveRepository: LiveRepository,
							productRepository: ProductRepository?) {
		self.episode = episode
		self.products = []
		self.currentlyFeaturedProducts = []
		self.liveRepository = liveRepository
		self.productRepository = productRepository
		self.fetchProducts()
		self.fetchCurrentlyFeaturedProducts()
		
		registerForEpisodeUpdates()
		refresh()
	}
	
	private func refresh() {
		liveRepository.fetch(episode: episode).then { [weak self] fetchedEpisode in
			self?.episode = fetchedEpisode
			if self?.episode.status == .broadcasting {
				self?.fetchBroadcastURL()
			}
		}
		.sink()
		.store(in: &cancellables)
	}
	
	private func fetchBroadcastURL() {
		liveRepository.fetchBroadcastUrl(for: episode)
			.receive(on: RunLoop.main)
			.then { [unowned self] fetchedEpisode in
				self.episode = fetchedEpisode
			}
			.sink()
			.store(in: &cancellables)
	}

	public func fetchProducts() {
		productRepository?.fetchProducts(for: episode)
			.then { [unowned self] fetchedProducts in
				withAnimation {
					self.products = fetchedProducts
					//					self.showProducts  = true
				}
			}
			.sink()
			.store(in: &cancellables)
	}

	public func fetchCurrentlyFeaturedProducts() {
		productRepository?.fetchCurrentlyFeaturedProducts(for: episode)
			.then { [unowned self] fetchedProducts in
				withAnimation {
					self.currentlyFeaturedProducts = fetchedProducts
					//                    self.showProducts  = true
				}
			}
			.sink()
			.store(in: &cancellables)
	}

	public func registerForProductHighlights() {
		productRepository?.registerForProductHighlights(for: episode)
			.receive(on: RunLoop.main)
			.sink {  [unowned self] productUpdate in
				withAnimation {
					self.currentlyFeaturedProducts = productUpdate.products
				}
				//            self.showCurrentlyFeaturedProducts  = true
			}.store(in: &cancellables)
	}

	public func unRegisterForProductHighlights() {
		productRepository?.unRegisterProductHighlights(for: episode)
	}
	
	private func registerForEpisodeUpdates() {
		liveRepository.registerForEpisodeUpdates()
			.ignoreError()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if update.id == episode.id {
					withAnimation {
						episode.waitingRomDescription = update.waitingRoomDescription
						episode.status = update.status
					}
					if update.status == .broadcasting {
						self.fetchBroadcastURL()
					}
				}
			}.store(in: &cancellables)
	}
	
	deinit {
		liveRepository.leaveEpisodeUpdates()
	}
}
