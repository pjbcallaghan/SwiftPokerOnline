//
//  ServerBrowserViewModel.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 10/02/2025.
//

import Foundation
import FirebaseFirestore

class ServerBrowserViewModel: ObservableObject {
	@Published var pokerTables: [PokerTable] = []
	private var db = Firestore.firestore()
	private var listener: ListenerRegistration?
	
	init() {
		fetchPokerTables()
	}
	
	func fetchPokerTables() {
		listener = db.collection("pokerTables")
			.order(by: "createdAt", descending: true)
			.addSnapshotListener { snapshot, error in
				if let error = error {
					print("Error fetching poker tables: \(error)")
					return
				}
				
				guard let documents = snapshot?.documents else {
					print("No poker tables found")
					return
				}
				
				self.pokerTables = documents.compactMap { doc in
					try? doc.data(as: PokerTable.self)
				}
			}
	}
	
	deinit {
		listener?.remove()  
	}
}

func createPokerTable(name: String) {
	let db = Firestore.firestore()
	let pokerTable = PokerTable()
	pokerTable.roomName = name
	
	do {
		let ref = try db.collection("pokerTables").addDocument(from: pokerTable)
		print("PokerTable created with ID: \(ref.documentID)")
	} catch {
		print("Error saving PokerTable: \(error)")
	}
}
