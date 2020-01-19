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

class ViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var mapView: MKMapView!
  
  var locationManager: CLLocationManager?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let ourLocation = CLLocation(latitude: 44.410, longitude: 26.100)
    let regionRadius: CLLocationDistance = 25000.0
    let region = MKCoordinateRegion(center: ourLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    mapView.setRegion(region, animated: true)
    mapView.delegate = self

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
  
  
  func startLocationService() {
    locationManager?.requestAlwaysAuthorization()
  }

}

//  MARK: - CoreLocation Delegate methods
extension ViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    guard let initialLocation = locations.first else {return}
    print("The initial location is: \(initialLocation)")
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
}

//  MARK: - MapKit Delegate methods
extension ViewController: MKMapViewDelegate {
  
  func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
    print("Rendering...")
  }
  
}

