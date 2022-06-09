//
//  LivePlayerInfoHeaderFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import Foundation
import SwiftUI
import Live

public protocol LivePlayerInfoHeaderFactory {
	associatedtype LivePlayerInfoHeaderView: View
	func makeLivePlayerInfoHeaderView(episode: Episode,
																		regularFont: String,
																		close: @escaping () -> Void) -> LivePlayerInfoHeaderView
}

