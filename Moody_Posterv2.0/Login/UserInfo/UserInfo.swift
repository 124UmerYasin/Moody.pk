//
//  UserInfo.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit

class UserInfo : UIViewController, UITextFieldDelegate{
    
    //MARK: Label and button outlets 
    @IBOutlet var screenLabel: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var promoCodeField: UITextField!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var enterBtn: UIButton!
    @IBOutlet weak var NameView: UIView!
    @IBOutlet weak var errorField: UILabel!
    var isPromocode:Bool = false
    
    
    
    //MARK: calls when first time View Loads
    //. Tap gesture added on view
    //. Checks ref code and language
    //. Ui settings
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToHideKeyboardOnTapOnView()
        nameTextField.becomeFirstResponder()
        checkRefCode()
        checkLng()
        setVisibilty()
        promoCodeField.delegate = self
       
    }
    
    //MARK: Textfield delegate calls when there is change in text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       if(!isPromocode){
            disableBtn(continueBtn)
            if isVaildName(textField.text!){
                enableBtn(enterBtn)
            }
        }
        return true
    }
    
    
    //MARK: Sets visibitly required in view 
    func setVisibilty(){
        activityLoader.isHidden = true
        continueBtn.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: Checking language and localising label
    func checkLng(){
        if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
            screenLabel.text(NSLocalizedString("Enter invitation Code", comment: ""))
        }
    }
    
    //MARK: Checks reference is available
    //. Reference is recieved if user has downloaded from link
    //. ref code is saved to text field
    func checkRefCode(){
        if(UserDefaults.standard.string(forKey: "refCode") != nil){
            promoCodeField.text = UserDefaults.standard.string(forKey: "refCode")!
            
        }
    }
    

    //MARK: Tells the delegate when the text selection changes in the specified text field.
    //. Enables/Disbales enterBtn on promo text count
    func textFieldDidChangeSelection(_ textField: UITextField) {
                
        if (promoCodeField.text!.count > 4)  {
            enableBtn(continueBtn)
            continueBtn.isEnabled = true
            continueBtn.backgroundColor = UIColor(named: "AccentColor")
        }else{
            
            continueBtn.isEnabled = false
            continueBtn.backgroundColor = UIColor(named: "DisableBtn")
        }
    }


      //MARK: Continue button pressed action
      //. Checks Internet and if promoCode bool is true (it gets true when name has been updated)
      //. EnterPromocode functions calls which validates promocode and call promo code Api
      @IBAction func continueButton(_ sender: Any) {
        if(CheckInternet.Connection()){
            if isPromocode{
                enterPromoCode()
            }
            else{
                updateName()
            }
        }else{
            DispatchQueue.main.async {
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
            }
        }
      }
    
    //MARK: if user wants to skip promo it naviagtes to next promo video screen
    @IBAction func skipBtnPressed(_ sender: Any) {
            DispatchQueue.main.async { [self] in
                activityLoader.stopAnimating()
                activityLoader.isHidden = true
                navigateToPromoVideo()
            }
    }

    //MARK: Contunue Button after user enter its name
    //. if name is not empty UpdateName method is called where after name validation api is called
    @IBAction func enterBtnPressed(_ sender: Any) {
        if(CheckInternet.Connection()){
            if(nameTextField.text != nil && nameTextField.text != ""){
                activityLoader.isHidden = false
                activityLoader.startAnimating() 
                updateName()
            }else{
                
                errorField.isHidden = false
            }
        }else{
            enableBtn(enterBtn)
            enterBtn.isUserInteractionEnabled = true
            continueBtn.isUserInteractionEnabled = true
            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet Not Available. Please check your connection and try again.", comment: ""), parentController: self)
        }
    }
}
