//
//  PlayerViewModel.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 12/02/2025.
//

import FirebaseFirestore
import Foundation

class PlayerViewModel: ObservableObject {
	@Published var player: Player?
	private var db = Firestore.firestore()
	private var listener: ListenerRegistration?
	
	init(playerID: String) {
		fetchPlayerData(playerID: playerID)
	}
	
	func fetchPlayerData(playerID: String) {
		listener = db.collection("Users").document(playerID)
			.addSnapshotListener { documentSnapshot, error in
				if let error = error {
					print("Error fetching player data: \(error)")
					return
				}
				
				guard let document = documentSnapshot else {
					print("Document not found")
					return
				}
				
				DispatchQueue.main.async {
					self.player = try? document.data(as: Player.self)
				}
			}
	}
	
	deinit {
		listener?.remove()
	}
}
