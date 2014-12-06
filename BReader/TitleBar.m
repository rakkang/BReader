//
//  TitleBar.m
//  BReader
//
//  Created by ruikye on 14-5-11.
//
//

#import "TitleBar.h"

@interface TitleBar()
{
    UILabel*                _titleLabel;
    UIView*                 _leftButton;
    UIView*                 _rightButton;
    BOOL                    _isHidden;
}
@end

@implementation TitleBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int height = frame.size.height;
        int buttomWidth = 1.5 * height;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttomWidth, 0, frame.size.width - 2*buttomWidth, frame.size.height)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont systemFontOfSize:24]];
        [_titleLabel setTextColor:kUIColorFromRGB(0x111111, 0.9)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];

        // Shadow
        _titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
        _titleLabel.layer.shadowOffset = CGSizeMake(1, 1);
        _titleLabel.layer.shadowOpacity = 0.9;
        _titleLabel.layer.shadowRadius = 2;
        [self addSubview:_titleLabel];
    }
    return self;
}

-(UILabel*) titleLabel{
    return _titleLabel;
}

-(void) setTitle:(NSString *)title{
    [_titleLabel setText:title];
}

-(void) addLeftOperationButton:(UIButton *)leftButton{
    if (leftButton != nil) {
        [_leftButton removeFromSuperview];

        [leftButton removeFromSuperview];
        [leftButton setFrame:CGRectMake(0, 0, self.frame.size.height*1.5, self.frame.size.height)];
        [self addSubview:leftButton];
    }
}

-(void) addRightOperationButton:(UIButton *)rightButton{
    if (rightButton != nil) {
        [_rightButton removeFromSuperview];

        [rightButton removeFromSuperview];
        int width = self.frame.size.height * 1.5;
        [rightButton setFrame:CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)];
        [self addSubview:rightButton];
    }
}

-(void) showingWithAnim:(BOOL)anim{
    int height = self.frame.size.height;
    int originY = self.frame.origin.y;

    [UIView beginAnimations:@"showingAnim_titlebar" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 0.0;
    self.alpha = 1;
    self.frame = CGRectMake(0, originY + height, self.frame.size.width, height);
    [UIView commitAnimations];
    _isHidden = NO;
}

-(void) hiddingWithAnim:(BOOL)anim{
    int height = self.frame.size.height;
    int originY = self.frame.origin.y;

    [self setHidden:NO];
    [UIView beginAnimations:@"hiddingAnim_titlebar" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 1;
    self.frame = CGRectMake(0, originY - height, self.frame.size.width, height);
    self.alpha = 0.0;
    [UIView commitAnimations];
    _isHidden = YES;
}

-(BOOL) isHidden{
    return _isHidden;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
