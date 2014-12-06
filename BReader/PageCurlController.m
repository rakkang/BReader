//
//  DemoViewController.m
//  PageDemo
//
//  Created by 4DTECH on 13-4-12.
//  Copyright (c) 2013年 4DTECH. All rights reserved.
//

#import "PageCurlController.h"
#define MIN_MOVE_WIDTH

static CGRect MENU_RECT;

@interface PageCurlController ()

@end

@implementation PageCurlController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    
    minMoveWidth = width /5.0f;
    
    menuRect = CGRectMake(width/3.0f, height/3.0f, width/3.0f, height/3.0f);
    MENU_RECT = menuRect;
    currentIndex = 0;
    [super viewDidLoad];
    [self indexChange:1];
    // Do any additional setup after loading the view.
}

bool insideMenuRect(float x, float y){
    return (x) > MENU_RECT.origin.x && (x) < (MENU_RECT.origin.x + MENU_RECT.size.width)
    && (y)>MENU_RECT.origin.y && (y) < (MENU_RECT.origin.y + MENU_RECT.size.height);
}

bool insideNextRect(float x, float y){
    if (x < MENU_RECT.origin.x || (x > MENU_RECT.origin.x && x < (MENU_RECT.origin.x + MENU_RECT.size.width) && y < MENU_RECT.origin.y)) {
        return false;
    } else {
        return true;
    }
}

-(PageCurlView *) createView:(int)index
{
    NSMutableString *string = [NSMutableString string];
    for(int i=0;i<1000;i++)
    {
        [string appendFormat:@" %d ", i, nil];
    }
    PageCurlView *vi = [[PageCurlView alloc] initWithFrame:self.view.bounds txt:string excludeStatusBar:YES];
    vi.hidden = YES;
    vi.delegate = self;
   
    return vi;
}

-(void) indexChange:(int)newIndex
{
    if(currentIndex == newIndex)
        return;
    if(currentIndex ==0)
    {
        [self setVisitPage:[self createView:newIndex]];
        [self.view addSubview:self.visitPage];
        self.visitPage.hidden = NO;
    }
    
    if(newIndex>0)
    {
        if (newIndex>=currentIndex)
        {
            
            
            if(self.prePage)
            {
                [self.prePage removeFromSuperview];
                
            }
            if(newIndex>1)
            {
                [self setPrePage:self.visitPage];
                [self setVisitPage:self.nextPage];
            }
            [self setNextPage:[self createView:newIndex+1]];
            [self.view insertSubview:self.nextPage  atIndex:0];
        }
        else
        {
            if(self.nextPage)
            {
                [self.nextPage removeFromSuperview];
            }
            [self setNextPage:self.visitPage];
            
            
            
            [self setVisitPage:self.prePage];
            if(newIndex > 1)
            {
                [self setPrePage:[self createView:newIndex-1]];
                
                [self.view addSubview:self.prePage];
            }
            else
            {
                [self setPrePage:nil];
            }
        }
        currentIndex = newIndex;
    }
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    float x = [touch locationInView:self.view].x;
    float y = [touch locationInView:self.view].y;
    
    if (insideMenuRect(x, y)) {
        isMenuTouchEvent = YES;
        NSLog(@"Touch in menu rectagnel side");
        return;
    } else {
        isMenuTouchEvent = NO;
        isTapToNextPage = insideNextRect(x, y);
        NSLog(@"%s", isTapToNextPage ? "Tap to next" : "Tap to prev");
    }
    
    startX = x;
    fromLeft = !isTapToNextPage;
    tap = YES;
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isMenuTouchEvent) {
        return;
    }
    
    if(fromLeft && currentIndex <=1){
        return;
    }
    
    UITouch *touch = [touches anyObject];
    float x = [touch locationInView:self.view].x;
    //CGRect rect = _visitPage.frame;
    if (fromLeft) {
        //self.nextPage.hidden = NO;
        if(self.prePage)
        {
            self.prePage.hidden = NO;
            self.nextPage.hidden = YES;
            [_prePage move:x animation:NO];
        }
        
    }
    else
    {
        self.prePage.hidden = YES;
        self.nextPage.hidden = NO;
        [_visitPage move:x animation:NO];
        
    }
    tap = NO;
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isMenuTouchEvent) {
        NSLog(@"Show menu views");
        return;
    }
    
    UITouch *touch = [touches anyObject];
    float x = [touch locationInView:self.view].x;
    
    if (!fromLeft && (tap||startX - x >minMoveWidth))
    {
        [self.view setUserInteractionEnabled:NO];
        self.nextPage.hidden = NO;
        nextPageIndex = currentIndex+1;
        [_visitPage move:-self.view.frame.size.width animation:YES];
    }
    
    else if(!fromLeft && startX - x <=minMoveWidth)    {
        [self.view setUserInteractionEnabled:NO];
        [_visitPage move:self.view.frame.size.width animation:YES];
    }
    
    else if(currentIndex >1)    {
        [self.view setUserInteractionEnabled:NO];
        _prePage.hidden = NO;
        
        if (fromLeft && (tap||x-  startX >minMoveWidth)) {
            nextPageIndex = currentIndex-1;
            [_prePage move:self.view.frame.size.width animation:YES];
        }
        
        else if(fromLeft &&  x - startX<=minMoveWidth){
            [_prePage move:-self.view.frame.size.width animation:YES];
        }
    }
}

-(void) didFinishMove
{
    [self indexChange:nextPageIndex];
    [self.view setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
