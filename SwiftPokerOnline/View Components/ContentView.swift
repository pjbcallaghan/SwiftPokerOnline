//
//  ContentView.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 28/01/2025.
//

import SwiftUI
import FirebaseFirestore

//Server browser view. This is the view players first see upon opening the app.

struct ContentView: View {
	let samplePlayer = Player()
	
	@State private var createRoomName = ""
	@StateObject private var viewModel = ServerBrowserViewModel()
	@EnvironmentObject private var auth: AuthViewModel
	
	
	var body: some View {
		NavigationStack {
			
			//Background
			ZStack{
				LinearGradient(gradient: Gradient(colors: [
					Color(red: 0.0, green: 0.5, blue: 0.0),
					Color(red: 0.2, green: 0.8, blue: 0.2)]),
									startPoint: .top, endPoint: .bottom)
				.ignoresSafeArea()
				
				
				//Header
				VStack{
					HStack {
						Text("Server browser").foregroundStyle(.white).font(.largeTitle.bold())
						Spacer()
						Button() {
							auth.showLoginView = true
						} label: {
							Image(systemName: "person.circle").resizable().scaledToFit().buttonStyle(.borderedProminent).tint(.white)
						}
					}.frame(height: 40)
						.padding()
					
					//Server List
					ScrollView {
						ForEach(viewModel.pokerTables, id: \.id) { table in
							NavigationLink(){
								Table(tableID: table.id ?? "No ID")
							} label: {
								HStack {
									VStack(alignment: .leading) {
										Text(table.roomName).font(.headline)
										Text(table.id ?? "NoId")
										Text("Players: \(table.players.count)").font(.subheadline)
									}
									Spacer()
									Image(systemName:"arrow.right.circle.fill")
										.resizable()
										.scaledToFit()
								}
								.foregroundStyle(.white)
								.frame(height: 40)
								.padding()
							}.buttonStyle(.plain)
						}
					}
					Spacer()
					
					//Room creation field
					HStack {
						TextField("Enter a name for your room", text: $createRoomName).foregroundStyle(.white).tint(.white)
						Button("Create Room"){
							createPokerTable(name: createRoomName)
							createRoomName = ""
						}.buttonStyle(.borderedProminent)
							.tint(Color(red: 0.1, green: 0.5, blue: 0.1))
							.disabled(createRoomName.count < 3)
					}.padding(20)
					
					
				}
			}
		}.sheet(isPresented: $auth.showLoginView) { LoginView() }
	}
}

#Preview {
	ContentView()
		.environmentObject(AuthViewModel())
}
