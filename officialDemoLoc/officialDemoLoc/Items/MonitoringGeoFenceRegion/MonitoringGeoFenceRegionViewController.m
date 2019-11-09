//
//  MonitoringGeoFenceRegionViewController.m
//  officialDemoLoc
//
//  Created by eidan on 16/12/19.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MonitoringGeoFenceRegionViewController.h"

#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>

@interface MonitoringGeoFenceRegionViewController ()<MAMapViewDelegate,AMapGeoFenceManagerDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapGeoFenceManager *geoFenceManager;

@property (nonatomic, strong) UILabel *regionStatusLable;

@property (nonatomic, strong) CLLocation *userLocation;  //获得自己的位置，方便demo添加围栏进行测试，

@end

@implementation MonitoringGeoFenceRegionViewController

- (void)dealloc
{
    [self doClear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMapView];
    
    [self configGeoFenceManager];
    
    // Do any additional setup after loading the view.
}

//初始化地图
- (void)initMapView {
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
}

//初始化地理围栏manager
- (void)configGeoFenceManager {
    self.geoFenceManager = [[AMapGeoFenceManager alloc] init];
    self.geoFenceManager.delegate = self;
    self.geoFenceManager.activeAction = AMapGeoFenceActiveActionInside | AMapGeoFenceActiveActionOutside | AMapGeoFenceActiveActionStayed; //进入，离开，停留都要进行通知
    self.geoFenceManager.allowsBackgroundLocationUpdates = YES;  //允许后台定位
}

- (void)showInMapWithRegion:(AMapGeoFenceRegion *)region
{
    if (region == nil)
    {
        return;
    }

    switch ([region regionType]) {
        case AMapGeoFenceRegionTypeCircle:
        {
            AMapGeoFenceCircleRegion *circleRegion = (AMapGeoFenceCircleRegion *)region;
            MACircle *circleOverlay = [self showCircleInMap:circleRegion.center radius:circleRegion.radius];
            [self.mapView setVisibleMapRect:circleOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];   //设置地图的可见范围，让地图缩放和平移到合适的位置
        }
            break;
        case AMapGeoFenceRegionTypePolygon:
        {
            AMapGeoFencePolygonRegion *polygonRegion = (AMapGeoFencePolygonRegion *)region;
            MAPolygon *polygonOverlay = [self showPolygonInMap:polygonRegion.coordinates count:polygonRegion.count];
            [self.mapView setVisibleMapRect:polygonOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
        }
            break;
        case AMapGeoFenceRegionTypePOI:
        {
            AMapGeoFencePOIRegion *poiRegion = (AMapGeoFencePOIRegion *)region;
            [self showCircleInMap:poiRegion.center radius:poiRegion.radius];

        }
            break;
        case AMapGeoFenceRegionTypeDistrict:
        {
            AMapGeoFenceDistrictRegion *districtRegion = (AMapGeoFenceDistrictRegion *)region;
            for (NSArray *arealocation in districtRegion.polylinePoints) {
                
                CLLocationCoordinate2D *coorArr = malloc(sizeof(CLLocationCoordinate2D) * arealocation.count);
                
                for (int i = 0; i < arealocation.count; i++) {
                    AMapLocationPoint *point = [arealocation objectAtIndex:i];
                    coorArr[i] = CLLocationCoordinate2DMake(point.latitude, point.longitude);
                }
                
                MAPolygon *polygonOverlay = [self showPolygonInMap:coorArr count:arealocation.count];
                [self.mapView setVisibleMapRect:polygonOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
                
                free(coorArr);
                coorArr = NULL;
                
            }

        }
            break;

            
        default:
            break;
    }
}

//添加地理围栏对应的Overlay，方便查看。地图上显示圆
- (MACircle *)showCircleInMap:(CLLocationCoordinate2D )coordinate radius:(NSInteger)radius {
    MACircle *circleOverlay = [MACircle circleWithCenterCoordinate:coordinate radius:radius];
    [self.mapView addOverlay:circleOverlay];
    return circleOverlay;
}

//地图上显示多边形
- (MAPolygon *)showPolygonInMap:(CLLocationCoordinate2D *)coordinates count:(NSInteger)count {
    MAPolygon *polygonOverlay = [MAPolygon polygonWithCoordinates:coordinates count:count];
    [self.mapView addOverlay:polygonOverlay];
    return polygonOverlay;
}

// 清除上一次按钮点击创建的围栏
- (void)doClear {
    [self.mapView removeOverlays:self.mapView.overlays];  //把之前添加的Overlay都移除掉
    [self.geoFenceManager removeAllGeoFenceRegions];  //移除所有已经添加的围栏，如果有正在请求的围栏也会丢弃
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeRegionStatusLable) object:nil];
    [self removeRegionStatusLable];
}

// 清除围栏状态信息显示
- (void)removeRegionStatusLable
{
    if (_regionStatusLable != nil)
    {
        [_regionStatusLable removeFromSuperview];
    }
}

