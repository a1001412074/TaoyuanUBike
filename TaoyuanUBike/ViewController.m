//
//  ViewController.m
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/23.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import "ViewController.h"
#import "CustomPinAnnotation.h"
#import "StopInfoView.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "CustomCollectTableViewCell.h"
#import "Reachability.h"

#define JSONDATA_URL @"http://data.tycg.gov.tw/api/v1/rest/datastore/a1b4714b-3b75-4ff8-a8f2-cc377e4eaa0f?format=json"

@interface ViewController () <MKMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CLLocationManager * locationManager;
    CLLocation * userLocation;
    
    NSArray * resultJson;
    NSArray * uBikeLocationInfo;
    NSInteger count;
    MKAnnotationView * mkAnnotationView;
    NSMutableArray * likeMutableArray;
    StopInfoView * stopInfoView;

    UITableView * collectTableView;
    NSMutableArray * userCollerInfo;
    
    double distance;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UINavigationBar *homePageNavBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _mapView.delegate = self;
    
    locationManager = [CLLocationManager new];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    [self checkNetorkStaus];
    
    NSLog(@"%ld",(long)count);

    UIView * homaPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    homaPageView.backgroundColor = [UIColor colorWithRed:60.0 / 255.0 green:67.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
    [self.view addSubview:homaPageView];

    _homePageNavBar.barTintColor = [UIColor colorWithRed:60.0 / 255.0 green:67.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStopInfoFromWidget:) name:JUMP_TO_NOTIFICATION object:nil];
    
    [self savaIconToNSFile];
}



-(void) checkNetorkStaus {
    
    Reachability * reach = [Reachability reachabilityWithHostName:JSONDATA_URL];
    
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if(netStatus == NotReachable) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"請檢查網路連線是否正常" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self checkNetorkStaus];
            }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        });
        
    } else {
        
        [self downloadJsonCompletionHandler:^{
            
        }];
        
    }
    
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation * currentLocation = locations.lastObject;
    
    CLLocationCoordinate2D coordinate = currentLocation.coordinate;
    
    userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
        [_mapView setRegion:region animated:true];
    });
    
}

#pragma mark - DownloadJsonData
-(void)downloadJsonCompletionHandler:(void(^)()) done {
    
    NSURL * url = [NSURL URLWithString:JSONDATA_URL];
    
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error) {
            NSLog(@"Download Fail: %@",error);
            return;
        }
        
        resultJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self customAnnotation];
        });
        
        done();
        
    }];
    
    [task resume];
    
}

-(void) savaIconToNSFile {
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL * baseURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.SharedUserDefault"];
    
    NSArray * imageFileArray =@[@"Status.png",@"Bike.png",@"ParkingLot.png"];
    for(int i = 0 ; i < imageFileArray.count ; i++) {
        NSURL * url = [[NSURL alloc] initWithString:imageFileArray[i] relativeToURL:baseURL];
        UIImage * image = [UIImage imageNamed:imageFileArray[i]];
        NSData * imageData = UIImagePNGRepresentation(image);
        [imageData writeToURL:url atomically:true];
    }

    
}

