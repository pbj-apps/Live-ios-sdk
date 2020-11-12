//
//  LiveStore.swift
//  
//
//  Created by Sacha on 04/10/2020.
//

import Foundation
import Combine
import UIKit

public class LiveStore:  ObservableObject {

	public var firebaseFCMToken: String?
	public let liveStreamRepository: LiveStreamRepository
	var chatRepository: ChatRepository?
	private var cancellables = Set<AnyCancellable>()
	private let feedBackGenerator = UINotificationFeedbackGenerator()
	@Published private var remindedLiveStreamIds = [String]()
	public var isChatEnabled: Bool { return chatRepository != nil }

	public init(liveStreamRepository: LiveStreamRepository, chatRepository: ChatRepository?) {
		self.liveStreamRepository = liveStreamRepository
		self.chatRepository = chatRepository
	}

	@Published public var isLoadingLiveStreams = false
	public var noLiveStreams: Bool { isLoadingLiveStreams == false && liveStreams.isEmpty }
	@Published public var currentLiveStream: LiveStream?
	@Published public var liveStreams: [LiveStream] = [] {
		didSet {
			currentLiveStream = liveStreams.first
		}
	}
	@Published public var chatMessages: [ChatMessage] = []

	@Published public var liveStreamWatchedIndex: Int?
	public var liveStreamWatched: LiveStream? {
		if let index = liveStreamWatchedIndex {
			return liveStreams[index]
		}
		return nil
	}

	/// This is for previews only purposes
	public var forceEmptyLiveStreams = false

	public func getLiveStreams() -> AnyPublisher<[LiveStream], Error> {
		liveStreamRepository.getLiveStreams()
	}

	public func getSchedule() -> AnyPublisher<[LiveStream], Error> {
		liveStreamRepository.getLiveStreamsSchedule()
	}

	public func fetchBroadcastUrl(for liveStream: LiveStream) -> AnyPublisher<String, Error> {
		liveStreamRepository.fetchBroadcastUrl(for: liveStream)
	}

public func fetchLiveStreams() {
			if liveStreams.isEmpty {
				isLoadingLiveStreams = true
			}

			if forceEmptyLiveStreams {
				isLoadingLiveStreams = false
				return
			}
		getSchedule()
			.ignoreError()
//			.removeDuplicates()
			.map { liveStreams in liveStreams.filter { $0.status != .finished } }// Remove finished streams
//			.map { liveStreams in liveStreams.filter { Date() <= $0.endDate } }// Remove finished streams
			.map { [weak self] in
				$0.forEach { if $0.status == .broadcasting { self?.zfetchBroacastUrl(for: $0) } }
				self?.isLoadingLiveStreams = false
				return $0
			}
			.assign(to: \.liveStreams, on: self)
			.store(in: &cancellables)
	}

	public func listenToLiveStreamUpdates() {
		liveStreamRepository.registerForRealTimeLiveStreamUpdates()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if let liveStreamToUpdate = self.liveStreams.first(where: { $0.id == update.id }) {
					var updatedLiveStream = liveStreamToUpdate
					updatedLiveStream.waitingRomDescription = update.waitingRoomDescription
					updatedLiveStream.status = update.status
					self.update(liveStream: updatedLiveStream)

					// Fetch broadcastURL
					if updatedLiveStream.status == .broadcasting {
						self.zfetchBroacastUrl(for: updatedLiveStream)
					}
				}
			}.store(in: &cancellables)
	}

	public func stopListeningToLiveStreamUpdates() {
		liveStreamRepository.leaveRealTimeLiveStreamUpdates()
	}

	func zfetchBroacastUrl(for liveStream: LiveStream) {
		fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] broadcastURL in
				var updatedLiveStream = liveStream
				updatedLiveStream.broadcastUrl = broadcastURL
				self.update(liveStream: updatedLiveStream)
			}
			.sink()
			.store(in: &cancellables)
	}

	private func update(liveStream: LiveStream) {
		guard let indexToReplace = liveStreams.firstIndex(where: { $0.id == liveStream.id }) else {
			return
		}
		liveStreams[indexToReplace] = liveStream
	}

	public func fetchMessages(for liveStream: LiveStream) {
		fetchChatMessages(for: liveStream)
			.ignoreError()
			.removeDuplicates()
			.assign(to: \.chatMessages, on: self)
			.store(in: &cancellables)
	}

	// MARK: Notifications

	public func toggleReminderFor(liveStream: LiveStream) {
		requestPushNoticationsPermission()
		feedBackGenerator.prepare()
		if let fcmToken = firebaseFCMToken {
			// Optimistic toggle locally.
			if let index = self.remindedLiveStreamIds.firstIndex(of: liveStream.showId) {
				remindedLiveStreamIds.remove(at: index)
				liveStreamRepository.unSubscribe(from: liveStream, with: fcmToken)
					.finally { [unowned self] in
						self.syncSubscriptions()
					}
					.sink()
					.store(in: &self.cancellables)
			} else {
				remindedLiveStreamIds.append(liveStream.showId)
				// Add subscription
				liveStreamRepository.subscribe(to: liveStream, with: fcmToken)
					.finally {  [unowned self] in
						self.syncSubscriptions()
					}
					.sink()
					.store(in: &self.cancellables)
			}
			feedBackGenerator.notificationOccurred(.success)
		}
	}

	private func requestPushNoticationsPermission() {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if granted {
				DispatchQueue.main.async {
					if !UIApplication.shared.isRegisteredForRemoteNotifications {
						UIApplication.shared.registerForRemoteNotifications()
					}
				}
			} else if let error = error {
				print(error)
			}
		}
	}

	public func isReminderSet(for liveStream: LiveStream) -> Bool {
		return remindedLiveStreamIds.contains(liveStream.showId)
	}

	public func syncSubscriptions(completion: (() -> Void)? = nil) {
		liveStreamRepository.subscriptions().sink(receiveCompletion: { _ in }, receiveValue: {  [unowned self] ids in
			self.remindedLiveStreamIds = ids
			completion?()
		})
		.store(in: &cancellables)
	}

	// MARK: - Chat

	public func fetchChatMessages(for liveStream: LiveStream) -> AnyPublisher<[ChatMessage], Error> {
		if let chatRepository = chatRepository {
			return chatRepository.getChatMessages(for: liveStream)
		} else {
			return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
		}
	}

	public func send(message: String, for liveStream: LiveStream) -> AnyPublisher<Void, Error> {
		if let chatRepository = chatRepository {
			return chatRepository.postChatMessage(message: message, on: liveStream)
		} else {
			return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
		}
	}
}