#pragma mark xib btns click
// 添加地址围栏
- (IBAction)addGeoFenceRegion:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"添加地址围栏" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"添加圆形围栏",@"添加多边形围栏",@"添加POI关键词围栏",@"添加POI周边围栏",@"添加行政区域围栏", nil];
    [sheet showInView:[self view]];
}

// 暂停／开始地址围栏
- (IBAction)activeGeoFenceRegion:(id)sender{
    
    if ([[self.geoFenceManager geoFenceRegionsWithCustomID:nil] count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有地址围栏，请添加" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if ([[(UIButton *)sender currentTitle] isEqualToString:@"暂停地址围栏"] == YES)
    {
        if ([self pauseGeoFenceRegion] == YES)
        {
            [(UIButton *)sender setTitle:@"开始地址围栏" forState:UIControlStateNormal];
        }
    }
    else
    {
        [self startGeoFenceRegion];
        [(UIButton *)sender setTitle:@"暂停地址围栏" forState:UIControlStateNormal];
    }
}

//添加圆形围栏按钮点击
- (void)addGeoFenceCircleRegion:(id)sender {
    [self doClear];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.908692, 116.397477); //天安门
    if (self.userLocation) {
        coordinate = self.userLocation.coordinate;
    }
    [self.geoFenceManager addCircleRegionForMonitoringWithCenter:coordinate radius:300 customID:@"circle_1"];
}

//添加多边形围栏按钮点击
- (void)addGeoFencePolygonRegion:(id)sender {
    NSInteger count = 4;
    CLLocationCoordinate2D *coorArr = malloc(sizeof(CLLocationCoordinate2D) * count);
    
    coorArr[0] = CLLocationCoordinate2DMake(39.933921, 116.372927);     //平安里地铁站
    coorArr[1] = CLLocationCoordinate2DMake(39.907261, 116.376532);     //西单地铁站
    coorArr[2] = CLLocationCoordinate2DMake(39.900611, 116.418161);     //崇文门地铁站
    coorArr[3] = CLLocationCoordinate2DMake(39.941949, 116.435497);     //东直门地铁站
    
    [self doClear];
    [self.geoFenceManager addPolygonRegionForMonitoringWithCoordinates:coorArr count:count customID:@"polygon_1"];
    
    free(coorArr);
    coorArr = NULL;
}

//添加POI关键词围栏按钮点击
- (void)addGeoFencePOIKeywordRegion:(id)sender {
    [self doClear];
    [self.geoFenceManager addKeywordPOIRegionForMonitoringWithKeyword:@"北京大学" POIType:@"高等院校" city:@"北京" size:20 customID:@"poi_1"];
}

//添加POI周边围栏按钮点击
- (void)addGeoFencePOIAroundRegion:(id)sender {
    [self doClear];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.908692, 116.397477); //天安门
    [self.geoFenceManager addAroundPOIRegionForMonitoringWithLocationPoint:coordinate aroundRadius:10000 keyword:@"肯德基" POIType:@"050301" size:20 customID:@"poi_2"];
}

//添加行政区域围栏按钮点击
- (void)addGeoFenceDistrictRegion:(id)sender {
    [self doClear];
    [self.geoFenceManager addDistrictRegionForMonitoringWithDistrictName:@"海淀区" customID:@"district_1"];
}

- (BOOL)pauseGeoFenceRegion
{
    BOOL ret = NO;
    NSArray *geoFenceRegions = [self.geoFenceManager monitoringGeoFenceRegionsWithCustomID:nil];
    for (AMapGeoFenceRegion *region in geoFenceRegions) {
//        [self.geoFenceManager pauseTheGeoFenceRegion:region];
        [self.geoFenceManager pauseGeoFenceRegionsWithCustomID:[region customID]];
        ret = YES;
    }
    [self.mapView removeOverlays:self.mapView.overlays];  //把之前添加的Overlay都移除掉

    return ret;
}

- (BOOL)startGeoFenceRegion
{
    BOOL ret = NO;
    NSArray *geoFenceRegions = [self.geoFenceManager pausedGeoFenceRegionsWithCustomID:nil];
    for (AMapGeoFenceRegion *region in geoFenceRegions) {
//        if ([self.geoFenceManager startTheGeoFenceRegion:region] == YES)
//        {
//            ret = YES;
//            [self showInMapWithRegion:region];
//        }
//        else
        {
            if ([[self.geoFenceManager startGeoFenceRegionsWithCustomID:[region customID]] count] > 0)
            {
                ret = YES;
            }
            [self showInMapWithRegion:region];
        }
    }
    return ret;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self addGeoFenceCircleRegion:nil];
    }
    else if (buttonIndex  == 1)
    {
        [self addGeoFencePolygonRegion:nil];
    }
    else if (buttonIndex  == 2)
    {
        [self addGeoFencePOIKeywordRegion:nil];
    }
    else if (buttonIndex  == 3)
    {
        [self addGeoFencePOIAroundRegion:nil];
    }
    else if (buttonIndex  == 4)
    {
        [self addGeoFenceDistrictRegion:nil];
    }
}

