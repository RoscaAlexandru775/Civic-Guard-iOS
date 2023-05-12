//
//  Filter.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 12.05.2023.
//

import SwiftUI

struct FiltersView: View {
    @Binding var showFilter: Bool
    @Binding var selectedOption: String
    @Binding var selectedDistance: Double
    @Binding var selectedInstitution: String
    @Binding var selectedStatus: String
    
    var institutions = ["All", "City Hall", "Waste management company", "Park management company", "Water and Wastewater Utility"]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showFilter = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            Text("Filter")
                .font(.headline)
            
            Picker("Select Option", selection: $selectedOption) {
                Text("All Complaints").tag("All Complaints")
                Text("My Complaints").tag("My Complaints")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Select Option", selection: $selectedStatus) {
                Text("All").tag("All")
                Text("Active").tag("Active")
                Text("Inactive").tag("Inactive")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Text("Selected Distance: \(selectedDistance, specifier: "%.0f") km")
                .font(.headline)
                .padding()
            
            Slider(value: $selectedDistance, in: 1...1000, step: 1)
                .accentColor(.gray)
                .padding(.horizontal)
            
            Text("Select institution:")
                .font(.headline)
            
            Picker("Institution", selection: $selectedInstitution) {
                ForEach(institutions, id: \.self) { institution in
                    Text(institution)
                }
            }
            .font(.headline)
            .padding()
            .padding(.horizontal)
            .background(Color.white)
            .shadow(radius: 5)
            .cornerRadius(2)
            .pickerStyle(MenuPickerStyle())
            .tint(.black)
            
            Spacer()
            
            HStack {
                Button(action: {
                    showFilter = false
                }) {
                    Text("Done")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedOption = "All Complaints"
                    selectedDistance = 1000.0
                    selectedInstitution = "All"
                    selectedStatus = "All"
                }) {
                    Text("Reset")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
            }
            
        }
    }
}
