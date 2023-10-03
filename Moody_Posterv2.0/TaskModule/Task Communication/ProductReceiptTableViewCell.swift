//
//  ProductReceiptTableViewCell.swift
//  Moody_Posterv2.0
//
//  Created by Umer Yasin on 19/01/2022.
//

import UIKit

class ProductReceiptTableViewCell: UITableViewCell {

    @IBOutlet weak var fullyOuterView: UIView!
    @IBOutlet weak var attachmentName: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    var imageLink:String?
    
    
    //MARK: called when this xib view is initialized.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullyOuterView.layer.borderWidth = 1
        fullyOuterView.layer.borderColor = UIColor(named: "Green")?.cgColor
        fullyOuterView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
