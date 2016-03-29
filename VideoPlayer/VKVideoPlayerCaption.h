//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKVideoPlayerConfig.h"

#define kMinGapDurationInSeconds 7
#define kDurationThresholdInMinutes 5

//=========================宏定义错误类型=============================//

//字幕错误类型
typedef enum {
  // There was an error fetching the caption from the server.
  kCaptionErrorFetchError = 1000,
  
  // There was an error parsing the caption.
  kCaptionErrorParseError,
  
  // There were invalid segments in the caption.
  kCaptionErrorInvalidSegmentsError,
  
  // There was an unknown error.
  kCaptionErrorUnknown,
  
} VKCaptionErrorCode;

//=========================宏定义语言类型=============================//

typedef enum CaptionLanuguageType
{
    kCaptionLanguageOfEnglish   = 0,
    kCaptionLanguageOfChinese   = 1,
    kCaptionLanguageOfJapanese  = 2,
    kCaptionLanguageOfKorean    = 3,
    kCaptionLanguageOfOttoman   = 4
} CaptionLanuguageType;

//=========================XML字幕宏定义==============================//

#define kCaptionCuepointsString         @"cuepoints"
#define kCaptionCuepointString          @"cuepoint"
#define kCaptionStartString             @"start"
#define kCaptionEndString               @"end"
#define kCaptionNameString              @"name"
#define kCaptionSubtitlesString         @"subtitles"
#define kCaptionSubtitleString          @"subtitle"

#define kCaptionStartTimeKey            @"StartTimeKey"
#define kCaptionEndTimeKey              @"EndTimeKey"
#define kCaptionNameKey                 @"NameKey"
#define kCaptionSubtitlesKey            @"SubtitlesKey"

//=========================字幕协议==============================//

//字幕协议
@protocol VKVideoPlayerCaptionProtocol <NSObject>

//片段数组
@property (nonatomic, readonly) NSArray* segments;

//边界时间数组
- (NSArray*)boundryTimes;

//指定时间中的字幕内容
- (NSString*)contentAtTime:(NSInteger)timeInMilliseconds withLanguageType:(CaptionLanuguageType)type;

//标题类型
+ (NSString*)captionType;

@end

//===========================字幕类==============================//

//定义字幕类型数据
@interface VKVideoPlayerCaption : NSObject<VKVideoPlayerCaptionProtocol>

//=================成员变量==================//

//语言种类
@property (nonatomic, assign) CaptionLanuguageType languageType;

//语言标志码
@property (nonatomic, strong) NSString* languageCode;

//字幕片段数组
@property (nonatomic, strong) NSArray* segments;

//边界时间数组
@property (nonatomic, strong) NSArray* boundryTimes;

//首选的广告位置时间数组
@property (nonatomic, strong) NSArray* preferredAdSlotTimes;

//无效的片段数组
@property (nonatomic, strong) NSArray* invalidSegments;


//=================公开方法==================//

//类方法,利用字符串数组进行初始化字幕类对象
- (id)initWithRawString:(NSString *)subtitleRawData;

//类方法,利用数据类型进行初始化字幕类对象
- (id)initWithXMLData:(NSData *)subtitleXMLData;

//由NSSTring字符串解析字幕数据
- (void)parseSubtitleRaw:(NSString *)string completion:(void (^)(NSMutableArray *segments, NSMutableArray *invalidSegments))completion;

//由NSData数据解析字幕数据
- (void)parseSubtitleData:(NSData *)data completion:(void (^) (NSMutableArray *segments, NSMutableArray *invalidSegments))completion;


@end
