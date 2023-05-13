//
//  ContentView.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

struct ContentView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var userIsLoggedIn = false
    @State private var displayLogin = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    
 
    var ref = Database.database().reference()
   
    var body: some View {
        if userIsLoggedIn {
            HomeView()
        } else {
            if displayLogin{
                loginView
            } else{
                registerView
            }
        }
    }
    
    var loginView: some  View {
        ZStack {
            Color.black
            
            RoundedRectangle(cornerRadius: 30, style: .continuous).foregroundStyle(.linearGradient(colors: [.cyan, Color(red: 60/255, green: 138/255, blue: 158/255)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 1000, height: 400).rotationEffect(.degrees(135)).offset(y: -350)
            VStack(spacing: 20) {
                Text("Welcome").foregroundColor(.white).font(.system(size: 40, weight: .bold, design: .rounded)).offset(x: -100, y: -100)
                
               
                TextField("Email", text: $email).foregroundColor(.white).textFieldStyle(.plain).placeholder(when: email.isEmpty){
                    Text("Email").foregroundColor(.white).bold()
                }
                Rectangle().frame(width: 350, height: 1).foregroundColor(.white)
                
                SecureField("Password", text: $password).foregroundColor(.white).textFieldStyle(.plain).placeholder(when: password.isEmpty) {
                    Text("Password").foregroundColor(.white).bold()
                };
                
                Rectangle().frame(width: 350, height: 1).foregroundColor(.white)
                
                Button {
                    login()
                } label: {
                    Text("Login").bold().frame(width: 200, height: 40).background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.linearGradient(colors: [.cyan, Color(red: 60/255, green: 138/255, blue: 158/255)], startPoint: .topLeading, endPoint: .bottomTrailing))).foregroundColor(.white)
                }.padding(.top).offset(y:50)
                
                Button {
                    displayLogin.toggle()
                } label: {
                    Text("Don't have an account? Register").bold().foregroundColor(.white)
                }.padding(.top)
                    .offset(y: 60)
                
                
            }.frame(width: 350).onAppear {
                if let _ = Auth.auth().currentUser {
                    userIsLoggedIn = true
                } else {
                    userIsLoggedIn = false
                }
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }.ignoresSafeArea()

    }
    
    var registerView: some  View {
        ZStack {
            Color.black
            
            RoundedRectangle(cornerRadius: 30, style: .continuous).foregroundStyle(.linearGradient(colors: [.cyan, Color(red: 60/255, green: 138/255, blue: 158/255)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 1000, height: 400).rotationEffect(.degrees(135)).offset(y: -350)
            VStack(spacing: 20) {
                Text("Register").foregroundColor(.white).font(.system(size: 40, weight: .bold, design: .rounded)).offset(x: -100, y: -100)
                
                TextField("Username", text: $username).foregroundColor(.white).textFieldStyle(.plain).placeholder(when: username.isEmpty){
                    Text("Username").foregroundColor(.white).bold()
                }
                Rectangle().frame(width: 350, height: 1).foregroundColor(.white)
                
                TextField("Email", text: $email).foregroundColor(.white).textFieldStyle(.plain).placeholder(when: email.isEmpty){
                    Text("Email").foregroundColor(.white).bold()
                }
                Rectangle().frame(width: 350, height: 1).foregroundColor(.white)
                
                SecureField("Password", text: $password).foregroundColor(.white).textFieldStyle(.plain).placeholder(when: password.isEmpty) {
                    Text("Password").foregroundColor(.white).bold()
                };
                
                Rectangle().frame(width: 350, height: 1).foregroundColor(.white)
                
                Button {
                    register()
                } label: {
                    Text("Sign up").bold().frame(width: 200, height: 40).background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.linearGradient(colors: [.cyan, Color(red: 60/255, green: 138/255, blue: 158/255)], startPoint: .topLeading, endPoint: .bottomTrailing))).foregroundColor(.white)
                }.padding(.top).offset(y:50)
                
                Button {
                    displayLogin.toggle()
                } label: {
                    Text("Already have an account? Login").bold().foregroundColor(.white)
                }.padding(.top)
                    .offset(y: 60)
                
                
            }.frame(width: 350).onAppear {
                if let _ = Auth.auth().currentUser {
                    userIsLoggedIn = true
                } else {
                    userIsLoggedIn = false
                }
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }.ignoresSafeArea()

    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password){
            result, error in if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else{
                
                    userIsLoggedIn = true
            
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) {
        
            result, error in  if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                let userId = Auth.auth().currentUser?.uid
                let usersRef = ref.child("Users").child(userId!)
                let user = ["username": username, "email": email, "role": "user", "deviceToken": ""]
                    usersRef.setValue(user)
                userIsLoggedIn = true
            
            }
        }
    }

     
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
