//
//  DramaModel.m
//  SizeClass
//
//  Created by Kevin on 15/3/11.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "DramaModel.h"

@implementation DramaModel

@synthesize dramaID;
@synthesize dramaName;
@synthesize dramaDirector;
@synthesize dramaTheaterName;
@synthesize dramaDisplayYear;

+ (instancetype)dramaModelWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary)
    {
        DramaModel *dramaModel = [[DramaModel alloc] init];
        
        dramaModel.dramaID = [dictionary objectForKey:@"DramaID"];
        dramaModel.dramaName = [dictionary objectForKey:@"DramaName"];
        dramaModel.dramaDirector = [dictionary objectForKey:@"DramaDirector"];
        dramaModel.dramaTheaterName = [dictionary objectForKey:@"DramaTheaterName"];
        dramaModel.dramaDisplayYear = [dictionary objectForKey:@"DramaDisplayYear"];
        
        return dramaModel;
    }
    else
    {
        NSLog(@"传入的字典数据为空，返回nil");
    }
    
    return nil;
}

@end
