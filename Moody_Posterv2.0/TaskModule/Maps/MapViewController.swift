//
//  MapViewController.swift
//  Moody_IOS
//

import Foundation
import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var timeView: UIView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet weak var lastUpdatedTime: UILabel!
    
    //MARK: Camera Variables
    var camera = GMSCameraPosition()
    var mapView = GMSMapView()
    let marker = GMSMarker()
    let path = GMSMutablePath()
    
    
    var isFirst:Bool = true
    var previousCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
     let markerView = UIImageView(image: UIImage(named: "tasker_location"))
    var rotation:Double = 0.0
    
    //MARK: Pickup Lat Long
    var pickupLong:Double = 0.0
    var pickupLat:Double = 0.0
    var updatedTime = " -- : -- "
    
    var taskerLocationTimer: Timer?
    
    weak var task: URLSessionDownloadTask?
    var backgroundSessionCompletionHandler: (() -> Void)?
    lazy var downloadsSession: URLSession = { [weak self] in
        let configuration = URLSessionConfiguration.background(withIdentifier:"\(UIDevice.current.identifierForVendor!.uuidString)\(NSDate())")
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity
        return Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    
    //MARK: calls when first time View Loads
    //. Setup Views
    //. Add Markers
    //. set pickup/dropoff locations
    //. set Map camera postions
    //. Update location timer updates
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewBorder()
        setLastUpdatedTimeLabel()
        registerNotification()
        setNaviagtionItem()
        setMapFocusPoint()
        addMarker(longitude: UserDefaults.standard.double(forKey: DefaultsKeys.tasker_location_longitude), latitude: UserDefaults.standard.double(forKey: DefaultsKeys.tasker_location_latitude))
        addPickupLocation(longitude: UserDefaults.standard.double(forKey: DefaultsKeys.pickup_location_longitude), latitude: UserDefaults.standard.double(forKey: DefaultsKeys.pickup_location_latitude))
        setDropOffLocation()
        startTaskerLocationUpdateTimer()
        
    }
    
    //MARK: Calls just before view appears
    //. Hides Tabbar
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: Calls when view disappers
    //. invalidates tasker location timer
    override func viewDidDisappear(_ animated: Bool) {
        taskerLocationTimer?.invalidate()
    
    }
    
    //MARK: Sets DropOffLocation Coordinates
    //. Fetch coordinates from user defaults
    //. split coordinates to lat long
    //. set Drop location 
    func setDropOffLocation(){
        if(UserDefaults.standard.string(forKey: DefaultsKeys.dropOffLocation) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.dropOffLocation) != ""){
            
            let dropOff:String = UserDefaults.standard.string(forKey: DefaultsKeys.dropOffLocation)!
            let latLong = dropOff.split(separator: ",")
            let dropOffLatitude = Double(latLong[0])!
            let dropOffLongitude = Double(latLong[1].split(separator: " ")[0])!
            addDropLocation(longitude: dropOffLongitude, latitude: dropOffLatitude)
            
        }
    }
    
    //MARK: Sets NavigationBar styling
    func setNaviagtionItem(){
        self.navigationItem.backButtonTitle = " "
        self.navigationItem.title = "Tasker Location"
        self.navigationController?.navigationBar.tintColor = .black
    }
    //MARK: Registers Notification Observers
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTaskerLocation(_:)), name: NSNotification.Name(rawValue: "onLocationUpdate"), object: nil)
    }


    //MARK: Update Tasker location on emit received
    @objc func updateTaskerLocation(_ notification:NSNotification){
        let data = notification.userInfo as! [String:Any]
        print("DATA FROM LOCATION IMIT : \(data)" )
        var coordinate = [String]()
        guard let time = data["last_location_time"] as? String else {return}
        updatedTime  = time
        setLastUpdatedTimeLabel()
        data["location_logs"] as? [String] != nil ? coordinate = data["location_logs"] as! [String] : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: "update tasker location / onLocationUpdate", Key: "location_logs")
        updateTaskerLocation(coordinate: coordinate)
    
    }
