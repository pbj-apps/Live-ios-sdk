//
//  Websocket.swift
//  
//
//  Created by Sacha on 11/08/2020.
//

import Foundation
import Combine
import UIKit

class Websocket: NSObject, URLSessionWebSocketDelegate {

	public var token: () -> String = { "" }
	private let logsEnabled = true
	private let url: String
	private let apiKey: String
	private var webSocketTask: URLSessionWebSocketTask?
	private var pingTimer: Timer?
	private var statusUpdatePublisher = PassthroughSubject<LiveStreamStatusUpdate, Never>()
	private var wasReceivingUpdates = false
	private var cancellables = Set<AnyCancellable>()


	init(url: String, apiKey: String) {
		self.url = url
		self.apiKey = apiKey
		super.init()

		// Cut connection proactively (if active) when application enters background.
		NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [unowned self] _ in
			if self.webSocketTask != nil {
				self.wasReceivingUpdates = true
				self.leaveEpisodeUpdates()
			}
		}.store(in: &cancellables)
		
		// Restart connection on entering foreground if connection was previously active.
		NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { [unowned self] _ in
			if self.wasReceivingUpdates {
				_ = self.joinEpisodeUpdates()
			}
		}.store(in: &cancellables)
	}

	func joinEpisodeUpdates() -> AnyPublisher<LiveStreamStatusUpdate, Never> {
		sendMessage(json: "{ \"command\": \"join-episode-updates\" }")
		return statusUpdatePublisher
			.eraseToAnyPublisher()
	}

	func leaveEpisodeUpdates() {
		sendMessage(json: "{ \"command\": \"leave-episode-updates\" }")
		closeConnection()
	}

	private func sendMessage(json: String) {
		if webSocketTask == nil {
			buildWebSocketTask()
		}
		if logsEnabled {
			print("⚡️ Websocket - send message : \(json)")
		}
		let message = URLSessionWebSocketTask.Message.string(json)
		webSocketTask?.send(message, completionHandler: { _ in })
	}

	private func sendPing() {
		let json = """
		  {
					"command": "ping"
		  }
		"""
		sendMessage(json: json)
	}

	private func closeConnection() {
		pingTimer?.invalidate()
		pingTimer = nil
		webSocketTask?.cancel(with: URLSessionWebSocketTask.CloseCode.goingAway, reason: nil)
		webSocketTask = nil
	}

	private func buildWebSocketTask() {
		let urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())
		webSocketTask = urlSession.webSocketTask(with: URL(string: "\(url)/episodes/stream?token=\(token())&org_api_key=\(apiKey)")!)
		webSocketTask?.resume()
		self.registerReceive()
		pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { [weak self] _ in
			self?.sendPing()
		})
	}

	private func registerReceive() {
		webSocketTask?.receive { [weak self] result in
			if let self = self {
				switch result {
				case .failure(let error):
					if self.logsEnabled {
						print("Error in receiving message: \(error)")
					}
				case .success(let message):
					switch message {
					case .string(let content):
						if self.logsEnabled {
							print("⚡️ Websocket - received message : \(content)")
						}

						// Test messsage.
						/*
						let testContent = """
						{
						"command":"episode-status-update",
						"episode":{
						"id":"19e19b29-3f93-4c20-ab1c-c2e27bc52127",
						"title":"The yo boi",
						"description":"Description",
						"waiting_room_description":"",
						"status":"broadcasting"
						},
						"stream_status":"idle",
						"extra":{
						"playback_cutoff":false
						}
						}
						"""
						*/

						if let data = content.data(using: .utf8) {
							let jsonDecoder = JSONDecoder()
							if let response = try? jsonDecoder.decode(JSONEpisodeStatusWebsocketResponse.self, from: data) {
								if response.command == "episode-status-update" {
									let update = LiveStreamStatusUpdate(id: response.episode.id,
																											waitingRoomDescription: response.episode.waiting_room_description,
																											status: response.extra.playback_cutoff ? .broadcasting : LiveStreamStatus.fromString(response.episode.status))
									self.statusUpdatePublisher.send(update)
								}
								print(response)
							}
						}

						self.registerReceive()
					case .data(let data):
						if self.logsEnabled {
							print("Received data: \(data)")
						}
					@unknown default:
						if self.logsEnabled {
							print("default case: \(message)")
						}
					}
				}
			}
		}
	}
}

struct JSONEpisodeStatusWebsocketResponse: Decodable {
	let command: String
	let episode: JSONWebsocketEpisode
	let extra: JSONWebsocketExtra
}

struct JSONWebsocketEpisode: Decodable {
	let id: String
	let status: String
	let waiting_room_description: String
}

struct JSONWebsocketExtra: Decodable {
	let playback_cutoff: Bool
}
