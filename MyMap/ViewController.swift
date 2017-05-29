//
//  ViewController.swift
//  MyMap
//
//  Created by pco2699 on 2017/05/27.
//  Copyright © 2017年 pco2699. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    InputText.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var InputText: UITextField!
  @IBOutlet weak var dispMap: MKMapView!
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // キーボードを閉じる
    textField.resignFirstResponder()
    
    let searchKeyword =  textField.text
    print(searchKeyword ?? "値が入っていません")
    
    let geocoder = CLGeocoder()
    
    geocoder.geocodeAddressString(searchKeyword!, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
      
      if let placemark = placemarks?[0] {
        if let targetCoordinate = placemark.location?.coordinate {
          print(targetCoordinate)
          
          let pin = MKPointAnnotation()
          
          pin.coordinate = targetCoordinate
          
          pin.title = searchKeyword
          
          self.dispMap.addAnnotation(pin)
          
          self.dispMap.region = MKCoordinateRegionMakeWithDistance(targetCoordinate, 500.0, 500.0)
        }
      }
    })
    
    return true
  }
  
  @IBAction func changeMapButtonAction(_ sender: Any) {
    if dispMap.mapType == .standard {
      dispMap.mapType = .satellite
    }
    else if dispMap.mapType == .satellite {
      dispMap.mapType = .hybrid
    }
    else if dispMap.mapType == .hybrid {
      dispMap.mapType = .satelliteFlyover
    }
    else if dispMap.mapType == .satelliteFlyover {
      dispMap.mapType = .hybridFlyover
    }
    else {
      dispMap.mapType = .standard
    }
  }
}

