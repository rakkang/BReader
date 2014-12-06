//
//  PaperController.m
//  BReader
//
//  Created by ruikye on 14-4-2.
//
//

#import "PaperController.h"
#import "BookUtils.h"
#import "PageView.h"
#import "TypeSetter.h"
#import "ViewHelper.h"
#import "Resource.h"
#import "TitleBar.h"
#import "ToolBarView.h"
#import "ProgressSettingsView.h"
#import "CommonSettingsiew.h"

static CGRect MENU_RECT;
static bool insideMenuRect(float x, float y){
    return x>MENU_RECT.origin.x&&x<MENU_RECT.origin.x+MENU_RECT.size.width&&y>MENU_RECT.origin.y&&y<MENU_RECT.origin.y+MENU_RECT.size.height;
}

static float FONT_LEVEL[] = {10.0f, 12.0f, 14.0f, 16.0, 18.f};

static bool insideNextRect(float x, float y){
    return !(x<MENU_RECT.origin.x||(x>MENU_RECT.origin.x&&x<(MENU_RECT.origin.x+MENU_RECT.size.width)&&y<MENU_RECT.origin.y));
}

typedef enum {
    TOUCH_MENU,
    TOUCH_NEXT,
    TOUCH_PREV
}TOUCH_OPT;

@interface PaperController ()
{
    PageView*               pageView;
    TypeSetter*             typeSetter;
    Book*                   book;
    int                     yOffset;
    CGRect                  mainRect;
    CGRect                  paperFrame;
    TOUCH_OPT               touchOperation;
    BookLoader*             loader;
    TitleBar*               titleBar;
    ToolBarView*            toolBarView;
    ProgressSettingsView*   progSatusView;
    CommonSettingsiew*      settingsView;

    int                     status_font_level; //{0,1,2,3,4}
    BOOL                    status_is_night_mode;
}
@end

@implementation PaperController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        status_font_level = 2;
        status_is_night_mode = NO;
    }
    return self;
}

-(void) bindBook:(Book *)_book{
    book = _book;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    int width       = self.view.frame.size.width;
    int height      = self.view.frame.size.height;

    MENU_RECT       = CGRectMake(width/3.0f, height/3.0f, width/3.0f, height/3.0f);
    mainRect        = [[UIScreen mainScreen] bounds];
    typeSetter      = [TypeSetter shareInstance];

    [typeSetter setFontColor:kUIColorFromRGB(status_is_night_mode?0x777777:0x000000, 0.7)];
    [typeSetter setLineSpace:4.0f];
    [typeSetter setFontSize:FONT_LEVEL[status_font_level]];
    [typeSetter setMargin:MakeMargin(16, 8, 16, 8)];

    if (IOS7_OR_LATER) {
        yOffset     = [[UIApplication sharedApplication] statusBarFrame] .size.height;
        paperFrame  = CGRectMake(0, 20, mainRect.size.width, mainRect.size.height - 20);
    } else{
        paperFrame  = CGRectMake(0, 0, mainRect.size.width, mainRect.size.height - 20);
    }

    pageView = [[PageView alloc] initWithFrame:paperFrame];
    [pageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:status_is_night_mode ? @"paper_night.png" : @"paper.png"]]];
    [self.view addSubview:pageView];

    titleBar                        = [[TitleBar alloc] initWithFrame:CGRectMake(0, yOffset, self.view.frame.size.width, 48)];
    titleBar.layer.shadowOpacity    = 1;
    titleBar.layer.shadowOffset     = CGSizeMake(0, 2);
    titleBar.layer.shadowRadius     = 2;
    titleBar.layer.shadowColor      = [UIColor blackColor].CGColor;

    UIButton* leftBtn = [[UIButton alloc] init];
    [leftBtn setImage:[Resource resForName:@"btn_back.png"] forState:UIControlStateNormal];
    [leftBtn setTitle:@"书架" forState:UIControlStateNormal];
    [leftBtn setTitleColor:kUIColorFromRGB(0xcccccc, 0.9) forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backToBookShelf) forControlEvents:UIControlEventTouchUpInside];

    [titleBar addLeftOperationButton:leftBtn];
    [titleBar setBackgroundColor:kUIColorFromRGB(0x000000, 0.90)];
    [self.view addSubview:titleBar];
    [titleBar hiddingWithAnim:YES];

    toolBarView = [[ToolBarView alloc] initWithFrame:CGRectMake(0, paperFrame.size.height - 48 + yOffset, self.view.frame.size.width, 48)];
    [toolBarView setBackgroundColor:kUIColorFromRGB(0x000000, 0.90)];
    [toolBarView setTarget:self
                   catalog:@selector(openCatalog)
              jumpProfress:@selector(jumpProgress)
                 nightMode:@selector(setNightMode)
                  settings:@selector(openSettings)];
    [self.view addSubview:toolBarView];
    [toolBarView hiddingWithAnim:YES];

    progSatusView   = [[ProgressSettingsView alloc] initWithFrame:CGRectMake(0, paperFrame.size.height+yOffset, self.view.frame.size.width, 72)];
    progSatusView.hidden = YES;
    [progSatusView setBackgroundColor:[UIColor blackColor]];

    settingsView    = [[CommonSettingsiew alloc] initWithFrame:CGRectMake(0, paperFrame.size.height + yOffset, self.view.frame.size.width, 48)];
    settingsView.hidden = YES;
    [settingsView setBackgroundColor:[UIColor blackColor]];

    // 加载书籍内容
    [self loadBookContent];
}

