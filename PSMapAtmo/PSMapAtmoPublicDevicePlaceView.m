//
//  PSNetAtmoPublicDevicePlaceView.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoPublicDevicePlaceView.h"

@interface PSNetAtmoPublicDevicePlaceView()

@property (nonatomic) float meassure;

@end

@implementation PSNetAtmoPublicDevicePlaceView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    DLogFuncName();
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor clearColor];
        
        self.frame = CGRectMake(0, 0, 10, 10);
        self.opaque = YES;
        
    }
    return self;
}

- (void) setMeassure:(float)meassure
{
    DLogFuncName();
    _meassure = meassure;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect
{
    DLogFuncName();
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * color = nil;
    if (self.meassure < 5.0)
    {
        color = [UIColor blueColor];
    }
    else if (self.meassure > 20)
    {
        color = [UIColor redColor];
    }
    else
    {
        color = [UIColor greenColor];
        
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    
    CGContextFillEllipseInRect(context, rect);
    
//    UIFont *font = [UIFont boldSystemFontOfSize: [UIFont smallSystemFontSize]];
//    NSString *label = [NSString stringWithFormat:@"%.2f",self.meassure ];
//    CGPoint labelLocation;
//    
//    if ([label length] == 1)
//    {
//        labelLocation = CGPointMake(rect.size.width / 2.0f, (rect.size.height / 2.0f) - (font.capHeight / 2.0f));
//    }
//    else if ([label length] == 2)
//    {
//        labelLocation = CGPointMake(rect.size.width / 2.0f, (rect.size.height / 2.0f) - (font.capHeight / 2.0f));
//    } else
//    {
//        labelLocation = CGPointMake(rect.size.width / 2.0f, (rect.size.height / 2.0f) - (font.capHeight / 2.0f));
//    }
//    
//    
//    [label drawAtPoint:labelLocation withFont:font];
//    [[UIColor whiteColor] set];  //or some color that contrasts with background
//    [label drawAtPoint:labelLocation withFont:font];
//    NSLog(@"Drawn label at (%f,%f)", labelLocation.x, labelLocation.y);
}
@end
