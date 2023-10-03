//
//  ReferenceIdView.swift
//  Moody_Posterv2.0
//
//  Created by mujtaba Hassan on 11/08/2021.
//

import UIKit

class ReferenceIdView: UITableViewCell {
    @IBOutlet weak var taskIdLabel: UILabel!
    @IBOutlet weak var taskId: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var copyImgeView: UIImageView!
    @IBOutlet weak var fullyOutterView: UIView!
    
    
    //MARK: called when this view is initialized.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        fullyOutterView.roundCorners(corners: [.bottomRight, .topRight, .bottomLeft, .topLeft], radius: 4)
        fullyOutterView.layer.borderWidth = 2
        fullyOutterView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        
        if(UserDefaults.standard.string(forKey: DefaultsKeys.referenceId) != nil){
            
            taskId.text = UserDefaults.standard.string(forKey: DefaultsKeys.referenceId)!
        }else{
            
            taskId.text = "N/A"
        }
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
