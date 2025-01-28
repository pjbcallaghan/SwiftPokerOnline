//
//  Hand Evaluation Logic.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 13/02/2025.
//

import Foundation

func evaluateHands(table: PokerTable) {
	for player in table.players {
		player.bestHandName = "highCard"
	}
	
	checkHands(table: table)
	
	var playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		if player.StrFlush { player.bestHandName = "strFlush";  player.score = 10_000 }
		else if player.kind4 { player.bestHandName = "kind4";  player.score = 9_000 }
		else if player.fullHouse { player.bestHandName = "fullHouse";  player.score = 8_000 }
		else if player.flush { player.bestHandName = "flush";  player.score = 7_000 }
		else if player.straight { player.bestHandName = "straight";  player.score = 6_000 }
		else if player.kind3 { player.bestHandName = "kind3";  player.score = 5_000 }
		else if player.pair2 { player.bestHandName = "pair2";  player.score = 4_000 }
		else if player.pair1 { player.bestHandName = "pair1";  player.score = 3_000 }
		else { player.bestHandName = "highCard";  player.score = 2_000 }
		
		tieBreaker2(table: table)
		
		for card in player.bestHand {
			if card.number == 1 { player.handStrength += 14 }
			else { player.handStrength += card.number }
		}
	}
	
	playersInHand.sort {
		if $0.score == $1.score {
			return $0.handStrength > $1.handStrength // Compare handStrength if scores are equal
		}
		return $0.score > $1.score // Compare scores otherwise
	}
	
	print("Player \(playersInHand[0].id) takes down the pot of \(table.pot) chips")
	playersInHand[0].chips += table.pot
	
}

func tieBreaker2(table: PokerTable) {
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

func rankValue(for card: Card) -> Int {
	return card.number == 1 ? 14 : card.number // Treat Ace (rank 1) as 14
}

func checkFlush(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		var suitCount: [String: [Card]] = [:] // Map suit to an array of cards
		
		// Group cards by suit
		for card in player.holeCards {
			suitCount[card.suit, default: []].append(card)
		}
		
		// Check each suit for a flush
		for (_, cards) in suitCount {
			if cards.count >= 5 {
				
				player.flush = true
			}
		}
	}
}

func checkPairs(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		var valueCount: [Int: Int] = [:]
		
		// Count the occurrences of each card number
		for card in player.holeCards {
			valueCount[card.number, default: 0] += 1
		}
		
		// Clear the player's combination arrays
		player.fourOfKindCards = []
		player.threeOfKindCards = []
		player.pairCards = []
		
		var pairs = 0
		var kind3x2 = 0
		
		// Iterate over the counts to identify combinations
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

func isConsecutive(_ cards: [Card]) -> Bool {
	for i in 1..<cards.count {
		if cards[i].number != cards[i - 1].number + 1 {
			return false
		}
	}
	return true
}

func checkStraight(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		
		let uniqueCards = Array(Set(player.holeCards)).sorted()
		
		// Loop over all potential starting points for a straight
		if uniqueCards.count > 4 {
			for i in 0..<(uniqueCards.count - 4) {
				let subArray = Array(uniqueCards[i...(i + 4)]) // 5 consecutive cards
				
				// Check if the 5 cards are consecutive
				if isConsecutive(subArray) {
					player.straight = true
					if player.bestHandName == "straight" {
						player.bestHand = uniqueCards.sorted().suffix(5)
					}
					
					// Check if all cards in the straight have the same suit
					let suits = Set(subArray.map { $0.suit })
					if suits.count == 1 {
						player.StrFlush = true // Straight Flush
						if player.bestHandName == "strFlush" {
							player.bestHand = uniqueCards.sorted().suffix(5)
						}
					}
				}
			}
		}
	}
}

func checkStraightAHigh(table: PokerTable) {
	let playersInHand = table.players.filter({ $0.inHand })
	for player in playersInHand {
		let aceHigh = [1, 10, 11, 12, 13]
		
		// Filter player's hand for Ace High straight cards
		let aceHighCards = player.holeCards.filter { aceHigh.contains($0.number) }
		
		// Remove duplicates based on the .number property
		var uniqueValues: [Card] = []
		var seenNumbers: Set<Int> = []
		
		for card in aceHighCards {
			if !seenNumbers.contains(card.number) {
				uniqueValues.append(card)
				seenNumbers.insert(card.number)
			}
		}
		
		// Check if there are exactly 5 unique cards and if they all share the same suit
		if uniqueValues.count == 5 {
			player.straight = true
			
			if player.bestHandName == "straight" {
				player.bestHand = uniqueValues
			}
			
			// Check if all cards in the Ace High straight share the same suit
			let suits = Set(uniqueValues.map { $0.suit })
			if suits.count == 1 {
				player.StrFlush = true // This indicates a straight flush
				if player.bestHandName == "strFlush" {
					player.bestHand = uniqueValues
				}
			}
		}
	}
}

func checkHands(table: PokerTable) {
	checkFlush(table: table)
	checkPairs(table: table)
	checkStraight(table: table)
	checkStraightAHigh(table: table)
}