#pragma mark - MKMapViewDelegate And StopInfoView Methods
-(void) customAnnotation {
    
    uBikeLocationInfo = [[resultJson valueForKey:@"result"]valueForKey:@"records"];
//    NSLog(@"result:%@",uBikeLocationInfo);
    count = 0;
    for(int i = 0 ; i <uBikeLocationInfo.count ; i++) {
        
        double lat = [[uBikeLocationInfo[i]valueForKey:@"lat"] doubleValue];
        double lon = [[uBikeLocationInfo[i]valueForKey:@"lng"] doubleValue];
        
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
        
        CustomPinAnnotation * customPinAnnotation = [CustomPinAnnotation new];
        customPinAnnotation = [customPinAnnotation createAnnotationWithcoordinate:location title:nil subtitle:nil color:nil];
        // 總車位(輛)
        double total = [[uBikeLocationInfo[i]valueForKey:@"tot"] doubleValue];
        // 可租用車輛數
        double bike = [[uBikeLocationInfo[i]valueForKey:@"sbi"] doubleValue];
        // 使用率
        double utilization = 100 - (bike / total) * 100;
//        NSLog(@"%lf",utilization);
        
        if(utilization >= 1 && utilization <= 10) {
            customPinAnnotation.image = [UIImage imageNamed:@"0%"];
        } else if(utilization >= 11 && utilization <= 20) {
            customPinAnnotation.image = [UIImage imageNamed:@"10%"];
        } else if(utilization >= 21 && utilization <= 30) {
            customPinAnnotation.image = [UIImage imageNamed:@"20%"];
        } else if(utilization >= 31 && utilization <= 40) {
            customPinAnnotation.image = [UIImage imageNamed:@"30%"];
        } else if(utilization >= 41 && utilization <= 50) {
            customPinAnnotation.image = [UIImage imageNamed:@"40%"];
        } else if(utilization >= 51 && utilization <= 60) {
            customPinAnnotation.image = [UIImage imageNamed:@"50%"];
        } else if(utilization >= 61 && utilization <= 70) {
            customPinAnnotation.image = [UIImage imageNamed:@"60%"];
        } else if(utilization >= 71 && utilization <= 80) {
            customPinAnnotation.image = [UIImage imageNamed:@"70%"];
        } else if(utilization >= 81 && utilization <= 90) {
            customPinAnnotation.image = [UIImage imageNamed:@"80%"];
        } else if(utilization >= 91 && utilization <= 99) {
            customPinAnnotation.image = [UIImage imageNamed:@"90%"];
        } else if(utilization == 100) {
            customPinAnnotation.image = [UIImage imageNamed:@"100%"];
        }
        
        customPinAnnotation.identifier = count;
        count++;
        
        [_mapView addAnnotation:customPinAnnotation];
    }
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if(![annotation isKindOfClass:[CustomPinAnnotation class]]) {
        return nil;
    }
    
    CustomPinAnnotation * customPinAnnotation = (CustomPinAnnotation*)annotation;
    
    NSString * storeID = @"store";
    
    MKAnnotationView * result = [mapView dequeueReusableAnnotationViewWithIdentifier:storeID];
    
    if(result == nil) {
        result = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:storeID];
    } else {
        result.annotation = annotation;
    }
    result.tag = customPinAnnotation.identifier;
    result.image = customPinAnnotation.image; 
    
    return result;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    mkAnnotationView = view;
    
    NSInteger target = view.tag;
    NSArray * uBikeStopInfo = uBikeLocationInfo[target];
    
    NSLog(@"ID:%ld",(long)target);
    
    double lat = [[uBikeStopInfo valueForKey:@"lat"] doubleValue];
    double lon = [[uBikeStopInfo valueForKey:@"lng"] doubleValue];
    CLLocationCoordinate2D annotationLocation = CLLocationCoordinate2DMake(lat, lon);
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            // 不允許 App 使用定位服務的處理
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"定位尚未開啟" message:@"定位尚未開啟前無法顯示最佳路徑及距離" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * setting = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self focusAnnotation:annotationLocation];
                [self showDirection:annotationLocation];
            }];
            [alert addAction:cancel];
            [alert addAction:setting];
            [self presentViewController:alert animated:true completion:nil];
        } else {
            [self showTheStopInfo:uBikeStopInfo];
            [self showDirection:annotationLocation];
        }
    }
    
}

-(void)focusAnnotation:(CLLocationCoordinate2D) annotationLocation {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotationLocation, span);
    [_mapView setRegion:region animated:true];
    
}

-(void)showTheStopInfo:(NSArray*) stopInfo {
    
    [stopInfoView removeFromSuperview];
    
    stopInfoView = [[StopInfoView alloc]init];
    
//    NSLog(@"stopii:%@",stopInfo);
    stopInfoView.stopNameLabel.text = [stopInfo valueForKey:@"sna"];
    
    // The Stop Status
    NSString * act = [stopInfo valueForKey:@"act"];
    
    if([act isEqualToString:@"1"]) {
        stopInfoView.stopStatusLabel.text = @"可租可還";
    } else {
        stopInfoView.stopStatusLabel.text = @"維護中";
    }

    // The Stop Can use Bike Quantity
    NSString * sbi = [stopInfo valueForKey:@"sbi"];
    stopInfoView.bikeCountLabel.text = sbi;
    
    // The Stop Can Stop Bike Quantity
    NSString * bemp = [stopInfo valueForKey:@"bemp"];
    stopInfoView.stopCountLabel.text = bemp;
    
    // 收藏
    NSUserDefaults * shardDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.SharedUserDefault"];
    NSArray * userDefault = [shardDefault objectForKey:@"likePress"];
    [stopInfoView.starBtn setImage:[UIImage imageNamed:@"Star"] forState:UIControlStateNormal];
    NSLog(@"showdef:%@",userDefault);
    for(int i=0;i<userDefault.count;i++){
        NSString * stopID = [stopInfo valueForKey:@"_id"];
        NSString * likeStopID = [userDefault[i]valueForKey:@"_id"];
        if([stopID isEqual:likeStopID]){
            [stopInfoView.starBtn setImage:[UIImage imageNamed:@"Star2"] forState:UIControlStateNormal];
            stopInfoView.starBtn.enabled = NO;
        }
    }
    [stopInfoView.starBtn addTarget:self action:@selector(likePress) forControlEvents:UIControlEventTouchUpInside];
    
//    // 目標距離
//    stopInfoView.distanceLabel.text = [self targetDistance];
    [stopInfoView.loadingDistanceActivity startAnimating];
    
    // 上次更新時間
    stopInfoView.refreshLastTimeLabel.text = [self refreshLastTime:stopInfo];
    
//    NSLog(@"%@",userDefault);
    [self.view addSubview:stopInfoView];
    
}

