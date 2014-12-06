//
//  ProgressSettingsView.m
//  BReader
//
//  Created by ruikye on 14-5-11.
//
//

#import "ProgressSettingsView.h"

static int ITEM_HEIGHT = 24;

@implementation ProgressSettingsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        int space_y = (frame.size.height - 2 * ITEM_HEIGHT) / 3;
        int space_x = space_y;

        UIButton* prevChapater = [[UIButton alloc] initWithFrame:CGRectMake(space_x, space_y, 48, ITEM_HEIGHT)];
        [prevChapater setTitle:@"上一章" forState:UIControlStateNormal];
        [prevChapater.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [prevChapater setTitleColor:kUIColorFromRGB(0x5599aa, 1) forState:UIControlStateHighlighted];
        [prevChapater setTitleColor:kUIColorFromRGB(0xaaaaaa, 0.9) forState:UIControlStateNormal];
        prevChapater.layer.borderWidth = 0.8;
        prevChapater.layer.borderColor = kUIColorFromRGB(0xaaaaaa, 0.5).CGColor;
        prevChapater.layer.cornerRadius = 2;
        [self addSubview:prevChapater];

        UILabel* chapaterLabel = [[UILabel alloc] initWithFrame:CGRectMake(space_x*2 + 48, space_y, frame.size.width - 48*2 -space_x*4, ITEM_HEIGHT)];
        [chapaterLabel setFont:[UIFont systemFontOfSize:11]];
        [chapaterLabel setTextColor:kUIColorFromRGB(0xaaaaaa, 0.9)];
        [chapaterLabel setText:@"第一集 秦羽 第一章 秦羽"];
        [chapaterLabel setTextAlignment:NSTextAlignmentCenter];
        [chapaterLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:chapaterLabel];

        UIButton* nextChapater = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - space_x - 48, space_y, 48, ITEM_HEIGHT)];
        [nextChapater setTitle:@"下一章" forState:UIControlStateNormal];
        [nextChapater.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [nextChapater setTitleColor:kUIColorFromRGB(0x5555aa, 0.9) forState:UIControlStateHighlighted];
        [nextChapater setTitleColor:kUIColorFromRGB(0xaaaaaa, 0.9) forState:UIControlStateNormal];
        nextChapater.layer.borderWidth = 0.8;
        nextChapater.layer.borderColor = kUIColorFromRGB(0xaaaaaa, 0.5).CGColor;
        nextChapater.layer.cornerRadius = 2;
        [self addSubview:nextChapater];

        UIButton* prevPage = [[UIButton alloc] initWithFrame:CGRectMake(space_x, frame.size.height - space_y - ITEM_HEIGHT, 16, ITEM_HEIGHT)];
        [prevPage setTitle:@"<" forState:UIControlStateNormal];
        [prevPage.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [prevPage setTitleColor:kUIColorFromRGB(0x5599aa, 1) forState:UIControlStateHighlighted];
        [prevPage setTitleColor:kUIColorFromRGB(0xaaaaaa, 0.9) forState:UIControlStateNormal];
        prevPage.layer.borderWidth = 0.8;
        prevPage.layer.borderColor = kUIColorFromRGB(0xaaaaaa, 0.5).CGColor;
        prevPage.layer.cornerRadius = 2;
        [self addSubview:prevPage];

        UIButton* nextPage = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - space_x - 16, frame.size.height - space_y - ITEM_HEIGHT, 16, ITEM_HEIGHT)];
        [nextPage setTitle:@">" forState:UIControlStateNormal];
        [nextPage.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [nextPage setTitleColor:kUIColorFromRGB(0x5555aa, 0.9) forState:UIControlStateHighlighted];
        [nextPage setTitleColor:kUIColorFromRGB(0xaaaaaa, 0.9) forState:UIControlStateNormal];
        nextPage.layer.borderWidth = 0.8;
        nextPage.layer.borderColor = kUIColorFromRGB(0xaaaaaa, 0.5).CGColor;
        nextPage.layer.cornerRadius = 2;
        [self addSubview:nextPage];

        UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(space_x*2+16, frame.size.height-space_y-ITEM_HEIGHT, frame.size.width - 32-4*space_x, ITEM_HEIGHT)];

        UIImage* image = [UIImage imageNamed:@"seek_bar_thumb"];
        [slider setThumbImage:image forState:UIControlStateHighlighted];
        [slider setThumbImage:image forState:UIControlStateNormal];

        slider.minimumValue = 0;
        slider.maximumValue = 100;

        [self addSubview:slider];

        self.layer.shadowOffset = CGSizeMake(0, -2);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    return self;
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
