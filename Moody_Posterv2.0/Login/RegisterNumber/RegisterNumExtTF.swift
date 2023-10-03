//
//  RegisterNumExtTF.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit

extension RegisterNumber: UITextFieldDelegate{
    
    //MARK: On begin editing actions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLable.isHidden = true
    }
    
    //MARK: On editing textfield action
    //. Phone Number is check than total count is checked
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let text = textField.text else{return}
        errorLable.isHidden = textField.text!.count == 0 ? true : false
        
        if(text.first == "3" || text.first == "0"){
            errorLable.isHidden = true
            if(text.first == "3"){
                checkCount(text: text, textfield: textField, number: 10)
            }else if(text.first == "0"){
                checkCount(text: text, textfield: textField, number: 11)
            }
        }else{
            errorLable.isHidden = false
        }
    }
    
    
    
    //MARK:  On editing textfield action for lower then 13 version
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textHandling(text: textField.text! + string, textfield: textField)
    }
    
    //MARK: checking if the number is valid starting from 0 or 3
    func textHandling(text: String, textfield: UITextField) -> Bool{
        errorLable.isHidden = text.count == 0 ? true : false
        
        if(text.first == "3" || text.first == "0"){
            errorLable.isHidden = true
            if(text.first == "3"){
                checkCount(text: text, textfield: textfield, number: 10)
            }else if(text.first == "0"){
                checkCount(text: text, textfield: textfield, number: 11)
            }
        }else{
            errorLable.isHidden = false
            if(text.count >= 11){
                let number = text.replacingOccurrences(of: " ", with: "")
                let index = number.suffix(10)
                checkCount(text: String(index), textfield: textfield, number: 10)
                textfield.text = String(index)
            }
        }
        
        return true
        
    }
    
    //MARK: Button colour change based on number added.
    func checkCount(text: String, textfield: UITextField, number: Int){
        
        if(termsAndConditionBool){
            enableBtn(continueBtn)
        }
       
        if(text.count > number)
        {
            textfield.text!.removeLast()
            
        }else if (text.count != number){
            disableBtn(continueBtn)
        }
    }
    
    
    
}
