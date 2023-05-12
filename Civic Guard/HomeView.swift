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
 
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var userIsLoggedIn = true
    @State private var complaints: [Complaint] = []
    @State private var showFilter = false
    @State private var selectedOption = "All Complaints"
    @State private var selectedDistance = 1000.0
    @State private var selectedInstitution = "All"
    @State private var selectedStatus = "All"
    

    let ref = Database.database().reference()
    
    
    var body: some View {
        switch (isLoading, userIsLoggedIn, showFilter) {
            case (true, _, _):
                loading
            case (_, false, _):
                ContentView()
            case (_, _, true):
                filters
            default:
                content
        }
    }
    
    var loading: some View {
        ProgressView().onAppear{
            fetchComplaints()
        }
    }
    
    var filters: some View {
        FiltersView(showFilter: $showFilter, selectedOption: $selectedOption, selectedDistance: $selectedDistance, selectedInstitution: $selectedInstitution, selectedStatus: $selectedStatus)
    }
    
    var content: some View {
        ZStack(alignment: .bottomTrailing) {
            
            NavigationView {
                
                List(filteredComplaints, id: \.creationDate) { complaint in
                    HStack(spacing: 10) {
                        AsyncImage(url: URL(string: complaint.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(complaint.title)
                                .font(.headline).foregroundColor(.black)
                            Text(complaint.description)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        
                        ZStack(alignment: .topTrailing) {
                            if complaint.status == true {
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.red)
                            } else if complaint.status == false {
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }.searchable(text: $searchText)
                .navigationTitle("Complaints")
            }
            Button(action: {
                showFilter = true
            }) {
                  Image(systemName: "slider.horizontal.3")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 20, height: 20)
                      .foregroundColor(.gray)
                      .padding(15)
                      .padding(.trailing, 3)
                      .background(Color.black)
                      .clipShape(Circle())
                      .frame(width: 50, height: 50)
              } .padding(20)
                .offset(x: 0, y: -180)

            
            Button(action: {
                  // First button action
                  // Add your code here
              }) {
                  Image(systemName: "plus")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 20, height: 20)
                      .foregroundColor(.gray)
                      .padding(15)
                      .padding(.trailing, 3)
                      .background(Color.black)
                      .clipShape(Circle())
                      .frame(width: 50, height: 50)
              } .padding(20)
                .offset(x: 0, y: -120)
            
            Button(action: {
                  // First button action
                  // Add your code here
              }) {
                  Image(systemName: "location")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 20, height: 20)
                      .foregroundColor(.gray)
                      .padding(15)
                      .padding(.trailing, 3)
                      .background(Color.black)
                      .clipShape(Circle())
                      .frame(width: 50, height: 50)
              } .padding(20)
                .offset(x: 0, y: -60)
            Button(action: {
                do {
                    try Auth.auth().signOut()
                    userIsLoggedIn = false
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError.localizedDescription)")
                }
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.red)
                    .padding(15)
                    .background(.black)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                }
                .padding(20)
        }.onAppear {
            if let _ = Auth.auth().currentUser {
                userIsLoggedIn = true
            } else {
                userIsLoggedIn = false
            }
            fetchComplaints()
        }
        
    }
    
   
    var filteredComplaints: [Complaint] {
        
        var complaintsCopy: [Complaint] = complaints
        
        if selectedStatus != "All" {
            if selectedStatus == "Active" {
                complaintsCopy =  complaints.filter { complaint in
                    return complaint.status == false
                    
                }
            } else {
                complaintsCopy = complaints.filter { complaint in
                    return complaint.status == true
                    
                }
            }
            
        }
        
        if selectedInstitution != "All" {
            complaintsCopy =  complaints.filter { complaint in
                 return complaint.institutionName == selectedInstitution
            }
            
        }
        
        if selectedOption != "All Complaints" {
            complaintsCopy =  complaints.filter { complaint in
                return complaint.userId == Auth.auth().currentUser?.uid
            }
            
        }
        
        if searchText.isEmpty {
               return complaintsCopy
           } else {
               return complaintsCopy.filter { complaint in
                   
                   let lowercasedSearchText = searchText.lowercased()
                   return complaint.title.lowercased().contains(lowercasedSearchText) ||
                       complaint.description.lowercased().contains(lowercasedSearchText)
               }
           }
    }
    
   
    func fetchComplaints(){
        ref.child("Complaints").observe(.value){
            snapshot in
            if let value = snapshot.value as?  [String: [String: Any]] {
                var complaintList: [Complaint] = []
                for (_, complaintData) in value {
                    do {
                    
                        let jsonData = try JSONSerialization.data(withJSONObject: complaintData, options: [])
                        let complaint = try JSONDecoder().decode(Complaint.self, from: jsonData)
                        complaintList.append(complaint)
                        
                    } catch {
                        print("Error decoding complaint: \(error.localizedDescription)")
                        
                    }
                }
                complaints = complaintList
            }
            isLoading = false
             
        }withCancel: { error in
            print("Error fetching data: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
