//
//  AppGuideViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Mujtaba Hassan on 30/11/2021.
//

import UIKit
//MARK: This Screen shows App Walkthrough screens
class AppGuideViewController: UIViewController {

    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    
    //MARK: Variables
    var slides: [Slide] = []
    var currentPage  = 0 {
        didSet {
            if currentPage == slides.count - 1 {
                nextBtn.setTitle("Done", for: .normal)
            }else{
                nextBtn.setTitle("Skip", for: .normal)
            }
        }
    }
    //MARK: calls when first time View Loads
    //. Set slides images
    //. add pageControl target
    override func viewDidLoad() {
        super.viewDidLoad()
        setSlides()
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
    }
    
    //MARK: Pops back to setting screen
    @IBAction func skipBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: On swipe it change page
    //. chnages view, current page
    @objc func changePage(sender: AnyObject) -> () {
        let indexPath = IndexPath(item: currentPage, section: 0)
        
        currentPage += 1
        let x = CGFloat(pageControl.currentPage) * collectionView.frame.size.width
        collectionView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    @IBAction func dismissBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setSlides(){
        let screenSize: CGRect = UIScreen.main.bounds
        let width = screenSize.width
        
        //Checks screen width and sets images respectively
        if(width > 500){
            
            slides = [Slide(image: UIImage(named: "image11")!),
                      Slide(image: UIImage(named: "image22")!),
                      Slide(image: UIImage(named: "image33")!),
                      Slide(image: UIImage(named: "image44")!),
                      Slide(image: UIImage(named: "image55")!)]
        }else{
            slides = [Slide(image: UIImage(named: "image1")!),
                      Slide(image: UIImage(named: "image2")!),
                      Slide(image: UIImage(named: "image3")!),
                      Slide(image: UIImage(named: "image4")!),
                      Slide(image: UIImage(named: "image5")!)]
        }
    }
}

extension AppGuideViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: Sets up Each Slide view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppGuideCollectionViewCell", for: indexPath) as! AppGuideCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    //MARK: Slides count is set here
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    //MARK: width and height are height is set of each slide
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = UIScreen.main.bounds.size.width
        let itemHeight = UIScreen.main.bounds.size.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    //MARK: Tells the delegate that the scroll view has ended decelerating the scrolling movement.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
    
    
    
}
