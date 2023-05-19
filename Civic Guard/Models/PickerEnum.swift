//
//  PickerEnum.swift
//  Civic Guard
//
//  Created by Alexandru Rosca on 19.05.2023.
//

import UIKit

enum PickerEnum {
    enum Source: String{
        case library, camera
    }
    static func checkPermission() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            return true
        } else {
            return false
        }
    }
}
