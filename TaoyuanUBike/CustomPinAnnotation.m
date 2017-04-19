//
//  CustomPinAnnotation.m
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/23.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import "CustomPinAnnotation.h"

@implementation CustomPinAnnotation

-(CustomPinAnnotation*) createAnnotationWithcoordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString*)subtitle color:(UIColor*)color {
    
    CustomPinAnnotation * annotation = [CustomPinAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = title;
    annotation.subtitle = subtitle;
    annotation.color = color;
    
    return annotation;
}

-(UIImage*)CustomAnnotationImageWithPhoto:(UIImage*) image {
    
    // 大頭針 (寬：70,高160)
    UIImage * backgroundImage = [UIImage imageNamed:@"AnnotationBackground.png"];
    // 大頭針上面的圖片
    UIImage * photoImage = image;
    // 產生畫布(maybe)
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 0.0f);
    // 第一張畫
    [backgroundImage drawInRect:CGRectMake(0, 0, 70, 160)];
    // 第二張畫
    [photoImage drawInRect:CGRectMake(5, 5, backgroundImage.size.width -10, backgroundImage.size.height/2 - 20)];
    // 輸出
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 畫畫結束
    UIGraphicsEndImageContext();
    
    return resultImage;
    
}

@end
