//
//  DefaultKeys.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/06/2021.
//

import Foundation

//MARK: Defaultkeys struct contains the keys we require to maintain the state of application when it is running and even after the app is terminated.
struct DefaultsKeys {
    
    static var name = "1"
    static var email = "2"
    static var phone_number = "3"
    static var profile_picture = "4"
    static var wallet_balance = "5"
    static var token = "6"
    static var socket_id = "7"
    static var status = "8"
    static var is_poster = "9"
    static var is_tasker = "10"
    static var poster_rating = "11"
    
    
    static var taskId = "12"
    static var conversationId = "13"
    
    
    static var coordinates = "14"
    static var pickUpLocation = "15"
    static var isTaskerAssigned = "16"
    static var taskerName = "17"
    
    static var reviews = "18"
    static var posterId = "19"

    static var tasker_location_latitude = "20"
    static var tasker_location_longitude = "21"
    
    static var pickup_location_latitude = "22"
    static var pickup_location_longitude = "23"
    
    static var qb_id = "24"
    static var qb_login = "25"
    static var qb_password = "26"
    static var tasker_qb_id = "27"
    
    ///Constants
    static var moody_phone_number = "28"
    static var moody_charges = "29"
    static var minimum_amount_for_top_up = "30"
    static var maximum_top_up_amount = "31"
    static var refresh_distance_kilometers = "32"
    static var refresh_distance_seconds = "33"
    static var minimum_balance_for_creating_task = "34"
    
    static var qb_app_id = "35"
    static var qb_account_key = "36"
    static var qb_auth_key = "37"
    static var qb_auth_secret = "38"
    static var taskType = "39"

    
    static var instructions = "40"
    static var tagLine = "41"
    
    static var inviteCode = "42"
    static var inviteFriend = "43"
    
    static var errorReport = "44"
    
    static var splashCheck =  false
    static var IntroVideo = false
    static var firstLogin = false
    static var historyYearCheck = false
    
    static var taskHistoryRefId = ""
    
    static var baseFare = "45"
    static var timeTaken = "46"
    static var perMinuteRate = "47"
    static var totalAmountPaid = "48"
    static var feedBackAudio = "49"
    static var estimateFare = "50"
    static var userImg = "50"
    static var referenceId = "51"
    static var referenceIdFlag = "52"


    static var isfromChatOrNot = "53"

    
    
    //chat user defaults
    static var messages = "100"
    static var notifyBool = "99"
    static var notifyStatus = "98"
    static var messagesTime = "97"
    static var messagesDictionary = "96"
    
    static var dropOffLocation = "97"
    
    
    
    static var taskerNameDetail = "98"
    static var VehicleNumber = "99"
    static var RatingOfTasker = "100"
    static var taskerProfileImage = "101"
    static var customer_support_notification = "102"

    static var numberOfActiveTask = "103"

    
    static var taskStatusMessage = "104"
    static var basefare = "105"
    static var totalDistance = "106"
    static var totalTime = "107"
    
    static var promo_balance = "108"
    
    static var ratePerKm = "109"
    static var ratePerMin = "110"
    static var moody_intro_video = "111"
    static var totalDiscount = "112"
    static var fareAfterDiscount = "113"
    static var ticketId = "114"
    static var selectedHistoryMonth = "115"
    static var selectedDate = "116"
    

    static var shoppingDetails = "117"
    static var helpBadge = "118"
    static var currentTotalDistance = "119"

    static var arrivalTimeDuration = "120"
    static var callLogMessage = "121"
    static var isQbLogin = "122"
    
    
    static var localMessages = "123"
    static var localmessageType = "124"
    static var localIndex = "125"
    static var localImageData = "126"
    static var localLocation = "127"
    static var localTaskId = "128"
    static var taskIdInCall = "129"
    static var taskerDetails = "130"
    static var completedTaskId = "131"

    
    static var payableAmounts = "132"

}
