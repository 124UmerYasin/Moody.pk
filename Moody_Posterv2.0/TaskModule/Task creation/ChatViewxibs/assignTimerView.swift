//
//  assignTimerView.swift
//  Moody_Posterv2.0
//
//  Created by Faran Shaukat on 04/10/2021.
//

import UIKit

protocol stopTimerP{
    func stopTimer()
}

class assignTimerView: UITableViewCell,stopTimerP {
   
    
    
    @IBOutlet weak var TimerCountDownLabel: UILabel!
    
    @IBOutlet weak var FindingTaskerLabel: UILabel!
    
    @IBOutlet weak var arrivingWithinLabel: UILabel!
    
    @IBOutlet weak var clockImage: UIImageView!
    
    var milliseconds:Int = 0
    var seconds:Int = 0
    var minutes:Int = 0
    var hours:Int = 0
    var timer:Timer!
    
    //MARK:  called when this view is initialized.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let time = UserDefaults.standard.integer(forKey: DefaultsKeys.arrivalTimeDuration)
        ChatViewController.stopTimer = self
        milliseconds = time
        seconds = (milliseconds / 1000) % 60
        minutes = (milliseconds / 1000) / 60
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)

    }

    //MARK:  @objc timer function
    @objc func update() {
        if(seconds<10){
            if(minutes < 10){
                TimerCountDownLabel.text = "0\(minutes):0\(seconds)"

            }else{
                TimerCountDownLabel.text = "\(minutes):0\(seconds)"
            }

        }else{
            if(minutes < 10){
                TimerCountDownLabel.text = "0\(minutes):\(seconds)"

            }else{
                TimerCountDownLabel.text = "\(minutes):\(seconds)"
            }

        }
        seconds = seconds - 1
        if(minutes <= 0 && seconds <= 0){
            timer.invalidate()
            timer = nil
            TimerCountDownLabel.text = "--:--"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeTimerView"), object: nil, userInfo: nil)

        }
        if(seconds < 0 ){
            minutes = minutes - 1
            seconds = 59
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func stopTimer() {
        if(timer != nil){
            timer.invalidate()
            timer = nil
            TimerCountDownLabel.text = "--:--"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeTimerView"), object: nil, userInfo: nil)

        }else{
            timer?.invalidate()
            timer = nil
            TimerCountDownLabel.text = "--:--"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeTimerView"), object: nil, userInfo: nil)

        }
    }
}
