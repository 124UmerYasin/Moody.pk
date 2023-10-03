//
//  ShareLocationViewController.swift
//  Moody_Posterv2.0
//
//  Created by mujtaba Hassan on 09/11/2021.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ShareLocationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var searchLocationField: UILabel!
    @IBOutlet weak var mpView: GMSMapView!
    @IBOutlet weak var shareLocationButton: UIButton!
    @IBOutlet weak var searchLocationButton: UIButton!
    
    //MARK: Varibales
    var marker = GMSMarker()
    var location = CLLocation()
    var isFromSearch : Bool = true
    static var send:Bool = false
    
    //MARK: calls when first time View Loads
    //. Set and Styles views
    //. Set delegates and map settings
    //. Setup Map view
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setDelegatesAndMapSetting()
        setMapView()
    }
    
    //MARK: On click search bar  GMSAutoComplete controller is present
    @IBAction func onClicksearchLocation(_ sender: Any) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        acController.tintColor = UIColor.black
        present(acController, animated: true, completion: nil)
    }
    
    
    //MARK: Sets views
    //. Styles seach location button
    //. Sets Navigation
    func setUpView(){
        searchLocationButton.layer.borderWidth = 1
        searchLocationButton.layer.borderColor = UIColor.lightGray.cgColor
        self.navigationItem.title = NSLocalizedString("Share Location", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.black
        tabBarController?.tabBar.removeFromSuperview()
    }
    
    //MARK: Sets Image and postion of mapview
    func setMapView(){
        let makerImage = UIImage(named: "pin")
        let markerView = UIImageView(image:makerImage)
        
        mpView.animate(toLocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        mpView.animate(toZoom: 20.0)
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mpView
        
        marker.iconView = markerView
    }
    //MARK: Set mapview delegate abd mapView Setting
    func setDelegatesAndMapSetting(){
        mpView.delegate = self
        mpView.isMyLocationEnabled = true
        mpView.settings.compassButton = true
        mpView.settings.myLocationButton = true
    }
    
    //MARK: Location is shared
    //. SendLoc Notifcation observer is post
    //. view is poped
    @IBAction func onCLickShareLocation(_ sender: Any) {
        var locDict = [String:Any]()
        locDict["loc"] = location
        ShareLocationViewController.send = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendLoc"), object: nil,userInfo: locDict)
        self.navigationController?.popViewController(animated: true)

    }
    
    //MARK: Calls when view disappers
    override func viewWillDisappear(_ animated: Bool) {
        LocationManagers.locationSharesInstance.stopLocationUpdate()
    }
    
}

extension ShareLocationViewController : GMSMapViewDelegate{

    
    //MARK: Camera change Position this methods will call every time
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
       
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        marker.position = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
        marker.appearAnimation = .pop
        CATransaction.commit()

    }
    
    //MARK: Sets marker image
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        let makerImage = UIImage(named: "dot")
        let markerView = UIImageView(image:makerImage)
        marker.iconView = markerView

    }
    
    
    //MARK: Sets location and coordinates of location to text field
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if isFromSearch {
            location = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
            searchLocationField.text = "\(position.target.latitude) , \(position.target.longitude)"
        }else{
            isFromSearch = true
        }
        let makerImage = UIImage(named: "pin")
        let markerView = UIImageView(image:makerImage)
        marker.iconView = markerView
    }
}





extension ShareLocationViewController: GMSAutocompleteViewControllerDelegate {

    //MARK: Calls to auto complete places
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        isFromSearch = false
        print("Place name: \(String(describing: place.name))")
        dismiss(animated: true, completion: nil)
        self.mpView.clear()
        searchLocationField.text = place.formattedAddress
        print(place.coordinate)
        location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        let makerImage = UIImage(named: "pin")
        let markerView = UIImageView(image:makerImage)

        let cord2D = CLLocationCoordinate2D(latitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude))
        marker.position =  cord2D
        marker.snippet = place.name
        marker.map = self.mpView
        marker.iconView = markerView
        self.mpView.camera = GMSCameraPosition.camera(withTarget: cord2D, zoom: 15)

    }

    

    //MARK: calls when fail to autocomplete
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {

        print(error.localizedDescription)

    }

    

    //MARK: Calls when cancel search
    //. dismiss AutoComplete controller
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Gets addressName from coordinates
    func getAdressName(coords: CLLocation) {

        CLGeocoder().reverseGeocodeLocation(coords) { [self] (placemark, error) in
                if error != nil {
                    print("Hay un error")
                } else {

                    let place = placemark! as [CLPlacemark]
                    if place.count > 0 {
                        let place = placemark![0]
                        var adressString : String = ""
                        if place.thoroughfare != nil {
                            adressString = adressString + place.thoroughfare! + ", "
                        }
                        if place.subThoroughfare != nil {
                            adressString = adressString + place.subThoroughfare! + "\n"
                        }
                        if place.locality != nil {
                            adressString = adressString + place.locality! + " - "
                        }
                        if place.postalCode != nil {
                            adressString = adressString + place.postalCode! + "\n"
                        }
                        if place.subAdministrativeArea != nil {
                            adressString = adressString + place.subAdministrativeArea! + " - "
                        }
                        if place.country != nil {
                            adressString = adressString + place.country!
                        }

                        searchLocationField.text = adressString

                    }
                }
            }
      }
}
