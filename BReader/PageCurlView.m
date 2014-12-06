//
//  PageView.m
//  PageDemo
//
//  Created by 4DTECH on 13-4-12.
//  Copyright (c) 2013年 4DTECH. All rights reserved.
//

#import "PageCurlView.h"

@implementation PageCurlView
@synthesize txtView =  _txtView,image =  _image;
- (id)initWithFrame:(CGRect)frame txt:(NSString *)text excludeStatusBar:(BOOL)bar
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        CGRect _rect = [[UIApplication sharedApplication] statusBarFrame];
        _txtView = [[UITextView alloc] initWithFrame:CGRectMake(0, _rect.size.height, frame.size.width , frame.size.height -_rect.size.height)];
        
        _viewForTxt = [[UIView alloc] initWithFrame:frame];
        _imgView = [[UIView alloc] initWithFrame:frame];
        
        [_txtView setShowsHorizontalScrollIndicator:NO];
        [_txtView setShowsVerticalScrollIndicator:NO];
        [_txtView setText:text];
        _txtView.editable= NO;
        [_txtView setUserInteractionEnabled:NO];
        [_viewForTxt addSubview:_txtView];
        
        
        [self addSubview:_viewForTxt];
        
        _imgView.clipsToBounds = YES;
        _viewForTxt.clipsToBounds = YES;
        // self.clipsToBounds = NO;
        
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, frame.size.width, frame.size.height)];
        
        [_imgView addSubview:_image];
        
        [self addSubview:_imgView];
        _imgView.hidden = YES;
        
        _shadow = [[CAGradientLayer alloc] init];
        _shadow.colors =[NSArray arrayWithObjects:(id)[UIColor colorWithRed:0xee /255.0 green:0xee /255.0 blue:0xee /255.0 alpha:0.1].CGColor,(id)[UIColor colorWithRed:0x00 /255.0 green:0x00 /255.0 blue:0x00 /255.0 alpha:0.2].CGColor,
                            (id)[UIColor colorWithRed:0xee /255.0 green:0xee /255.0 blue:0xee /255.0 alpha:0.1].CGColor
                            ,nil];
        _shadow.frame = CGRectMake(self.frame.size.width - self.frame.size.width /6 /2, 0, self.frame.size.width /6, self.frame.size.height);
        _shadow.startPoint = CGPointMake(0, 0.5);
        _shadow.endPoint = CGPointMake(1.0, 0.5);
        _image.clipsToBounds = NO;
        _shadow.hidden = YES;
        [self.layer addSublayer:_shadow];
        
    }
    return self;
}

-(void) didMoveToSuperview
{
    UIGraphicsBeginImageContext(self.viewForTxt.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 这里不用滤镜了 随便加点灰色吧
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0xcc /255.0 green:0xcc /255.0 blue:0xcc /255.0 alpha:0.1].CGColor);
    CGContextTranslateCTM(context, self.viewForTxt.frame.size.width, 0);
    CGContextScaleCTM(context, -1, 1);
    
    [self.viewForTxt.layer renderInContext:context];
    CGContextFillRect(context, self.viewForTxt.bounds);
    
    _image.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    CAGradientLayer *shadow = [[CAGradientLayer alloc] init];
    shadow.colors =[NSArray arrayWithObjects:(id)[UIColor colorWithRed:0xee /255.0 green:0xee /255.0 blue:0xee /255.0 alpha:0.2].CGColor,(id)[UIColor colorWithRed:0x00 /255.0 green:0x00 /255.0 blue:0x00 /255.0 alpha:0.3].CGColor
                    ,nil];
    shadow.frame = CGRectMake(-10, 0, 10, self.frame.size.height);
    shadow.startPoint = CGPointMake(0, 0.5);
    shadow.endPoint = CGPointMake(1.0, 0.5);
    
    _image.clipsToBounds = NO;
    [_image.layer addSublayer:shadow];
    //[_txtView removeFromSuperview];
    
}

-(void) move:(float)x animation:(BOOL)animation
{
    
    _shadow.hidden = NO;
    
    _imgView.hidden = NO;
    if (animation) {
        [UIView beginAnimations:@"ad" context:nil];
        [UIView setAnimationDidStopSelector:@selector(didFinishMove)];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5f];
    }
    CGRect rect = _imgView.frame;
    rect.origin.x = x;
    rect.size.width = self.frame.size.width - x;
    _imgView.frame = rect;
    
    rect = _viewForTxt.frame;
    rect.size.width = x;
    rect.origin.x = self.frame.size.width - x;
    _viewForTxt.frame = rect;
    rect = self.frame;
    rect.origin.x = -(self.frame.size.width - x);
    self.frame = rect;
    if(animation)
    {
        [UIView commitAnimations];
    }
}

-(void) didFinishMove
{
    self.shadow.hidden = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishMove)])
    {
        [self.delegate didFinishMove];
    }
    self.hidden = self.frame.origin.x !=0;
}

-(void) endMove
{
    _image.hidden = YES;
}

//-(void) dealloc
//{
//    [_viewForTxt release];
//    [_image release];
//    [_txtView release];
//    [_imgView release];
//    [super dealloc];
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
