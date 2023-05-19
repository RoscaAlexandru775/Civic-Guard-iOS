//
//  HomeView.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


struct HomeView: View {
 
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var showFilter = false
    @State private var userIsLoggedIn = true
    @State private var complaints: [Complaint] = []
    @State private var selectedOption = "All Complaints"
    @State private var selectedDistance = 1000.0
    @State private var selectedInstitution = "All"
    @State private var selectedStatus = "All"
    @State private var currentLocationLatitude:Double? = nil
    @State private var currentLocationLongitude: Double? = nil
    
    let locationManager = CLLocationManager()
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
        FiltersView(showFilter: $showFilter, selectedOption: $selectedOption, selectedDistance: $selectedDistance, selectedInstitution: $selectedInstitution, selectedStatus: $selectedStatus).onAppear{
            
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways{
                if let latitude = locationManager.location?.coordinate.latitude{
                    currentLocationLatitude = latitude
                }
                if let longitude = locationManager.location?.coordinate.longitude{
                    currentLocationLongitude = longitude
                }
            } else {
                showAlert = true
            }
            
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Location Authorization"),
                message: Text("Please grant location permission in order to use distance filter.")
            )
        }
    }
    
    
    var content: some View {
        
        NavigationView{
            ZStack(alignment: .bottomTrailing) {
                
                List(filteredComplaints, id: \.creationDate) { complaint in
                    NavigationLink(destination: DetailedComplaintView(complaint: complaint)){
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
                    }
                }.searchable(text: $searchText)
                        .navigationTitle("Complaints")
                
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
                
                
                NavigationLink(destination: AddComplaintView()){
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
                
                
                NavigationLink(destination: MapView(currentLocationLatitude: $currentLocationLatitude, currentLocationLongitude: $currentLocationLongitude, complaints: Binding.constant(filteredComplaints))){
                    Image(systemName: "map.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                        .padding(15)
                        .padding(.trailing, 3)
                        .background(Color.black)
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                    
                }.padding(20)
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
                if locationManager.authorizationStatus != .authorizedWhenInUse && locationManager.authorizationStatus != .authorizedAlways {
                    locationManager.requestWhenInUseAuthorization()
                }
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
                
            }
        }
    }
    
    var filteredComplaints: [Complaint] {
        
        var complaintsCopy: [Complaint] = complaints
        
        if selectedOption != "All Complaints" {
            complaintsCopy =  complaintsCopy.filter { complaint in
                return complaint.userId == Auth.auth().currentUser?.uid
            }
            
        }
        
        if selectedStatus != "All" {
            if selectedStatus == "Active" {
                complaintsCopy =  complaintsCopy.filter { complaint in
                    return complaint.status == false
                    
                }
            } else {
                complaintsCopy = complaintsCopy.filter { complaint in
                    return complaint.status == true
                    
                }
            }
            
        }
        
        //filter on selectedDistance
        if currentLocationLatitude != nil && currentLocationLongitude != nil {
            let myLocation = CLLocation(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!)
            complaintsCopy = complaintsCopy.filter { complaint in
                if let latitude = Double(complaint.locationLatitude), let longitude = Double(complaint.locationLongitude) {
                    let complaintLocation = CLLocation(latitude: latitude, longitude: longitude)
                    //distance in km
                    let distance = myLocation.distance(from: complaintLocation) / 1000.0
                    return distance <= selectedDistance
                }
                return true
            }
            
        }
        
        if selectedInstitution != "All" {
            complaintsCopy =  complaintsCopy.filter { complaint in
                 return complaint.institutionName == selectedInstitution
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
                for (complaintID, complaintData) in value {
                               do {
                                   var mutableComplaintData = complaintData // Create a mutable copy
                                   mutableComplaintData["id"] = complaintID // Assign the complaint ID

                                   let jsonData = try JSONSerialization.data(withJSONObject: mutableComplaintData, options: [])
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
