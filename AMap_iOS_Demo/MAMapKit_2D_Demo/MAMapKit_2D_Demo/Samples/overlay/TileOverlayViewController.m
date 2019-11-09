//
//  TileOverlayViewController.m
//  OfficialDemo3D
//
//  Created by Li Fei on 3/3/14.
//  Copyright (c) 2014 songjian. All rights reserved.
//

#import "TileOverlayViewController.h"

#import "LocalTileOverlay.h"

#define kTileOverlayLocalMinZ       11
#define kTileOverlayLocalMaxZ       13

@interface TileOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MATileOverlay *tileOverlay;

@end

@implementation TileOverlayViewController

#pragma mark - Utility

- (MATileOverlay *)constructTileOverlay
{
    MATileOverlay *tileOverlay = nil;
    tileOverlay = [[LocalTileOverlay alloc] init];
    tileOverlay.minimumZ = kTileOverlayLocalMinZ;
    tileOverlay.maximumZ = kTileOverlayLocalMaxZ;
    return tileOverlay;
}

- (void)addTileOverlay
{
    /* 删除之前的楼层. */
    [self.mapView removeOverlay:self.tileOverlay];
    
    /* 添加新的楼层. */
    self.tileOverlay = [self constructTileOverlay];
    
    [self.mapView addOverlay:self.tileOverlay];
}

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MATileOverlay class]])
    {
        MATileOverlayRenderer *renderer = [[MATileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    
    return nil;
}

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addTileOverlay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end
