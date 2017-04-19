//
//  TodayTableViewCell.h
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/27.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayTableViewCell : UITableViewCell

@property (strong,nonatomic) UILabel * stopNameLabel;
@property (strong,nonatomic) UIImageView * bikeImageView;
@property (strong,nonatomic) UILabel * bikeCountLabel;
@property (strong,nonatomic) UIImageView * parkingLotImageView;
@property (strong,nonatomic) UILabel * stopCountLabel;

@end
