//
//  MoodyTerms&Conditions.swift
//  Moody_Posterv2.0
//
//  Created by mujtaba Hassan on 06/10/2021.
//

import UIKit
import WebKit
//MARK: Class to open Terms&Condition on WenView
class MoodyTerms_Conditions: UIViewController {
    //MARK: Opens Moody website terms and conditions page on WebView 
    var webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        laodWebview()
    }
    
    
    //MARK: Loads Moody website webview 
    func laodWebview(){
        let url = URL(string: "https://moody.pk/terms-and-conditions/")
        webView = WKWebView(frame: view.bounds)
        let urlRequest = URLRequest(url: url!)
        view.addSubview(webView)
        webView.load(urlRequest)
    }
}
