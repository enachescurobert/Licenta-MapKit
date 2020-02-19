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
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import AVFoundation

class MapVC: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var directionsTableView: UITableView!
  @IBOutlet weak var rideInfoView: UIView!
  @IBOutlet weak var timePassedLbl: UILabel!
  @IBOutlet weak var totalLbl: UILabel!
  @IBOutlet weak var parkingCodeLbl: UILabel!
  
  // MARK: - Properties
  let userDefaults = UserDefaults.standard
  let parkingCodes:[String] = ["123456", "678900", "135790", "246800", "142530"]
  
  /// Location Properties
  var locationManager: CLLocationManager?
  var currentLocation: CLLocation?
  
  /// Firestore Properties
  var db: Firestore!
  var users: [User] = []
  var userLocations: [UserLocation] = []
  var scooters:[ScooterModel] = []
  
  var selectedScooter:String?
  
  /// Geocoding and Directions Properties
  var travelDirections: [String] = []
  var polylineDirections: [MKPolyline] = []
  lazy var geocoder = CLGeocoder()
  var voice:AVSpeechSynthesizer?
  
  //  MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.hidesBackButton = true
    
    self.userDefaults.set("No active scooter", forKey: "ACTIVE_SCOOTER")
    
    // [START setup]
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    // [END setup]
    db = Firestore.firestore()
    
    //      MARK: - Upload to Firebase
    #warning("CREATE USER AT LOGIN")
    // Add a new document with a generated ID
    var ref: DocumentReference? = nil
    ref = db.collection("users").addDocument(data: [
      "first": "Robert",
      "last": "Test",
      "born": 1996
    ]) { err in
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
      }
    }
    
    //      MARK: - Read from Database
    ///    Getting all Users
    db.collection("Users").getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          print("\(document.documentID) => \(document.data())")
          let user:User = User(data: document.data())!
          print(user)
          self.users.append(user)
        }
      }
    }
    
    //    MARK: - Setting the map
    let ourLocation = CLLocation(latitude: 44.410, longitude: 26.100)
    let regionRadius: CLLocationDistance = 25000.0
    let region = MKCoordinateRegion(center: ourLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    voice = AVSpeechSynthesizer()
    mapView.setRegion(region, animated: true)
    mapView.delegate = self
    
    //    MARK: - Setting user location
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.requestLocation()
    
    updateUI()
    
    if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      activateLocationServices()
    } else {
      startLocationService()
    }
    
    directionsTableView.delegate = self
    directionsTableView.dataSource = self
    
    produceOverlay()
  }
  
  //  MARK: - IBActions
  @IBAction func changeMapType(_ sender: UISegmentedControl) {
    
    if sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 1 {
      mapView.isHidden = false
      directionsTableView.isHidden = true
      if sender.selectedSegmentIndex == 0 {
        mapView.mapType = .standard
        directionsTableView.isHidden = true
      } else if sender.selectedSegmentIndex == 1 {
        mapView.mapType = .satellite
        directionsTableView.isHidden = true
      }
    } else {
      mapView.isHidden = true
      directionsTableView.isHidden = false
    }
  }
  
  private func produceOverlay() {
    var points: [CLLocationCoordinate2D] = []
    points.append(CLLocationCoordinate2DMake(44.5045861, 26.0606003))
    points.append(CLLocationCoordinate2DMake(44.5048310, 26.1622238))
    points.append(CLLocationCoordinate2DMake(44.3830111, 26.1711502))
    points.append(CLLocationCoordinate2DMake(44.3842379, 26.0595703))
    points.append(CLLocationCoordinate2DMake(44.5055655, 26.0595703))
    
    let polygon = MKPolygon(coordinates: &points, count: points.count)
    mapView.addOverlay(polygon)
  }
  
  private func loadDirections(destination:CLLocation?) {
    
    if travelDirections.count != 0 {
      self.travelDirections.removeAll()
      self.directionsTableView.reloadData()
    }
    
    guard let start = currentLocation, let end = destination else { return }
    let request = MKDirections.Request()
    let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: start.coordinate))
    let endMapItem = MKMapItem(placemark: MKPlacemark(coordinate: end.coordinate))
    request.source = startMapItem
    request.destination = endMapItem
    request.requestsAlternateRoutes = false
    request.transportType = .automobile
    let directions = MKDirections(request: request)
    directions.calculate() {
      [weak self] (response, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      if let route = response?.routes.first {
        
        /// Delete the old polyline if a new one will be created
        let overlays = self!.mapView.overlays
        for overlay in overlays {
          if overlay is MKPolyline {
            self!.mapView.removeOverlay(overlay)
          }
        }
        
        self?.mapView.addOverlay(route.polyline)
        
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .full
        formatter.units = .metric
        for step in route.steps {
          let distance = formatter.string(fromDistance: step.distance)
          self?.travelDirections.append(step.instructions + " (\(distance)")
        }
        self?.directionsTableView.reloadData()
      }
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
  
  @IBAction func stopTimerPressed(_ sender: Any) {
    #warning("Stop Timer Logic")
    for user in users {
      if user.username == selectedScooter {
        stopTheEngineOf(user_id: user.user_id)
      }
    }
  }
  
  
  // MARK: - Methods
  /// We use requestAlwaysAuthorization instead of requestWhenInUseAuthorization
  /// because we need the location of the user even if the app is in background
  func startLocationService() {
    locationManager?.requestAlwaysAuthorization()
  }
  
  func activateLocationServices() {
    if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
      for scooter in scooters {
        let region = CLCircularRegion(center: scooter.location.coordinate, radius: 500, identifier: scooter.name)
        region.notifyOnEntry = true
        locationManager?.startMonitoring(for: region)
      }
    }
    locationManager?.startUpdatingLocation()
  }
  
  func updateUI() {
    getAllUserLocationsFromFirestore()
    printAddress()
  }
  
  func getAllUserLocationsFromFirestore() {
    db.collection("User Locations").getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          print("\(document.documentID) => \(document.data())")
          let userLocation:UserLocation = UserLocation(document: document)!
          print(userLocation)
          self.userLocations.append(userLocation)
        }
        self.loadScootersFromUsers()
        self.mapView.addAnnotations(self.scooters)
        self.mapView.register(ScooterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
      }
    }
  }
  
  func loadScootersFromUsers() {
    for userLocation in userLocations {
      let shouldBeOnTopOfCluster = false
      
      let scooter:ScooterModel = ScooterModel(
        latitude: userLocation.geoPoint!.latitude,
        longitude: userLocation.geoPoint!.longitude,
        name: (userLocation.user?.username)!,
        user_id: userLocation.user_id!,
        imageName: "app-icon.png",
        shouldBeOnTopOfCluster: shouldBeOnTopOfCluster)
      
      /// we will only add scooters to our map
      if (userLocation.user?.scooter)! {
        scooters.append(scooter)
      }
      
    }
  }
  
  func loadScooters() {
    guard let entries = loadPlist() else {
      fatalError("Unable to load data")
    }
    
    for property in entries {
      guard let name = property["Name"] as? String,
        let latitude = property["Latitude"] as? NSNumber,
        let longitude = property["Longitude"] as? NSNumber,
        let image = property["Image"] as? String else {
          fatalError("Error reading data")
      }
      print("name: \(name)")
      print("latitude: \(latitude)")
      print("longitude: \(longitude)")
      print("image: \(image)")
      print("")
      
      var shouldBeOnTopOfCluster = false
      if property["shouldBeOnTopOfCluster"] != nil {
        shouldBeOnTopOfCluster = property["shouldBeOnTopOfCluster"] as? Bool ?? false
      }
      let scooter = ScooterModel(latitude: latitude.doubleValue, longitude: longitude.doubleValue, name: name, user_id: "test", imageName: image, shouldBeOnTopOfCluster: shouldBeOnTopOfCluster)
      scooters.append(scooter)
    }
  }
  
  private func printAddress() {
    
    for scooter in scooters {
      geocoder.reverseGeocodeLocation(scooter.location, completionHandler: {
        (placemarks, error) in
        if let error = error {
          print(error.localizedDescription)
          return
        }
        guard let placemark = placemarks?.first else {
          return
        }
        let streetNumber = placemark.subThoroughfare ?? ""
        if let street = placemark.thoroughfare,
          let city = placemark.locality,
          let state = placemark.administrativeArea {
          print("The address is: \(streetNumber) \(street) \(city), \(state)")
        }
        
      })
    }
    
  }
  
  private func loadPlist() -> [[String: Any]]? {
    guard let plistUrl = Bundle.main.url(forResource: "Scooters", withExtension: "plist"),
      let plistData = try? Data(contentsOf: plistUrl) else { return nil }
    var placedEntries: [[String: Any]]? = nil
    
    do {
      placedEntries = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [[String: Any]]
    } catch {
      print("error reading plist")
    }
    return placedEntries
  }
  
  func showAlertWithOnlyConfirmationOption(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    self.present(alert, animated: true)
  }
  
  func showAlertWithOptions(title: String, message: String, handler: @escaping (UIAlertAction) -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: handler))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    self.present(alert, animated: true)
  }
  
  func stopTheEngineOf(user_id: String) {
    self.db.collection("User Locations").document(user_id).updateData([
      "user.engineStoppedAt": FieldValue.serverTimestamp(),
      "user.engineStarted" : false]
    ) { err in
      if let err = err {
        print("Error updating document: \(err)")
        self.showAlertWithOnlyConfirmationOption(title: "Error!", message: "Please try again later.")
      } else {
        print("Document successfully updated")
        self.showAlertWithOnlyConfirmationOption(title: "Engine - Stopped", message: "Thank you for choosing our app.")
        self.userDefaults.set("No active scooter", forKey: "ACTIVE_SCOOTER")
        self.rideInfoView.isHidden = true
        #warning("STOP THE TIMER")
      }
    }
  }
  
}

