//
//  EstimateFare.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 06/08/2021.
//

import UIKit

class EstimateFare: UITableViewCell {

    //MARK: Outlets 
    @IBOutlet weak var fullyOuterView: UIView!
    @IBOutlet weak var estimateLabel: UILabel!
    @IBOutlet weak var moneyImage: UIImageView!
    
    var btnImage:UIImage!

    //MARK: Calls when xib file get awake
    //. Sets view and value to extimate fare value 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullyOuterView.roundCorners(corners: [.topRight,.bottomLeft,.bottomRight], radius: 10)
        let fare = UserDefaults.standard.double(forKey: DefaultsKeys.estimateFare)
        //estimateLabel.semanticContentAttribute = .forceLeftToRight
        estimateLabel.text = NSLocalizedString("Estimated Fare:", comment: "") + " \(fare)"
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
