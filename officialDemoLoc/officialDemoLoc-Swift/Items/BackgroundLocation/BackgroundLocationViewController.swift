//
//  BackgroundLocationViewController.swift
//  officialDemoLoc
//
//  Created by liubo on 10/8/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

import UIKit

class BackgroundLocationViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {
    
    //MARK: - Properties
    
    let showSegment = UISegmentedControl(items: ["开始定位", "停止定位"])
    let backgroundSegment = UISegmentedControl(items: ["开启后台", "禁止后台"])
    let pointAnnotation = MAPointAnnotation()
    
    var mapView: MAMapView!
    lazy var locationManager = AMapLocationManager()
    
    //MARK: - Action Handle
    
    func configLocationManager() {
        locationManager.delegate = self
        
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    @objc func showSegmentAction(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            locationManager.stopUpdatingLocation()
            
            mapView.removeAnnotation(pointAnnotation)
        }
        else {
            mapView.addAnnotation(pointAnnotation)
            
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func backgroundSegmentAction(sender: UISegmentedControl) {
        
        locationManager.stopUpdatingLocation()
        mapView.removeAnnotation(pointAnnotation)
        showSegment.selectedSegmentIndex = 1
        
        if sender.selectedSegmentIndex == 1 {
            
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.allowsBackgroundLocationUpdates = false
        }
        else {
            
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true
        }
    }
    
    //MARK: - AMapLocationManagerDelegate
    
    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        let error = error as NSError
        NSLog("didFailWithError:{\(error.code) - \(error.localizedDescription)};")
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        NSLog("location:{lat:\(location.coordinate.latitude); lon:\(location.coordinate.longitude); accuracy:\(location.horizontalAccuracy)};");
        
        pointAnnotation.coordinate = location.coordinate
        mapView.centerCoordinate = location.coordinate
        mapView.setZoomLevel(15.1, animated: false)
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        initToolBar()
        
        initMapView()
        
        configLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addAnnotation(pointAnnotation)
        locationManager.startUpdatingLocation()
    }
    
    func initMapView() {
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        
        view.addSubview(mapView)
    }
    
    func initToolBar() {
        let flexble = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        showSegment.addTarget(self, action: #selector(showSegmentAction(sender:)), for: .valueChanged)
        showSegment.selectedSegmentIndex = 0
        
        backgroundSegment.addTarget(self, action: #selector(backgroundSegmentAction(sender:)), for: .valueChanged)
        backgroundSegment.selectedSegmentIndex = 0
        
        setToolbarItems([flexble, UIBarButtonItem(customView: showSegment), flexble, UIBarButtonItem(customView: backgroundSegment), flexble], animated: false)
    }
    
    //MARK: - MAMapVie Delegate
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier = "pointReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView?.canShowCallout  = false
            annotationView?.animatesDrop    = false
            annotationView?.isDraggable     = false
            annotationView?.image           = UIImage(named: "icon_location.png")
            
            return annotationView
        }
        
        return nil
    }

}
