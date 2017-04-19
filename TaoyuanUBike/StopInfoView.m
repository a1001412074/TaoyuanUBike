//
//  StopInfoView.m
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/24.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import "StopInfoView.h"

typedef enum:NSInteger {
    
    IPhone5 = 0,
    IPhone6and7 = 1,
    IPhone6and7Plus = 2
    
} IPhoneSize;

@implementation StopInfoView
{
    IPhoneSize iphoneSize;
}
-(instancetype) init {
    
    self = [super initWithFrame:CGRectZero];
    // 螢幕寬度
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    // 螢幕高度
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGRect rect;
    if(screenWidth == 320 && screenHeight == 568) {
        // 5S
        iphoneSize = IPhone5;
    } else if(screenWidth == 375 && screenHeight == 667) {
        // 6 and 7
        iphoneSize = IPhone6and7;
    } else if(screenWidth == 414 && screenHeight == 736) {
        // Plus
        iphoneSize = IPhone6and7Plus;
    }
    
    switch (iphoneSize) {
        case IPhone5:
            rect = CGRectMake(0, screenHeight * 0.7, screenWidth, screenHeight - screenHeight * 0.7);
            break;
        case IPhone6and7:
            rect = CGRectMake(0, screenHeight * 0.75, screenWidth, screenHeight - screenHeight * 0.75);
            break;
        case IPhone6and7Plus:
            rect = CGRectMake(0, screenHeight * 0.78, screenWidth, screenHeight - screenHeight * 0.78);
            break;
            
        default:
            break;
    }
    
    self.frame = rect;
    self.backgroundColor = [UIColor colorWithRed:60.0 / 255.0 green:67.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    [self createStopNameLabel];
    [self createStartAndCancelButton];
    [self createStatusImageViewAndLabel];
    [self createCanUseQuantityImageViewAndLabel];
    [self createCanStopBikeImageViewAndLabel];
    [self careatActivity];
    
    NSLog(@"x:%lf",self.frame.origin.x);
    NSLog(@"y:%lf",self.frame.origin.y);
    NSLog(@"w:%lf",self.frame.size.width);
    NSLog(@"h:%lf",self.frame.size.height);
    
    return self;
}

-(void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0f);
    // 第一點
    CGContextMoveToPoint(context, self.frame.origin.x + 10, self.frame.origin.x + 70);
    //第二點
    CGContextAddLineToPoint(context, self.frame.size.width - 10, self.frame.origin.x + 70);
    
    CGContextStrokePath(context);
}

-(void)createStopNameLabel {
    
    _stopNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x + 10, self.frame.origin.x + 10, 200 ,30)];
    _stopNameLabel.textColor = [UIColor whiteColor];
    
    UIImageView * locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x + 10, self.frame.origin.x + 70 - 27, 20, 20)];
    
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(locationImageView.frame.origin.x + 22, self.frame.origin.x + 70 - 27, 90, 20)];
    _distanceLabel.font = [UIFont systemFontOfSize:14];
    _distanceLabel.textColor = [UIColor whiteColor];
    
    locationImageView.image = [UIImage imageNamed:@"Location.png"];
    
    UIImageView * refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_distanceLabel.frame.origin.x + _distanceLabel.frame.size.width + 2, _distanceLabel.frame.origin.y, 20, 20)];
    refreshImageView.image = [UIImage imageNamed:@"Refresh.png"];
    
    _refreshLastTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(refreshImageView.frame.origin.x + 22, refreshImageView.frame.origin.y, 90, 20)];
    
    _refreshLastTimeLabel.textColor = [UIColor whiteColor];
    _refreshLastTimeLabel.font = [UIFont systemFontOfSize:14];
    
    [self addSubview:locationImageView];
    [self addSubview:_stopNameLabel];
    [self addSubview:_distanceLabel];
    [self addSubview:refreshImageView];
    [self addSubview:_refreshLastTimeLabel];
}

-(void)createStartAndCancelButton {
    
    UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, _stopNameLabel.frame.origin.y, 30, 30)];
    UIImage * cancelImage = [UIImage imageNamed:@"Cancel.png"];
    [cancelBtn setImage:cancelImage forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    _starBtn = [[UIButton alloc] initWithFrame:CGRectMake(cancelBtn.frame.origin.x - 40, _stopNameLabel.frame.origin.y, 30, 30)];
    

    switch (iphoneSize) {
        case IPhone5:
            cancelBtn.frame = CGRectMake(self.frame.size.width - 40, _stopNameLabel.frame.origin.y, 25, 25);
            _starBtn = [[UIButton alloc] initWithFrame:CGRectMake(cancelBtn.frame.origin.x - 40, _stopNameLabel.frame.origin.y, 25, 25)];
            break;
        default:
            break;
    }
   
    [self addSubview:_starBtn];
    [self addSubview:cancelBtn];
}



-(void)cancelBtnAction {
    
    [self removeFromSuperview];
}


