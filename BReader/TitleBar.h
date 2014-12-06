//
//  TitleBar.h
//  BReader
//
//  Created by ruikye on 14-5-11.
//
//

#import <UIKit/UIKit.h>
#import "ViewHelper.h"

@interface TitleBar : UIView

-(UILabel*) titleLabel;
-(void) setTitle:(NSString*) title;
-(void) showingWithAnim:(BOOL)anim;
-(void) hiddingWithAnim:(BOOL)anim;
-(void) addLeftOperationButton:(UIButton*) leftButton;
-(void) addRightOperationButton:(UIButton*) rightButton;

@end
