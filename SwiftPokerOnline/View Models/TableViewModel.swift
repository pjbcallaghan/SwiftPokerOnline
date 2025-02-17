//
//  Server.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 29/01/2025.
//

import Foundation
import FirebaseFirestore

let db = Firestore.firestore()

class TableViewModel: ObservableObject {
	@Published var table: PokerTable?
	@Published var hasLoaded = false
	private var db = Firestore.firestore()
	private var listener: ListenerRegistration?
	
	init(tableID: String) {
		fetchTableData(tableID: tableID)
	}
	
	func fetchTableData(tableID: String) {
		listener = db.collection("pokerTables").document(tableID)
			.addSnapshotListener { documentSnapshot, error in
				if let error = error {
					print("Error fetching table data: \(error)")
					return
				}
				
				guard let document = documentSnapshot else {
					print("Document not found")
					return
				}
				
				DispatchQueue.main.async {
					self.table = try? document.data(as: PokerTable.self)
					self.hasLoaded = true
				}
			}
	}
	
	func updatePokerTable() {
		guard let pokerTable = table else { return }
		do {
			try db.collection("pokerTables").document(pokerTable.id ?? "Fake room").setData(from: pokerTable)
		} catch {
			print("Error updating poker table: \(error)")
		}
	}
	
	func addPlayer(newPlayer: Player) {
		guard let pokerTable = table else { return }
		pokerTable.players.append(newPlayer)
		updatePokerTable()
	}
	
	func removePlayer(user: String) {
		guard let pokerTable = table else { return }
		
		pokerTable.players.removeAll { $0.user == user }
		
		let playersData = pokerTable.players.map { try? Firestore.Encoder().encode($0) }
		
		db.collection("pokerTables").document(pokerTable.id ?? "Fake room")
			.updateData(["players": playersData]) { error in
				if let error = error {
					print("Error removing player: \(error)")
				} else {
					print("Player removed successfully!")
					
					DispatchQueue.main.async {
						self.table?.players.removeAll { $0.user == user }
					}
				}
			}
	}
	
	deinit {
		listener?.remove()
	}
	
	var players: [Player] {
		table?.players ?? []
	}
}
