//
//  DramaVideoModel.h
//  SizeClass
//
//  Created by Kevin on 15/3/11.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DramaVideoModel : NSObject

//============================话剧数据实体属性=============================//

//话剧ID
@property (strong, nonatomic) NSString *dramaVideoID;

//话剧名称
@property (strong, nonatomic) NSString *dramaVideoName;

//话剧路径
@property (strong, nonatomic) NSString *dramaVideoUrl;

//话剧长度
@property (assign, nonatomic) NSInteger dramaVideoLength;

//话剧缩略图路径
@property (strong, nonatomic) NSString *dramaVideoImageUrl;


//============================对外接口方法=============================//

//对外接口获取一个话剧数据对象
+ (instancetype)dramaVideoModelWithDiction:(NSDictionary *)dictionary;

@end