-(NSString*)targetDistance {
    
    NSString * distanceStr = [NSString stringWithFormat:@"約 %.0f 公尺",distance];
    if(distance > 1000) {
        distance = distance / 1000;
        distanceStr = [NSString stringWithFormat:@"約 %.2f 公里",distance];
    }
    
    
    return distanceStr;
}

-(NSString*)refreshLastTime:(NSArray*) stopInfo{
    // 現在的時間
    NSDate * didseletAnnotationTime = [NSDate date];
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HHmm"];
    int didseletAnnotationTimeInt = [[dateFormatter stringFromDate:didseletAnnotationTime]intValue];
    
    // 取目前資料更新時間
    NSString * mday = [stopInfo valueForKey:@"mday"];
    NSRange range = NSMakeRange(8, 4);
    int updataTime = [[mday substringWithRange:range] intValue];
    
    NSString * lastTimeRefreshStr = [NSString stringWithFormat:@" %d 分鐘前",didseletAnnotationTimeInt - updataTime];
    NSLog(@"nowtime:%d",didseletAnnotationTimeInt);
    NSLog(@"updatatime:%d",updataTime);
    return lastTimeRefreshStr;
    
}

-(void)likePress {
    
    NSInteger identify = mkAnnotationView.tag;
    
    NSArray * uBikeStopInfo = uBikeLocationInfo[identify];
    NSString * _id = [uBikeStopInfo valueForKey:@"_id"];
    NSLog(@"_id:%@",_id);
    
    NSUserDefaults * shardDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.SharedUserDefault"];
    NSArray * userDefault = [shardDefault objectForKey:@"likePress"];
    
    NSLog(@"最愛:%@",userDefault);
    if(userDefault != nil && userDefault.count > 0) {
        likeMutableArray = [NSMutableArray arrayWithArray:userDefault];
        
    } else {
        likeMutableArray = [NSMutableArray new];
    }
    
    if([stopInfoView.starBtn.currentImage isEqual:[UIImage imageNamed:@"Star"]]) {
        // 沒收藏
        [stopInfoView.starBtn setImage:[UIImage imageNamed:@"Star2"] forState:UIControlStateNormal];
        
        [likeMutableArray addObject:uBikeStopInfo];
        stopInfoView.starBtn.enabled = NO;
        
    }
    

    NSLog(@"刪除:%@",likeMutableArray);
    [shardDefault setObject:likeMutableArray forKey:@"likePress"];
    [shardDefault synchronize];

}

-(void)showDirection:(CLLocationCoordinate2D) destination{
    
    [_mapView removeOverlays:_mapView.overlays];
    distance = 0;
    
    MKDirectionsRequest * mkDirectionsRequest = [MKDirectionsRequest new];
    MKMapItem * sourceMapItem = [MKMapItem mapItemForCurrentLocation];
//    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination];
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
    MKMapItem * destinationMkMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    mkDirectionsRequest.source = sourceMapItem;
    mkDirectionsRequest.destination = destinationMkMapItem;
    mkDirectionsRequest.requestsAlternateRoutes = YES;
    mkDirectionsRequest.transportType = MKDirectionsTransportTypeWalking;
    
    MKDirections * directions = [[MKDirections alloc] initWithRequest:mkDirectionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            NSLog(@"error:%@",error);
            return;
        }
        
        MKRoute * route = response.routes.firstObject;
        [_mapView addOverlay:route.polyline];
        
        distance = route.distance;
        
        // 目標距離
        stopInfoView.distanceLabel.text = [self targetDistance];
        
        [stopInfoView.loadingDistanceActivity stopAnimating];
        
        NSLog(@"距離:%f",route.distance);
    }];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer * renderer = [MKPolylineRenderer new];
    renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 3.0;
    renderer.strokeColor = [UIColor orangeColor];
    
    return renderer;
    
}

