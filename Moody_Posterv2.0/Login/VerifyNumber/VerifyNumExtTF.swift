//
//  VerifyNumExtTF.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit

extension VerifyNumber: UITextFieldDelegate{
    
    //MARK: del otp
    //. Delegate calls when del is pressed on keypad
    //. cursor move backwards and clears the field
    func textFieldDidDelete() {
           if(fieldNumber == 2){
               fieldNumber = 1
               textField2.text = ""
               textField1.becomeFirstResponder()
           }
           if(fieldNumber == 3){
               fieldNumber = 2
               textField3.text = ""
               textField2.becomeFirstResponder()
           }
           if(fieldNumber == 4){
               fieldNumber = 3
               textField4.text = ""
               textField3.becomeFirstResponder()
           }
       }
    
    //MARK: Appending OTP to Fields
    func getTheCode(){
        recivedCode = ""
        recivedCode = textField1.text!
        recivedCode!.append(textField2.text!)
        recivedCode!.append(textField3.text!)
        recivedCode!.append(textField4.text!)
    }
    
    //MARK: Clearing OTP Fields
    func resetFields(){
        recivedCode = ""
        textField1.text? = ""
        textField2.text? = ""
        textField3.text? = ""
        textField4.text? = ""
    }
    
    //MARK: Clearing OTP Fields
    func setTextAlignment(){
        textField1.textAlignment = .center
        textField2.textAlignment = .center
        textField3.textAlignment = .center
        textField4.textAlignment = .center
    }
    
    //MARK: On begin editing actions
    //. calls when number is add in text field
    //. it checks on which field to append and than appends number to that field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == textField1){
                   fieldNumber = 1
               } else if(textField == textField2){
                   fieldNumber = 2
               } else if(textField == textField3){
                   fieldNumber = 3
               } else if(textField == textField4){
                   fieldNumber = 4
               }
        
        if textField.text!.count > 0{
            textField.text = ""
            textField.becomeFirstResponder()
        }

        if invalidOTP == true {
        inilizesUIViews(view1)
        inilizesUIViews(view2)
        inilizesUIViews(view3)
        inilizesUIViews(view4)
        textField1.text = ""
        textField2.text = ""
        textField3.text = ""
        textField4.text = ""
        invalidOTP = false
        }
        recivedCode = ""
        self.getTheCode()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return fieldsHandling(string: string , textField: textField)
    }
    
    //MARK: Handling text fields for OTP screen.
    //. checks count and calls api when boxes are complete
    func fieldsHandling(string: String, textField: UITextField) -> Bool{
        
        if string.count != 0{
            textField.text = ""
            textFieldsCheck(string: string, textField: textField)
            self.getTheCode()
            if recivedCode.count == 4{
                verifyNumAPI()
            }else {
                errorLabel.isHidden = true
                setViewBoader( UIColor(named: "AppTextColor")!)

            }
        }
        return false
    }
    
    
    //MARK: Checking and getting values from each textfield in otp screen
    func textFieldsCheck(string: String, textField: UITextField){
        if(textField == textField1){
            fieldNumber = 1
            handleTextBoxes(textField: textField1, string: string, nextField: textField2)
        } else if(textField == textField2){
            fieldNumber = 2
            handleTextBoxes(textField: textField2, string: string, nextField: textField3)
        } else if(textField == textField3){
            fieldNumber = 3
            handleTextBoxes(textField: textField3, string: string, nextField: textField4)
        } else if(textField == textField4){
            fieldNumber = 4
            textField4.text = string
            textField4.endEditing(true)
        }
    }
    
    //MARK: Handles boxes selcetion
    func handleTextBoxes(textField:UITextField,string:String,nextField:UITextField){
        textField.text = string
        if(nextField.text?.count == 0){
            nextField.becomeFirstResponder()
        }else{
            textField.endEditing(true)
        }
    }
    
}
