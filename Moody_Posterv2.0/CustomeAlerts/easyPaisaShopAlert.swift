//
//  easyPaisaShopAlert.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 03/09/2021.
//

import UIKit

class easyPaisaShopAlert: UIViewController {
    
    //MARK: Calls when view is loaded
    //. Tap gesrture is added on exit
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.exit))
        self.view.addGestureRecognizer(tap)
    }
    

    //MARK: - Dismiss Alert
    @objc func exit(sender : UITapGestureRecognizer){
        
        self.dismiss(animated: true, completion: nil)
    }

}
