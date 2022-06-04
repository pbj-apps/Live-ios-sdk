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

@MainActor
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
		
		Task {
			try await self.fetchProducts()
		}
		Task {
			try await self.fetchCurrentlyFeaturedProducts()
		}
		registerForEpisodeUpdates()
		Task {
			try await refresh()
		}
	}
	
	private func refresh() async throws {
		episode = try await liveRepository.fetch(episode: episode)
		if episode.status == .broadcasting {
			try await fetchBroadcastURL()
		}
	}
	
	private func fetchBroadcastURL() async throws {
		episode = try await liveRepository.fetchBroadcastUrl(for: episode)
	}

	public func fetchProducts() async throws {
		let fetchedProducts = try await productRepository?.fetchProducts(for: episode)
		withAnimation {
			self.products = fetchedProducts ?? []
		}
	}

	public func fetchCurrentlyFeaturedProducts() async throws {
		let fetchedProducts = try await productRepository?.fetchCurrentlyFeaturedProducts(for: episode)
		withAnimation {
			self.currentlyFeaturedProducts = fetchedProducts ?? []
		}
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
						Task {
							try await self.fetchBroadcastURL()
						}
					}
				}
			}.store(in: &cancellables)
	}
	
	deinit {
		liveRepository.leaveEpisodeUpdates()
	}
}
