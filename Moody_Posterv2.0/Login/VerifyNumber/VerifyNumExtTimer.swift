//
//  VerifyNumExtTimer.swift
//  Moody_Posterv2.0
//
//  Created by   on 04/06/2021.
//

import Foundation
import UIKit

extension VerifyNumber{
    
//MARK: Timmer for OTP
    func configTimer(){
        time = Constants.RESEND_OTP_TIMER
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [self] timer in
            timerLabel.isHidden = false
            if(time >= 0){
                startTimer()
            }
            else{
                stopTimer()
            }
        })
    }
    
    //MARK: it starts timers and decrement every second
    func startTimer(){
        timerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        timerLabel.text =  NSLocalizedString("Resend OTP", comment: "") + " (" + "\(time)"+"s)"
        time = time - 1
    }
    
    //MARK: it stops timer
    //. invalidates timers
    //. Ui changes
    //. resend Btn unhide
    func stopTimer(){
        timerLabel.isHidden = true
        resendBtn.isHidden = false
        resendBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        successLabel.isHidden = true
        timer!.invalidate()
        time = Constants.RESEND_OTP_TIMER
    }
    
    
}