#pragma mark - Widgget Method
-(void)showStopInfoFromWidget:(NSNotification*) notification {
    
    NSString * stopIDStr = notification.object;
    NSInteger stopID = [stopIDStr integerValue];
    [stopInfoView removeFromSuperview];
//    NSLog(@"idd:%@",stopIDStr);
//    NSLog(@"array%@",uBikeLocationInfo);
    [self downloadJsonCompletionHandler:^{
        NSArray * stopInfoArray = [uBikeLocationInfo objectAtIndex:stopID - 1];
//        NSLog(@"stt:%@",stopInfoArray);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            double lat = [[stopInfoArray valueForKey:@"lat"] doubleValue];
            double lon = [[stopInfoArray valueForKey:@"lng"] doubleValue];
            //        NSLog(@"lon:%lf",lon);
            CLLocationCoordinate2D annotationLocation = CLLocationCoordinate2DMake(lat, lon);
            
            [self focusAnnotation:annotationLocation];
            
            [self showTheStopInfo:stopInfoArray];
            
            [self showDirection:annotationLocation];
            NSLog(@"widgetID:%@",[stopInfoArray valueForKey:@"_id"]);

        });
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.jumpToStopID = nil;
        
    }];
    
}
- (IBAction)showCollectViewAction:(id)sender {
    [self showCollectView];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(void)showCollectView {
    
    [stopInfoView removeFromSuperview];
    [collectTableView removeFromSuperview];
    
    // 螢幕寬度
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    // 螢幕高度
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    collectTableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * 0.2 / 2, screenHeight * 0.4 / 2, screenWidth * 0.8, screenHeight * 0.6)];
    collectTableView.delegate = self;
    collectTableView.dataSource = self;
    
    collectTableView.layer.cornerRadius = 10;
    collectTableView.layer.masksToBounds = YES;
    
    collectTableView.tableFooterView = [UIView new];

    collectTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    
    
    [collectTableView registerNib:[UINib nibWithNibName:@"CollectCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    [self getUserCollectInfo];
    [self.view addSubview:collectTableView];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userCollerInfo.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    CustomCollectTableViewCell * cell = (CustomCollectTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.stopNameLabel.text = [userCollerInfo[indexPath.row] valueForKey:@"sna"];
        
        [cell.starBtn addTarget:self action:@selector(cancelCollect:) forControlEvents:UIControlEventTouchUpInside];
        cell.starBtn.tag = indexPath.row;

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if(indexPath.row != 0) {
        
    double lat = [[userCollerInfo[indexPath.row] valueForKey:@"lat"]doubleValue];
    double lon = [[userCollerInfo[indexPath.row] valueForKey:@"lng"]doubleValue];
    CLLocationCoordinate2D theStopLocation = CLLocationCoordinate2DMake(lat, lon);
    
    NSString * _id = [userCollerInfo[indexPath.row] valueForKey:@"_id"];
    NSArray * stopInfoArray;
    for(int i = 0 ; i < uBikeLocationInfo.count ; i++) {
        if([_id isEqual:[uBikeLocationInfo[i]valueForKey:@"_id"]]) {
            stopInfoArray = uBikeLocationInfo[i];
        }
    }
    
    [collectTableView removeFromSuperview];
    [self focusAnnotation:theStopLocation];
    [self showTheStopInfo:stopInfoArray];
    [self showDirection:theStopLocation];
    //}
}


-(void)getUserCollectInfo {
    
    userCollerInfo = [NSMutableArray new];
    
    NSUserDefaults * shardDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.SharedUserDefault"];
    NSArray * userDefault = [shardDefault objectForKey:@"likePress"];
    userCollerInfo = [NSMutableArray arrayWithArray:userDefault];

    NSLog(@"user:%@",userCollerInfo);
}

-(void)cancelCollect:(UIButton*) sender {
    
    NSLog(@"inde:%@",userCollerInfo[sender.tag]);
    [userCollerInfo removeObjectAtIndex:sender.tag];
    
    [collectTableView reloadData];
    
    NSUserDefaults * shardDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.SharedUserDefault"];
    [shardDefault setObject:userCollerInfo forKey:@"likePress"];
    [shardDefault synchronize];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSArray * touchArray = [touches allObjects]; // 所有碰觸點
    UITouch * touch = touchArray.firstObject; // 最新的碰觸點
    CGPoint point = [touch locationInView:self.view]; // 哪個view上的碰處點
    UIView * tmp = [self.view hitTest:point withEvent:event];
    if(tmp != collectTableView) {
        [collectTableView removeFromSuperview];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
