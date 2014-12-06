//
//  ViewHelper.m
//  BReader
//
//  Created by ruikye on 14-4-3.
//
//
static UIActivityIndicatorView* _progress;
#import "ViewHelper.h"
@interface ViewHelper()
{
}
@end;

@implementation ViewHelper

+(void) showProgress:(UIView *)holder{
    if (_progress==nil) {
        _progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    } else {
        [self hideProgress];
    }
    [ViewHelper addSubView:_progress parent:holder alignX:UIP_SCREEN_CENTER anlignY:UIP_SCREEN_CENTER];
    [_progress startAnimating];
}

+(void) hideProgress{
    [_progress stopAnimating];
    [_progress removeFromSuperview];
}

+(void) addSubView:(UIView *)view parent:(UIView *)parent alignX:(NSInteger)alignX anlignY:(NSInteger)alignY{
    [parent addSubview:view];
    CGRect _pFrame = [parent frame];
    CGRect _vFrame = [view frame];
    CGRect _sFrame = [[UIScreen mainScreen] bounds];
    CGRect _status = [[UIApplication sharedApplication] statusBarFrame];

    switch (alignX) {
        case UIP_ALIGN_CENTER:
            _vFrame.origin.x = _pFrame.origin.x + (_pFrame.size.width - _vFrame.size.width)/2;
            break;
        case UIP_ALIGN_LEFT:
            _vFrame.origin.x = _pFrame.origin.x;
            break;
        case UIP_ALIGN_RIGHT:
            _vFrame.origin.x = _pFrame.origin.x + _pFrame.size.width - _vFrame.size.width;
            break;
        case UIP_SCREEN_CENTER:
            _vFrame.origin.x = (_sFrame.size.width - _vFrame.size.width)/2;
            break;
        case UIP_SCREEN_LEFT:
            _vFrame.origin.x = 0;
            break;
        case UIP_SCREEN_RIGHT:
            _vFrame.origin.x = _sFrame.size.width - _vFrame.size.width;
            break;
        default:
            _vFrame.origin.x = _pFrame.origin.x + alignX;
            break;
    }

    switch (alignY) {
        case UIP_ALIGN_CENTER:
            _vFrame.origin.y = _pFrame.origin.y + (_pFrame.size.height - _vFrame.size.height)/2;
            break;
        case UIP_ALIGN_LEFT:
            _vFrame.origin.y = _pFrame.origin.y;
            break;
        case UIP_ALIGN_RIGHT:
            _vFrame.origin.y = _pFrame.origin.y + _pFrame.size.height - _vFrame.size.height;
            break;
        case UIP_SCREEN_CENTER:
            _vFrame.origin.y = (_sFrame.size.height - _vFrame.size.height)/2 - _status.size.height/2;
            break;
        case UIP_SCREEN_LEFT:
            _vFrame.origin.y = - _status.size.height/2;
            break;
        case UIP_SCREEN_RIGHT:
            _vFrame.origin.y = _sFrame.size.height - _vFrame.size.height - _status.size.height/2;
            break;
        default:
            _vFrame.origin.y = _pFrame.origin.y + alignY;
            break;
    }
    [view setFrame:_vFrame];
}
@end
