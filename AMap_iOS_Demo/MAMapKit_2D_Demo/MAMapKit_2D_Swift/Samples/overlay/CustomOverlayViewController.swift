//
//  CustomOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CustomOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var customOverlay: CustomOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(customOverlay)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func initOverlay() {
        customOverlay = CustomOverlay.init(center: CLLocationCoordinate2DMake(39.929641, 116.431025), radius: 10000)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: CustomOverlay.self))
        {
            let renderer = CustomOverlayRenderer.init(overlay: overlay)
            
            return renderer;
        }
        
        return nil;
    }
}

