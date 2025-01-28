//
//  PlayerViewAI.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 31/01/2025.
//

import SwiftUI

struct OpponentView: View {
	@StateObject var table: TableViewModel
	@EnvironmentObject var auth: AuthViewModel
	@Binding var hasJoined: Bool
	var playerNumber: Int

	//Animation Variables
	@State private var actionTextVisible = false
	@State private var actionTextOpacity = 0.0
	@State private var actionTextOffset = 30
	
	var body: some View {
		let player = table.players.first(where: { $0.user == auth.username })
		if hasJoined {
			if let player = player {
				let opponents = table.players
					.filter { $0.user != player.user } // Remove the player
					.sorted {
						let buttonA = $0.button
						let buttonB = $1.button
						
						// Adjust button values to create a circular order
						let adjustedA = (buttonA - player.button + 6) % 6
						let adjustedB = (buttonB - player.button + 6) % 6
						
						return adjustedA < adjustedB
					}
				let sortedPlayers = [player] + opponents  // Ensure player is first
				if sortedPlayers.indices.contains(playerNumber) {
					let opponent = sortedPlayers[playerNumber]
					opponentView(opponent: opponent)
				} else {
					noOpponent()  // Handle out-of-bounds case safely
				}
			}
		} else {
			let sortedPlayers = table.players.sorted(by: {$0.button < $1.button})
			if sortedPlayers.indices.contains(playerNumber - 1) {
				let opponent = sortedPlayers[playerNumber - 1]
				opponentView(opponent: opponent)
			} else {
				noOpponent()
			}
		}
	}
	
	fileprivate func noOpponent() -> some View {
		VStack {
			Text("No Player")
			HStack {
				noCard()
				noCard()
			}
			Text("Chips: 0")
		}
		.foregroundStyle(.white)
	}
	
	fileprivate func opponentView(opponent: Player) -> some View {
		return ZStack {
			VStack {
				HStack {
					ZStack {
						Circle().frame(height: 20).foregroundStyle(.black).shadow(radius: 5)
						Text("D").font(.headline).shadow(radius: 3)
					}.opacity( opponent.button == 0 ? 1.0 : 0.0)
					
					Text(
						opponent.user
					)
				}.offset(x: -15)
				HStack {
					if opponent.inHand == true {
						if table.table?.gameState == "showdown" {
							cardView(card: opponent.holeCards[0])
							cardView(card: opponent.holeCards[1])
						} else {
							cardBack()
							cardBack()
						}
					} else {
						noCard()
						noCard()
					}
				}
				Text("Chips: \(opponent.chips)")
			}
			.foregroundStyle(.white)
			
			// DEBUGGING BUTTON
			Button("Call") {
				call(player: opponent)
			}
			.disabled(!opponent.playerToAct)
			.buttonStyle(.borderedProminent)
			.tint(.red)
			
			Text("  \(opponent.actionText)  ").padding(4).background(.white).clipShape(.capsule)
				.opacity(actionTextOpacity)
				.offset(y: CGFloat(actionTextOffset))
				.animation(.easeInOut, value: actionTextOpacity)
				.shadow(radius: 5)
				.onChange(of: opponent.updateAction) {
					actionTextOffset = 0
					actionTextOpacity = 1.0
					Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
						DispatchQueue.main.async {
							withAnimation {
								actionTextOffset = 30
								actionTextOpacity = 0.0
							}
						}
					}
				}
		}
	}
	
	
	//FOR DEBUGGING
	func call(player: Player) {
		player.called = true
		player.playerToAct = false
		if player.amountToCall > 0 {
			if player.chips > player.amountToCall {
				player.chips -= player.amountToCall
				if let table = table.table {
					table.roundPot += player.amountToCall
				}
				player.actionText = "Call \(player.amountToCall)"
				print("Player \(player.id) calls \(player.amountToCall)")
				player.amountToCall = 0
			} else {
				if let table = table.table {
					table.roundPot += player.chips
				}
				player.chips = 0
				player.amountToCall = 0
				player.actionText = "ALL IN"
				print("Player \(player.id) all in")
			}
			
		} else {
			player.actionText = "Check"
			print("Player \(player.id) checks.")
		}
		player.updateAction.toggle()
			table.updatePlayerToAct(player: player)
	}
}


#Preview {
	Table(tableID: "AneuzpjNUtTPG7dUVNJP")
		.environmentObject(AuthViewModel())
}
