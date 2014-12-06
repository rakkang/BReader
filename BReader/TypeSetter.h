//
//  TypeSetter.h
//  SplitPage
//
//  Created by Ruikye on 14-1-18.
//  Copyright (c) 2014年 Ruikye. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "BookUtils.h"

typedef struct {
    float left;
    float top;
    float right;
    float bottom;
}Margin;

Margin MakeMargin(float left, float top, float right, float  bottom);

@interface TypeSetter : NSObject
+(TypeSetter *) shareInstance;
-(void) setFontStyle:(UIFont *) font;
-(void) setFontSize:(float) size;
-(void) setFontColor:(UIColor *) color;
-(void) setLineSpace:(float) space;
-(void) setMargin:(Margin) margin;
-(long) fuzzyRange:(CGRect) bounds;
-(void) fixPage:(Page *) page bound:(CGRect)bounds encoding:(BEncoding) encoding;
-(CTFrameRef) makeFrame:(NSString *) string bound:(CGRect)bounds startNewLine:(BOOL)startNewLine;

-(void) save;
-(void) recovery;
-(void) reset;
@end
