//
//  File.swift
//  Moody_Posterv2.0
//
//  Created by Muhammad Mobeen Rana on 30/09/2021.
//

import Foundation

struct TaskerQbDetails:Codable {
    var taskerQbId : String = ""
    var taskImageUrl : String = ""
    var taskerName : String = ""
    var taskId : String = ""
    
    
    init(id : String , imageUrl : String, name : String, taskID : String) {
        taskerQbId = id
        taskImageUrl = imageUrl
        taskerName = name
        taskId = taskID
    }
}

