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

extension UIColor {
	public static var pbjPink = #colorLiteral(red: 0.9098039216, green: 0.2196078431, blue: 0.4274509804, alpha: 1)
}


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
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.pbjPink]
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
					
					Button(action: {
						viewModel.fetchCurrentEpisode()
					}) {
						Text("Fetch Current Episode")
					}
					
					
					HStack {
						Button(action: {
							viewModel.fetch(episode: Episode(id: viewModel.liveEpisodeId))
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
						LivePlayer(episode: episode, close: { })
						"""
					}) {
						Text("Show Live Player")
					}
					.disabled(viewModel.liveEpisodeId.isEmpty)
					
					Button(action: {
						viewModel.showsVodPlayer = true
						viewModel.command = """
						VodPlayer(url: url, close: { })
						"""
					}) {
						Text("Show VOD Player")
					}
				}
				.disabled(!viewModel.isInitialized)
				
				Section(header: Text("Command")
									.foregroundColor(.white)) {
					TextEditor(text: $viewModel.command)
						.font(Font.system(size: 12, design: .monospaced))
						.frame(height: 80)
				}
				Section(header: Text("Response")
									.foregroundColor(.white)) {
					TextEditor(text: $viewModel.response)
						.font(Font.system(size: 12, design: .monospaced))
						.frame(height: 150)
				}
			}
			.fullScreenCover(isPresented: $viewModel.showsLivePlayer, onDismiss: {}) {
				LivePlayer(episode: Episode(id: viewModel.liveEpisodeId),
									 close: { viewModel.showsLivePlayer = false })
			}
			.fullScreenCover(isPresented: $viewModel.showsVodPlayer, onDismiss: {}) {
				let url = viewModel.vodVideo?.videoURL ?? URL(string:"https://www.w3schools.com/html/mov_bbb.mp4")
				VodPlayer(url: url!,
											close: { viewModel.showsVodPlayer = false })
					.accentColor(Color(UIColor.pbjPink))
			}
			.navigationBarTitle("Live SDK", displayMode: .large)
		}
		.accentColor(Color(UIColor.pbjPink))
	}
}

struct LiveApiView_Preview: PreviewProvider {
	
	static var previews: some View {
		LiveApiView()
	}
}

