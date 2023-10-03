//
//  SuccessfulPaymentViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import Foundation
import UIKit

class SuccessfulPaymentViewController: UIViewController{
    @IBOutlet weak var successfulPaymentLabel: UILabel!
    
    
    //MARK: calls when first time View Loads
    //. It loads view and pops to back screen after 5 second
    override func viewDidLoad() {
        //MARK: Navigating to home screen after 5 seconds delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK: Calls just after view appears
    //. hides navigationBar
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: Calls just before view appears
    //.Check urdu lng and style label 
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: successfulPaymentLabel, text: successfulPaymentLabel.text ?? "Found Nothing in successfulPaymentLabel", lineSpacing: 10)
        }
    }
    
}
