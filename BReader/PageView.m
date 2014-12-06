//
//  YLLabel.m
//  YLLabelDemo
//
//  Created by Ruikye on 14-1-18.
//  Copyright (c) 2014年 Ruikye. All rights reserved.
//

#import "PageView.h"
#import "ViewHelper.h"

@interface PageView()
{
    BOOL    _loading;
    BOOL    _clear;
    Page*   _page;
}
@end

@implementation PageView
-(Page*) page
{
    return _page;
}

-(BOOL) isLoading
{
    return _loading;
}

-(void) doAphaAnimation
{
    [UIView beginAnimations:@"showAlpha" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 0.9;
    self.alpha = 1;
    [UIView commitAnimations];
}

-(BOOL) showPage:(Page *)page{
    if (page == nil) {
        return NO;
    }

    _page = page;
    _loading = NO;
    [self setNeedsDisplay];
    [self doAphaAnimation];
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_page==nil||_page.string==nil||_clear) {
        _clear = NO;
        return;
    }

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx,0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CTFrameRef frame = [[TypeSetter shareInstance] makeFrame:_page.string bound:self.bounds startNewLine:_page.startWithNewLine];
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
}

- (void)setTextColor:(UIColor *)textColor
{
    [[TypeSetter shareInstance] setFontColor:textColor];
}
@end
