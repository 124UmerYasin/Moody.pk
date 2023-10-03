//
//  Regex.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit

extension UIViewController{
    
    //MARK: Email Validation regex
   func isVaildEmail(_ value: String)-> Bool{
        let EMAIL_ADDRESS =
            "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
            "\\@" +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
            "(" +
            "\\." +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
            ")+"
        
        let string = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", EMAIL_ADDRESS)
        return predicate.evaluate(with: string) || string.isEmpty
    }
    

    
    //MARK: PhNumber validation Regex
    func isVaildNumber(_ value: String)-> Bool{
        let PHONE_NUMBER = "^((3)|(03))[0-9]{9}$"
        
        let string = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", PHONE_NUMBER)
        return predicate.evaluate(with: string) || string.isEmpty
    }
    
    //MARK: name validation regex 
    func isVaildName(_ value: String)-> Bool{
        let NAME = "[a-zA-Z0-9\\s+]{3,}"
        
        let string = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", NAME)
        return predicate.evaluate(with: string) || string.isEmpty
    }
}
