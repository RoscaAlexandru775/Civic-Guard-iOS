//
//  Civic_GuardApp.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 29.04.2023.
//

import SwiftUI
import Firebase

@main
struct Civic_GuardApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ImageViewModel()).onAppear{
                UserDefaults.standard.setValue(false, forKey: "_UIConstrainBasedLayoutLogUnsetisfiable")
            }
        }
    }
}
