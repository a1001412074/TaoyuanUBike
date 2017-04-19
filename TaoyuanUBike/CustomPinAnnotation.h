//
//  CustomPinAnnotation.h
//  TaoyuanUBike
//
//  Created by 沈維庭 on 2017/2/23.
//  Copyright © 2017年 WEITING. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomPinAnnotation : MKPointAnnotation

@property NSInteger identifier;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) UIImage *image;


-(CustomPinAnnotation*) createAnnotationWithcoordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString*)subtitle color:(UIColor*)color;

-(UIImage*)CustomAnnotationImageWithPhoto:(UIImage*) image;

@end