#pragma mark - AMapGeoFenceManagerDelegate

// 如果需要后台定位权限时，需要实现
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

//添加地理围栏完成后的回调，成功与失败都会调用
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error {
    
    if ([customID hasPrefix:@"circle"]) {
        if (error) {
            NSLog(@"======= circle error %@",error);
        } else {
            AMapGeoFenceCircleRegion *circleRegion = (AMapGeoFenceCircleRegion *)regions.firstObject;  //一次添加一个圆形围栏，只会返回一个
            MACircle *circleOverlay = [self showCircleInMap:circleRegion.center radius:circleRegion.radius];
            [self.mapView setVisibleMapRect:circleOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];   //设置地图的可见范围，让地图缩放和平移到合适的位置
        }
    } else if ([customID isEqualToString:@"polygon_1"]) {
        if (error) {
            NSLog(@"=======polygon error %@",error);
        } else {
            AMapGeoFencePolygonRegion *polygonRegion = (AMapGeoFencePolygonRegion *)regions.firstObject;
            MAPolygon *polygonOverlay = [self showPolygonInMap:polygonRegion.coordinates count:polygonRegion.count];
            [self.mapView setVisibleMapRect:polygonOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
        }
    } else if ([customID isEqualToString:@"poi_1"]) {
        if (error) {
            NSLog(@"======== poi1 error %@",error);
        } else {
            
            for (AMapGeoFencePOIRegion *region in regions) {
                [self showCircleInMap:region.center radius:region.radius];
            }
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.908692, 116.397477); //天安门
            self.mapView.centerCoordinate = coordinate;
            self.mapView.zoomLevel = 11;
            
        }
    } else if ([customID isEqualToString:@"poi_2"]) {
        if (error) {
            NSLog(@"======== poi2 error %@",error);
        } else {
            for (AMapGeoFencePOIRegion *region in regions) {
                [self showCircleInMap:region.center radius:region.radius];
            }
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.908692, 116.397477); //天安门
            self.mapView.centerCoordinate = coordinate;
            self.mapView.zoomLevel = 13;
        }
    } else if ([customID isEqualToString:@"district_1"]) {
        if (error) {
            NSLog(@"======== district1 error %@",error);
        } else {
            
            for (AMapGeoFenceDistrictRegion *region in regions) {
                
                for (NSArray *arealocation in region.polylinePoints) {
                    
                    CLLocationCoordinate2D *coorArr = malloc(sizeof(CLLocationCoordinate2D) * arealocation.count);
                    
                    for (int i = 0; i < arealocation.count; i++) {
                        AMapLocationPoint *point = [arealocation objectAtIndex:i];
                        coorArr[i] = CLLocationCoordinate2DMake(point.latitude, point.longitude);
                    }
                    
                    MAPolygon *polygonOverlay = [self showPolygonInMap:coorArr count:arealocation.count];
                    [self.mapView setVisibleMapRect:polygonOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
                    
                    free(coorArr);
                    coorArr = NULL;
                    
                }
                
            }
        }
    }
}

//地理围栏状态改变时回调，当围栏状态的值发生改变，定位失败都会调用
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error {
    if (error) {
        NSLog(@"status changed error %@",error);
    }else{
        NSLog(@"status changed %@",[region description]);
        
        CGRect frame = [self view].frame;
        if (_regionStatusLable == nil)
        {
            _regionStatusLable = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 140, frame.size.height, 105)];
            [_regionStatusLable setNumberOfLines:3];
        }
        
        NSString *status = @"unknown";
        switch (region.fenceStatus) {
            case AMapGeoFenceRegionStatusInside:
                status = @"Inside";
                break;
            case AMapGeoFenceRegionStatusOutside:
                status = @"Outside";
                break;
            case AMapGeoFenceRegionStatusStayed:
                status = @"Stayed";
                break;

            default:
                break;
        }
        [_regionStatusLable setText:[NSString stringWithFormat:@"%@ %@", status, [region description]]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeRegionStatusLable) object:nil];
        [self performSelector:@selector(removeRegionStatusLable) withObject:nil afterDelay:30];
        if ([_regionStatusLable superview] == nil)
        {
            [self.view addSubview:_regionStatusLable];
        }
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    self.userLocation = userLocation.location;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolygon class]]) {
        MAPolygonRenderer *polylineRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        polylineRenderer.lineWidth = 3.0f;
        polylineRenderer.strokeColor = [UIColor orangeColor];
        
        return polylineRenderer;
    } else if ([overlay isKindOfClass:[MACircle class]]) {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 3.0f;
        circleRenderer.strokeColor = [UIColor purpleColor];
        
        return circleRenderer;
    }
    return nil;
}

- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = YES;
        annotationView.draggable                    = NO;
        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
    
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
