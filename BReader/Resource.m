//
//  Resource.m
//  BReader
//
//  Created by ruikye on 14-4-8.
//
//

#import "Resource.h"

@implementation Resource

+(UIImage*) resForName:(NSString *)name{
    return [self resForName:name inDirectory:@""];
}

+(UIImage*) resForName:(NSString *)name inDirectory:(NSString *)dir{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil inDirectory:dir];
    return [[UIImage alloc]initWithContentsOfFile:path];
}

@end