// 加载书籍内容
-(void) loadBookContent{
    [ViewHelper showProgress:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [book readBookMark];
        loader = [[BookLoader alloc] initWithBook:book bookMark:book.mark];
        [loader buildCache:pageView.bounds];
        dispatch_async(dispatch_get_main_queue(), ^{
            [pageView showPage:[loader currPage]];
            [ViewHelper hideProgress];
            self.title = [loader catalogInfo].name;
        });
    });
}

// 显示指定的二级菜单
-(void) showSubSettingsView:(UIView*) view{
    [self.view addSubview:view];
    view.hidden = NO;
    int height = view.frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 0;
        view.frame = CGRectMake(0, paperFrame.size.height - height + yOffset, self.view.frame.size.width, height);
        view.alpha = 1;
    }completion:^(BOOL finished){
    }];
}

// 隐藏二级菜单
-(BOOL) hideAllSubSettingsViews{
    BOOL needHide = !progSatusView.hidden||!settingsView.hidden;

    if (needHide) {
        [UIView animateWithDuration:0.3 animations:^{
            if (!progSatusView.hidden) {
                progSatusView.alpha = 1;
                progSatusView.frame = CGRectMake(0, paperFrame.size.height+yOffset, self.view.frame.size.width, 64);
                progSatusView.alpha = 0;
            }

            if (!settingsView.hidden) {
                settingsView.alpha = 1;
                settingsView.frame = CGRectMake(0, paperFrame.size.height+yOffset, self.view.frame.size.width, 48);
                settingsView.alpha = 0;
            }
        } completion:^(BOOL finished){
            progSatusView.hidden = YES;
            settingsView.hidden = YES;
            [progSatusView removeFromSuperview];
            [settingsView removeFromSuperview];
        }];
    }

    return !needHide;
}

// 隐藏一级菜单
-(void) hideMenuBars{
    [titleBar hiddingWithAnim:YES];
    [toolBarView hiddingWithAnim:YES];
}

// 显示一级菜单
-(void) showMenuBars{
    [titleBar showingWithAnim:YES];
    [toolBarView showingWithAnim:YES];
}

// 打开目录
-(void) openCatalog{
    DLog(@"open catalog");
}

// 跳转进度
-(void) jumpProgress{
    [self hideMenuBars];
    [self showSubSettingsView:progSatusView];
}

// 日·夜间模式设定
-(void) setNightMode{
    book.mark = [loader getBookMark];
    status_is_night_mode = !status_is_night_mode;

    if (status_is_night_mode) {
        [typeSetter setFontColor:kUIColorFromRGB(0x777777, 0.7)];
        [pageView setBackgroundColor:[UIColor colorWithPatternImage:[Resource resForName:@"paper_night.png"]]];
    } else {
        [typeSetter setFontColor:kUIColorFromRGB(0x000000, 0.7)];
        [pageView setBackgroundColor:[UIColor colorWithPatternImage:[Resource resForName:@"paper.png"]]];
    }

    [self hideMenuBars];
    [self loadBookContent];
}

// 所有设置
-(void) openSettings{
    [self hideMenuBars];
    [self showSubSettingsView:settingsView];
}

// 回到书架
-(void) backToBookShelf{
    [self.navigationController popViewControllerAnimated:YES];
}

// 自动保存书签
-(void) viewDidDisappear:(BOOL)animated{
    book.mark = [loader getBookMark];
    [book saveBookMark];
    // Sava status
    [super viewDidAppear:animated];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint loc = [touch previousLocationInView:self.view];

    if (insideMenuRect(loc.x, loc.y)) {
        touchOperation = TOUCH_MENU;
    } else if(insideNextRect(loc.x, loc.y)){
        touchOperation = TOUCH_NEXT;
    } else {
        touchOperation = TOUCH_PREV;
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL isHidden = titleBar.hidden;
    switch (touchOperation) {
        case TOUCH_MENU:{
            if ([self hideAllSubSettingsViews]) {
                if (isHidden) {
                    [self showMenuBars];
                } else{
                    [self hideMenuBars];
                }
            }

            break;
        }
        case TOUCH_NEXT:
            if ([self hideAllSubSettingsViews]) {
                if (!isHidden) {
                    [self hideMenuBars];
                } else {
                    [pageView showPage:[loader nextPage]];
                }
            }
            break;
        case TOUCH_PREV:
            if ([self hideAllSubSettingsViews]) {
                if (!isHidden) {
                    [self hideMenuBars];
                } else {
                    [pageView showPage:[loader prevPage]];
                }
            }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
