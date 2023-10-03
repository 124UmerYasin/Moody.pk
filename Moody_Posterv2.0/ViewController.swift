//
//  ViewController.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import UIKit
import FLAnimatedImage
class ViewController: UIViewController {
  

    //MARK: -Variables
    var image: FLAnimatedImage? = nil
    let imageView = FLAnimatedImageView()
    
    //MARK: -IBOutlets
    @IBOutlet weak var engBoolImg: UIImageView!
    @IBOutlet weak var urduBoolImg: UIImageView!
    @IBOutlet weak var langaugeSelectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.white
        
        setupNavigationBar()
        if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
            engLngSet()
        }
        
        firstScreenSetup()
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        imageView.removeFromSuperview()
    }
    
    //MARK: Launch Screen GiF is loaded from FLAnimatedImage Library
    func loadGifFromFLLibray(){
        if let url = Bundle.main.url(forResource: "moody-300", withExtension: "gif")
        {
            do {
                let myData = try Data(contentsOf: url)
                image = FLAnimatedImage(gifData: myData)
                imageView.contentMode = .scaleAspectFit
                imageView.animatedImage = image
                imageView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
                view.addSubview(imageView)
            } catch {
            }
        }
    }
    
    //MARK: Check to shows splash only when app loads.
    func checkSplash(){
        if DefaultsKeys.splashCheck == false {
            loadGifFromFLLibray()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [self] in
                navigateToNextScreen("Main" , "RegisterNumber")
         }
         DefaultsKeys.splashCheck = true
     }
}
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(named: "AccentColor")
        navigationController?.isNavigationBarHidden = true
        firstScreenSetup()
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: langaugeSelectionLabel, text: langaugeSelectionLabel.text ?? "Found Nothing in screenText", lineSpacing: 15)
            langaugeSelectionLabel.textAlignment = .left
        }
        
    }
    
    //MARK: English lng is set on Launch of application
    func engLngSet(){
        Bundle.setLanguage("Base")
        UserDefaults.standard.setValue("Base", forKey: "language")
    }
}

extension ViewController{
    //MARK: SetupScreen if user is alreday loggedIn it Navigates to HomeScreen if not it shows splash
    func firstScreenSetup(){
        if UserDefaults.standard.string(forKey: DefaultsKeys.token) != nil{
            setTabBar()
        }else{
            checkSplash()
        }
        
        
    }
}
