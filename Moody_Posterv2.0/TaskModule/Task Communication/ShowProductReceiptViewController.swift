//
//  ShowProductReceiptViewController.swift
//  Moody_Posterv2.0
//
//  Created by Umer Yasin on 18/01/2022.
//

import UIKit
import Lightbox

class ShowProductReceiptViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, LightboxControllerPageDelegate, LightboxControllerDismissalDelegate {
    
    @IBOutlet weak var receiptsTable: UITableView!
    @IBOutlet weak var amountField: UITextField!
    
    let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    var productReceipts = [[String:Any]()]
    var totalAmount : String?
    
    //MARK: - view didLoad
    // called when view controller initiate and set table view data sources and delegates
    // navigation bar titles.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "ProductReceiptTableViewCell", bundle: nil)
        receiptsTable.register(nib, forCellReuseIdentifier: "ProductReceiptTableViewCells")
        receiptsTable.dataSource = self
        receiptsTable.delegate = self
        self.navigationItem.leftBarButtonItems = [setBackBtn()]
        self.title = "Product Receipt"
        amountField.text = totalAmount
    }
    
    
    //MARK: - number of rows for table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productReceipts.count
    }
    
    
    //MARK: - data for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductReceiptTableViewCells",for: indexPath) as! ProductReceiptTableViewCell
        cell.imageLink = productReceipts[indexPath.row]["attachment_path"] as? String ?? "not found"
        cell.amountLabel.text = "\(productReceipts[indexPath.row]["amount"] as? Int ?? 0) Rs"
        cell.attachmentName.text = "Product Receipt \(indexPath.row + 1)"
        
        return cell
        
    }
    
    //MARK: - height for each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    //MARK: on click table view row
    // show images of receipts.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var images = [LightboxImage(image: UIImage())]
        images = [LightboxImage(imageURL: URL(string: productReceipts[indexPath.row]["attachment_path"] as? String ?? "not found")!)]
        let controller = LightboxController(images: images)
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        // Use dynamic background.
        controller.dynamicBackground = true
        // Present your controller.
        controller.hidesBottomBarWhenPushed = true
        LightboxConfig.hideStatusBar = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: BackBtn added in top NavigationBar
    func setBackBtn() -> UIBarButtonItem {
        
        backButton.setImage(UIImage(named: "blackBackButton"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(popToHome), for: .touchUpInside)
        let back = UIBarButtonItem(customView: backButton)
        
        return back
    }
    
    //MARK: Pop's back to home screen on back/close button
    @objc func popToHome(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: called when image controller is dismissed
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        print("called when view controller is dismissed")
    }
    
    //MARK: called when page is moved of light box
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.hidesBottomBarWhenPushed = true
        print("page moved")
    }
    
    
    
}
