//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKVideoPlayerCaption.h"
#import "VKVideoPlayerCaptionSRT.h"
#import "VKVideoPlayerCaptionXML.h"

@implementation VKVideoPlayerCaption

@synthesize languageType;
@synthesize languageCode;
@synthesize segments = _segments;
@synthesize boundryTimes = _boundryTimes;
@synthesize preferredAdSlotTimes = _preferredAdSlotTimes;
@synthesize invalidSegments = _invalidSegments;

#pragma mark -
#pragma mark - Initialize Methods

/**
 *  类方法,利用字幕字符串进行初始化对象
 *
 *  @param subtitleRawData 字符串类型字幕数据
 *
 *  @return 字幕对象
 */
- (id)initWithRawString:(NSString *)subtitleRawData
{
    self = [super init];
    
    if (self)
    {
        //防止block调用self导致循环强引用
        __weak __typeof(self) weakSelf = self;
        
        [self parseSubtitleRaw:subtitleRawData completion:^(NSMutableArray *segments, NSMutableArray *invalidSegments)
        {
            //初始化字幕片段数组
            weakSelf.segments = segments;
            
            //初始化无效片段数组
            weakSelf.invalidSegments = invalidSegments;
            
            //私有方法,初始化片段边界时间数组和广告时间点数组
            [weakSelf processSegmentsForART:weakSelf.segments];
        }];
    }
    
    return self;
}

/**
 *  类方法
 *
 *  @param subtitleXMLData 数据类型字幕数据
 *
 *  @return 字幕对象
 */
- (id)initWithXMLData:(NSData *)subtitleXMLData
{
    self = [super init];
    
    if (self)
    {
        //防止block调用self导致循环强引用
        __weak __typeof(self) weakSelf = self;
        
        [self parseSubtitleData:subtitleXMLData completion:^(NSMutableArray *segments, NSMutableArray *invalidSegments) {
            //初始化字幕片段数组
            weakSelf.segments = segments;
            
            //初始化无效片段数组
            weakSelf.invalidSegments = invalidSegments;
            
            //私有方法,初始化片段边界时间数组和广告时间点数组
            [weakSelf processSegmentsForXML:weakSelf.segments];
        }];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Class Public Methods

/**
 *  解析字幕数据方法
 *
 *  @param string     字符串类型字幕数据
 *  @param completion 解析完成Block
 */
- (void)parseSubtitleRaw:(NSString *)string completion:(void (^)(NSMutableArray *segments, NSMutableArray *invalidSegments))completion
{
    completion(nil, nil);
}

/**
 *  解析字幕数据方法
 *
 *  @param string     数据类型字幕数据
 *  @param completion 解析完成Block
 */
- (void)parseSubtitleData:(NSData *)data completion:(void (^) (NSMutableArray *segments, NSMutableArray *invalidSegments))completion
{
    completion(nil, nil);
}



/**
 *  返回字幕类型
 *
 *  @return 字符串常量
 */
+ (NSString*)captionType
{
    return @"subtitles";
}

#pragma mark -
#pragma mark - Private Methods

/**
 *  将时间格式的数据转换为秒 01:00:00 ---> 3600s
 *
 *  @param timecodeString 字符串类型时间数据
 *
 *  @return 返回该时间对应的秒数
 */
- (NSInteger)millisecondsFromTimecodeString:(NSString *)timecodeString
{
    NSArray *timeComponents = [timecodeString componentsSeparatedByString:@":"];

    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSArray *secondsComponents;
    NSInteger seconds = 0;
    NSInteger milliseconds = 0;
  
    if (timeComponents.count > 0)
        hours = [(NSString *)[timeComponents objectAtIndex:0] integerValue];

    if (timeComponents.count > 1)
        minutes = [(NSString *)[timeComponents objectAtIndex:1] integerValue];

    if (timeComponents.count > 2)
    {
        secondsComponents = [(NSString *)[timeComponents objectAtIndex:2] componentsSeparatedByString:@","];
      
        if (secondsComponents.count > 0)
            seconds = [(NSString *)[secondsComponents objectAtIndex:0] integerValue];
      
        if (secondsComponents.count > 1)
            milliseconds = [(NSString *)[secondsComponents objectAtIndex:1] integerValue];
    }

    NSInteger totalNumSeconds = (hours * 3600) + (minutes * 60) + seconds;

    return totalNumSeconds * 1000 + milliseconds;
}

/**
 *  私有的初始化方法
 *
 *  @param attributes 属性字典
 *
 *  @return 返回字幕类对象
 */
- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];

    if (!self)
    {
        return nil;
    }
    else
    {
        self.languageCode = [attributes valueForKeyPathWithNilCheck:@"language_code"];
        
        self.segments = [attributes valueForKeyPathWithNilCheck:@"subtitles"];
        
        [self processSegmentsForART:self.segments];
        
        return self;
    }
}

