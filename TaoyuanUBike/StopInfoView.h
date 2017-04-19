//
//  StopInfoView.h
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/24.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopInfoView : UIView

-(instancetype)init;

@property (strong,nonatomic) NSArray * stopInfo;
@property (strong,nonatomic) UILabel * stopNameLabel;
@property (strong,nonatomic) UILabel * stopStatusLabel;
@property (strong,nonatomic) UILabel * bikeCountLabel;
@property (strong,nonatomic) UILabel * stopCountLabel;
@property (strong,nonatomic) UIButton * starBtn;
@property (strong,nonatomic) UILabel * distanceLabel;
@property (strong,nonatomic) UILabel * refreshLastTimeLabel;
@property  UIActivityIndicatorView * loadingDistanceActivity;
@end
