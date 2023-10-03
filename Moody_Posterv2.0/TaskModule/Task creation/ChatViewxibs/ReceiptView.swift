//
//  ReceiptView.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 02/08/2021.
//

import UIKit

class ReceiptView: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var fullyOuterView: UIView!
    @IBOutlet weak var baseFare: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    @IBOutlet weak var perMinRate: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var perKmRate: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var discountStringLabel: UILabel!
    @IBOutlet weak var purchasingView: UIView!
    @IBOutlet weak var receiptViewHeight: NSLayoutConstraint!
    @IBOutlet weak var payableAmount: UILabel!
    
    //MARK: Variables
    let width:CGFloat = UIScreen.main.bounds.width - 50
    let height:CGFloat = 24
    var yPosition:CGFloat = 0
    
    //MARK: Calls when xib file get awake
    //. set receipt view label values
    //. set product list view
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setValues()
        setProductListView()
    }
    
    //MARK: Sets ProductList view
    //. Checks if task has productlusr
    //. Constriants are set of receipt with product list 
    func setProductListView(){
        if(UserDefaults.standard.dictionary(forKey: DefaultsKeys.shoppingDetails) != nil){
            var tags = 1
            let label = UILabel(frame: CGRect(x: 4, y: 0, width: fullyOuterView.layer.frame.width - 24, height: 24))
            label.text = "Purchased Product Receipt"
            label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            label.textColor = UIColor(named: "ButtonColor")!
            purchasingView.addSubview(label)
            yPosition += 24
            
            let prodDetails = UserDefaults.standard.dictionary(forKey: DefaultsKeys.shoppingDetails)!
            let proofs = prodDetails["proofs"] as! [[String:Any]]
            print(prodDetails)
            
            if(proofs.count > 0){
                for prof in proofs {
                    let label1 = UILabel()
                    label1.text = "Attachment"
                    label1.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                    label1.textColor = UIColor.black
                    label1.textAlignment = .left
                    
                    let label2 = UILabel()
                    label2.text = "\(prof["amount"] as! Int)"
                    label2.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                    label2.textColor = UIColor.black
                    label2.textAlignment = .right
                    
                    let stack = UIStackView(frame: CGRect(x: 4, y: yPosition, width: fullyOuterView.layer.frame.width - 24, height: 36))
                    stack.alignment = .fill
                    stack.distribution = .fill
                    stack.axis = .horizontal
                    stack.addArrangedSubview(label1)
                    stack.addArrangedSubview(label2)
                    stack.tag = tags
                    tags += tags
                    purchasingView.addSubview(stack)
                    yPosition += 24
                    
                }
                yPosition += 8
                let separatorView = UIView(frame: CGRect(x: 8, y: yPosition, width: fullyOuterView.layer.frame.width - 32, height: 1))
                separatorView.backgroundColor = UIColor(named: "FadeBlue")!
                purchasingView.addSubview(separatorView)
                
                let label1 = UILabel()
                label1.text = "Total Product Price"
                label1.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                label1.textColor = UIColor.black
                label1.textAlignment = .left
                
                let label2 = UILabel()
                label2.text = "\(prodDetails["total_amount"] as! Int)"
                label2.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                label2.textColor = UIColor.black
                label2.textAlignment = .right
                
                let stack = UIStackView(frame: CGRect(x: 4, y: yPosition, width: fullyOuterView.layer.frame.width - 24, height: 36))
                stack.alignment = .fill
                stack.distribution = .fill
                stack.axis = .horizontal
                stack.addArrangedSubview(label1)
                stack.addArrangedSubview(label2)
                purchasingView.addSubview(stack)
            }
            receiptViewHeight.constant = CGFloat((proofs.count * 24 ) + 72)
        }else{
            receiptViewHeight.constant = 0
        }
    }
    
    //MARK: Sets values of receipt to labels
    //. fetch values from defaults and sets to receipts labels
    func setValues(){
        print("i am called receipt view")
        let bf = UserDefaults.standard.integer(forKey: DefaultsKeys.baseFare)
        let tt = UserDefaults.standard.string(forKey: DefaultsKeys.timeTaken) ?? "N/A"
        let pm = UserDefaults.standard.double(forKey: DefaultsKeys.perMinuteRate)
        let tm = UserDefaults.standard.integer(forKey: DefaultsKeys.totalAmountPaid)
        let km = UserDefaults.standard.integer(forKey: DefaultsKeys.ratePerKm)
        let td = UserDefaults.standard.string(forKey: DefaultsKeys.totalDistance) ?? "0.0"
        
        let fareAfterDiscount = UserDefaults.standard.integer(forKey: DefaultsKeys.fareAfterDiscount)
        
        let disc = UserDefaults.standard.string(forKey: DefaultsKeys.totalDiscount) ?? "0"

        let payable = UserDefaults.standard.integer(forKey: DefaultsKeys.payableAmounts)

        
        baseFare.text = "Rs: \(bf)"
        timeTaken.text = "\(tt)"
        perMinRate.text = "Rs: \(pm)"
        totalDistance.text = "\(td) km"
        perKmRate.text = "Rs: \(km)"
        
        if(fareAfterDiscount != tm){
           
            discount.text = "\(disc)"
            totalAmount.text = "Rs: \(tm)"
            payableAmount.text = "Rs: \(payable)"
        }else{
            discount.isHidden = true
            discountStringLabel.isHidden = true
            totalAmount.text = "Rs: \(tm)"
            payableAmount.text = "Rs: \(payable)"

        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
