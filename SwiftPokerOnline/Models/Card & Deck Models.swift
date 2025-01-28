//
//  Deck.swift
//  Poker
//
//  Created by Patrick Callaghan on 15/01/2025.
//

import Foundation

struct Card: Hashable, Comparable, Codable {
	var id: String
	var number: Int
	var suit: String
	var image: String
	
	static func < (lhs: Card, rhs: Card) -> Bool {
		return lhs.number < rhs.number
	}
}

//Create a 52 card deck
func createDeck() -> [Card] {
	let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
	let numbers = 1...13  // Represents Ace (1) to King (13)
	
	var deck = [Card]()
	
	for suit in suits {
		for number in numbers {
			let suitImages = [
				"Hearts": "Heart_corazon",
				"Diamonds": "SuitDiamonds",
				"Clubs": "SuitClubs.svg",
				"Spades": "SuitSpades.svg"
			]
			
			let id: String
			let image = suitImages[suit] ?? "Back"
			
			if number == 1 {
				id = "Ace-\(suit)"
			} else if number == 11 {
				id = "Jack-\(suit)"
			} else if number == 12 {
				id = "Queen-\(suit)"
			} else if number == 13 {
				id = "King-\(suit)"
			} else {
				id = "\(number)-\(suit)"
			}
			deck.append(Card(id: id, number: number, suit: suit, image: image)) // Append the card here
		}
	}
	return deck
}