/**
 *  给出一个最接近广告位置时间的序号
 *
 *  @param timeInMilliseconds 时间
 *
 *  @return 广告数组中的序号
 */
- (NSNumber*)closestPreferredAdSlotTimeInMilliseconds:(NSNumber*)timeInMilliseconds
{
    if (self.preferredAdSlotTimes.count == 0)
        return nil;

    NSUInteger index = [self.preferredAdSlotTimes indexOfObject:timeInMilliseconds
                                                  inSortedRange:NSMakeRange(0, self.preferredAdSlotTimes.count)
                                                  options:NSBinarySearchingInsertionIndex
                                                  usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                      NSNumber* n1 = obj1;
                                                      NSNumber* n2 = obj2;
                                                      
                                                      return [n1 compare:n2];
                                                  }];

    if (index >= self.preferredAdSlotTimes.count)
    {
        index = self.preferredAdSlotTimes.count - 1;
    }
    
    CGFloat preferredAdSlotTime = [self.preferredAdSlotTimes[index] floatValue];

    BOOL isLessThanDurationThreshold = preferredAdSlotTime < ([timeInMilliseconds floatValue] + (kDurationThresholdInMinutes * 60 * 1000));
    
    BOOL isMoreThanCurrentTime = preferredAdSlotTime > [timeInMilliseconds floatValue];

    if (isMoreThanCurrentTime && isLessThanDurationThreshold)
    {
        return self.preferredAdSlotTimes[index];
    }
    else
    {
        return nil;
    }
}

/**
 *  初始化片段边界时间数组[0,10,30,50,50,60,80,100]和广告时间点[20,70]数组
 *
 *  @param segments 字幕片段数组
 */
- (void)processSegmentsForART:(NSArray*)segments
{
    NSMutableArray* times = [NSMutableArray array];
    NSMutableArray* adSlotTimes = [NSMutableArray array];
    
    for (int i = 0; i < segments.count; i++)
    {
        NSNumber* startTime = [segments[i] valueForKeyPath:@"start_time"];
        NSNumber* endTime = [segments[i] valueForKeyPath:@"end_time"];
        
        [times addObject:[NSValue valueWithCMTime:CMTimeMake([startTime integerValue], 1000)]];
        [times addObject:[NSValue valueWithCMTime:CMTimeMake([endTime integerValue], 1000)]];
        
        if (i + 1 < segments.count)
        {
            NSNumber* gapStartTime = [segments[i] valueForKeyPath:@"end_time"];
            NSNumber* gapEndTime = [segments[i+1] valueForKeyPath:@"start_time"];
            
            CGFloat gap = [gapEndTime floatValue] - [gapStartTime floatValue];
            
            if (gap >= kMinGapDurationInSeconds * 1000)
            {
                [adSlotTimes addObject:[NSNumber numberWithFloat:[gapStartTime floatValue] + gap/2]];
            }
        }
    }
    
    self.boundryTimes = times;
    self.preferredAdSlotTimes = adSlotTimes;
}

/**
 *  初始化片段边界时间数组[0,10,30,50,50,60,80,100]和广告时间点[20,70]数组
 *
 *  @param segments 字幕片段数组
 */
