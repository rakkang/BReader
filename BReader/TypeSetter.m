//
//  TypeSetter.m
//  SplitPage
//
//  Created by Ruikye on 14-1-18.
//  Copyright (c) 2014年 Ruikye. All rights reserved.
//

#import "TypeSetter.h"

Margin MakeMargin(float left, float top, float right, float  bottom){
    Margin margin = {left, top, right, bottom};
    return margin;
}

static TypeSetter * sharedInstance = nil;

@implementation TypeSetter
{
    Margin margin;
    UIFont* font;
    UIColor* fontColor;
    CGFloat lineSpace;
    CGFloat paragraphSpace;
    CGFloat firstHeadIndent;
    CTTextAlignment alignment;
    CTParagraphStyleSetting lineWrap;
}

+(TypeSetter *) shareInstance{
    @synchronized(self){
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
            [sharedInstance initialize];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            id instance = [super allocWithZone:zone];
            return instance;
        }
    }

    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(void) initialize {
    alignment = kCTJustifiedTextAlignment;
    lineSpace = 2.0f;
    lineWrap.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineWrap.valueSize = sizeof(CTLineBreakMode);
    CTLineBreakMode breakMode = kCTLineBreakByCharWrapping;
    lineWrap.value = &breakMode;
    [self defaultFont];
    margin = MakeMargin(0, 0, 0, 0);
}

-(void) defaultFont{
    font = [UIFont systemFontOfSize:12.0];
}

-(void) setFontColor:(UIColor *)color{
    fontColor = color;
}

-(void) setFontSize:(float)size{
    if (font == nil) {
        [self defaultFont];
    }

    font = [font fontWithSize:size];
}

-(void) setFontStyle:(UIFont *)newFont{
    if (newFont == nil) {
        return;
    }

    font = newFont;
}

-(void) setLineSpace:(float)space{
    lineSpace = space;
}

-(void) setMargin:(Margin)newMargin{
    margin = newMargin;
}

-(long) fuzzyRange:(CGRect) bounds{
    if (font == nil) {
        [self defaultFont];
    }

    CGSize size = [@"|" sizeWithFont:font];
    CGFloat primeter = size.height * size.width;

    if (primeter == 0) {
        return 0;
    }

    CGFloat length = bounds.size.width * bounds.size.height / primeter;
    return (long)length;
}

-(void) fixPage:(Page *)page bound:(CGRect)bounds encoding:(BEncoding)encoding{
    if (page == nil) { return; }
    CTFrameRef frame;
    CFRange range;
    NSStringEncoding encoding_type = [BookUtils parseBEncoding:encoding];
    NSString* trimStr = page.string;
    frame = [self makeFrame:trimStr bound:bounds startNewLine:page.startWithNewLine];
    range = CTFrameGetVisibleStringRange(frame);
    CFRelease(frame);
    if (range.length < page.string.length) {
        page.string = [page.string substringToIndex:range.length];
    }
    page.range = NSMakeRange(page.range.location, [page.string lengthOfBytesUsingEncoding:encoding_type]);

}

-(CTFrameRef) makeFrame:(NSString *)string bound:(CGRect)bounds startNewLine:(BOOL)startNewLine{
    NSMutableAttributedString* _string;


    firstHeadIndent = [@"字体" sizeWithFont:font].width;
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpace},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstHeadIndent}
    };

    CTParagraphStyleRef style;
    style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
    if (startNewLine) {
        _string = [[NSMutableAttributedString alloc] initWithString:string];
        [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil] range:NSMakeRange(0, [_string length])];
        CFRelease(style);//release style
    } else {
        NSRange range = [string rangeOfString:@"\r"];
        range.location = range.location==NSNotFound?0:range.location;
        NSMutableAttributedString* _subFix = [[NSMutableAttributedString alloc] initWithString:[string substringFromIndex:range.location]];
        [_subFix addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil] range:NSMakeRange(0, [_subFix length])];
        CFRelease(style);

        CTParagraphStyleSetting _settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
            {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpace},
            {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpace},
        };

        style = CTParagraphStyleCreate(_settings, sizeof(_settings)/sizeof(CTParagraphStyleSetting));
        _string = [[NSMutableAttributedString alloc] initWithString:[string substringToIndex:range.location]];
        [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil] range:NSMakeRange(0, [_string length])];
        [_string appendAttributedString:_subFix];
        CFRelease(style);
    }

    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)fontRef, (NSString*)kCTFontAttributeName, nil]
                     range:NSMakeRange(0, [_string length])];
    //CFRelease(fontRef);//release fontRef

    CGColorRef colorRef = fontColor.CGColor;
    [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)colorRef,(NSString*)kCTForegroundColorAttributeName, nil] range:NSMakeRange(0, [_string length])];
    //CFRelease(colorRef);//release colorRef

    CGRect _rect = CGRectMake(bounds.origin.x + margin.left, bounds.origin.y + margin.top , bounds.size.width - margin.left-margin.right, bounds.size.height - margin.top-margin.bottom);

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_string);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, _rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [_string length]), path, NULL);
    CFRelease(frameSetter);//release frameSetter
    CGPathRelease(path);// release path
    return frame;
}

-(void) save{

}

-(void) recovery{
    
}

-(void) reset{
    
}

@end
