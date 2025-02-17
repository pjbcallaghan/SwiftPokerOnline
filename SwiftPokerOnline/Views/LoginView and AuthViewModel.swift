//
//  PlayerProfile.swift
//  SwiftPokerOnline
//
//  Created by Patrick Callaghan on 31/01/2025.
//

import SwiftUI
import CryptoKit
import FirebaseFirestore
import Combine

//Log In screen

struct LoginView: View {
	@State private var user = ""
	@State private var pass = ""
	@EnvironmentObject var auth: AuthViewModel
	@State private var registerFailMessage = false
	@State private var loginFailMessage = false
	
	var body: some View {
		
		//Logout view
		
		if auth.isLoggedIn {
			Text("Currently logged in as: \(auth.username)")
			Text("Chips: \(auth.chips)").onAppear { auth.fetchChips() }
			Button("Log Out") {
				loginFailMessage = false
				registerFailMessage = false
				auth.logout()
			}.buttonStyle(.borderedProminent)
				.padding()
		} else {
			
			//Login View
			
			Text("Please register or log in:")
			HStack {
				Spacer(); Spacer()
				Spacer(); Spacer()
				VStack{
					TextField("Username", text: $user)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.autocorrectionDisabled()
						.textInputAutocapitalization(.never)
					TextField("Password", text: $pass)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.autocorrectionDisabled()
						.textInputAutocapitalization(.never)
				}
				Spacer(); Spacer()
				Spacer(); Spacer()
			}
			.padding()
			HStack {
				Spacer(); Spacer()
				Spacer(); Spacer()
				
				Button("Log In    "){
					registerFailMessage = false
					auth.login(username: user, password: pass)
					if auth.loginFailed {
						loginFailMessage = true
					}
				}.buttonStyle(.borderedProminent)
					.disabled(user.count < 3)
					.disabled(pass.count < 3)
				
				Spacer()
				
				Button("Register"){
					loginFailMessage = false
					registerUser(username: user, password: pass) { success, errorMessage in
						if success {
							print("User registered successfully!")
							auth.login(username: user, password: pass)
						} else {
							print("Error: \(errorMessage ?? "Unknown error")")
						}
					}
				}.buttonStyle(.borderedProminent)
					.disabled(user.count < 3)
					.disabled(pass.count < 3)
				
				Spacer(); Spacer()
				Spacer(); Spacer()
				
			}
			ZStack {
				Text("Username or password incorrect").opacity(loginFailMessage ? 1 : 0)
				Text("Username already exists").opacity(registerFailMessage ? 1 : 0)
			}.padding()
			
		}
		
	}
	
	func registerUser(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
		let hashedPassword = hashPassword(password)
		let db = Firestore.firestore()
		let userRef = db.collection("Users").document(username)
		
		userRef.getDocument { (document, error) in
			if let document = document, document.exists {
				completion(false, "Username already exists")
			} else {
				let userData: [String: Any] = [
					"username": username,
					"password": hashedPassword,
					"createdAt": Timestamp(),
					"chips": 10_000
				]
				
				userRef.setData(userData) { error in
					if let error = error {
						completion(false, "Error registering user: \(error.localizedDescription)")
					} else {
						completion(true, nil)
					}
				}
			}
		}
	}

}

//AuthViewModel

class AuthViewModel: ObservableObject {
	@Published var player: Player?
	@Published var isLoggedIn = false
	@Published var username: String = ""
	@Published var showLoginView = false
	@Published var loginFailed = false
	@Published var chips: Int = 0
	
	func login(username: String, password: String) {
		loginUser(username: username, password: password) { success, errorMessage in
			DispatchQueue.main.async {
				if success {
					self.isLoggedIn = true
					self.username = username
					self.showLoginView = false
				} else {
					print("Login failed: \(errorMessage ?? "Unknown error")")
				}
			}
		}
	}
	
	func logout() {
		isLoggedIn = false
		username = ""
	}
	
	func loginUser(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
		let hashedPassword = hashPassword(password)
		let db = Firestore.firestore()
		
		let userRef = db.collection("Users").document(username)
		userRef.getDocument { (document, error) in
			if let document = document, document.exists, let data = document.data() {
				let storedPassword = data["password"] as? String ?? ""
				
				if storedPassword == hashedPassword {
					completion(true, nil)  
					self.loginFailed = false
					
				} else {
					completion(false, "Invalid username or password")
					self.loginFailed = true
				}
			} else {
				completion(false, "Invalid username or password")
				self.loginFailed = true
				
			}
		}
	}
	
	//Gathers a users chips data from firestore. Currently a users chip data is not changed by in game performances so this is pointless.
	func fetchChips() {
		guard isLoggedIn else { return }
		
		Firestore.firestore().collection("Users").document(username).getDocument { document, error in
			if let document = document, document.exists {
				DispatchQueue.main.async {
					self.chips = document.data()?["chips"] as? Int ?? 0
				}
			}
		}
	}
	
}

//Encrypt password user registers with
func hashPassword(_ password: String) -> String {
	let passwordData = Data(password.utf8)
	let hashed = SHA256.hash(data: passwordData)
	return hashed.compactMap { String(format: "%02x", $0) }.joined()
}



#Preview {
	LoginView()
		.environmentObject(AuthViewModel())
}
