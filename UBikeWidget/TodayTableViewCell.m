//
//  TodayTableViewCell.m
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/27.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import "TodayTableViewCell.h"

typedef enum:NSInteger {
    
    IPhone5 = 0,
    IPhone6and7 = 1,
    IPhone6and7Plus = 2
    
} IPhoneSize;

@implementation TodayTableViewCell
{
    IPhoneSize iphoneSize;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // 螢幕寬度
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    // 螢幕高度
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
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
    
    
    [self customUI];
}

-(void)customUI{
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL * baseURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.SharedUserDefault"];
    NSURL * bileImageURL = [NSURL URLWithString:@"Bike.png" relativeToURL:baseURL];
    NSURL * parkingLotImageURL = [NSURL URLWithString:@"ParkingLot.png" relativeToURL:baseURL];
    // Custom Stop Name Label UI
    switch (iphoneSize) {
        case IPhone5:
            
            _stopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 15, self.frame.origin.y + 8, 180, 20)];
            break;
        case IPhone6and7:
            
            _stopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 15, self.frame.origin.y + 8, 230, 20)];
            break;
        case IPhone6and7Plus:
            
            _stopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 15, self.frame.origin.y + 8, 270, 20)];
            
            break;
        default:
            _stopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 15, self.frame.origin.y + 8, 150, 20)];
            break;
    }
    
    // Custom Bike ImageView UI
    _bikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_stopNameLabel.frame.origin.x + _stopNameLabel.frame.size.width + 7,_stopNameLabel.frame.origin.y, 20, 20)];
    _bikeImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:bileImageURL]];
    
    // Custom BikeCount Label UI
    _bikeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bikeImageView.frame.origin.x + _bikeImageView.frame.size.width + 2, _bikeImageView.frame.origin.y, 22, 20)];
    _bikeCountLabel.textColor = [UIColor whiteColor];
    _bikeCountLabel.textAlignment = NSTextAlignmentCenter;
    
    // Custom Parking Lot ImageView UI
    _parkingLotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_bikeCountLabel.frame.origin.x + _bikeCountLabel.frame.size.width + 4, _bikeCountLabel.frame.origin.y, 20, 20)];
    _parkingLotImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:parkingLotImageURL]];
    
    // Custom Parking Lot Label UI
    _stopCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_parkingLotImageView.frame.origin.x + _parkingLotImageView.frame.size.width, _parkingLotImageView.frame.origin.y, 30, 20)];
    _stopCountLabel.textColor = [UIColor whiteColor];
    _stopCountLabel.textAlignment = NSTextAlignmentCenter;

    
    [self addSubview:_stopNameLabel];
    [self addSubview:_bikeImageView];
    [self addSubview:_bikeCountLabel];
    [self addSubview:_parkingLotImageView];
    [self addSubview:_stopCountLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
