//
//  SerialLocationViewController.m
//  officialDemoLoc
//
//  Created by 刘博 on 15/9/21.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "HeadinglLocationViewController.h"

@interface HeadinglLocationViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate>

@property (nonatomic, strong) UISegmentedControl *showSegment;
@property (nonatomic, strong) UISegmentedControl *headingSegment;
@property (nonatomic, strong) MAPointAnnotation *pointAnnotaiton;
@property (nonatomic, assign) BOOL headingCalibration;
@property (nonatomic, strong) MAPinAnnotationView *annotationView;
@property (nonatomic, assign) CGFloat annotationViewAngle;
@property (nonatomic, strong) CLHeading *heading;

@end

@implementation HeadinglLocationViewController

#pragma mark - Action Handle

- (void)configLocationManager
{
    _headingCalibration = NO;

    self.locationManager = [[AMapLocationManager alloc] init];

    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (void)showsSegmentAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex)
    {
        //停止定位
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        
        //移除地图上的annotation
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.pointAnnotaiton = nil;
        _annotationView = nil;
    }
    else
    {
        [self startHeadingLocation];
    }
    
}

- (void)showsHeadingAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex)
    {
        _headingCalibration = YES;
    }
    else
    {
        _headingCalibration = NO;
    }
}

- (void)startHeadingLocation
{
    //开始进行连续定位
    [self.locationManager startUpdatingLocation];
    
    if ([AMapLocationManager headingAvailable] == YES)
    {
        [self.locationManager startUpdatingHeading];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        _headingCalibration = YES;
        [self startHeadingLocation];
    }
    else
    {
        _headingCalibration = NO;
        [self startHeadingLocation];
    }
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f, reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode.formattedAddress);
    
    //获取到定位信息，更新annotation
    if (self.pointAnnotaiton == nil)
    {
        self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
        [self.pointAnnotaiton setCoordinate:location.coordinate];
        
        [self.mapView addAnnotation:self.pointAnnotaiton];
    }
    
    [self.pointAnnotaiton setCoordinate:location.coordinate];
    
    [self.mapView setCenterCoordinate:location.coordinate];
    [self.mapView setZoomLevel:15.1 animated:NO];
}

- (BOOL)amapLocationManagerShouldDisplayHeadingCalibration:(AMapLocationManager *)manager
{
    return _headingCalibration;
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (_annotationView != nil)
    {
        CGFloat angle = newHeading.trueHeading*M_PI/180.0f + M_PI - _annotationViewAngle;
        NSLog(@"################### heading : %f - %f", newHeading.trueHeading, newHeading.magneticHeading);
        _annotationViewAngle = newHeading.trueHeading*M_PI/180.0f + M_PI;
        _heading = newHeading;
        _annotationView.transform =  CGAffineTransformRotate(_annotationView.transform ,angle);
    }
}

#pragma mark - Initialization

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}

- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    self.showSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Start", @"Stop", nil]];
    [self.showSegment addTarget:self action:@selector(showsSegmentAction:) forControlEvents:UIControlEventValueChanged];
    self.showSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:self.showSegment];
    
    self.headingSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"不校准", @"校准", nil]];
    [self.headingSegment addTarget:self action:@selector(showsHeadingAction:) forControlEvents:UIControlEventValueChanged];
    self.headingSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *showItem2 = [[UIBarButtonItem alloc] initWithCustomView:self.headingSegment];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, showItem, flexble, showItem2, flexble, nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initToolBar];
    
    [self initMapView];
    
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startHeadingLocation];
    
    if ([AMapLocationManager headingAvailable] == NO)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持方向功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        
        MAPinAnnotationView *annotationView = _annotationView;
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            annotationView.canShowCallout   = NO;
            annotationView.animatesDrop     = NO;
            annotationView.draggable        = NO;
            annotationView.image            = [UIImage imageNamed:@"icon_location.png"];
            _annotationView = annotationView;
            _annotationViewAngle = 0;
        }
        
        return annotationView;
    }
    
    return nil;
}

@end
