//
//  UImageExt.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/06/2021.
//

import UIKit

extension SettingsVC : UIImagePickerControllerDelegate{
    
    ///Image picker controller to pick images from gallery
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
 
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            var dictionary = [String:Any]()
       
            dictionary["profile_picture"] = pickedImage.jpegData(compressionQuality: 1.0)?.base64EncodedString()
            dictionary["extension"] = "jpg"
            
            UserDefaults.standard.set(pickedImage.pngData(), forKey: DefaultsKeys.profile_picture)
            profilePictureAPICall(dictionary:  dictionary)
        }
    }
    
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}

