//
//  DatesExtension.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit

///Extension provides dates functionalities.
extension Date {
    //MARK: Returns Current date with month and year
    var currentMonthAndYear: String {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM"
        let formattedDate = format.string(from: date)
        
        return formattedDate
        
    }
    
    //MARK: Returns Current month
    var currentMonth: String {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "MM"
        let formattedDate = format.string(from: date)
        
        return formattedDate
        
    }
    
    //MARK: Returns Current year
    var currentYear: String {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let formattedDate = format.string(from: date)
        
        return formattedDate
    }

}
