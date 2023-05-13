//
//  ComplaintPreview.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import SwiftUI

struct ComplaintPreview: View {
    
    @Binding var selectedComplaint: LocationItem
      

    var body: some View {
        
        VStack(spacing: 0){
            if selectedComplaint.title != "" {
                Spacer()
                HStack(alignment: .bottom, spacing: 10){
                    ZStack{
                        AsyncImage(url: URL(string: selectedComplaint.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                        
                    }.padding(6)
                        .background(.white)
                        .cornerRadius(10)
                    
                    
                    
                    VStack(alignment: .leading, spacing: 4){
                        
                        HStack{
                            Spacer()
                            ZStack(){
                                if selectedComplaint.status == true {
                                    Circle()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.red)
                                } else if selectedComplaint.status == false {
                                    Circle()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        Text(selectedComplaint.title).font(.title2)
                            .fontWeight(.bold)
                        Text(selectedComplaint.description)
                            .font(.subheadline)
                        
                    }
                    
                }.padding(20).background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial).offset(y: 50)).cornerRadius(10)
            }
            
        }
    }
}

