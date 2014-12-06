//
//  YLLabel.h
//  YLLabelDemo
//
//  Created by Ruikye on 14-1-18.
//  Copyright (c) 2014年 Ruikye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeSetter.h"
#import "BookUtils.h"

@interface PageView : UIView
-(BOOL) isLoading;
-(Page*) page;
-(BOOL) showPage:(Page*) page;
@end
