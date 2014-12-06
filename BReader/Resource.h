//
//  Resource.h
//  BReader
//
//  Created by ruikye on 14-4-8.
//
//

#import <Foundation/Foundation.h>

@interface Resource : NSObject
+(UIImage*) resForName:(NSString*)name;
+(UIImage*) resForName:(NSString *)name inDirectory:(NSString*)dir;
@end
