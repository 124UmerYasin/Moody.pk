//
//  Strings.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation


enum Strings{
    
    //MARK: Api Manager header settings.
    static let APPLICATION_JSON = NSLocalizedString("application/json", comment: "")
    static let CONTENT_TYPE = NSLocalizedString("Content-Type", comment: "")
 
    //MARK: Error Handler variables
    static let ERROR_TITLE = NSLocalizedString("Error", comment: "")
    static let ERROR_MESSAGE = NSLocalizedString("Something Went Wrong. Please try again.", comment: "")
    
    //MARK: Notification message type
    static let task_annotated = "task_annotated"
    static let task_cancelled = "task_cancelled"
    static let tasker_arrived = "tasker_arrived"
    static let new_message = "new_message"
    static let new_message_cs = "new_message_cs"
    static let task_customer_support = "customer_support"
    static let new_message_deo = "new_message_deo"
    static let task_completed = "task_completed"
    static let transaction_verified = "transaction_verified"
    static let transaction_declined = "transaction_declined"
    static let tasker_assigned = "tasker_assigned"
    
    static var selectedLang  = "eng"
    static let wallet_balance = "wallet_balance"
    static let wallet_balance_update = "wallet_balance_update"
    static let promo_balance = "promo_balance"
    static let promo_code = "promo_code"
    static let fare_estimation = "fare_estimation"
    
    static var promo_code_invited_by = "promo_code_invited_by"
    
    static var drop_off_location = "drop_off_location"
    static var qb_call = "qb_call"
    static var previous_poster_device_token = "previous_poster_device_token"
    
    
    
}
