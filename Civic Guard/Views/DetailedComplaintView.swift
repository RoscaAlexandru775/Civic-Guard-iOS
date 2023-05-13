//
//  DetailedComplaintView.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct DetailedComplaintView: View {

    @State var showButton = false
    @State var complaint: Complaint
    @State var hideBackButton = false
    
    let ref = Database.database().reference()
    
    
    var body: some View {
        VStack(spacing: 20){
            Text(complaint.title).font(.title).fontWeight(.bold)
            
            AsyncImage(url: URL(string: complaint.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
            }
            
            Text(complaint.description).font(.title3).fontWeight(.bold)
            
            HStack{
                Text("Status").font(.title2).fontWeight(.bold)

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
                
            HStack{
                Text("Institution: ").font(.title2).fontWeight(.bold)

                Spacer()
                
                Text(complaint.institutionName).font(.title2).fontWeight(.bold)
            }
            
            HStack{
                Text("Date: ").font(.title2).fontWeight(.bold)

                Spacer()
                
                Text(complaint.creationDate).font(.title2).fontWeight(.bold)
            }
           
            Text("Address: \(complaint.locationAddress)").font(.title3).fontWeight(.bold)

            Spacer()

            if showButton == true {
                Button(action: {
                    changeStatus()
                }) {
                    Text("Change Status")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
        }.padding()
            .navigationBarBackButtonHidden(hideBackButton)
            .onAppear{
            if Auth.auth().currentUser?.uid != complaint.userId && complaint.status == false
            {
                showButton = true
            }
        }
    }
    
    func changeStatus()
    {
        let complaintRef = ref.child("Complaints").child(complaint.id)
        complaintRef.updateChildValues(["status": true])
        complaint.status = true
        showButton = false
    }
}

struct DetailedComplaintView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedComplaintView(complaint: Complaint(id:"jj", userId: "232", status: false, locationLatitude: "41.343", title: "dfdfds", locationLongitude: "26.654", creationDate: "dsfds", description: "Sdfds", imageUrl: "https://firebasestorage.googleapis.com/v0/b/proiect-mds-48325.appspot.com/o/images%2F1655132152648.jpg?alt=media&token=6dd8b223-8b2c-4911-b2bb-f2413a5960c6", locationAddress: "asdasd", institutionName: "sdfdsfds"))
    }
}
