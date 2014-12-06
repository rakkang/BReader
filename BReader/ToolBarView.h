//
//  ToolBarView.h
//  BReader
//
//  Created by ruikye on 14-4-17.
//
//

#import <UIKit/UIKit.h>

@interface ToolBarView : UIView

-(void) showingWithAnim:(BOOL)anim;
-(void) hiddingWithAnim:(BOOL)anim;

-(void) setTarget:(id)target catalog:(SEL)action1 jumpProfress:(SEL)action2 nightMode:(SEL)action3 settings:(SEL)action4;

@end
