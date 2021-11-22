//
//  LiveApiView.swift
//  SachasPotatoes
//
//  Created by Sacha on 15/10/2021.
//

import Foundation
import SwiftUI
import LiveUI
import Live
import Combine


extension ApiEnvironment: Identifiable {
	public var id: Int {
		hashValue
	}
	
	public var wording: String {
		switch self {
		case .dev:
			return "dev"
		case .demo:
			return "demo"
		case .prod:
			return "prod"
		}
	}
}

struct LiveApiView: View {
	
	@StateObject var viewModel = LiveApiViewModel()
	
	var body: some View {
		UITableView.appearance().backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.09019607843, blue: 0.3019607843, alpha: 1)
		return NavigationView {
			List {
				Section(header: Text("Api")
									.foregroundColor(.white)) {
					TextField("Api Key", text: $viewModel.apiKey)
					Picker(selection: $viewModel.environment, label: Text("Environment")) {
						ForEach([ApiEnvironment.dev, ApiEnvironment.demo, ApiEnvironment.prod], id: \.self) { t in
							Text(t.wording)
						}
					}.pickerStyle(SegmentedPickerStyle())
					Button(action: viewModel.initialize) {
						Text("Initialize")
							.disabled(
								viewModel.apiKey.isEmpty)
					}
				}
				
				Section(header: Text("Vod")
									.foregroundColor(.white)) {
					
					
					Button(action: {
						viewModel.fetchVodCategories()
					}) {
						Text("Fetch All Categories")
					}
					
					HStack {
						Button(action: {
							viewModel.fetch(category: VodCategory(id: viewModel.vodCategoryId))
						}) {
								Text("Fetch Category")
						}
						.disabled(viewModel.vodCategoryId.isEmpty)
						
						TextField("Category Id", text: $viewModel.vodCategoryId)
					}
					
					
					Button(action: {
						viewModel.fetchVodVideos()
					}) {
						Text("Fetch All Videos")
					}
					
					HStack {
						Button(action: {
							viewModel.fetch(video: VodVideo(id: viewModel.vodVideoId))
						}) {
								Text("Fetch Video")
						}
						.disabled(viewModel.vodVideoId.isEmpty)
						
						TextField("Video Id", text: $viewModel.vodVideoId)
					}
					
					Button(action: {
						viewModel.fetchVodPlaylists()
					}) {
						Text("Fetch All Playlists")
					}
					
					HStack {
						Button(action: {
							viewModel.fetch(playlist: VodPlaylist(id: viewModel.vodPlaylistId))
						}) {
								Text("Fetch Playlist")
						}
						.disabled(viewModel.vodPlaylistId.isEmpty)
						
						TextField("Playlist Id", text: $viewModel.vodPlaylistId)
					}
					
					
					HStack {
						Button(action: {
							viewModel.searchVodVideos(query: viewModel.searchTerm)
						}) {
								Text("Search Videos")
						}
						.disabled(viewModel.searchTerm.isEmpty)
						TextField("Query", text: $viewModel.searchTerm)
					}
					
					HStack {
						Button(action: {
							viewModel.searchVod(query: viewModel.searchTerm)
						}) {
								Text("Search Videos & Playlists")
						}
						.disabled(viewModel.searchTerm.isEmpty)
						TextField("Query", text: $viewModel.searchTerm)
					}
					
					
				}.disabled(!viewModel.isInitialized)
				
				Section(header: Text("Live")
									.foregroundColor(.white)) {
					
					Button(action: {
						viewModel.fetchEpisodes()
					}) {
						Text("Fetch All Episodes")
					}
					
					HStack {
						Button(action: {
							viewModel.fetch(episode: LiveStream(id: viewModel.liveEpisodeId))
						}) {
								Text("Fetch Episode")
						}
						.disabled(viewModel.liveEpisodeId.isEmpty)
						
						TextField("Episode Id", text: $viewModel.liveEpisodeId)
					}
					
				}
				.disabled(!viewModel.isInitialized)
				
				Section(header: Text("UI")
									.foregroundColor(.white)) {
					
					Button(action: {
						viewModel.showsLivePlayer = true
						viewModel.command = """
						LiveVodPlayer(url: url, close: { })
						"""
					}) {
						Text("Show Live Player")
					}
					
					Button(action: {
						viewModel.showsVodPlayer = true
						viewModel.command = """
						LiveVodPlayer(url: url, close: { })
						"""
					}) {
						Text("Show VOD Player")
					}
				}
				Section(header: Text("Command")
									.foregroundColor(.white)) {
					TextEditor(text: $viewModel.command)
						.font(Font.system(size: 12, design: .monospaced))
						.frame(height: 150)
				}
				Section(header: Text("Response")
									.foregroundColor(.white)) {
					TextEditor(text: $viewModel.response)
						.font(Font.system(size: 12, design: .monospaced))
						.frame(height: 150)
				}
			}
			.fullScreenCover(isPresented: $viewModel.showsLivePlayer, onDismiss: {}) {

				GeometryReader { proxy in
					LivePlayer(liveStream: viewModel.liveStream!,
										 close: { viewModel.showsLivePlayer = false },
										 proxy: proxy)
				}
			}
			.fullScreenCover(isPresented: $viewModel.showsVodPlayer, onDismiss: {}) {
				let url = viewModel.vodVideo?.videoURL ?? URL(string:"https://www.w3schools.com/html/mov_bbb.mp4")
				VodPlayer(url: url!,
											close: { viewModel.showsVodPlayer = false })
					.accentColor(.pink)
			}
		}
		.navigationBarTitle("Live SDK", displayMode: .large)
		.accentColor(.pink)
	}
}

struct LiveApiView_Preview: PreviewProvider {
	
	static var previews: some View {
		LiveApiView()
	}
}

