//
//  ViewController.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/29/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView
import CoreLocation
import Firebase

class ViewController: UIViewController, Alertable {
    
    
    @IBOutlet weak var actionButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerMapButtonOutlet: UIButton!
    @IBOutlet weak var destTextFieldOutlet: UITextField!
    @IBOutlet weak var destinationCircleOutlet: CircleView!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    
    var delegate:CenterVCDelegate?
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    var tableView = UITableView()
    var matchingItems:[MKMapItem] = [MKMapItem]()
    var currentUserId = Auth.auth().currentUser?.uid
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .white)
    var selectedItemPlacemark:MKPlacemark? = nil
    var route:MKRoute!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        checkLocationServices()
        setupAndStartSplashAnimation()
        mapView.delegate = self
        destTextFieldOutlet.delegate = self
        
        DataService.instance.REF_DRIVERS.observe(.value, with: { (snapshot) in
            self.loadDriverAnnotationsFromFB()
        })
       
        UpdateService.instance.observeTrips { (tripDict) in
            
            if let tripDict = tripDict {
                let pickUpCoordinateArray = tripDict["pickUpCoordinate"] as! NSArray
                let tripKey = tripDict["passengerKey"] as! String
                let acceptanceStatus = tripDict["tripAccepted"] as! Bool
                
                if acceptanceStatus == false {
                    DataService.instance.driverIsAvailable(key: self.currentUserId!) { (available) in
                        if let available = available {
                            if available == true {
                                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                let pickUpVC = storyboard.instantiateViewController(identifier: "PickUpVC") as? PickUpVC
                                pickUpVC?.initData(coordinate: CLLocationCoordinate2D(latitude: pickUpCoordinateArray[0] as! CLLocationDegrees, longitude: pickUpCoordinateArray[1] as! CLLocationDegrees), passengerKey: tripKey)
                                
                                pickUpVC?.pickupVCDelegate = self
                                self.present(pickUpVC!, animated: true, completion: nil)
                            }
                        }
                    }
                }
                
            }
            
        }
        
        
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataService.instance.driverIsAvailable(key: self.currentUserId!, handler: { (status) in
            if !status! {
                DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
                    if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                        for trip in tripSnapshot {
                            if trip.childSnapshot(forPath: "driverKey").value as? String == self.currentUserId {
                                let pickUpCoordinateArray = trip.childSnapshot(forPath: "pickUpCoordinate").value as! NSArray
                                let pickUpCoordinate = CLLocationCoordinate2D(latitude: pickUpCoordinateArray[0] as! CLLocationDegrees, longitude: pickUpCoordinateArray[1] as! CLLocationDegrees)
                                
                                let pickUpPlaceMark = MKPlacemark(coordinate: pickUpCoordinate)
                                self.dropPinFor(placemark: pickUpPlaceMark)
                                self.searchMapKitForResultsWithPolyline(originMapItem: nil, destinationMapItem: MKMapItem(placemark: pickUpPlaceMark))
                            }
                        }
                    }
                })
            }
        })
        
        DataService.instance.REF_TRIPS.observe(.childRemoved, with: { (removedTripSnapshot) in
            
            let removedTripDict = removedTripSnapshot.value as? [String:AnyObject]
            
            if let removedDriverKey = removedTripDict!["driverKey"] as? String {
                DataService.instance.REF_DRIVERS.child(removedDriverKey).updateChildValues(["driverIsOnTrip": false])
            }
            
            DataService.instance.userIsDriver(userKey: self.currentUserId!, handler: { (isDriver) in
                if isDriver {
                    // Remove overlays and annotations
                    self.removeOverlaysAndAnnotations(forDriver: false, forPassengers: true)
                } else {
//                    self.cancelButtonOutlet.fadeTo(alphaValue: 0.0, withDuration: 0.2)

                    self.requestRideButtonLayout(r: 255, g: 255, b: 255, text: "REQUEST RIDE")
                    self.destTextFieldOutlet.isUserInteractionEnabled = true
                    self.destTextFieldOutlet.text = ""
                    
                    self.removeOverlaysAndAnnotations(forDriver: false, forPassengers: true)
                    self.centerMapOnUserLocation()
                    
                }
            })
            
        })
        
        
    }
    
    
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        DataService.instance.driverIsOnTrip(key: self.currentUserId!, handler: { (status, driverKey, tripKey) in
            if status! {
                UpdateService.instance.cancelTrip(passengerKey: tripKey!, driverKey: driverKey!)
            }
        })
        DataService.instance.passengerIsOnTrip(passengerKey: self.currentUserId!, handler: { (status, driverKey, tripKey) in
            if status! {
                UpdateService.instance.cancelTrip(passengerKey: self.currentUserId!, driverKey: driverKey!)
            } else {
                UpdateService.instance.cancelTrip(passengerKey: self.currentUserId!, driverKey: nil)
            }
        })
    }
    

    @IBAction func actionButtonWasPressed(_ sender: Any) {
        UpdateService.instance.updateTripsWithCoordinatesUponRequest()


        self.requestRideButtonLayout(r: 255, g: 32, b: 68, text: "PLEASE WAIT.")
        
        
        self.view.endEditing(true)
        destTextFieldOutlet.isUserInteractionEnabled = false
//        self.cancelButtonOutlet.fadeTo(alphaValue: 1.0, withDuration: 0.2)
        
    }
    
    @IBAction func menuButtonPressedAction(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func centerButtonAction(_ sender: Any) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == self.currentUserId {
                        if user.hasChild("tripCoordinate") {
                            self.zoom(mapView: self.mapView)
                            self.centerMapButtonOutlet.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        } else {
                            self.centerMapOnUserLocation()
                            self.centerMapButtonOutlet.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        }
                    }
                }
            }
        })
    }
    
    
    
}