- (void)processSegmentsForXML:(NSArray*)segments
{
    NSMutableArray* times = [NSMutableArray array];
    NSMutableArray* adSlotTimes = [NSMutableArray array];
    
    for (int i = 0; i < segments.count; i++)
    {
        NSNumber* startTime = [segments[i] valueForKeyPath:kCaptionStartTimeKey];
        NSNumber* endTime = [segments[i] valueForKeyPath:kCaptionEndTimeKey];
        
        [times addObject:[NSValue valueWithCMTime:CMTimeMake([startTime integerValue], 1000)]];
        [times addObject:[NSValue valueWithCMTime:CMTimeMake([endTime integerValue], 1000)]];
        
        if (i + 1 < segments.count)
        {
            NSNumber* gapStartTime = [segments[i] valueForKeyPath:kCaptionEndTimeKey];
            NSNumber* gapEndTime = [segments[i+1] valueForKeyPath:kCaptionStartTimeKey];
            
            CGFloat gap = [gapEndTime floatValue] - [gapStartTime floatValue];
            
            if (gap >= kMinGapDurationInSeconds * 1000)
            {
                [adSlotTimes addObject:[NSNumber numberWithFloat:[gapStartTime floatValue] + gap/2]];
            }
        }
    }
    
    self.boundryTimes = times;
    self.preferredAdSlotTimes = adSlotTimes;
}

#pragma mark -
#pragma mark - VKVideoPlayerCaption Protocol Methods

/**
 *  返回指定时间的字幕内容
 *
 *  @param timeInMilliseconds 指定时间
 *
 *  @return 字幕内容
 */
- (NSString*)contentAtTime:(NSInteger)timeInMilliseconds withLanguageType:(CaptionLanuguageType)type
{
    NSString *startTimeKey;
    NSString *endTimeKey;
    
    if ([self isKindOfClass:[VKVideoPlayerCaptionSRT class]])
    {
        startTimeKey = @"start_time";
        endTimeKey = @"end_time";
    }
    else if([self isKindOfClass:[VKVideoPlayerCaptionXML class]])
    {
        startTimeKey = kCaptionStartTimeKey;
        endTimeKey = kCaptionEndTimeKey;
    }
    
    //定义该时间下的字典变量
    NSDictionary* time = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:timeInMilliseconds], startTimeKey,
                        @"", endTimeKey,nil];
    
    //检索字幕片段数组中的该时间所在序号
    NSUInteger index = [self.segments indexOfObject:time
                                      inSortedRange:NSMakeRange(0, self.segments.count)
                                      options:NSBinarySearchingInsertionIndex
                                      usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                          NSNumber* n1 = [obj1 valueForKeyPath:startTimeKey];
                                          NSNumber* n2 = [obj2 valueForKeyPath:startTimeKey];
                                        
                                          if (!n1)
                                              n1 = [NSNumber numberWithInt:0];
                                        
                                          if (!n2)
                                              n2 = [NSNumber numberWithInt:0];
                                        
                                          return [n1 compare:n2];
                                    }];
    
    if (index >= self.segments.count)
    {
        index = self.segments.count - 1;
    }
  
    NSInteger segmentStartTime = [[[self.segments objectAtIndex:index] valueForKeyPath:startTimeKey] integerValue];
    NSInteger segmentEndTime = [[[self.segments objectAtIndex:index] valueForKeyPath:endTimeKey] integerValue];
  
    if (index == 0 && timeInMilliseconds < segmentStartTime)
    {
        return @"";
    }
  
    if (segmentStartTime == timeInMilliseconds)
    {
        //case when exactly the start of a new segment, so use that segment
    }
    else
    {
        //use the segment just before but check for edgecase when only 1 segment and index is already 0
        if (index > 0)
            index--;
        
        segmentStartTime = [[[self.segments objectAtIndex:index] valueForKeyPath:startTimeKey] integerValue];
        segmentEndTime = [[[self.segments objectAtIndex:index] valueForKeyPath:endTimeKey] integerValue];
    }
  
    if (timeInMilliseconds >= segmentStartTime && timeInMilliseconds < segmentEndTime)
    {
        if ([startTimeKey isEqualToString:@"start_time"])
        {
            //ART类型字幕数据
            return [[self.segments objectAtIndex:index] valueForKeyPath:@"content"];
        }
        else if([startTimeKey isEqualToString:kCaptionStartTimeKey])
        {
            //XML类型字幕数据
            return [[[self.segments objectAtIndex:index] objectForKey:kCaptionSubtitlesKey] objectAtIndex:type];
        }
        else
        {
            return @"";
        }
    }
    else
    {
        return @"";
    }
}

@end
