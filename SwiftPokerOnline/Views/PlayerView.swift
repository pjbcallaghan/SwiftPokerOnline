//
//  PlayerView.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 31/01/2025.
//

import SwiftUI

struct PlayerView: View {
	@ObservedObject var table: TableViewModel
	@EnvironmentObject var auth: AuthViewModel
	@Environment(\.scenePhase) private var scenePhase  // Track app state changes
	@Binding var joinedTable: Bool
	
	//Animation variables
	@State private var cardScale = 0.0
	@State private var cardSpin = 0.0
	@State private var actionTextVisible = false
	@State private var actionTextOpacity = 0.0
	@State private var actionTextOffset = 30
	@State private var raiseViewOffset = 600
	@State private var raiseAmount = 0
	
	var body: some View {
		ZStack {
			if !joinedTable {
				if !auth.isLoggedIn {
					loginButton()
				} else {
					joinTableButton()
				}
			}
			HStack {
				Spacer()
				VStack {
					HStack {
						if let player = table.players.first(where: { $0.user == auth.username }) {
							ZStack {
								Circle().frame(height: 20).foregroundStyle(.black).shadow(radius: 5)
								Text("D").font(.headline).shadow(radius: 3)
							}.opacity(player.button == 0 ? 1.0 : 0.0)
						}
						Text(auth.username)
					}
					HStack {
						if let player = table.players.first(where: { $0.user == auth.username }), player.holeCards.count > 1 {
							VStack {
								ZStack {
									HStack {
										cardView(card: player.holeCards[0])
											.scaleEffect(cardScale)
											.rotationEffect(.degrees(cardSpin))
										cardView(card: player.holeCards[1])
											.scaleEffect(cardScale)
											.rotationEffect(.degrees(cardSpin))
									}
									
									Text("  \(player.actionText)  ").padding(4).background(.white).clipShape(.capsule)
										.opacity(actionTextOpacity)
										.offset(y: CGFloat(actionTextOffset))
										.animation(.easeInOut, value: actionTextOpacity)
										.shadow(radius: 5)
										.onChange(of: player.updateAction) {
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
								Text("Chips: \(player.chips)")
									.foregroundStyle(.white)
							}
							
							.onAppear() {
								withAnimation(.easeInOut(duration: 1.0)) {
									cardScale += 1
									cardSpin += 720
								}
							}
						} else {
							VStack {
								HStack {
									noCard()
									noCard()
										.onAppear() { cardScale = 0.0 }
								}
								Text("Chips: 0") //THIS NEEDS TO BE FIXED
									.foregroundStyle(.white)
							}
							
						}
					}.foregroundStyle(.black)
				}.foregroundStyle(.white)
				Spacer()
				VStack {
					if let player = table.players.first(where: { $0.user == auth.username }) {
						VStack {
							HStack {
								Button(player.amountToCall > 0 ? "Call \(player.amountToCall)" : "Check") {
									call(player: player)
									print(player.user)
									print(player.called)
								}
								Button("Raise") {
									withAnimation {
										raiseViewOffset = 0
									}
								}
							}
							Button("Fold") {
								fold(player: player)
							}
						}
						.buttonStyle(.borderedProminent).tint(.green)
						.disabled(!player.playerToAct)
						
					}
				}
				Spacer()
			}.opacity(joinedTable ? 1 : 0)
			Spacer()
				.sheet(isPresented: $auth.showLoginView, content: { LoginView() })
			raiseView().offset(y: CGFloat(raiseViewOffset))
		}
		
		.onChange(of: scenePhase) { oldPhase, newPhase in
			if newPhase == .background || newPhase == .inactive {
				// Remove player when app moves to background
				if joinedTable {
					table.removePlayer(user: auth.username)
					joinedTable = false
				}
			}
		}
	}
	
	//SUB VIEWS
	fileprivate func joinTableButton() -> some View {
		return Button("Join table"){
			let newPlayer = Player()
			newPlayer.user = auth.username
			newPlayer.id = (0...5).first { id in
				!table.players.map { $0.id }.contains(id)
			} ?? 5
			
			table.addPlayer(newPlayer: newPlayer)
			if table.players.count == 2 {
				if table.table != nil {
					table.startGame()
				}
			}
			joinedTable = true
		}.buttonStyle(.borderedProminent).tint(.green)
			.disabled(table.hasLoaded == false)
	}
	
	fileprivate func loginButton() -> some View {
		return Button(){
			auth.showLoginView = true
		} label : {
			VStack {
				Text("Please log in to join a table").foregroundStyle(.white)
				Image(systemName: "person.circle.fill")
					.resizable()
					.frame(width: 30, height: 30)
					.padding(2)
			}
		}.buttonStyle(.plain)
			.foregroundStyle(.white)
	}
	
	fileprivate func raiseView() -> some View {
		return VStack {
			if let player = table.players.first(where: { $0.user == auth.username }) {
				VStack {
					HStack {
						Button(){
							withAnimation {
								raiseViewOffset = 600
							}
						} label: {Text("Cancel")}.buttonStyle(.bordered)
						
						Spacer()
						
						Button(){
							raise(player: player, bet: raiseAmount*25)
							withAnimation {
								raiseViewOffset = 600
							}
						} label: { Text("Raise: \(raiseAmount*25)")}.buttonStyle(.borderedProminent).tint(.green).disabled(raiseAmount == 0)
					}.padding(.top).padding(.horizontal)
					Slider(
						value: Binding(
							get: { Double(raiseAmount) },
							set: { raiseAmount = Int($0) }
						),
						in: 0...Double(max(0, (player.chips - player.amountToCall))/25) // Clamp to ensure valid range
					).padding()
				}
				.background(.ultraThinMaterial)
				
			}
		}
	}
	
	//PLAYER ACTIONS
	func raise(player: Player, bet: Int) {
		
		player.chips -= player.amountToCall
		if let table = table.table {
			table.roundPot += player.amountToCall
		}
		for player in table.players {
			player.called = false
			player.amountToCall += bet
		}
		
		player.chips -= bet
		if let table = table.table {
			table.roundPot += bet
		}
		player.called = true
		player.playerToAct = false
		player.amountToCall = 0
		
		if player.chips == 0 {
			player.actionText = "ALL IN"
			print("Player \(player.id) all in")
		} else {
			player.actionText = "Raise \(bet)"
			print("Player \(player.id) raises \(bet).")
		}
		player.updateAction.toggle()
		table.updatePlayerToAct(player: player)
	}
	
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
	
	func fold(player: Player) {
		player.folded = true
		player.inHand = false
		player.playerToAct = false
		player.actionText = "Fold"
		player.updateAction.toggle()
		print("Player \(player.id) folds.")
		table.updatePlayerToAct(player: player)
	}
	
}

#Preview {
	Table(tableID: "AneuzpjNUtTPG7dUVNJP")
		.environmentObject(AuthViewModel())
}