// MARK:- UILayout for Views
extension ViewController {
    
    
    
    
    
    func requestRideButtonLayout(r:CGFloat, g:CGFloat, b:CGFloat, text:String) {
        self.actionButtonOutlet.setTitleColor(UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0), for: .normal)
        self.actionButtonOutlet.setTitle(text, for: .normal)
    }
    
}



// MARK:- The PickUpVCDelegate functionality
extension ViewController:PickupVCDelegate {
    
    func pickupViewController(controller: PickUpVC, itemForPolyline item: MKMapItem?) {
        self.shouldPresentLoadingView(status: true)
        self.searchMapKitForResultsWithPolyline(originMapItem: nil, destinationMapItem: item!)
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}


// MARK:- This is where the locationmanger functionality is located
extension ViewController: CLLocationManagerDelegate {
    

    
    func loadDriverAnnotationsFromFB() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Could not retrieve a driver snapshot.")
                return
            }
                for driver in driverSnapshot {
                    
                    
                    guard driver.hasChild("coordinate") else {
                        print("The driver doesn't have a coordinate", driver.childSnapshot(forPath: "email").value as? String)
                        return
                    }
                    
                        if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {

                            if let driverDict = driver.value as? Dictionary<String, AnyObject> {
                                let coordinateArray = driverDict["coordinate"] as! NSArray
                                let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                let annotation = DriverAnnotation(coordinate: driverCoordinate, key: driver.key)
                                
                                var driverIsVisable:Bool {
                                    return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                        if let driverAnnotation = annotation as? DriverAnnotation {
                                            if driverAnnotation.key == driver.key {
                                                
                                                driverAnnotation.updateAnnotationPosition(annotation: driverAnnotation, coordinate: driverCoordinate)
                                                return true
                                            }
                                        }
                                        return false
                                    })
                                }
                                
                                if !driverIsVisable {
                                    self.mapView.addAnnotation(annotation)
                                }
                                
                            }
                        } else {
                            
                            for annotation in self.mapView.annotations {
                                if annotation.isKind(of: DriverAnnotation.self) {
                                    if let annotation = annotation as? DriverAnnotation {
                                        if annotation.key == driver.key {
                                            self.mapView.removeAnnotation(annotation)
                                        }
                                    }
                                }
                            }
                            
                        }
                }
        })
    }
    
    
    
    func checkLocationServices() {
        
        if (CLLocationManager.locationServicesEnabled()) {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            print("Location services aren't enabled.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {

            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Show alert letting kids know that they are not allowed to access the location.")
        }
    }
    

   
    
    
}
// MARK:- Mapview delegate functionality
extension ViewController:MKMapViewDelegate {
    
