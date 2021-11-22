//
//  ApiEnvironment+Domain.swift
//  
//
//  Created by Sacha DSO on 16/11/2021.
//

import Foundation

extension ApiEnvironment {
	var domain: String {
		switch self {
		case .dev:
			return "api.pbj-live.dev.pbj.engineering"
		case .demo:
			return "api.pbj-live.demo.pbj.engineering"
		case .prod:
			return "api.pbj.live"
		}
	}
}

