//
//  UpdateAlert.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/08/2021.
//

import Foundation
import UIKit

class UpdateAlert: UIViewController{
    
    var actionButton: (()-> Void)?
    
    
    //MARK: Dismisses Alert
    @IBAction func closeDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Dismisses Alert
    @IBAction func noDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: update is tapped
    //. View is dismissed and naviagte to AppStore 
    @IBAction func updateDidTap(_ sender: Any) {
        actionButton?()
        self.dismiss(animated: true, completion: nil)
    }
    
}
