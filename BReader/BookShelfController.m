//
//  BookShelfController.m
//  BReader
//
//  Created by ruikye on 14-4-8.
//
//

#import "BookShelfController.h"
#import "BookCellView.h"
#import "BookUtils.h"
#import "ViewHelper.h"
#import "PaperController.h"
#import "TitleBar.h"
#import "Resource.h"

@interface BookShelfController ()<OnViewTouchDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    PaperController*    _paperController;
    UICollectionView*   _collectionView;
    NSMutableArray*     _booksArray;
}
@end

@implementation BookShelfController
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
    [super viewDidLoad];

    Book* book    = [Book forName:@"星辰变.txt"];
    
    _booksArray   = [[NSMutableArray alloc] init];
    [_booksArray addObject:book];

    book          = [Book forName:@"盘龙.txt"];
    [_booksArray addObject:book];

    book          = [Book forName:@"天珠变.txt"];
    [_booksArray addObject:book];

    book          = [Book forName:@"遮天.txt"];
    [_booksArray addObject:book];

    UICollectionViewFlowLayout* gLayout = [[UICollectionViewFlowLayout alloc] init];
    [gLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    gLayout.itemSize                = CGSizeMake(60, 110);
    CGFloat space                   = (self.view.frame.size.width - 180) / 4;
    gLayout.sectionInset            = UIEdgeInsetsMake(space, space, space, space);
    gLayout.minimumLineSpacing      = 50;
    gLayout.minimumInteritemSpacing = space;

    int yOffset = 0;
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        [self.view setBackgroundColor:[UIColor blackColor]];
        yOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
    } else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }

    TitleBar* titleBar = [[TitleBar alloc] initWithFrame:CGRectMake(0, yOffset, self.view.frame.size.width, 48)];
    [titleBar setTitle:@"我的书架"];
    [titleBar setBackgroundColor:[UIColor colorWithPatternImage:[Resource resForName:@"bookshelf_header_bg.png"]]];
    [self.view addSubview:titleBar];

    _collectionView                 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 48+yOffset, self.view.frame.size.width, self.view.frame.size.height-48+yOffset) collectionViewLayout:gLayout];
    _collectionView.delegate        = self;
    _collectionView.dataSource      = self;
    [_collectionView registerClass:[BookCellView class] forCellWithReuseIdentifier:@"BookCellView"];
    [_collectionView setBackgroundColor:[UIColor colorWithPatternImage:[Resource resForName:@"bookshelf_layer_center.9.png"]]];

    [self.view addSubview:_collectionView];
}

-(BOOL) prefersStatusBarHidden{
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark for UICollectionDataSource
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _booksArray.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BookCellView* cell = (BookCellView*)[collectionView dequeueReusableCellWithReuseIdentifier:@"BookCellView" forIndexPath:indexPath];
    [cell initializeforBook:[_booksArray objectAtIndex:indexPath.item]];
    [cell setClickDelegate:self];
    return cell;
}

#pragma mark for OnViewTouchDelegate
-(void) onClick:(UIView *)view{
    if ([view isKindOfClass:[BookCellView class]]) {
        _paperController = [[PaperController alloc] init];
        [_paperController.view setFrame:[[UIScreen mainScreen] bounds]];
        [_paperController bindBook:((BookCellView*)view).book];
        [self.navigationController pushViewController:_paperController animated:YES];
    }
}
@end