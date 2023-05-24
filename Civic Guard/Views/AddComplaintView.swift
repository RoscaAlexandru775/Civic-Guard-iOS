//
//  AddComplaintView.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import SwiftUI
import CoreLocation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

struct AddComplaintView: View {
    
    @State private var showAlert: Bool = false
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var institution: String = "City Hall"
    @State private var currentLocationLatitude: Double = 44.4174344
    @State private var currentLocationLongitude: Double = 26.032286666666664
    @State private var currentAddress: String = ""
    @State private var alertMessage: String = ""
    @State private var imageUrl: String = ""
    @State private var permissionGranted: Bool = true
    @State private var isLoading:Bool = true
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    @EnvironmentObject var vm: ImageViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private let institutions = ["City Hall", "Waste management company", "Park management company", "Water and Wastewater Utility"]
    
    var body: some View {
        if isLoading {
            ProgressView().onAppear{
                if let latitude = locationManager.location?.coordinate.latitude{
                    currentLocationLatitude = latitude
                }
                if let longitude = locationManager.location?.coordinate.longitude{
                    currentLocationLongitude = longitude
                }
                getAddressFromLocation(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
//                getAddressForLatLng(latitude: String(currentLocationLatitude), longitude: String(currentLocationLongitude))

            }
        } else{
            content
        }
    }
    
    var content: some View {
        VStack{
            TextField("", text: $title).padding().foregroundColor(.black).textFieldStyle(.plain).overlay(RoundedRectangle(cornerRadius:  20).stroke(.gray)).placeholder(when: title.isEmpty){
                Text("Title").foregroundColor(.black).bold().padding()}
            TextField("", text: $description).padding().foregroundColor(.black).textFieldStyle(.plain)   .accentColor(.black).overlay(RoundedRectangle(cornerRadius:  20).stroke(.gray)).placeholder(when: description.isEmpty){
                Text("Description").foregroundColor(.black).bold().padding()}
            Picker("Institution", selection: $institution) {
                ForEach(institutions, id: \.self) { institution in
                    Text(institution)
                }
            }
            Text("Address: \(currentAddress)")
            VStack{
                if let image = vm.image {
                    Image(uiImage: image).resizable().scaledToFit().frame(minWidth: 0, maxWidth: .infinity)
                } else {
                    Image(systemName: "photo.fill").resizable().scaledToFit().opacity(0.6).frame(minWidth: 0, maxWidth: .infinity).padding(.horizontal)
                }
                HStack{
                
                    Button{
                        vm.source = .camera
                        vm.showPhotoPicker()
                    } label: {
                        Text("Camera")
                    }.padding().foregroundColor(.white).background(.blue).cornerRadius(10)
                    
                    Button{
                        vm.source = .library
                        vm.showPhotoPicker()
                    } label: {
                        Text("Photos")
                    }.padding().foregroundColor(.white).background(.blue).cornerRadius(10)
                    
                }.sheet(isPresented: $vm.showPicker){
                    ImagePicker(sourceType: vm.source == .library ? .photoLibrary : .camera, selectedImage: $vm.image)
                }
                Spacer()
                Button {
                    addNewComplaints()
                } label: {
                    Text("Submit")
                }.padding().foregroundColor(.white).background(.blue).cornerRadius(10)
                
            }
        }.padding().navigationTitle("New Complaint")
        .onAppear{
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways{
                if let latitude = locationManager.location?.coordinate.latitude{
                    currentLocationLatitude = latitude
                }
                if let longitude = locationManager.location?.coordinate.longitude{
                    currentLocationLongitude = longitude
                }
                getAddressFromLocation(latitude: currentLocationLatitude, longitude: currentLocationLongitude)
//                getAddressForLatLng(latitude: String(currentLocationLatitude), longitude: String(currentLocationLongitude))


            } else {
                permissionGranted = false
                alertMessage = "Please grant location permission in order to determine your location."
                showAlert = true
            }
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Alert"),
                message: Text(alertMessage),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        goBack()
                    }
                )
            )
        }
    }
    private func goBack(){
        if !permissionGranted {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func addNewComplaints(){

        if checkComplaintData() {
            uploadComplaintImage()
            
        }
        
    }
    
    
    private func saveComplaint(){
        let ref = Database.database().reference().child("Complaints")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
          
        let newComplaint = [
            "title": title,
            "description": description,
            "institutionName": institution,
            "locationAddress": currentAddress,
            "status": false,
            "userId": Auth.auth().currentUser?.uid ?? "",
            "imageUrl": imageUrl,
            "creationDate": currentDate,
            "locationLatitude": String(currentLocationLatitude),
            "locationLongitude": String(currentLocationLongitude)
            
        ] as [String : Any]
        
        ref.childByAutoId().setValue(newComplaint) { error, ref in
                if let error = error {
                    print("Failed to add complaint: \(error.localizedDescription)")
                } else {
//                    print("Complaint added successfully!")
                }
            }

    }
    
    
    private func checkComplaintData() -> Bool{
       
        if title.isEmpty {
            alertMessage = "Please add a title"
            showAlert = true
            return false
        }
        if description.isEmpty {
            alertMessage = "Please add a description"
            showAlert = true
            return false
        }
        if currentAddress.isEmpty {
            alertMessage = "Please wait untill we get your location"
            showAlert = true
            return false
        }
        return true
    }
    
    private func uploadComplaintImage(){
        
        if vm.image == nil {
            
            alertMessage = "Please add a photo"
            showAlert = true
            return
        }
        isLoading = true
        let uid = UUID()
        let ref = Storage.storage().reference().child("images/\(uid)")
        guard let imageData = vm.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                isLoading = false
                alertMessage = "Failed to push image to Storage \(err)"
                showAlert = true
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    isLoading = false
                    alertMessage = "Failed to retrieve downloadUrl \(err)"
                    showAlert = true
                    return

                }
                imageUrl = url?.absoluteString ?? ""
                saveComplaint()
                isLoading = false
                permissionGranted = false
                alertMessage = "Succes"
                showAlert = true
            }
            
        }
    }
   
    func getAddressFromLocation(latitude: Double, longitude: Double) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error retrieving address: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            guard let placemark = placemarks?.first else {
                isLoading = false
                return
            }
            
            let address = "\(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
            currentAddress = address
            isLoading = false
        }
    }
    
//
//    private func getAddressForLatLng(latitude: String, longitude: String) {
//
//        if let api_key = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"] {
//            let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(api_key)")
//            let data = try! Data(contentsOf: url!)
//            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//            if let result = json["results"] as? [[String: Any]] {
//                if let address = result[0]["formatted_address"] as? String {
//                    currentAddress = address
//                }
//            }
//            isLoading = false
//        }
//    }
}

struct AddComplaintView_Previews: PreviewProvider {
    static var previews: some View {
        AddComplaintView()
    }
}
