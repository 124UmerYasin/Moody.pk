//
//  ApiEndpoints.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation


//MARK: Class contains Constants.apiurls to all endpoints used in this application
final class ENDPOINTS {
    
    
    
    //MARK: ENDPOINTS of API calls of application 
    static var createOTP = "\(Constants.apiurl)create_otp"   //done
    static var verifyOTP = "\(Constants.apiurl)verify_otp" //done
    
    static var updateUser = "\(Constants.apiurl)update_user_settings" //done (nothing got in response)
    static var getConstants = "\(Constants.apiurl)get_constants"   //done
    
    static var readTaskHistory = "\(Constants.apiurl)get_task_history" //done.
    
    static var viewTaskHistoryDetail = "\(Constants.apiurl)view_task_history_details" //done

    static var createTask = "\(Constants.apiurl)create_task" //done

    static var cancelTask = "\(Constants.apiurl)cancel_task_by_poster" //done
    static var send_message = "\(Constants.apiurl)send_message"  // no need
    static var taskerAssigned = "\(Constants.apiurl)find_me_a_tasker"
    static var getReview = "\(Constants.apiurl)get_reviews" //done
    static var get_fare_details = "\(Constants.apiurl)get_fare_details" // done
    static var task_ratings = "\(Constants.apiurl)task_ratings"  // done
    static var get_conversation = "\(Constants.apiurl)get_conversation" //no need
    static var notify_support = "\(Constants.apiurl)notify_support" //done
    static var update_application_logs = "\(Constants.apiurl)update_application_logs" //done
    static var create_top_up_task = "\(Constants.apiurl)create_top_up_task" //done

    static var createQuery = "\(Constants.apiurl)create_query" //done
    static var endQuery = "\(Constants.apiurl)end_query" //done
    
    static var sendMessageQuery = "\(Constants.apiurl)send_message_customer_support"     //no need
    static var fetchCsMessages = "\(Constants.apiurl)get_customer_support_conversation" // no need

    static var getLocationLogs = "\(Constants.apiurl)display_location_logs"
    static var getTaskerQBDetails = "\(Constants.apiurl)get_quickblox_details"  //done
    
    static var validateInviteCode = "\(Constants.apiurl)validate_invite_code"  // done
    
    static var viewTransactionsHistory = "\(Constants.apiurl)get_transaction_history" // done
    static var createTransaction = "\(Constants.apiurl)create_transaction" //done
    
    static var logout = "\(Constants.apiurl)app_logout" //done

    static var get_active_task_details = "\(Constants.apiurl)get_active_task_details" // no need it only has key when task is ongoing≥
    static var update_fcm_token = "\(Constants.apiurl)update_fcm_token" //done
    
    static var easyPaisaAppFlow = "\(Constants.apiurl)create_transaction_easypaisa_deposit" //Done
    
    static var ticketHistory = "\(Constants.apiurl)tickets_history"
    
    static var createTicket = "\(Constants.apiurl)create_ticket"
    
    static var changeTicketStatus = "\(Constants.apiurl)change_ticket_status"
    
    static var readTicketConversation = "\(Constants.apiurl)read_ticket_conversation"
    
    static var sendTicketMessage = "\(Constants.apiurl)ticket_send_message"
    static var reset_notification_count_task = "\(Constants.apiurl)reset_notification_count_task"

    static var set_call_log = "\(Constants.apiurl)set_call_log"
    
    static var get_qb_details = "\(Constants.apiurl)get_qb_details"
    
    static var save_user_logs = "\(Constants.apiurl)save_user_logs"
    
    static var get_task_product_receipts = "\(Constants.apiurl)get_task_product_receipts"

    

    
}

