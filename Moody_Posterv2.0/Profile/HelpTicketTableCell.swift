//
//  HelpTicketTableCell.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 06/09/2021.
//

import UIKit

class HelpTicketTableCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var ticketLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ticketNumber: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var unreadMsgsTagLbl: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageDescription: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    //MARK: - Properties
    static var identifier : String { return String(describing: self)
    }
    static var nib : UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeLabelBordersRound(yourLabel: unreadMsgsTagLbl)
        unreadMsgsTagLbl.isHidden = true
        giveShadowToView(view: mainView)
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
        ticketLabel.text = NSLocalizedString("Ticket #", comment: "")
        statusLabel.text = NSLocalizedString("Status", comment: "")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    //MARK: - IBActions
    @IBAction func StatusButtonOnClick(_ sender: Any) {
    }
    
    //MARK: - Generic function to style to Labels
    func makeLabelBordersRound(yourLabel:UILabel)
    {
        yourLabel.layer.cornerRadius = 10.0
        yourLabel.layer.masksToBounds = true
        yourLabel.layer.borderColor = UIColor.red.cgColor
        yourLabel.layer.borderWidth = 1.0
    }
    
    //MARK: - Generic function to style to Views
    func giveShadowToView(view : UIView){
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
