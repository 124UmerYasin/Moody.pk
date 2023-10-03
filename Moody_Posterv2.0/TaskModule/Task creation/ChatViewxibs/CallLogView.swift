//
//  CallLogView.swift
//  Moody_Posterv2.0
//
//  Created by Muhammad Mobeen Rana on 07/10/2021.
//

import UIKit

class CallLogView: UITableViewCell {

    //MARK: - IBOulets
    @IBOutlet weak var callLogImage: UIView!
    @IBOutlet weak var callLogLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    
    //MARK: - Properties
    static var identifier : String {return String(describing: self)}
    static var nib : UINib {return UINib(nibName: identifier, bundle: nil)}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
