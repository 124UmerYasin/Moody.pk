//
//  Rating.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 02/08/2021.
//

import UIKit

class Rating: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var widthConstant: NSLayoutConstraint!
    @IBOutlet weak var fullyouterView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickStar2(_ sender: Any) {
        //print"yes")
    }
}
