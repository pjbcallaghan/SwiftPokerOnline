//
//  SwiftPokerOnlineApp.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 28/01/2025.
//

import SwiftUI
import Firebase

@main
struct SwiftPokerOnlineApp: App {
	@StateObject private var authViewModel = AuthViewModel()
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		WindowGroup {
			ServerBrowserView()
				.environmentObject(authViewModel)
		}
	}
}
