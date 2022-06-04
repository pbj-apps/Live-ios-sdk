//
//  APIError.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

private extension Error {
	func toApiError() -> APIError {
		return APIError.emptyResponse
	}
}

public enum APIError: Error {
	case emptyResponse
	case mappingError(error: DecodingError)
	case genericError(description: String)
	case remoteError(Error)
}

extension APIError {
	var localizedDescription: String {
		switch self {
		case .emptyResponse:
			return "Something went wrong"
		case let .genericError(description):
			return description
		case let .mappingError(error):
			return error.localizedDescription
		case let .remoteError(underlying):
			return underlying.localizedDescription
		}
	}

	var code: Int? {
		if case .remoteError(let underlying) = self {
			return (underlying as NSError).code
		}
		return nil
	}
}
