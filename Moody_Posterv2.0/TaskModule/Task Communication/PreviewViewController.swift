//
//  PreviewViewController.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import UIKit
import AVKit

//MARK: PreviewContoller is used to show full image.
//. It is open after tapping on Image and PrviewController is inisitated

class PreviewViewController: UIViewController {

    
    @IBOutlet weak var img: UIImageView!
    
    var imageData: Data!
    var url: URL!
    var localImage:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        if (localImage){
            img.image = UIImage(data: imageData)
        }else{
            do{
                imageData = try Data(contentsOf: url)
                img.image = UIImage(data: imageData)
            }catch{
                DispatchQueue.main.async {
                    self.showToast(message: NSLocalizedString("Cannot open image.", comment: ""), font: UIFont.boldSystemFont(ofSize: 13))
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        img.image = nil
        url = nil
        localImage = false
        imageData = nil
    }
}
