//
//  LivePlayerPreviewInfoFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import Foundation
import SwiftUI

public protocol LivePlayerPreviewInfoFactory {
	associatedtype LivePlayerPreviewInfoView: View
	func makeLivePlayerPreviewInfoView(message: String,
																		 startDate: Date,
																		 isAllCaps: Bool,
																		 regularFont: String,
																		 lightForegroundColor: Color) -> LivePlayerPreviewInfoView
}
