//
//  Table & Player Models.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 10/02/2025.
//

import Foundation
import FirebaseFirestore

class PokerTable: Codable, Identifiable {
	@DocumentID var id: String?
	@ServerTimestamp var createdAt: Timestamp?
	var roomName: String = ""
	var players: [Player] = []
	var gameState: String = "waiting"
	var deck = createDeck()
	var communityCards: [Card] = []
	var raiseAmount: Int = 0
	var roundPot = 0
	var pot = 0
	var showdownText = ""
	var showdownTextVisible = false
	var allPlayersCalled: Bool {
		let playersInHand = players.filter { $0.inHand }
		return playersInHand.allSatisfy { $0.called }
	}
}

class Player: Codable {
	//Account Variables
	var user: String = ""
	var pass: String = ""
	var chips: Int = 2000 
	
	//In Game Variables
	var button: Int = 10
	var folded = false
	var called = false
	var amountToCall = 0
	var inHand = false
	var playerToAct = false
	var id: Int = 0

	//Hand Evaluation Variables
	var StrFlush = false
	var kind4 = false
	var fullHouse: Bool {if kind3 && pair1 || kind3 && pair2 {return true} else {return false}}
	var flush = false
	var straight = false
	var kind3 = false
	var pair2 = false
	var pair1 = false
	var holeCards: [Card] = []
	var bestHand: [Card] = []
	var bestHandName: String = "highCard"
	var fourOfKindCards: [Card] = []
	var threeOfKindCards: [Card] = []
	var pairCards: [Card] = []
	var flushCards: [Card] = []
	var score: Int = 0
	var handStrength: Int = 0

	var actionText = ""
	var updateAction = false
}