//MARK: Sets Focus point to tasker current location 
    func setMapFocusPoint(){
        
        camera = GMSCameraPosition.camera(withLatitude: UserDefaults.standard.double(forKey: DefaultsKeys.tasker_location_latitude), longitude: UserDefaults.standard.double(forKey: DefaultsKeys.tasker_location_longitude), zoom: 15.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        self.mapView.addSubview(timeView)
        
    }
    
    func setupViewBorder(){
        self.timeView.layer.cornerRadius = 22
        self.timeView.layer.borderWidth = 1
        self.timeView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        
    }

//MARK: Timer to update tasker location
    func startTaskerLocationUpdateTimer(){
        guard taskerLocationTimer == nil else { return }
        taskerLocationTimer =  Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCurrentTaskerLocation), userInfo: nil, repeats: true)
    }
    

    //MARK: Update Tasker location with api when socket not connected
    @objc func updateCurrentTaskerLocation(){
        if(SocketsManager.sharesInstance.socket.status != .connected){
            getTaskLocationsAPICall()
        }
    }
    
    //MARK: Updates time when location gets updated
    func setLastUpdatedTimeLabel(){
        lastUpdatedTime.text = updatedTime
    }
    
    
    //MARK: Tasker location marker
    func addMarker(longitude: Double, latitude: Double){
        setMarkerPosition(longitude: longitude, latitude: latitude, rotation: 0.0)
    }

    //MARK: Sets tasker location updated postions
     func setMarkerPosition(longitude: Double, latitude: Double, rotation: Double){
        //mapView.animate(toLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = NSLocalizedString("Tasker", comment: "")
        marker.iconView = markerView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.rotation = rotation
        marker.map = mapView
        
    }
    
    //MARK: Set tasker pickup location
    func addPickupLocation(longitude: Double, latitude: Double){
        let pickupMarker = GMSMarker()
        let markerView = UIImageView(image: UIImage(named: "PickupLocation"))
        pickupMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        pickupMarker.title = NSLocalizedString("Pickup Location", comment: "")
        pickupMarker.iconView = markerView
        pickupMarker.map = mapView
        
    }
    
    //MARK: Set tasker dropoff locatiomn
    func addDropLocation(longitude: Double, latitude: Double){
        let long = longitude + 0.00001
        
        let dropOffMarker = GMSMarker()
        let dropOffView = UIImageView(image: UIImage(named: "DropoffLocation"))
        dropOffMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: long)
        dropOffMarker.title = NSLocalizedString("Dropoff Location", comment: "")
        dropOffMarker.iconView = dropOffView
        dropOffMarker.map = mapView
        
    }
    
    //MARK: API call to get Tasker updated location
    func getTaskLocationsAPICall(){
        
        var dictionary = [String:Any]()
        dictionary["task_id"] = UserDefaults.standard.string(forKey: DefaultsKeys.taskId)
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        let req = setRequestHeader(hasBodyData: true, hasToken: true, endpoint: ENDPOINTS.getLocationLogs, httpMethod: "POST",dictionary: dictionary ,token: UserDefaults.standard.string(forKey: DefaultsKeys.token))
        task = downloadsSession.downloadTask(with: req)
        task?.resume()
    }
    
    //MARK: get coordinates of tasker and update marker postion
    func updateTaskerLocation(coordinate: [String]){
    
            let coord = coordinate.last
            let latLong = coord!.split(separator: ",")
            let latitude: Double = Double(latLong[0])!
            let longitude: Double = Double(latLong[1].split(separator: " ")[0])!
            setMarkerPosition(longitude: longitude, latitude:latitude , rotation: 0.0)
    
        }
    
    
     //MARK: get distance b/t to updated locations
     func getDistanceBetweenLocations(latitude: Double, longitude: Double) -> Double {
        
        let coordinate0 = CLLocation(latitude: previousCoordinate.latitude, longitude: previousCoordinate.longitude)
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        return distanceInMeters
        
    }
    
    static func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    static func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    static func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
}


