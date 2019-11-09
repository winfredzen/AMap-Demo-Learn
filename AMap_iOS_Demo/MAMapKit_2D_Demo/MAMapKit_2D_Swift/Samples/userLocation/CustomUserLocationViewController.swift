//
//  CustomUserLocationViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CustomUserLocationViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var customUserLocationView: MAAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 开启定位
        mapView.isShowsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        let annoationview = views.first as! MAAnnotationView
        
        if(annoationview.annotation .isKind(of: MAUserLocation.self)) {
            let rprt = MAUserLocationRepresentation.init()
            rprt.fillColor = UIColor.red.withAlphaComponent(0.4)
            rprt.strokeColor = UIColor.gray
            rprt.image = UIImage.init(named: "userPosition")
            rprt.lineWidth = 3
            
            mapView.update(rprt)
            
            annoationview.calloutOffset = CGPoint.init(x: 0, y: 0)
            annoationview.canShowCallout = false
            self.customUserLocationView = annoationview
        }
    }
    
    func mapView(_ mapView:MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation:Bool ) {
        if(!updatingLocation && self.customUserLocationView != nil) {
            UIView.animate(withDuration: 0.1, animations: {
                let degree = userLocation.heading.trueHeading
                let radian = (degree * M_PI) / 180.0
                self.customUserLocationView.transform = CGAffineTransform.init(rotationAngle: CGFloat(radian))
            })
        }
    }

}
