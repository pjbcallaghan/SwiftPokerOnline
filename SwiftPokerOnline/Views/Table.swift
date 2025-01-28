//
//  Table.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 31/01/2025.
//

import SwiftUI

struct Table: View {
	@StateObject var table: TableViewModel
	@State private var joinedTable: Bool = false
	var tableID: String
	init(tableID: String) {
		self.tableID = tableID
		_table = StateObject(wrappedValue: TableViewModel(tableID: tableID))
	}
	
	var body: some View {
		ZStack {
			VStack {
				Text(table.table?.roomName ?? "Poker Table").foregroundStyle(.white)
				Spacer() ;Spacer()
				OpponentView(table: table, hasJoined: $joinedTable, playerNumber: 3)
				Spacer()
				HStack {
					Spacer()
					OpponentView(table: table, hasJoined: $joinedTable, playerNumber: 2)
					Spacer(); Spacer()
					OpponentView(table: table, hasJoined: $joinedTable, playerNumber: 4)
					Spacer()
				}
				Spacer(); Spacer()
				CommunityCardsView(table: table)
				Spacer()
				HStack {
					Spacer()
					OpponentView(table: table, hasJoined: $joinedTable, playerNumber: 1)
					Spacer(); Spacer()
					OpponentView(table: table, hasJoined: $joinedTable, playerNumber: 5)
					Spacer()
				}
				Spacer(); Spacer()
				PlayerView(table: table, joinedTable: $joinedTable)
				Spacer(); Spacer()
			}
			.background(LinearGradient(gradient: Gradient(colors: [
				Color(red: 0.0, green: 0.5, blue: 0.0),
				Color(red: 0.1, green: 0.6, blue: 0.1)]),
												startPoint: .top, endPoint: .bottom))
		}
		.navigationBarBackButtonHidden(true)  // Hide the back button
	}
}

#Preview {
	Table(tableID: "test")
		.environmentObject(AuthViewModel())
}
