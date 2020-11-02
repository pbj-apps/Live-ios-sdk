//
//  FirestoreClient.swift
//  Live
//
//  Created by Sacha on 26/07/2020.
//  Copyright © 2020 PBJApps. All rights reserved.
//

import FirebaseFirestore
import CodableFirebase


var firedb: Firestore = {
	let settings = FirestoreSettings()
	settings.isPersistenceEnabled = true
	let firedb: Firestore = Firestore.firestore()
	firedb.settings = settings
	return firedb
}()

class FirestoreClient {
	static let shared = FirestoreClient()
}

extension FirestoreClient {
	internal func getDb() -> Firestore {
		return firedb
	}
}

extension Encodable {
	func toFirebaseData() throws -> [String: Any] {
		do {
			return try FirestoreEncoder().encode(self)
		} catch {
			throw error
		}
	}
}

extension DocumentSnapshot {
	func toObject<T: Decodable>() throws -> T {
		let type = data() ?? [:]
		do {
			let assignedObject = try FirestoreDecoder().decode(T.self, from: type)
			return assignedObject
		} catch {
			throw error
		}
	}
}


extension DocumentReference: DocumentReferenceType {}
