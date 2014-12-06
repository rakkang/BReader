//
//  BookCellView.h
//  BReader
//
//  Created by ruikye on 14-4-8.
//
//

#import <UIKit/UIKit.h>
#import "ViewHelper.h"

@class Book;
@interface BookCellView : UICollectionViewCell
@property Book* book;
-(id) initWithFrame:(CGRect)frame forBook:(Book*)book;
-(void) initializeforBook:(Book*)book;
-(void) setClickDelegate:(id<OnViewTouchDelegate>)delegate;
@end
