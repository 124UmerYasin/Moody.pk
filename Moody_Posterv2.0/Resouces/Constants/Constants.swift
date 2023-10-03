//
//  Constants.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation

class Constants{
    
    //MARK: Application constant values
    static let app_version = "6.4 (56)"
    static let RESEND_OTP_TIMER = 60
    static let role = "is_poster"
    static let httpMethod = "POST"
    

    static let months = [NSLocalizedString("JAN", comment: ""), NSLocalizedString("FEB", comment: ""), NSLocalizedString("MAR", comment: ""), NSLocalizedString("APR", comment: ""), NSLocalizedString("MAY", comment: ""), NSLocalizedString("JUN", comment: ""), NSLocalizedString("JUL", comment: ""), NSLocalizedString("AUG", comment: ""), NSLocalizedString("SEP", comment: ""), NSLocalizedString("OCT", comment: ""), NSLocalizedString("NOV", comment: ""), NSLocalizedString("DEC", comment: "")]
    
    
    //MARK: - Production, development,stagging socket url
    
    static let socketUrl = "https://soc.moody.pk:2096"    //Production
    //static let socketUrl = "https://dev-soc.moody.pk:2053" //Dev
//    static let socketUrl = "https://st-soc.moody.pk/" //Staging
    
    
    //MARK: -URLs of Dev,Stagging and production webhooks
    
    // Whistle Ios-webhooks url
//    static var webhookUrl = "https://app.whistleit.io/api/webhooks/61f240cc0f2c5d6ee57e8d8e"  //Dev & Staging (Webhooks)
  static var webhookUrl = "https://app.whistleit.io/api/webhooks/61f24129a107a33e04757c48" //Production (Webhooks)
    static var webhookUrlEmpty = "https://app.whistleit.io/api/webhooks/61f24132850d6f42891b39e4" //Production only empty objects (Webhooks)

    //MARK: -URLs of Dev,Stagging and production APIs
//    static var apiurl = "https://dev-papi.moody.pk/app/" //Development
//      static var apiurl = "https://st-papi.moody.pk/app/"    //Stagging
    static var apiurl = "https://papi.moody.pk/app/"  //Production

    
    //MARK: -

    
}

//MARK: To update the Credentials, please see the README file.
struct CredentialsConstant {
//MARK: dev 1 Qbkeys
    //    static var applicationID:UInt = 91691
    //    static var authKey = "XVwyKvYGaTOCx4r"
    //    static var authSecret = "wD7A4k7KYKq7xBJ"
    //    static var accountKey = "-q4DrNM5RwmecJB5tonA"
    
    
//MARK: dev2 Qbkeys
//        static var applicationID:UInt = 91978
//        static var authKey = "tdwgz3EhR5jVfMG"
//        static var authSecret = "uVNKsTjDSkUAHDA"
//        static var accountKey = "-f8def-Ua3ZJxFXeeTCUX"

//MARK: Test Qbkeys
//    static var applicationID:UInt = 93742;
//    static var authKey = "8z8hETOLjBwXnea";
//    static var authSecret = "x32w5WaNwEHre-v";
//    static var accountKey = "Pn2hyPzzxzdD8ELFiJat";
    
//MARK: Production Qbkeys
        static var applicationID:UInt = 91732
        static var authKey = "T7CFw3jd5T4CE9j"
        static var authSecret = "h8UGvfUcdX7uySR"
        static var accountKey = "jkksyZfoyCHGLxg_DcvS"

}


