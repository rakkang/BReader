//
//  ViewHelper.h
//  BReader
//
//  Created by ruikye on 14-4-3.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    UIP_ALIGN_LEFT       = NSIntegerMax,
    UIP_ALIGN_RIGHT      = NSIntegerMin,
    UIP_ALIGN_CENTER     = NSIntegerMax-2,
    UIP_SCREEN_LEFT      = NSIntegerMax-1,
    UIP_SCREEN_RIGHT     = NSIntegerMin+1,
    UIP_SCREEN_CENTER    = NSIntegerMin+2
}UIParams;

@protocol OnViewTouchDelegate<NSObject>
-(void) onClick:(UIView*) view;
@end

@interface ViewHelper : NSObject
+(void) addSubView:(UIView*)view parent:(UIView*)parent alignX:(NSInteger)alignX anlignY:(NSInteger)alignY;
+(void) showProgress:(UIView*)holder;
+(void) hideProgress;
@end
