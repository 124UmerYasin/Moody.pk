//
//  ApiErrorHandler.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit

//MARK: CustomerEror class is used to handle all erros that can occur in Api call

class CustomError: Error {

    var title: String
    var code: Int
    
    init(title:String,code:Int) {
        self.title = title
        self.code = code
    }
}

extension ApiManager{
    
    //MARK: Returns error from the API to user.
    //. receive response and return custom object of error 
    func errorHandler(httpresponse: HTTPURLResponse, responseJSON: [String:Any]) -> CustomError{
        
        var error: CustomError!
        var message: String
        
        do{
            let errorMessage = try getErrors(response: responseJSON)
            message = errorMessage

        }catch{
            message = Strings.ERROR_MESSAGE
        }
        if(httpresponse.statusCode == STATUSCODES.TOKEN_NOT_AUTHENTICATE.rawValue){
            error = CustomError(title:"Token Not Authenticate" , code: httpresponse.statusCode)
            
        }else{
            error = CustomError(title:message , code: httpresponse.statusCode)
        }
        //error = CustomError(title:message , code: httpresponse.statusCode)
        return error
    }
    
    //MARK: Get errors from the API response
    //. Receives response of api
    //. checks Error count
    //. returns error message
    func getErrors(response: ([String: Any])) throws -> String{
      
        let errors = response["data"] as? [String: Any]
            
        if(errors != nil){
            if errors!.count > 0{
                
                let key:String = errors?.first!.key ?? ""
                let errorMessage:[String] = errors![key] as? [String] ?? [Strings.ERROR_MESSAGE]
                return String(errorMessage[0])
                
            }else{
                return Strings.ERROR_MESSAGE
            }
        }
        return Strings.ERROR_MESSAGE
    }
    
}
