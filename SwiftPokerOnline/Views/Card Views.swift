//
//  Card Views.swift
//  Poker
//
//  Created by Patrick Callaghan on 17/01/2025.
//

import Foundation
import SwiftUI

//Individual cards views

func noCard() -> some View {
	ZStack {
		RoundedRectangle(cornerRadius: 5).foregroundStyle(.white)
		VStack {
			HStack {
				Image("SuitSpades.svg").resizable().scaledToFit().frame(height: 20).offset(y: 9)
				Image("SuitDiamonds").resizable().scaledToFit().frame(height: 20).offset(y: 9)
			}
			HStack {
				Image("Heart_corazon").resizable().scaledToFit().frame(height: 20).offset(y: 9)
				Image("SuitClubs.svg").resizable().scaledToFit().frame(height: 20).offset(y: 9)
			}.padding(.bottom, 13)
			
		}
	}.frame(width: 60, height: 80).opacity(0.2)
}

func cardBack() -> some View {
	return Image("back").resizable().scaledToFit().frame(width:60, height: 80)
}

func cardView(card: Card) -> some View {
	ZStack {
		ZStack(alignment: .top) {
			RoundedRectangle(cornerRadius: 5).foregroundStyle(.white)
			HStack {
				if card.number == 1 {
					Text("A").font(.headline)
				} else if card.number == 11 {
					Text("J").font(.headline)
				} else if card.number == 12 {
					Text("Q").font(.headline)
				} else if card.number == 13 {
					Text("K").font(.headline)
				} else {
					Text("\(card.number)").font(.headline)
				}
				Image(card.image).resizable().scaledToFit().frame(height: 18).offset(x: -5)
			}.padding(.top, 5)
				.foregroundStyle(.black)
			
		}.frame(width: 60, height: 80)
		Image(card.image).resizable().scaledToFit().frame(height: 40).offset(y: 9)
	}
}

