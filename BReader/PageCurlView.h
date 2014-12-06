//
//  PageView.h
//  PageDemo
//
//  Created by 4DTECH on 13-4-12.
//  Copyright (c) 2013年 4DTECH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@protocol PageViewDelegate;
@interface PageCurlView : UIView
@property(nonatomic,retain) UITextView *txtView;
@property(nonatomic,retain) UIImageView *image;
@property(nonatomic,retain) UIView *imgView;
@property(nonatomic,retain) UIView *viewForTxt;
@property(nonatomic,retain) CAGradientLayer *shadow;
@property(nonatomic,assign) id<PageViewDelegate> delegate;

-(id) initWithFrame:(CGRect)frame txt:(NSString *)text excludeStatusBar:(BOOL)bar;
-(void) move:(float)x animation:(BOOL)animation;

@end

@protocol PageViewDelegate <NSObject>
-(void) didFinishMove;
@end