    func removeOverlaysAndAnnotations(forDriver:Bool?, forPassengers:Bool?) {
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
            
            if let _ = forPassengers {
                if let annotation = annotation as? PassengerAnnotation {
                    mapView.removeAnnotation(annotation)
                }
            }
            
            if let _ = forDriver {
                if let annotation = annotation as? DriverAnnotation {
                    mapView.removeAnnotation(annotation)
                }
            }
            
            for overlay in mapView.overlays {
                if overlay is MKPolyline {
                    mapView.removeOverlay(overlay)
                }
            }
        }
        
       
    }
    
    func centerMapOnUserLocation() {
        if let location = self.locationManager.location?.coordinate {
            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
        }
        
    }
    
    func removeRoutesFromMap() {
        DispatchQueue.main.async {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
    
    func zoom(mapView:MKMapView) {
        guard mapView.annotations.count != 0 else {
            print("There are no annotations.")
            return
        }
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self) {
            
            
        
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
            
        }
        

        var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0))
        
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: self.route.polyline)
        lineRenderer.strokeColor = UIColor(red: 3/255, green: 115/255, blue: 140/255, alpha: 1.0)
        lineRenderer.lineWidth = 3
        lineRenderer.lineJoin = .round
        lineRenderer.lineCap = .butt
        
        shouldPresentLoadingView(status: false)
        
        zoom(mapView: self.mapView)
        return lineRenderer
    }
    
    func searchMapKitForResultsWithPolyline(originMapItem:MKMapItem?, destinationMapItem:MKMapItem) {
        let request = MKDirections.Request()
        if let originMapItem = originMapItem {
            request.source = originMapItem
        } else {
            request.source = MKMapItem.forCurrentLocation()
        }
        request.destination = destinationMapItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard error == nil else {
                print("There was an error:", error?.localizedDescription)
                return
            }
            guard let _ = response else {
                print("There was no response")
                return
            }
            
            self.route = response?.routes[0]
            self.mapView.addOverlay(self.route.polyline)
            self.shouldPresentLoadingView(status: false)
        }
    }
    
    
    func dropPinFor(placemark: MKPlacemark) {
        selectedItemPlacemark = placemark
        
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
    
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destTextFieldOutlet.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard error == nil else {
                print("There was an error getting search results:", error?.localizedDescription)
                return
            }
            
            guard (response?.mapItems.count)! > 0 else {
                print("There were no results")
                return
            }
            
            for mapItem in response!.mapItems {
                self.matchingItems.append(mapItem as MKMapItem)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.shouldPresentLoadingView(status: false)
                }
                
            }
            
            
            
            
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        centerMapButtonOutlet.fadeTo(alphaValue: 1.0, withDuration: 0.2)
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        
        // MARK:- This finds the data for current loggedIn driver
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No uid.")
            return
        }
        
        ScoopUpUser.observePassengersAndDriver(uId: uid) { (user, didSucceed) in
            if !didSucceed {
                print("No user.")
                return
            }
            
            
            switch user?.userType {
            case "Driver":
                print("This is a driver")
                print("coordinates for current loggedIn Driver:", userLocation.coordinate)
                
                
                UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
                break
            case "Passenger":
                print("This is a passenger")
                UpdateService.instance.updatePassengerLocation(withCoordinate: userLocation.coordinate)
                break
            default:
                break
            }
        }
        

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view:MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view
        } else if let annotation = annotation as? PassengerAnnotation {
            let identifier = "passenger"
            var view:MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "currentLocationAnnotation")
            return view
        } else if let annotation = annotation as? MKPointAnnotation {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "destinationAnnotation")
            return annotationView
        }
        return nil
    }
    
}
// MARK:- Setting up the splashView functionality
extension ViewController {
    
