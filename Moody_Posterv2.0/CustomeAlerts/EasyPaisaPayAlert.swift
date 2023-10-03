//
//  EasyPaisaPayAlert.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 03/09/2021.
//

import UIKit

class EasyPaisaPayAlert: UIViewController {

    
    //MARK: - Outlets
    @IBOutlet weak var easypaisaAlertLabel: UILabel!
    @IBOutlet weak var depositAmount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Closes Alert
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Calls when view appears
    //. Styles and sets UI on check lng check 
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: depositAmount, text: depositAmount.text ?? "Found Nothing in depositAmount", lineSpacing: 2)
            
            setTextWithLineSpacing(label: easypaisaAlertLabel, text: easypaisaAlertLabel.text ?? "found nothing in easypaisaAlertLabel ", lineSpacing: 6)
            easypaisaAlertLabel.textAlignment = .center
        }
    }
    
}
