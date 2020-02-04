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

class ViewController: UIViewController {
    
    
    @IBOutlet weak var actionButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerMapButtonOutlet: UIButton!
    @IBOutlet weak var destTextFieldOutlet: UITextField!
    @IBOutlet weak var destinationCircleOutlet: CircleView!
    
    var delegate:CenterVCDelegate?
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    var tableView = UITableView()
    var matchingItems:[MKMapItem] = [MKMapItem]()
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .white)

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()
        setupAndStartSplashAnimation()
        mapView.delegate = self
        destTextFieldOutlet.delegate = self
        
        DataService.instance.REF_DRIVERS.observe(.value, with: { (snapshot) in
            self.loadDriverAnnotationsFromFB()
        })
       
    }
    


    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionButtonOutlet.animateButton(shouldLoad: true, with: nil)
        
    }
    
    @IBAction func menuButtonPressedAction(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func centerButtonAction(_ sender: Any) {
        
        if let location = locationManager.location?.coordinate {
            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            centerMapButtonOutlet.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        }
        
        
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
            performSearch()
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        animateTableView(shouldShow: false)
       
        print("selected")
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
}



