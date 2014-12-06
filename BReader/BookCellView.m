//
//  BookCellView.m
//  BReader
//
//  Created by ruikye on 14-4-8.
//
//

#import "BookUtils.h"
#import "BookCellView.h"
#import "Resource.h"

static NSInteger LABEL_SIZE = 15;

@interface BookCellView()
{
    UIImageView*            _coverImge;
    UILabel*                _bookName;
    UILabel*                _progress;
    id<OnViewTouchDelegate> _clickDelegate;
}

@end

@implementation BookCellView
@synthesize book;
- (id)initWithFrame:(CGRect)frame forBook:(Book *)_book
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeforBook:_book];
    }
    return self;
}

-(void) initializeforBook:(Book *)_book{
    self.book    = _book;
    CGRect frame = self.frame;

    if (_coverImge==nil) {
        _coverImge   = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - LABEL_SIZE*2)];
        [self addSubview:_coverImge];
    }

    if (_bookName==nil) {
        _bookName   = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - LABEL_SIZE*2+4, frame.size.width, LABEL_SIZE)];
        [_bookName setTextAlignment:NSTextAlignmentCenter];
        [_bookName setTextColor:kUIColorFromRGB(0xaaaaaa, 0.7)];
        [_bookName setBackgroundColor:[UIColor clearColor]];
        [_bookName setFont:[UIFont systemFontOfSize:12.0f]];
        [self addSubview:_bookName];
    }

    if (_progress==nil) {
        _progress   = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - LABEL_SIZE+2, frame.size.width, LABEL_SIZE)];
        [_progress setTextAlignment:NSTextAlignmentCenter];
        [_progress setBackgroundColor:[UIColor clearColor]];
        [_progress setFont:[UIFont systemFontOfSize:10.0f]];
        [self addSubview:_progress];
    }

    BOOL unRead = self.book.mark==nil||self.book.mark.position==0;

    [_coverImge setImage:[Resource resForName:[book.name stringByAppendingString:@".jpg"] inDirectory:@""]];
    [_bookName setText:[self.book simpleName]];
    [_progress setText:unRead? @"未读":[[NSString stringWithFormat:@"%0.2f", 100.0*self.book.mark.position / self.book.size] stringByAppendingString:@"%"]];

    if (unRead) {
        [_progress setTextColor:kUIColorFromRGB(0x55aa55, 0.7)];
    } else {
        [_progress setTextColor:[UIColor lightGrayColor]];
    }

    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowOpacity = 1;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 10;
    [self setNeedsDisplay];
}

-(void) setClickDelegate:(id<OnViewTouchDelegate>) delegate{
    _clickDelegate = delegate;
    if (_clickDelegate != nil) {
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapSelector:)];
        singleTap.numberOfTapsRequired      = 1;
        singleTap.numberOfTouchesRequired   = 1;
        [self addGestureRecognizer:singleTap];
    }
}

-(void) singleTapSelector:(UITapGestureRecognizer *)recognizer{
    [_clickDelegate onClick:self];
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