    func setupAndStartSplashAnimation() {
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
    }
    
}


// MARK:- UITextfield delegate functionality
extension ViewController:UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == destTextFieldOutlet {
            tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - 340)
            tableView.layer.cornerRadius = 5.0
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tag = 18
            tableView.rowHeight = 60
            view.addSubview(tableView)
            animateTableView(shouldShow: true)
            UIView.animate(withDuration: 0.2) {
                self.destinationCircleOutlet.backgroundColor = UIColor.red
                self.destinationCircleOutlet.borderColor = UIColor.init(red: 199/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
        }
        
        
        
        
    }
    
    
    func animateTableView(shouldShow:Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = CGRect(x: 20, y: 200, width: self.view.frame.width - 40, height: self.view.frame.height - 340)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 340)
            }) { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == destTextFieldOutlet {
            guard !destTextFieldOutlet.text!.isEmpty || destTextFieldOutlet.text != "" else {
                showAlert("User error", "Enter search criterion into the destination text field.")
                self.destTextFieldOutlet.becomeFirstResponder()
                return false
            }
            
            performSearch()
            shouldPresentLoadingView(status: true)
            view.endEditing(true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == destTextFieldOutlet {
            if textField.text == "" {
                UIView.animate(withDuration: 0.2) {
                    self.destinationCircleOutlet.backgroundColor = UIColor.init(red: 121/255, green: 140/255, blue: 140/255, alpha: 1.0)
                    self.destinationCircleOutlet.borderColor = UIColor.init(red: 2/255, green: 83/255, blue: 115/255, alpha: 1.0)
                }
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = [MKMapItem]()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            DataService.instance.REF_USERS.child(self.currentUserId!).child("tripCoordinate").removeValue()
            
            self.removeRoutesFromMap()
            
            for annotation in self.mapView.annotations {
                if let annotation = annotation as? MKPointAnnotation {
                    self.mapView.removeAnnotation(annotation)
                } else if annotation.isKind(of: PassengerAnnotation.self) {
                    self.mapView.removeAnnotation(annotation)
                }
            }
        }
        return true
    }
    
}
// MARK:- TableViewDelegate functionality
extension ViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mapItem = matchingItems[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.shouldPresentLoadingView(status: true)
        
        removeRoutesFromMap()
        
        let passengerCoordinate = locationManager.location?.coordinate
        
        let passengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!, key: currentUserId!)
        mapView.addAnnotation(passengerAnnotation)
        
        destTextFieldOutlet.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        let selectedMapItem = matchingItems[indexPath.row]
        animateTableView(shouldShow: false)
        view.endEditing(true)
        ScoopUpUser.observePassengersAndDriver(uId: currentUserId!) { (scoopUser, succeed) in
            guard succeed else { return }
                switch scoopUser?.userType {
                case "Driver":
                    print("Driver")
                case "Passenger":
                    print("Passenger")
                    DataService.instance.REF_USERS.child(self.currentUserId!).updateChildValues(["tripCoordinate":[selectedMapItem.placemark.coordinate.latitude, selectedMapItem.placemark.coordinate.longitude]])
                     print("Take Off")
                    self.dropPinFor(placemark: selectedMapItem.placemark)
                    self.searchMapKitForResultsWithPolyline(originMapItem: nil, destinationMapItem: selectedMapItem)
                    
                    
                default:
                    print("I don't know.")
                }
        }
        

        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if destTextFieldOutlet.text!.isEmpty || destTextFieldOutlet.text == "" {
            animateTableView(shouldShow: false)
        }
    }
    
    
    
}
// MARK:- Logout functionality
extension ViewController {
    private func logout(completion:@escaping(_ success:Bool?) -> ()) {
           do {
               try Auth.auth().signOut()
               completion(true)
           } catch {
               print("error:\(error.localizedDescription)")
               completion(false)
           }
       }
}



