//
//  DramaModel.h
//  SizeClass
//
//  Created by Kevin on 15/3/11.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DramaModel : NSObject

//话剧ID
@property (strong, nonatomic) NSString *dramaID;

//话剧名称
@property (strong, nonatomic) NSString *dramaName;

//上映剧院
@property (strong, nonatomic) NSString *dramaTheaterName;

//话剧上映年份
@property (strong, nonatomic) NSString *dramaDisplayYear;

//话剧导演
@property (strong, nonatomic) NSString *dramaDirector;

+ (instancetype)dramaModelWithDictionary:(NSDictionary *)dictionary;

@end
