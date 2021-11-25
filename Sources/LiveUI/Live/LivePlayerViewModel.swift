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

	@Published public var liveStream: LiveStream
	let productRepository: ProductRepository?
	let liveStreamRepository: LiveStreamRepository
	@Published public var products: [Product]
	@Published public var currentlyFeaturedProducts: [Product]
	@Published var showProducts = false
	//    @Published var showCurrentlyFeaturedProducts = false
	private var cancellables = Set<AnyCancellable>()

	public init(liveStream: LiveStream,
							liveStreamRepository: LiveStreamRepository,
							productRepository: ProductRepository?) {
		self.liveStream = liveStream
		self.products = []
		self.currentlyFeaturedProducts = []
		self.liveStreamRepository = liveStreamRepository
		self.productRepository = productRepository
		self.fetchProducts()
		self.fetchCurrentlyFeaturedProducts()
		
		registerForRealTimeLiveStreamUpdates()
		refresh()
	}
	
	private func refresh() {
		liveStreamRepository.fetch(liveStream: liveStream).then { [weak self] fetchedLivestream in
			self?.liveStream = fetchedLivestream
			if self?.liveStream.status == .broadcasting {
				self?.fetchBroadcastURL()
			}
		}
		.sink()
		.store(in: &cancellables)
	}
	
	private func fetchBroadcastURL() {
		liveStreamRepository.fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] fetchedLiveStream in
				self.liveStream = fetchedLiveStream
			}
			.sink()
			.store(in: &cancellables)
	}

	public func fetchProducts() {
		productRepository?.fetchProducts(for: liveStream)
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
		productRepository?.fetchCurrentlyFeaturedProducts(for: liveStream)
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
		productRepository?.registerForProductHighlights(for: liveStream)
			.receive(on: RunLoop.main)
			.sink {  [unowned self] productUpdate in
				print(productUpdate)
				withAnimation {
					self.currentlyFeaturedProducts = productUpdate.products
				}
				//            self.showCurrentlyFeaturedProducts  = true
			}.store(in: &cancellables)
	}

	public func unRegisterForProductHighlights() {
		productRepository?.unRegisterProductHighlights(for: liveStream)
	}
	
	private func registerForRealTimeLiveStreamUpdates() {
		liveStreamRepository.registerForRealTimeLiveStreamUpdates()
			.ignoreError()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if update.id == liveStream.id {
					liveStream.waitingRomDescription = update.waitingRoomDescription
					liveStream.status = update.status
					if update.status == .broadcasting {
						self.fetchBroadcastURL()
					}
				}
			}.store(in: &cancellables)
	}
	
	deinit {
		liveStreamRepository.leaveRealTimeLiveStreamUpdates()
	}
}
