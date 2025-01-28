//
//  CommunityCardsView.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 31/01/2025.
//

import SwiftUI

//View for the 5 central community cards

struct CommunityCardsView: View {
	@StateObject var table: TableViewModel
	
	//Animation variables
	@State private var cardScales: [Int: Double] = [:]
	@State private var cardSpins: [Int: Double] = [:]
	@State private var outcomeTextOffset = 30.0
	@State private var outcomeTextOpacity = 0.0
	
	var body: some View {
		VStack {
			ZStack {
				HStack {
					ForEach(0...4, id: \.self) { index in
						if let communityCards = table.table?.communityCards, communityCards.indices.contains(index) {
							cardView(card: communityCards[index])
								.foregroundStyle(.black)
								.scaleEffect(cardScales[index] ?? 1)
								.rotationEffect(.degrees(cardSpins[index] ?? 0))
								.onAppear {
									if cardScales[index] == nil { cardScales[index] = 1 }
									if cardSpins[index] == nil { cardSpins[index] = 0 }
									var delay = 0.3
									if communityCards.count > 3 {
										delay = 0.0
									} else {
										delay = 0.3
									}
									DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * delay)) {
										withAnimation(.easeInOut(duration: 1)) {
											cardScales[index]! += 1
											cardSpins[index]! += 720
										}
									}
								}
						} else {
							noCard()
								.onAppear { cardScales[index] = 0.0 }
						}
					}
				}
				if let table = table.table {
					showdownText(table)
				}
			}
			Text("Pot: \(table.table?.pot ?? 0)")
			Text("\(table.table?.roundPot ?? 0)")
		}.foregroundStyle(.white)
	}
	fileprivate func showdownText(_ table: PokerTable) -> some View {
		return Text("  \(table.showdownText)  ").padding(4).background(.white).clipShape(.capsule).foregroundStyle(.black)
			.opacity(outcomeTextOpacity)
			.offset(y: CGFloat(outcomeTextOffset))
			.animation(.easeInOut, value: outcomeTextOpacity)
			.shadow(radius: 5)
			.onChange(of: table.showdownTextVisible) {
				outcomeTextOffset = 0
				outcomeTextOpacity = 1.0
				Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
					DispatchQueue.main.async {
						withAnimation {
							outcomeTextOffset = 30
							outcomeTextOpacity = 0.0
						}
					}
				}
			}
	}
}

#Preview {
	Table(tableID: "test")
		.environmentObject(AuthViewModel())
}
