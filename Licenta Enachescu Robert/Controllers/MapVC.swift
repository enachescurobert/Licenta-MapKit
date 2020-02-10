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
import AVFoundation

class MapVC: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var onlineUsersCount: UIBarButtonItem!
  @IBOutlet weak var directionsTableView: UITableView!
  
  // MARK: - Properties
  var locationManager: CLLocationManager?
  var currentLocation: CLLocation?
  var userItemsReference = Database.database().reference(withPath: "Users")
  var onlineUsersReference = Database.database().reference(withPath: "Online")
  var childName = "Aurelian"
  var users: [UserModel] = []
  var user: User!
  var scooters:[ScooterModel] = []
  var travelDirections: [String] = []
  var polylineDirections: [MKPolyline] = []
  lazy var geocoder = CLGeocoder()
  var voice:AVSpeechSynthesizer?
  
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
    ///    Getting the entire Object
    userItemsReference.child(childName).observe(.value, with: {
      snapshot in
      print(snapshot)
    })
    
    ///    Parsing all elements
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
    
    ///    Creating an array of Users
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
    
    mapView.addAnnotations(scooters)
    mapView.register(ScooterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    
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
        
    directionsTableView.delegate = self
    directionsTableView.dataSource = self
    
    produceOverlay()
    producePolylineOverlay()
    
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
  
  private func producePolylineOverlay() {
    var points: [MKMapPoint] = []
    
    guard let lat = currentLocation?.coordinate.latitude,
      let long = currentLocation?.coordinate.longitude else {return}
    
    points.append(MKMapPoint(x: lat, y: long))
    points.append(MKMapPoint(x: 44.5048310, y: 26.1622238))
    let polygon = MKPolyline(points: points, count: points.count)
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

        let overlays = self!.mapView.overlays
        for overlay in overlays {
          if overlay is MKPolyline {
            self!.mapView.removeOverlay(overlay)
            }
        }
        
        let polyline: MKPolyline = route.polyline
        polyline.title = "titleForPolyline"
        
        self?.mapView.addOverlay(polyline)
        
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
    loadScooters()
    printAddress()
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
      let scooter = ScooterModel(latitude: latitude.doubleValue, longitude: longitude.doubleValue, name: name, imageName: image, shouldBeOnTopOfCluster: shouldBeOnTopOfCluster)
      scooters.append(scooter)
    }
  }
  
  private func printAddress() {
    
    for scooter in scooters {
      geocoder.reverseGeocodeLocation(scooter.location, completionHandler: {
        [weak self](placemarks, error) in
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
        
    let alert = UIAlertController(title: "Scooter selected", message: "Do you want a route to this scooter?", preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
      let destinationLocation = view.annotation?.coordinate
      let destination:CLLocation = CLLocation(latitude: destinationLocation!.latitude, longitude: destinationLocation!.longitude)
      self.loadDirections(destination: destination)
      mapView.deselectAnnotation(view.annotation, animated: false)
    }))
    
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    self.present(alert, animated: true)
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    if overlay is MKPolygon {
      let polyRenderer = MKPolygonRenderer(overlay: overlay)
      polyRenderer.strokeColor = UIColor.green.withAlphaComponent(0.5)
      polyRenderer.fillColor = UIColor.green.withAlphaComponent(0.2)
      polyRenderer.lineWidth = 2.0
      
      return polyRenderer
    } else if overlay is MKPolyline {
      
//      if overlay.title == "titleForPolyline" {
//        mapView.removeOverlay(overlay)
//      }
      
//      let overlays = mapView.overlays
//      for overlay in overlays {
//        if overlay is MKPolyline {
//            mapView.removeOverlay(overlay)
//        }
//      }
      
//      mapView.removeOverlays(mapView.overlays)
//      produceOverlay()
      
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      
      polylineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
      polylineRenderer.lineWidth = 2.0
      return polylineRenderer
    }
    
    return MKOverlayRenderer()
  }
  
}

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
