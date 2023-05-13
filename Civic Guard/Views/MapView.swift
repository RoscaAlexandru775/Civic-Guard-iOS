//
//  MapView.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 13.05.2023.
//

import SwiftUI
import MapKit


struct MapView: View {
    
    @Binding var currentLocationLatitude: Double?
    @Binding var currentLocationLongitude: Double?
    @Binding var complaints: [Complaint]
        
    @State private var showHomeView = false
    @State private var mapRegion: MKCoordinateRegion
    @State private var locations: [LocationItem]
    @State private var selectedComplaint: LocationItem = LocationItem(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "", description: "", imageUrl: "", status: false)

     
    init(currentLocationLatitude: Binding<Double?>, currentLocationLongitude: Binding<Double?>, complaints: Binding<[Complaint]>) {
        _currentLocationLatitude = currentLocationLatitude
        _currentLocationLongitude = currentLocationLongitude
        _complaints = complaints
        
        let latitude = currentLocationLatitude.wrappedValue ?? 44.4174344
        let longitude = currentLocationLongitude.wrappedValue ?? 26.032286666666664
        _mapRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 4.5, longitudeDelta: 4.5)))
        
        //To DO: refactor this
        let coordonates = complaints.map { complaint in
            return (Double(complaint.locationLatitude.wrappedValue), Double(complaint.locationLongitude.wrappedValue), complaint.title.wrappedValue, complaint.description.wrappedValue, complaint.imageUrl.wrappedValue, complaint.status.wrappedValue)
        }
        
        let locationItems = coordonates.map { location in
            if let latitude = location.0, let longitude = location.1{
                return LocationItem(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: location.2, description: location.3, imageUrl: location.4, status: location.5)
            }
            return LocationItem(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "", description: "", imageUrl: "", status: false)
        }
        _locations = State(initialValue: locationItems)
    }
    
    var body: some View {
        
        ZStack {
            Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    PinView().scaleEffect(selectedComplaint == location ? 1 : 0.7)
                        .shadow(radius: 10).onTapGesture {
                            selectedComplaint = location
                        }                }
            }.ignoresSafeArea()
            ComplaintPreview(selectedComplaint: $selectedComplaint).padding()
        }
        
    }
}
