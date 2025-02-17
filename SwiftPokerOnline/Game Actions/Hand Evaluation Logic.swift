//
//  Hand Evaluation Logic.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 13/02/2025.
//

//The logic within this document is badly organised, confusing, and has various inefficiencies. This code needs to be refactored.

import Foundation

//Calls the functions that check each player left in the hand for certain made hands.
func checkHands(table: PokerTable) {
	checkFlush(table: table)
	checkPairs(table: table)
	checkStraight(table: table)
	checkStraightAHigh(table: table)
}


//This function calls the other functions necessary for hand evaluation, and after updating info on players establishes the winner of the hand.
func evaluateHands(table: PokerTable) {
	for player in table.players {
		player.bestHandName = "highCard"
	}
	
	checkHands(table: table)
	
	var playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		if player.StrFlush { player.bestHandName = "strFlush";  player.score = 10 }
		else if player.kind4 { player.bestHandName = "kind4";  player.score = 9 }
		else if player.fullHouse { player.bestHandName = "fullHouse";  player.score = 8 }
		else if player.flush { player.bestHandName = "flush";  player.score = 7 }
		else if player.straight { player.bestHandName = "straight";  player.score = 6 }
		else if player.kind3 { player.bestHandName = "kind3";  player.score = 5 }
		else if player.pair2 { player.bestHandName = "pair2";  player.score = 4 }
		else if player.pair1 { player.bestHandName = "pair1";  player.score = 3 }
		else { player.bestHandName = "highCard";  player.score = 2 }
		
		tieBreaker(table: table)
		
		for card in player.bestHand {
			if card.number == 1 { player.handStrength += 14 }
			else { player.handStrength += card.number }
		}
	}
	
	//If players have the same hand (score), use handStrength (kicker values) to determine winner. These variable names are poorly chosen and confusing.
	playersInHand.sort {
		if $0.score == $1.score {
			return $0.handStrength > $1.handStrength
		}
		return $0.score > $1.score
	}
	
	print("Player \(playersInHand[0].id) takes down the pot of \(table.pot) chips")
	playersInHand[0].chips += table.pot
	
}

//This function is used when Ace needs to be treated as a high card.
func rankValue(for card: Card) -> Int {
	return card.number == 1 ? 14 : card.number
}

//This function is used to determine which players have the best hand if 2 players have the same made hand. For some hands, this logic is baked into the check/Hand/ logic (i.e. checkStraights).
func tieBreaker(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		switch player.bestHandName {
		case "strFlush":
			checkStraight(table: table)
			checkStraightAHigh(table: table)
			
		case "kind4":
			player.bestHand = player.fourOfKindCards
			let kicker = player.holeCards
				.filter { !player.bestHand.contains($0) }
				.sorted { rankValue(for: $0) < rankValue(for: $1) }
			player.bestHand.append(contentsOf: kicker.suffix(1))
			
		case "fullHouse":
			player.bestHand = player.threeOfKindCards
			let kicker = player.pairCards
				.sorted { rankValue(for: $0) < rankValue(for: $1) }
			player.bestHand.append(contentsOf: kicker.suffix(2))
			
		case "flush":
			player.bestHand = player.flushCards
			
		case "straight":
			checkStraight(table: table)
			checkStraightAHigh(table: table)
			
		case "kind3":
			player.bestHand = player.threeOfKindCards
			let kicker = player.holeCards
				.filter { !player.bestHand.contains($0) }
				.sorted { rankValue(for: $0) < rankValue(for: $1) }
			player.bestHand.append(contentsOf: kicker.suffix(2))
			
		case "pair2":
			player.bestHand = player.pairCards
			let kicker = player.holeCards
				.filter { !player.bestHand.contains($0) }
				.sorted { rankValue(for: $0) < rankValue(for: $1) }
			player.bestHand.append(contentsOf: kicker.suffix(1))
			
			
		case "pair1":
			player.bestHand = player.pairCards
			let kicker = player.holeCards
				.filter { !player.bestHand.contains($0) }
				.sorted { rankValue(for: $0) < rankValue(for: $1) }
			player.bestHand.append(contentsOf: kicker.suffix(3))
			
			
		default:
			let kicker = player.holeCards
				.sorted { rankValue(for: $0) < rankValue(for: $1) }
			player.bestHand = kicker.suffix(5)
		}
	}
}

