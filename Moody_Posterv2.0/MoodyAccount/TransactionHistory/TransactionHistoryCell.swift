//
//  TransactionHistoryCell.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import UIKit


class TransactionHistoryCell: UITableViewCell {

    //MARK: Variables for Transaction History cell labels
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var paymentMethodLable: UILabel!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var recivedBtn: UIButton!
    
    @IBOutlet weak var promoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
