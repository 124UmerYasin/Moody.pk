//
//  FareCalculationsDetails.swift
//  Moody_Posterv2.0
//
//  Created by Zaid Ahmed IoS on 22/08/2021.
//

import UIKit

class FareCalculationsDetails: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var baseFareLbl : UILabel!
    @IBOutlet weak var totalDistanceLbl : UILabel!
    @IBOutlet weak var totalTimeLbl : UILabel!
    @IBOutlet weak var perKmRate: UILabel!
    
    @IBOutlet weak var perMinRate: UILabel!
    
    

    //MARK: - Updates Fare calculation Ui
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    //MARK: Updates Fare UI
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    //MARK: Dismiss alert when tap
    @IBAction func closeDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Sets Fare calculationsDetails to labels
    func updateUI(){
        let baseFare = UserDefaults.standard.value(forKey: DefaultsKeys.basefare) as? Int
        let totalDistance = UserDefaults.standard.value(forKey: DefaultsKeys.currentTotalDistance) as? String
        let totalTime = UserDefaults.standard.value(forKey: DefaultsKeys.totalTime) as? String
        let ratePerKm = UserDefaults.standard.value(forKey: DefaultsKeys.ratePerKm) as? Double
        let ratePerMin = UserDefaults.standard.value(forKey: DefaultsKeys.ratePerMin) as? Double
       
        
        baseFareLbl.text = "\(baseFare ?? 0) Rs"
        totalDistanceLbl.text = "\(totalDistance ?? "N/A")"
        
        totalTimeLbl.text = "\(totalTime ?? "N/A")"
        perKmRate.text = "\(ratePerKm ?? 0) Rs"
        perMinRate.text = "\(ratePerMin ?? 0) Rs"

    }

}
