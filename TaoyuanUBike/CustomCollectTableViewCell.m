//
//  CustomCollectTableViewCell.m
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/3/5.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import "CustomCollectTableViewCell.h"

@implementation CustomCollectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    // 螢幕寬度
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.frame = CGRectMake(0, 0, screenWidth, 43);
    
    _starBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.8 - 35, (self.frame.size.height - 20) / 2, 20, 20)];
    [_starBtn setImage:[UIImage imageNamed:@"Star2.png"] forState:UIControlStateNormal];
        
    [self addSubview:_starBtn];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