//  MARK: - CoreLocation Delegate methods
extension MapVC: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      activateLocationServices()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if presentingViewController == nil {
      let alertController = UIAlertController(title: "Scooter nearby", message: "You are near the \(region.identifier). Go ahead, let's drive a little!", preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
        [weak self] action in
        self?.dismiss(animated: true, completion: nil)
      })
      alertController.addAction(alertAction)
      present(alertController, animated: false, completion: nil)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print(error.localizedDescription)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if currentLocation == nil {
      currentLocation = locations.first
    } else {
      guard let latest = locations.first else {return}
      let distanceInMeters = currentLocation?.distance(from: latest) ?? 0
      print("distance in meters: \(distanceInMeters)")
      currentLocation = latest
    }
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
}

//  MARK: - MapKit Delegate methods
extension MapVC: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if let titleOfView = view.annotation?.title {
      if titleOfView == selectedScooter {
        
        if userDefaults.string(forKey: "ACTIVE_SCOOTER") == "No active scooter" {
          
          showAlertWithOptions(title: "Scooter selected", message: "Do you want to START the engine of the scooter?", handler: {
            _ in
            for user in self.users {
              if user.username == titleOfView {
                
                self.db.collection("User Locations").document(user.user_id).updateData([
                  "user.engineStartedAt": FieldValue.serverTimestamp(),
                  "user.engineStarted" : true]
                ) { err in
                  if let err = err {
                    print("Error updating document: \(err)")
                    self.showAlertWithOnlyConfirmationOption(title: "Error!", message: "Please try again later.")
                  } else {
                    print("Document successfully updated")
                    self.showAlertWithOnlyConfirmationOption(title: "Engine - Started", message: "Enjoy your ride!")
                    self.userDefaults.set(user.username, forKey: "ACTIVE_SCOOTER")
                    self.rideInfoView.isHidden = false
                    #warning("START THE TIMER")
                  }
                }
                
              }
            }
          })
          
        } else {
          
          showAlertWithOptions(title: "Scooter selected", message: "Do you want to STOP the engine of the scooter?", handler: {
            _ in
            for user in self.users {
              if user.username == titleOfView {
                
                self.stopTheEngineOf(user_id: user.user_id)
                
              }
            }
          })
        }
        
      } else {
        showAlertWithOptions(title: "Scooter selected", message: "Do you want a route to this scooter?", handler: {
          _ in
          let destinationLocation = view.annotation?.coordinate
          let destination:CLLocation = CLLocation(latitude: destinationLocation!.latitude, longitude: destinationLocation!.longitude)
          self.loadDirections(destination: destination)
          mapView.deselectAnnotation(view.annotation, animated: false)
          if let title = view.annotation?.title {
            self.selectedScooter = title
          }
        })
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolygon {
      let polyRenderer = MKPolygonRenderer(overlay: overlay)
      polyRenderer.strokeColor = UIColor.green.withAlphaComponent(0.5)
      polyRenderer.fillColor = UIColor.green.withAlphaComponent(0.2)
      polyRenderer.lineWidth = 2.0
      return polyRenderer
    } else if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
      polylineRenderer.lineWidth = 2.0
      return polylineRenderer
    }
    return MKOverlayRenderer()
  }
}

//  MARK: - TableView Delegate
extension MapVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let text = travelDirections[indexPath.row]
    let utterance = AVSpeechUtterance(string: text)
    voice?.speak(utterance)
    
  }
}

extension MapVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return travelDirections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell", for: indexPath)
    cell.textLabel?.text = travelDirections[indexPath.row]
    return cell
  }
  
  
}
