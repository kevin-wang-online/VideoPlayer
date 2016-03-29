//
//  DramaVideoModel.m
//  SizeClass
//
//  Created by Kevin on 15/3/11.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "DramaVideoModel.h"

@implementation DramaVideoModel

@synthesize dramaVideoID;
@synthesize dramaVideoImageUrl;
@synthesize dramaVideoLength;
@synthesize dramaVideoName;
@synthesize dramaVideoUrl;

+ (instancetype)dramaVideoModelWithDiction:(NSDictionary *)dictionary
{
    if (dictionary != nil)
    {
        DramaVideoModel *dramaVideoModel = [[DramaVideoModel alloc] init];
        
        dramaVideoModel.dramaVideoID = [dictionary objectForKey:@"DramaVideoID"];
        dramaVideoModel.dramaVideoName = [dictionary objectForKey:@"DramaVideoName"];
        dramaVideoModel.dramaVideoUrl = [dictionary objectForKey:@"DramaVideoUrl"];
        dramaVideoModel.dramaVideoLength = [[dictionary objectForKey:@"DramaVideoLength"] integerValue];
        dramaVideoModel.dramaVideoImageUrl = [dictionary objectForKey:@"DramaVideoImageUrl"];
        
        return dramaVideoModel;
    }
    else
    {
        NSLog(@"给入的视频数据字典为空,返回对象为nil");
    }

    return nil;
}

@end
