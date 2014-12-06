//
//  DemoViewController.h
//  PageDemo
//
//  Created by 4DTECH on 13-4-12.
//  Copyright (c) 2013年 4DTECH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageCurlView.h"
@interface PageCurlController : UIViewController<PageViewDelegate>
{
    int currentIndex;
    BOOL fromLeft;
    BOOL tap;
    float startX;
    int nextPageIndex;
    float minMoveWidth;
    CGRect menuRect;
    BOOL isMenuTouchEvent;
    BOOL isTapToNextPage;
}
@property(nonatomic,retain) PageCurlView *visitPage;
@property(nonatomic,retain) PageCurlView *prePage;
@property(nonatomic,retain) PageCurlView *nextPage;
@end
