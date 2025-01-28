//
//  Game Flow Control.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 13/02/2025.
//

import Foundation

extension TableViewModel {
	
	//Logic for starting a new hand.
	func startGame() {
		guard let table = table else { return }
		
		//If any new players have joined the game, assign them the lowest available button value (table position).
		for player in table.players {
			let sortedPlayers = table.players.sorted(by: { $0.id > $1.id })
			if player.button == 10 { //Player does not have a true button value
				let filteredPlayers = sortedPlayers.filter { $0.button != 10 }
				if filteredPlayers.count == 0 {
					for player in sortedPlayers {
						player.button = player.id
					}
				} else {
					player.button = (filteredPlayers[0].button + (player.id - filteredPlayers[0].id) + 6) % 6
				}
			}
		}
		
		//Reset the deck to contain all 52 cards.
		table.deck = createDeck()
		
		//Reset hand evaluation and game logic for each player.
		for player in table.players {
			player.inHand = true
			player.StrFlush = false
			player.kind4 = false
			player.flush = false
			player.straight = false
			player.kind3 = false
			player.pair2 = false
			player.pair1 = false
			player.bestHand = []
			player.bestHandName = "highCard"
			player.folded = false
			player.called = false
			player.playerToAct = false
			player.amountToCall = 0
			player.holeCards.removeAll()
			
			if player.chips == 0 {
				player.chips = 2000
			}
			
			//Give each player 2 hole cards
			let cards = table.deck.shuffled().prefix(2)
			player.holeCards.append(contentsOf: cards)
			
			//Remove the dealt cards from the deck
			for card in player.holeCards {
				if let index = table.deck.firstIndex(where: { $0.id == card.id }) {
					table.deck.remove(at: index)
				}
			}
		}
		
		table.gameState = "deal"
		table.roundPot = 0
		table.pot = 0
		table.communityCards = []
		
		blinds()
	}
	
	//Logic for posting the blinds
	func blinds() {
		guard let table = table else { return }
		let playersInHand = table.players.filter { $0.inHand }
		let sortedPlayers = playersInHand.sorted { $0.button < $1.button }
		
		for player in table.players {
			player.amountToCall = 50
		}
		
		//Different players post the blinds if there are only 2 players in a hand.
		if playersInHand.count == 2 {
			sortedPlayers[0].amountToCall = 25
			sortedPlayers[0].chips -= 25
			table.roundPot += 25
			sortedPlayers[0].actionText = "Small Blind"
			sortedPlayers[0].updateAction.toggle()
			
			sortedPlayers[1].amountToCall = 0
			sortedPlayers[1].chips -= 50
			table.roundPot += 50
			sortedPlayers[1].actionText = "Big Blind"
			sortedPlayers[1].updateAction.toggle()
			
			sortedPlayers[0].playerToAct = true
			
		} else {
			sortedPlayers[1].amountToCall = 25
			sortedPlayers[1].chips -= 25
			table.roundPot += 25
			sortedPlayers[1].actionText = "Small Blind"
			sortedPlayers[1].updateAction.toggle()
			
			
			sortedPlayers[2].amountToCall = 0
			sortedPlayers[2].chips -= 50
			table.roundPot += 50
			sortedPlayers[2].actionText = "Big Blind"
			sortedPlayers[2].updateAction.toggle()
			
			//The action starts on a different player if there are more than 3 players in a hand.
			if table.players.count > 3 {
				sortedPlayers[3].playerToAct = true
			} else {
				sortedPlayers[0].playerToAct = true
			}
		}
		updatePokerTable()
	}
	
	//Logic for updating which player the action is on. This also handles checking if all players have folded and the pot has been won, or if all players have called and the next street needs to be dealt.
	func updatePlayerToAct(player: Player) {
		guard let table = table else { return }
		let playersInHand = table.players.filter({$0.inHand})
		
		//If all players have folded, the last remaining player wins the hand.
		if playersInHand.count == 1 {
			playersInHand[0].chips += table.pot
			playersInHand[0].chips += table.roundPot
			table.showdownText = "\(playersInHand[0].user) wins"
			table.showdownTextVisible.toggle()
			self.adjustButtons()
			self.startGame()
			return
		}
		
		//If all players have called, proceed to the next street.
		if !table.allPlayersCalled {
			let playersInHand = table.players.filter { $0.inHand }
			let sortedPlayers = playersInHand.sorted {$0.button < $1.button}
			let playerToAct = sortedPlayers.first(where: { $0.button > player.button })
			if let player = playerToAct {
				player.playerToAct = true
			} else {
				let player = playersInHand.min(by: { $0.button < $1.button })
				player?.playerToAct = true
			}
			
		} else {
			switch table.gameState {
			case "deal": flop()
			case "flop": turn()
			case "turn": river()
			case "river": showdown()
			default: break
			}
		}
		updatePokerTable()
	}
	
	//Functions for starting each different street
	func flop() {
		guard let table = table else { return }
		table.gameState = "flop"
		newRound(deal: 3)
		print("Flop")
		updatePokerTable()
	}
	
	func turn() {
		guard let table = table else { return }
		table.gameState = "turn"
		newRound(deal: 1)
		print("Turn")
		updatePokerTable()
	}
	
	func river() {
		guard let table = table else { return }
		table.gameState = "river"
		newRound(deal: 1)
		print("River")
		updatePokerTable()
	}
	
	//Logic for proceeding to the next street.
	func newRound(deal: Int) {
		guard let table = table else { return }
		
		//Reset the appropriate table data
		let playersInHand = players.filter { $0.inHand }
		for player in playersInHand {
			player.called = false
		}
		table.pot += table.roundPot
		table.roundPot = 0
		
		//Deal the appropriate number of cards to the center
		let cards = table.deck.shuffled().prefix(deal)
		for (_, card) in cards.enumerated() {
			table.communityCards.append(card)
			// Remove dealt card(s) from the deck
			if let cardIndex = table.deck.firstIndex(where: { $0.id == card.id }) {
				table.deck.remove(at: cardIndex)
			}
		}
		
		//Update which player the action is on.
		let playerToAct = playersInHand
			.filter { $0.button != 0 }
			.sorted(by: { $0.button < $1.button })
			.first ?? playersInHand[0]
		for player in players {
			player.playerToAct = false
		}
		playerToAct.playerToAct = true
		
		updatePokerTable()
	}
	
	//When beginning a new hand, update the position (button value) of each player.
	fileprivate func adjustButtons() {
		let players = self.players.sorted(by: { $0.button < $1.button })
		for (index, player) in players.enumerated() {
			player.button = index
		}
		for player in players {
			if player.button == 0 {
				player.button = self.players.count - 1
			} else {
				player.button -= 1
			}
		}
	}
	
	//When showdown is reached, execute the hand evaluation logic on each remaining player, assign the winning player, and begin a new hand.
	func showdown() {
		guard let table = table else { return }
		table.gameState = "showdown"
		
		let playersInHand = table.players.filter({ $0.inHand })
		for player in playersInHand {
			player.holeCards.append(contentsOf: table.communityCards)
		}
		
		evaluateHands(table: table)
		for player in playersInHand {
			print(player.id)
			print(player.bestHandName)
			for card in player.bestHand {
				print(card.id)
			}
			print("")
		}
		
		table.showdownText = "\(playersInHand[0].user) wins with \(playersInHand[0].bestHandName)"
		table.showdownTextVisible.toggle()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			self.adjustButtons()
			self.startGame()
		}
	}
}

