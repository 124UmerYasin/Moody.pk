//
//  SimpelAlert.swift
//  Moody_IOS
//

import Foundation
import UIKit

class SimpelAlert: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var alertIcon: UIImageView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var alertText: UILabel!
    @IBOutlet weak var alertTitle: UILabel!
    
    //MARK: Variables
    var alertImage = UIImage()
    var alertTitlee = String()
    var alertMessage = String()
    var yesBtnStr = String()
    var noBtnStr = String()
    
    
    var confirm: Bool?
    var actionButton: (()-> Void)?
    
    override func viewDidLoad() {
        setupViews()
    }
    
    //MARK: Setup views for Alert box.
    func setupViews(){
        self.view.backgroundColor = UIColor(named: "alertBackgroundColor")

        alertIcon.image = alertImage
        
        alertText.text = alertMessage
        alertTitle.text = alertTitlee
        yesButton.setTitle(yesBtnStr, for: .normal)
        noButton.setTitle(noBtnStr, for: .normal)
        
        noButton.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
        
    }

    //MARK: Action when Confirm button is pressed
    @IBAction func yesButtonPressed(_ sender: Any) {        
        actionButton?()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Action when No button is pressed.
    @IBAction func noButtonpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
}
