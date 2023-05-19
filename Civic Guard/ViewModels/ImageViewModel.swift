//
//  ImageViewModel.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 19.05.2023.
//

import SwiftUI

class ImageViewModel: ObservableObject{
    @Published var image: UIImage?
    @Published var showPicker = false
    @Published var source: PickerEnum.Source = .library
    
    func showPhotoPicker() {
        if source == .camera {
            if !PickerEnum.checkPermission() {
                print("There is no camera on this device")
                return
            }
        }
        showPicker = true
    }
}
