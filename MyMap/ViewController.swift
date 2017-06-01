//
//  ViewController.swift
//  MyMap
//
//  Created by pco2699 on 2017/05/27.
//  Copyright © 2017年 pco2699. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate , MKMapViewDelegate, CLLocationManagerDelegate{
  
  var locationManager: CLLocationManager!


  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    InputText.delegate = self
    
    // タップした時のアクションを追加
    let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
    dispMap.addGestureRecognizer(tapGesture)
    
    // MapView Delegate設定
    dispMap.delegate = self
    
    setupLocationManager()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupLocationManager() {
    locationManager = CLLocationManager()
    guard let locationManager = locationManager else { return }
    locationManager.requestWhenInUseAuthorization()
    
    let status = CLLocationManager.authorizationStatus()
    if status == .authorizedWhenInUse {
      locationManager.delegate = self
      locationManager.distanceFilter = 10
      locationManager.startUpdatingLocation()
    }
  }

  @IBOutlet weak var InputText: UITextField!
  @IBOutlet weak var dispMap: MKMapView!
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // キーボードを閉じる
    textField.resignFirstResponder()
    
    let searchKeyword =  textField.text
    let geocoder = CLGeocoder()
    
    geocoder.geocodeAddressString(searchKeyword!, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
      
      if let placemark = placemarks?[0] {
        if let targetCoordinate = placemark.location?.coordinate {
          print(targetCoordinate)
          
//          let pin = MKPointAnnotation()
          
//          pin.coordinate = targetCoordinate
          
//          pin.title = searchKeyword
          
//          self.dispMap.addAnnotation(pin)
          
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
  
  @IBAction func changeCurrentLocation(_ sender: Any) {
    self.dispMap.region = MKCoordinateRegionMakeWithDistance(dispMap.userLocation.coordinate, 500.0, 500.0)
  }
  
  
  func mapTapped(_ sender: UILongPressGestureRecognizer){
    // タッチ終了か？
    if sender.state == .ended {
      print("tapp")
      // 画面上のタッチした座標を取得
      let tapPoint = sender.location(in: view)
      // タッチした座標からマップ上の緯度経度を取得
      let location = dispMap.convert(tapPoint, toCoordinateFrom: dispMap)
      
      self.dispMap.removeOverlays(dispMap.overlays)
      self.dispMap.removeAnnotations(dispMap.annotations)
      
      getGurunabi(location)
    }
  }
  
  func getGurunabi(_ loc: CLLocationCoordinate2D) {
    let url = "https://api.gnavi.co.jp/RestSearchAPI/20150630/"
    Alamofire.request(url, parameters: ["keyid": "bbfa3d32ce78f4c79f6291f8b0845920", "format": "json", "latitude":loc.latitude, "longitude": loc.longitude, "input_coordinates_mode": 2, "coordinates_mode": 2, "range": 1])
      .responseJSON(completionHandler: { response in
        let json = JSON(response.result.value ?? "empty")
        json["rest"].forEach{(_, data) in
          let pin = MKPointAnnotation()
          
          pin.coordinate = CLLocationCoordinate2D(latitude: Double(data["latitude"].string!)!, longitude: Double(data["longitude"].string!)!)
          pin.title = data["name"].string!
          pin.subtitle = data["url"].string!
          
          self.dispMap.addAnnotation(pin)
          
        }
        
      })
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView?.animatesDrop = true
    }
    else {
      pinView?.annotation = annotation
    }
    
    pinView?.canShowCallout = true
    
    let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
    pinView?.rightCalloutAccessoryView = rightButton as? UIView
    
    return pinView
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let pin = view.annotation
    if let url = pin?.subtitle {
      let url_obj = URL(string: url!)
      let app: UIApplication = UIApplication.shared
      app.open(url_obj!)
    }
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    //円のデザインを決める
    let circleRenderer = MKCircleRenderer(overlay: overlay)
    circleRenderer.strokeColor = UIColor.red
    circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.5)
    circleRenderer.lineWidth = 1.0
    
    return circleRenderer
  }
  
}

