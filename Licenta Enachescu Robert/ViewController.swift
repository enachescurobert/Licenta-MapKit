//
//  ViewController.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 18/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

  var locationManager: CLLocationManager?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.requestLocation()
    
    }
  
  @IBAction func startLocationService(_ sender: Any) {
    locationManager?.requestAlwaysAuthorization()
  }

}

extension ViewController : CLLocationManagerDelegate {
  
//  MARK: - Location Delegate methods
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    guard let initialLocation = locations.first else {return}
    print("The initial location is: \(initialLocation)")
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
}

