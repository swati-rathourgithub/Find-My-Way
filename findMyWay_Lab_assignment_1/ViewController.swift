//
//  ViewController.swift
//  findMyWay_Lab_assignment_1
//
//  Created by user173890 on 6/12/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var transporttype: MKDirectionsTransportType = .automobile
    @IBOutlet weak var uiswitch: UISwitch!
    @IBOutlet weak var typelabel: UILabel!
    let locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        addDoubleTapGesture()
    }
    
    func addDoubleTapGesture()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        tap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tap)
    }
    
    @objc func addAnnotation(gestureRecognizer:UITapGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        coordinates = newCoordinates
        mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func navigateTapped(_ sender: Any) {
        if locationManager.location?.coordinate != nil && coordinates != nil
        {
            let location = locationManager.location!.coordinate
            let destination = CLLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
            let request = MKDirections.Request()
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates!))
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location))
            request.transportType = transporttype
            request.requestsAlternateRoutes = false
            let directions = MKDirections(request: request)
            directions.calculate { [unowned self] (response, error) in
                print("1")
                guard let response = response else
                {
                    
                    return
                }
                
                for route in response.routes
                {
                    print("2")
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    func setupLocationManager(){
        locationManager.delegate = self //set delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //for the accurate location
    }
    
    func centerViewOnUserLocation(){
        if let Location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: Location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            // show alert letting the user know they have to turn the location on
        }
    }
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            //Map
            //startTrackingUserLocation()
            break
        case .denied:
            //show alert to allow the access of location
            break
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // show the alert to the user that whats going on
            break
            
        case .authorizedAlways:
            break
            
            
        @unknown default:
            break
        }}
    
    @IBAction func findMyWayClicked(_ sender: Any) {
        centerViewOnUserLocation()
    }
    //func startTrackingUserLocation(){
    //    mapView.showsUserLocation = true // shows user's location
    //    centerViewOnUserLocation()
    //   locationManager.startUpdatingLocation()//to update the locationof the user
    //    previousLocation = getCenterLocation(for: mapView)
    //}
    
    
    @IBAction func valueChanged(_ sender: Any) {
        if uiswitch.isOn
        {
            transporttype = .automobile
            typelabel.text = "Automobile"
        }
        else
        {
            typelabel.text = "Walking"
            transporttype = .walking
        }
    }
    
}
extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("3")
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .darkGray
        return renderer
    }
}
