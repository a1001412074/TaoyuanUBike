//
//  TodayViewController.m
//  UBikeWidget
//
//  Created by 沈維庭 on 2017/2/27.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TodayTableViewCell.h"
#import "AppDelegate.h"
@interface TodayViewController () <NCWidgetProviding,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * saveUserLikeStop;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    saveUserLikeStop = [NSMutableArray new];
    
    _tableView.tableFooterView = [UIView new];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString * lastUpdataTime = [dateFormatter stringFromDate:currentDate];
    
    [saveUserLikeStop addObject:lastUpdataTime];
    
    self.preferredContentSize = CGSizeMake(320.0, 320.0);
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
//    [self downloadJson];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    
    
    if(activeDisplayMode == NCWidgetDisplayModeExpanded) {
        // 顯示更多
        self.preferredContentSize = CGSizeMake(320.0, saveUserLikeStop.count * 36 + 2);
    } else if(activeDisplayMode == NCWidgetDisplayModeCompact) {
        // 顯示更少  ios只能設定 顯示更多 的寬高可以多少，要設定顯示更少時的畫面大小的話可以更改只是改了執行時還會被指定為系統預設的
        self.preferredContentSize = CGSizeMake(0, 100.0);
    }
    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    
    NSUserDefaults * shardDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.SharedUserDefault"];
    NSArray * userDefault = [shardDefault objectForKey:@"likePress"];
    
    if(userDefault.count == 0) {
        [self collect];
        _tableView.hidden = YES;
    } else {
        [self downloadJsonCompletionHandler:completionHandler];
    }
    
    
    
}

-(void)downloadJsonCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSUserDefaults * shardDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.SharedUserDefault"];
    NSArray * userDefault = [shardDefault objectForKey:@"likePress"];
    NSLog(@"user:%@",userDefault);
    
    NSURL * url = [NSURL URLWithString:@"http://data.tycg.gov.tw/api/v1/rest/datastore/a1b4714b-3b75-4ff8-a8f2-cc377e4eaa0f?format=json"];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error) {
            NSLog(@"Download Fail: %@",error);
        }
        
        NSArray * resultJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        NSArray * uBikeLocationInfo = [[resultJson valueForKey:@"result"]valueForKey:@"records"];

        for(int i = 0 ; i < userDefault.count ; i++) {
            NSString * _id = [userDefault[i] valueForKey:@"_id"];
            for(int j = 0 ; j < uBikeLocationInfo.count ; j++) {
                NSString * stopID = [uBikeLocationInfo[j] valueForKey:@"_id"];
                if([_id isEqual:stopID]) {
                    [saveUserLikeStop addObject:uBikeLocationInfo[j]];
                }
            }
        }
        NSLog(@"love:%@",saveUserLikeStop);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
        
        if(completionHandler != nil) {
            completionHandler(NCUpdateResultNewData);
        }
    }];
    [task resume];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return saveUserLikeStop.count;
    return saveUserLikeStop.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TodayTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        if (indexPath.row == 0) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        } 
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        if (indexPath.row == 0) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        cell.stopNameLabel.frame = CGRectMake(0, cell.frame.origin.y + 8, cell.frame.size.width, 20);
        cell.stopNameLabel.textAlignment = NSTextAlignmentCenter;
        
        cell.stopNameLabel.text = [NSString stringWithFormat:@"上次更新時間: %@",saveUserLikeStop[indexPath.row]];
        cell.stopNameLabel.font = [UIFont systemFontOfSize:14];
        cell.bikeImageView.hidden = YES;
        cell.bikeCountLabel.hidden = YES;
        cell.parkingLotImageView.hidden = YES;
        cell.stopCountLabel.hidden = YES;
    } else {
        cell.stopNameLabel.text = [[saveUserLikeStop objectAtIndex:indexPath.row] valueForKey:@"sna"];
        cell.bikeCountLabel.text = [[saveUserLikeStop objectAtIndex:indexPath.row] valueForKey:@"sbi"];
        cell.stopCountLabel.text = [[saveUserLikeStop objectAtIndex:indexPath.row] valueForKey:@"bemp"];
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * stopID = [[saveUserLikeStop objectAtIndex:indexPath.row]valueForKey:@"_id"];
    [self openAPPShowStopInfoFromURLWithStopID:stopID];
    
}

-(void)collect {
    
    UILabel * notCollectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 30)];
    notCollectLabel.text = @"目前沒有喜歡的收藏據點";
    notCollectLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton * goToCollectBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - self.view.frame.size.width / 6, notCollectLabel.frame.origin.y + notCollectLabel.frame.size.height + 5, 100, 20)];
    [goToCollectBtn addTarget:self action:@selector(openUBikeApp) forControlEvents:UIControlEventTouchUpInside];
    [goToCollectBtn setTitle:@"前往收藏" forState:UIControlStateNormal];
    goToCollectBtn.titleLabel.textColor = [UIColor redColor];

    
    [self.view addSubview:notCollectLabel];
    [self.view addSubview:goToCollectBtn];
    
}

-(void)openUBikeApp{
    
    NSURL * url = [NSURL URLWithString:@"UBikeApp://"];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        NSLog(@"OpenURL Done:%i",success);
    }];
    
}

-(void)openAPPShowStopInfoFromURLWithStopID:(NSString*) stopID {
    NSLog(@"today:%@",stopID);
    NSString * urlStr = [NSString stringWithFormat:@"UBikeApp://%@",stopID];
    NSURL * url = [NSURL URLWithString:urlStr];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        NSLog(@"OpenURL Done:%i",success);
    }];
    
}



@end