//Checks each player in the hand for a flush.
func checkFlush(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		var suitCount: [String: [Card]] = [:]
		
		for card in player.holeCards {
			suitCount[card.suit, default: []].append(card)
		}
		
		for (_, cards) in suitCount {
			if cards.count >= 5 {
				
				player.flush = true
			}
		}
	}
}

//Checks each players in the hand for 1 pair, 2 pairs, 3 of a kind or 4 of a kind.
func checkPairs(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		var valueCount: [Int: Int] = [:]
		
		for card in player.holeCards {
			valueCount[card.number, default: 0] += 1
		}
		
		player.fourOfKindCards = []
		player.threeOfKindCards = []
		player.pairCards = []
		
		var pairs = 0
		var kind3x2 = 0
		
		for (number, count) in valueCount {
			if count == 4 {
				player.kind4 = true
				player.fourOfKindCards = player.holeCards.filter { $0.number == number }
			}
			
			if count == 3 {
				player.kind3 = true
				kind3x2 += 1
				player.threeOfKindCards = player.holeCards.filter { $0.number == number }
			}
			
			if count == 2 {
				pairs += 1
				player.pairCards.append(contentsOf: player.holeCards.filter { $0.number == number })
			}
		}
		
		if kind3x2 == 2 {
			if player.kind4 == false {
				
				player.threeOfKindCards.sort { $0.number > $1.number }
				player.threeOfKindCards.removeSubrange(3...5)
				
			}
		}
		
		if pairs == 3 {
			player.pair2 = true
			player.pairCards.sort { $0.number > $1.number }
			player.pairCards.removeSubrange(4...5)
		}
		
		if pairs == 2 {
			player.pair2 = true
		}
		
		if pairs == 1 {
			player.pair1 = true
		}
		pairs = 0
	}
}

//This function checks if cards are consecutive for straigh evaluation.
func isConsecutive(_ cards: [Card]) -> Bool {
	for i in 1..<cards.count {
		if cards[i].number != cards[i - 1].number + 1 {
			return false
		}
	}
	return true
}

//Checks each player for a straight or straight flush.
func checkStraight(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		
		let uniqueCards = Array(Set(player.holeCards)).sorted()
		
		if uniqueCards.count > 4 {
			for i in 0..<(uniqueCards.count - 4) {
				let subArray = Array(uniqueCards[i...(i + 4)])
				
				if isConsecutive(subArray) {
					player.straight = true
					if player.bestHandName == "straight" {
						player.bestHand = uniqueCards.sorted().suffix(5)
					}
					
					// Check if all cards in the straight have the same suit
					let suits = Set(subArray.map { $0.suit })
					if suits.count == 1 {
						player.StrFlush = true
						if player.bestHandName == "strFlush" {
							player.bestHand = uniqueCards.sorted().suffix(5)
						}
					}
				}
			}
		}
	}
}

//Check each player for an ace high straight or straight flush. This function could definitely be removed and just baked into the previous function using the rankValue function.
func checkStraightAHigh(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		let aceHigh = [1, 10, 11, 12, 13]
		
		let aceHighCards = player.holeCards.filter { aceHigh.contains($0.number) }
		
		var uniqueValues: [Card] = []
		var seenNumbers: Set<Int> = []
		
		for card in aceHighCards {
			if !seenNumbers.contains(card.number) {
				uniqueValues.append(card)
				seenNumbers.insert(card.number)
			}
		}
		
		if uniqueValues.count == 5 {
			player.straight = true
			
			if player.bestHandName == "straight" {
				player.bestHand = uniqueValues
			}
			
			let suits = Set(uniqueValues.map { $0.suit })
			if suits.count == 1 {
				player.StrFlush = true
				if player.bestHandName == "strFlush" {
					player.bestHand = uniqueValues
				}
			}
		}
	}
}


