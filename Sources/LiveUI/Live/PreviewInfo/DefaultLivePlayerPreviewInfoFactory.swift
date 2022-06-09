//
//  DefaultLivePlayerPreviewInfoFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import Foundation
import SwiftUI

public class DefaultLivePlayerPreviewInfoFactory: LivePlayerPreviewInfoFactory {
	
	
	public func makeLivePlayerPreviewInfoView(message: String,
																						startDate: Date,
																						isAllCaps: Bool,
																						regularFont: String,
																						lightForegroundColor: Color) -> some View {
		LivePlayerPreviewInfo(message: message,
													startDate: startDate,
													isAllCaps: isAllCaps,
													regularFont: regularFont,
													lightForegroundColor: lightForegroundColor)
	}

	public init() {}
}