#pragma Mark Create Status Info UI
-(void)createStatusImageViewAndLabel {
    
    UIImageView * statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 12, self.frame.origin.x + 85, 20, 20)];
    statusImageView.image = [UIImage imageNamed:@"Status.png"];
    [self addSubview:statusImageView];
    
    UILabel * statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusImageView.frame.size.width + statusImageView.frame.origin.x + 2, statusImageView.frame.origin.y, self.frame.size.width / 3 - 50, 20)];
    statusLabel.text = @"狀態";
    statusLabel.textColor = [UIColor whiteColor];
    [self addSubview:statusLabel];
    
    switch (iphoneSize) {
        case IPhone5:
            _stopStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 15 ,(self.frame.size.height - statusImageView.frame.origin.y + 20) / 4 + statusImageView.frame.origin.y + 10,self.frame.size.width / 3, 30)];
            _stopStatusLabel.font = [UIFont systemFontOfSize:20];
            break;
        case IPhone6and7:
            _stopStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 12 - 10 ,(self.frame.size.height - statusImageView.frame.origin.y + 20) / 4 + statusImageView.frame.origin.y + 10,self.frame.size.width / 3, 30)];
            _stopStatusLabel.font = [UIFont systemFontOfSize:20];
            break;
        case IPhone6and7Plus:
            _stopStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 12 - 10 ,(self.frame.size.height - statusImageView.frame.origin.y + 20) / 4 + statusImageView.frame.origin.y + 10,self.frame.size.width / 3, 30)];
            _stopStatusLabel.font = [UIFont systemFontOfSize:20];
            break;
        default:
            break;
    }
    
    _stopStatusLabel.textColor = [UIColor whiteColor];
    [self addSubview:_stopStatusLabel];
    
}

-(void)createCanUseQuantityImageViewAndLabel {
 
    UIImageView * bikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 + 15,self.frame.origin.x + 85,20,20)];
    
    UILabel * canUseQuantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(bikeImageView.frame.size.width + bikeImageView.frame.origin.x + 2, bikeImageView.frame.origin.y,self.frame.size.width / 3 - 50, 20)];
    
    switch (iphoneSize) {
        case IPhone5:
            bikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 ,self.frame.origin.x + 85,20,20)];
            canUseQuantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(bikeImageView.frame.size.width + bikeImageView.frame.origin.x + 2, bikeImageView.frame.origin.y,self.frame.size.width / 3, 20)];
            
            _bikeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 10, (self.frame.size.height - bikeImageView.frame.origin.y + 20) / 4 + bikeImageView.frame.origin.y + 10, 50, 30)];
            _bikeCountLabel.font = [UIFont systemFontOfSize:24];
            break;
        case IPhone6and7:
            _bikeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 5, (self.frame.size.height - bikeImageView.frame.origin.y + 20) / 4 + bikeImageView.frame.origin.y + 10, 50, 30)];
            _bikeCountLabel.font = [UIFont systemFontOfSize:24];
            break;
        case IPhone6and7Plus:
            _bikeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 15, (self.frame.size.height - bikeImageView.frame.origin.y + 20) / 4 + bikeImageView.frame.origin.y + 10, 50, 30)];
            _bikeCountLabel.font = [UIFont systemFontOfSize:24];
            break;
        default:
            break;
    }
    
    bikeImageView.image = [UIImage imageNamed:@"Bike.png"];
    
    canUseQuantityLabel.text = @"可借數量";
    canUseQuantityLabel.textColor = [UIColor whiteColor];
    
    _bikeCountLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:canUseQuantityLabel];
    [self addSubview:bikeImageView];
    [self addSubview:_bikeCountLabel];
}

-(void)createCanStopBikeImageViewAndLabel {
    
    UIImageView * stopBikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width / 3) * 2 + 15, self.frame.origin.x + 85, 20, 20)];
    
    UILabel * stopBikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(stopBikeImageView.frame.size.width + stopBikeImageView.frame.origin.x + 2, stopBikeImageView.frame.origin.y, self.frame.size.width / 3 - 50, 20)];
    
    
    
    switch (iphoneSize) {
        case IPhone5:
            stopBikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width / 3) * 2, self.frame.origin.x + 85, 20, 20)];
            stopBikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(stopBikeImageView.frame.size.width + stopBikeImageView.frame.origin.x + 2, stopBikeImageView.frame.origin.y, self.frame.size.width / 3 , 20)];
            
             _stopCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 * 2 + stopBikeLabel.frame.size.width / 2 - 10, (self.frame.size.height - stopBikeImageView.frame.origin.y + 20) / 4 + stopBikeImageView.frame.origin.y + 10, 50, 30)];
            _stopCountLabel.font = [UIFont systemFontOfSize:24];
            break;
        case IPhone6and7:
            _stopCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 * 2 + stopBikeLabel.frame.size.width / 2 + 15, (self.frame.size.height - stopBikeImageView.frame.origin.y + 20) / 4 + stopBikeImageView.frame.origin.y + 10, 50, 30)];
            _stopCountLabel.font = [UIFont systemFontOfSize:24];
            break;
        case IPhone6and7Plus:
            _stopCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 * 2 + stopBikeLabel.frame.size.width / 2 + 15, (self.frame.size.height - stopBikeImageView.frame.origin.y + 20) / 4 + stopBikeImageView.frame.origin.y + 10, 50, 30)];
            _stopCountLabel.font = [UIFont systemFontOfSize:24];
            break;
        default:
            break;
    }
    
    stopBikeImageView.image = [UIImage imageNamed:@"ParkingLot.png"];
    stopBikeLabel.text = @"可停數量";

    stopBikeLabel.textColor = [UIColor whiteColor];
    _stopCountLabel.textColor = [UIColor whiteColor];
    [self addSubview:stopBikeImageView];
    [self addSubview:stopBikeLabel];
    
    [self addSubview:_stopCountLabel];
}

-(void)careatActivity {
    
    if(_loadingDistanceActivity != nil) {
        [_loadingDistanceActivity removeFromSuperview];
    }
    
    _loadingDistanceActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(_distanceLabel.frame.size.width / 2, _distanceLabel.frame.origin.y, 20, 20)];
    _loadingDistanceActivity.color = [UIColor whiteColor];
    _loadingDistanceActivity.hidesWhenStopped = true;
    [self addSubview:_loadingDistanceActivity];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
