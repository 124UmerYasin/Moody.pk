//
//  MyTextField.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 30/07/2021.
//

import Foundation
import UIKit

protocol MyTextFieldDelegate: AnyObject {
    func textFieldDidDelete()
}

class MyTextField: UITextField {

    weak var myDelegate: MyTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        myDelegate?.textFieldDidDelete()
    }

}
