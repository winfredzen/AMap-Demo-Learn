//
//  OperateMapViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class OperateMapViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMapView()
        
        
        let sws = makeSwitchsPannelView()
        sws.center = CGPoint.init(x: sws.bounds.midX + 10, y: self.view.bounds.height - sws.bounds.midY - 20)
        
        sws.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleRightMargin]
        self.view.addSubview(sws)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        mapView.isShowsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    func makeSwitchsPannelView() -> UIView {
        let ret = UIView.init()
        ret.backgroundColor = UIColor.white
        
        let sw1 = UISwitch.init()
        let sw2 = UISwitch.init()
        
        let l1 = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: sw1.bounds.height))
        l1.text = "drag:"
        
        let l2 = UILabel.init(frame: CGRect.init(x: 0, y: l1.frame.maxY + 5, width: 70, height: sw1.bounds.height))
        l2.text = "zoom:"
        
        ret.addSubview(l1)
        ret.addSubview(sw1)
        ret.addSubview(l2)
        ret.addSubview(sw2)
        
        var temp = sw1.frame
        temp.origin.x = l1.frame.maxX + 5
        sw1.frame = temp
        
        temp = sw2.frame
        temp.origin.x = l2.frame.maxX + 5
        temp.origin.y = l2.frame.minY
        sw2.frame = temp
        
        sw1.addTarget(self, action: #selector(self.enableDrag(sender:)), for: UIControlEvents.valueChanged)
        sw2.addTarget(self, action: #selector(self.enableZoom(sender:)), for: UIControlEvents.valueChanged)
        
        sw1.isOn = mapView.isScrollEnabled
        sw2.isOn = mapView.isZoomEnabled
        
        ret.bounds = CGRect.init(x: 0, y: 0, width: sw2.frame.maxX, height: l2.frame.maxY)
        
        return ret
    }
    
    //MARK: - event handling
    @objc func enableDrag(sender:UISwitch) {
        mapView.isScrollEnabled = sender.isOn
    }
    
    @objc func enableZoom(sender:UISwitch) {
        mapView.isZoomEnabled = sender.isOn
    }
}