//MARK: call api in background for location logs.
extension MapViewController : URLSessionDelegate,URLSessionDownloadDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            if let completionHandler = backgroundSessionCompletionHandler {
                backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
                                //MARK: URL Session Api calling Delegates
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      if error?.localizedDescription == "The request timed out." {
          DispatchQueue.main.async {
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_location_logs", response: "\(String(describing: error?.localizedDescription))", body: [:])
          }
      }

    }
    private func URLSession(session: URLSession, didBecomeInvalidWithError error: NSError?) {
        whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_location_logs", response: "\(String(describing: error?.localizedDescription))", body: [:])


      }

    
    //MARK: URL Session call of display_location_logs Api
    //. Searlized JSON response
    //. Store response in Local file directory
    //. updates tasker location
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let statusCode = Int((downloadTask.response as? HTTPURLResponse)?.statusCode ?? 0)
            let responseJSON:[String:Any]
            do{
                responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                if(statusCode == STATUSCODES.SUCCESSFULL.rawValue || statusCode == STATUSCODES.CREATED_SUCCESSFULLY.rawValue){
                    let response:[String:Any] = responseJSON["data"] as! [String : Any]
                    print("MAP: \(response)")
                    var logs = [String]()
                    DispatchQueue.main.async { [self] in
                        response["location_logs"] as? [String] != nil ? logs = response["location_logs"] as! [String] : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getLocationLogs, Key: "location_logs")
                        
                        let pickupCoordinates = response["pickup_location"] as! String
                        let pickupLatLong = pickupCoordinates.split(separator: ",")
                        let pickupTaskerLat = Double(pickupLatLong[0])!
                        let pickupTaskerLong = Double(pickupLatLong[1].split(separator: " ")[0])!
                        updatedTime = response["last_location_time"] as! String
                        setLastUpdatedTimeLabel()
                        //  let pickupTaskerLong = Double(pickupLatLong[1])!
                        
                        UserDefaults.standard.setValue(pickupTaskerLat, forKey: (DefaultsKeys.pickup_location_latitude))
                        UserDefaults.standard.setValue(pickupTaskerLong, forKey: (DefaultsKeys.pickup_location_longitude))
                        
                        let taskerCoordinates = response["tasker_coordinates"] as! String
                        let taskerLatLong = taskerCoordinates.split(separator: ",")
                        let taskerLat = Double(taskerLatLong[0])!
                        let taskerLong = Double(taskerLatLong[1].split(separator: " ")[0])!
                        // let taskerLong = Double(taskerLatLong[1])!
                        
                        UserDefaults.standard.setValue(taskerLong, forKey: (DefaultsKeys.tasker_location_longitude))
                        UserDefaults.standard.setValue(taskerLat, forKey: (DefaultsKeys.tasker_location_latitude))
                        if !(logs.isEmpty) {
                            //printlogs as Any)
                            updateTaskerLocation(coordinate: logs)
                        }else{
                            whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.getLocationLogs, Key: "location_logs")
                        }
                    }
                    
                }else{
                    whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_location_logs", response: "\(responseJSON)", body: [:])

                }
            }catch{
                whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_location_logs", response: "error occur while parsing response", body: [:])

            }
        }catch {
            whistleWebhook.sharedInstance.APIFaliureWebhooks(Endpoint: "get_location_logs", response: "Json error\(error.localizedDescription)", body: [:])

            print("Json error\(error.localizedDescription)")
        }
    }
    
    
    
    //MARK: Create Request header for display location log network call
    func setRequestHeader(hasBodyData: Bool, hasToken: Bool, endpoint: String, httpMethod: String, dictionary: [String:Any]? = nil, token: String? = nil) -> URLRequest {
        
        URLCache.shared.removeAllCachedResponses()
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(Strings.APPLICATION_JSON, forHTTPHeaderField: Strings.CONTENT_TYPE)
        
        if hasToken{
            request.setValue(token ?? "", forHTTPHeaderField: "token")
        }
        if hasBodyData{
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary as Any, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        return request
    }
}
