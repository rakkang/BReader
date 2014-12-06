//
//  ToolBarView.m
//  BReader
//
//  Created by ruikye on 14-4-17.
//
//

#import "ToolBarView.h"

static const NSInteger ICON_SIZE = 30;//px

@interface ToolBarView()
{
    UIButton* _catalog;
    UIButton* _progress;
    UIButton* _nightMode;
    UIButton* _settings;

    BOOL    _isHidden;
}

@end

@implementation ToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutInit:frame.size];
    }
    return self;
}

-(void) layoutInit:(CGSize) size{
    int space_x                     = (size.width - ICON_SIZE * 4) / 5;
    int space_y                     = (size.height - ICON_SIZE - 12) / 2;

    _catalog                        = [[UIButton alloc] initWithFrame:CGRectMake(space_x, space_y, ICON_SIZE, ICON_SIZE)];
    [_catalog setImage:[UIImage imageNamed:@"icon_item_directory.png"] forState:UIControlStateNormal];
    UILabel* item1 = [[UILabel alloc] initWithFrame:CGRectMake(space_x, ICON_SIZE+3, ICON_SIZE, 12)];
    [item1 setText:@"目录"];
    [item1 setBackgroundColor:[UIColor clearColor]];
    [item1 setFont:[UIFont systemFontOfSize:8.5]];
    [item1 setTextAlignment:NSTextAlignmentCenter];
    [item1 setTextColor:kUIColorFromRGB(0xaaaaaa, 0.7)];

    _progress                       = [[UIButton alloc] initWithFrame:CGRectMake(space_x*2 + ICON_SIZE, space_y, ICON_SIZE, ICON_SIZE)];
    [_progress setImage:[UIImage imageNamed:@"icon_item_progress.png"] forState:UIControlStateNormal];
    UILabel* item2 = [[UILabel alloc] initWithFrame:CGRectMake(space_x*2 + ICON_SIZE+3, ICON_SIZE+3, ICON_SIZE, 12)];
    [item2 setText:@"进度"];
    [item2 setBackgroundColor:[UIColor clearColor]];
    [item2 setFont:[UIFont systemFontOfSize:8.5]];
    [item2 setTextAlignment:NSTextAlignmentCenter];
    [item2 setTextColor:kUIColorFromRGB(0xaaaaaa, 0.7)];

    _nightMode                   = [[UIButton alloc] initWithFrame:CGRectMake(space_x*3 + ICON_SIZE*2, space_y, ICON_SIZE, ICON_SIZE)];
    [_nightMode setImage:[UIImage imageNamed:@"icon_item_bright.png"] forState:UIControlStateNormal];
    UILabel* item3 = [[UILabel alloc] initWithFrame:CGRectMake(space_x*3 + ICON_SIZE*2, ICON_SIZE+3, ICON_SIZE, 12)];
    [item3 setText:@"日·夜间"];
    [item3 setBackgroundColor:[UIColor clearColor]];
    [item3 setFont:[UIFont systemFontOfSize:8.5]];
    [item3 setTextAlignment:NSTextAlignmentCenter];
    [item3 setTextColor:kUIColorFromRGB(0xaaaaaa, 0.7)];

    _settings                       = [[UIButton alloc] initWithFrame:CGRectMake(space_x*4 + ICON_SIZE*3, space_y, ICON_SIZE, ICON_SIZE)];
    [_settings setImage:[UIImage imageNamed:@"icon_bookshelf_set_up.png"] forState:UIControlStateNormal];
    UILabel* item4 = [[UILabel alloc] initWithFrame:CGRectMake(space_x*4 + ICON_SIZE*3, ICON_SIZE+3, ICON_SIZE, 12)];
    [item4 setText:@"设置"];
    [item4 setBackgroundColor:[UIColor clearColor]];
    [item4 setFont:[UIFont systemFontOfSize:8.5]];
    [item4 setTextAlignment:NSTextAlignmentCenter];
    [item4 setTextColor:kUIColorFromRGB(0xaaaaaa, 0.7)];

    [self addSubview:_catalog];
    [self addSubview:item1];

    [self addSubview:_progress];
    [self addSubview:item2];

    [self addSubview:_nightMode];
    [self addSubview:item3];

    [self addSubview:_settings];
    [self addSubview:item4];

    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 2;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

-(void)setTarget:(id)target catalog:(SEL)action1 jumpProfress:(SEL)action2 nightMode:(SEL)action3 settings:(SEL)action4 {
    [_catalog addTarget:target action:action1 forControlEvents:UIControlEventTouchUpInside];
    [_progress addTarget:target action:action2 forControlEvents:UIControlEventTouchUpInside];
    [_nightMode addTarget:target action:action3 forControlEvents:UIControlEventTouchUpInside];
    [_settings addTarget:target action:action4 forControlEvents:UIControlEventTouchUpInside];
}

-(void) showingWithAnim:(BOOL)anim{
    int height = self.frame.size.height;
    int originY = self.frame.origin.y;

    [UIView beginAnimations:@"showingAnim_titlebar" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 0.0;
    self.alpha = 1;
    self.frame = CGRectMake(0, originY - height, self.frame.size.width, height);
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
    self.frame = CGRectMake(0, originY + height, self.frame.size.width, height);
    self.alpha = 0.0;
    [UIView commitAnimations];
    _isHidden = YES;
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
