//
//  ClusterView.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 31/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import MapKit

class ClusterView: MKMarkerAnnotationView {
  
  override var annotation: MKAnnotation? {
    willSet {
      markerTintColor = UIColor.brown
      displayPriority = .required
    }
  }

}
