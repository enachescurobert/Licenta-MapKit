//
//  ViewController.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 18/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class MapVC: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: - Properties
  var locationManager: CLLocationManager?
  var userItemsReference = Database.database().reference(withPath: "Users")
  var childName = "Aurelian"
  var users: [UserModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //      MARK: - Upload to Firebase
    let userRef = self.userItemsReference.child(childName)
    let values: [String: Any] = ["email": "testescu@gmail.com",
                                 "engineStarted": false,
                                 "scooter": false,
                                 "username": "testescu"
    ]
    userRef.setValue(values)
    
    //      MARK: - Read from Database
    //    Getting the entire Object
    userItemsReference.child(childName).observe(.value, with: {
      snapshot in
      print(snapshot)
    })
    
    //    Parsing all elements
    userItemsReference.child(childName).observe(.value, with: {
      snapshot in
      let values = snapshot.value as! [String:AnyObject]
      let email = values["email"] as! String
      let username = values["username"] as! String
      let scooter = values["scooter"] as! Bool
      let engineStarted = values["engineStarted"] as! Bool
      
      print("email: \(email)")
      print("username: \(username)")
      print("is a scooter: \(scooter)")
      if scooter {
        print("the engine is on: \(engineStarted)")
      }
      
    })
    
    //    Creating an array of Users
    userItemsReference.observe(.value, with: {
      snapshot in
      var newUsers: [UserModel] = []
      for user in snapshot.children {
        let userItem = UserModel(snapshot: user as! DataSnapshot)
        newUsers.append(userItem)
      }
      
      self.users = newUsers
      //      print("Users: \(self.users)")
    })
    
    //    MARK: - Setting the map
    let ourLocation = CLLocation(latitude: 44.410, longitude: 26.100)
    let regionRadius: CLLocationDistance = 25000.0
    let region = MKCoordinateRegion(center: ourLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    mapView.setRegion(region, animated: true)
    
    mapView.delegate = self
    
    //    MARK: - Setting user location
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.requestLocation()
    
    
    startLocationService()
    
  }
  
  //  MARK: - IBActions
  @IBAction func changeMapType(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      mapView.mapType = .standard
    } else if sender.selectedSegmentIndex == 1 {
      mapView.mapType = .satellite
    }
  }
  
  // MARK: - Methods
  func startLocationService() {
    locationManager?.requestAlwaysAuthorization()
  }
  
}

//  MARK: - CoreLocation Delegate methods
extension MapVC: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    guard let initialLocation = locations.first else {return}
    print("The initial location is: \(initialLocation)")
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
}

//  MARK: - MapKit Delegate methods
extension MapVC: MKMapViewDelegate {
  
  func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
    print("Rendering...")
  }
  
}
