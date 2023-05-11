//
//  HomeView.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 10.05.2023.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct HomeView: View {

    @State private var userIsLoggedIn = true
    func fetchComplaint(){
        Database.database().reference()
    }
    var body: some View {
        if userIsLoggedIn {
            content
        } else {
                 ContentView()
              }
    }
    var content: some View {
        VStack(spacing: 20) {
            Button {
                do {
                    try Auth.auth().signOut()
                    userIsLoggedIn = false // Update the login status
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError.localizedDescription)")
                }
                
            } label: {
                Text("Log out").bold().foregroundColor(.black)
            }.padding(.top)
                .offset(y: 60)
        }.onAppear {
            if let _ = Auth.auth().currentUser {
                userIsLoggedIn = true
            } else {
                userIsLoggedIn = false
            }}
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
