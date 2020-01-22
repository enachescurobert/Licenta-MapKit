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
  @IBOutlet weak var onlineUsersCount: UIBarButtonItem!
  
  // MARK: - Properties
  var locationManager: CLLocationManager?
  var previousLocation: CLLocation?
  var userItemsReference = Database.database().reference(withPath: "Users")
  var onlineUsersReference = Database.database().reference(withPath: "Online")
  var childName = "Aurelian"
  var users: [UserModel] = []
  var user: User!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.hidesBackButton = true
//    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
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
    
//    MARK: - Querying Firebase
    userItemsReference.queryOrdered(byChild: "scooter").observe(.value, with: {
      snapshot in
      var newUsers: [UserModel] = []
      for user in snapshot.children {
        let userItem = UserModel(snapshot: user as! DataSnapshot)
        newUsers.append(userItem)
      }
      
      self.users = newUsers
    })
    
//    MARK: - Updating Firebase
    let valuesToUpdate:[String: Any] = ["email":"updated_email@gmail.com"]
    userItemsReference.child(childName).ref.updateChildValues(valuesToUpdate)
    
//    MARK: - Deleting the Firebase reference
    //Deleting by using removeValue
    userItemsReference.child("Robert").ref.removeValue()
    //If we'll set a nil value, it will be deleted
    userItemsReference.child("Robert").setValue(nil)
    
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
    
    if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      activateLocationServices()
    } else {
      startLocationService()
    }
    Auth.auth().addStateDidChangeListener {
      auth, user in
      if let user = user {
        self.user = User(uid: user.uid, email: user.email!)
        let currentUserReference = self.onlineUsersReference.child(self.user.uid)
        currentUserReference.setValue(self.user.email)
        currentUserReference.onDisconnectRemoveValue()
      }
    }
    
    onlineUsersReference.observe(.value, with: {
      snapshot in
      if snapshot.exists() {
        self.onlineUsersCount?.title = "Online users: \(snapshot.childrenCount.description)"
      } else {
        self.onlineUsersCount?.title = "0 online users"
      }
    })
    
  }
  
  //  MARK: - IBActions
  @IBAction func changeMapType(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      mapView.mapType = .standard
    } else if sender.selectedSegmentIndex == 1 {
      mapView.mapType = .satellite
    }
  }
  
  @IBAction func signOut(_ sender: Any) {
    do {
        try Auth.auth().signOut()
      self.navigationController?.popViewController(animated: true)
        } catch let err {
            print(err)
    }
  }
  
  @IBAction func goToUserLocation(_ sender: Any) {
        mapView.setCenter(mapView?.userLocation.coordinate ?? CLLocationCoordinate2DMake(44.410, 26.100), animated: true)
  }
  
  // MARK: - Methods
  func startLocationService() {
    locationManager?.requestAlwaysAuthorization()
  }
  
  func activateLocationServices() {
    locationManager?.startUpdatingLocation()
  }
  
}

//  MARK: - CoreLocation Delegate methods
extension MapVC: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      activateLocationServices()
    }
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if previousLocation == nil {
      previousLocation = locations.first
    } else {
      guard let latest = locations.first else {return}
      let distanceInMeters = previousLocation?.distance(from: latest) ?? 0
      print("distance in meters: \(distanceInMeters)")
      previousLocation = latest
    }
    
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
