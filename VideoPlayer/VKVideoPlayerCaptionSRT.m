//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKVideoPlayerCaptionSRT.h"

@implementation VKVideoPlayerCaptionSRT

#pragma mark - VKVideoPlayerCaptionParserProtocol

#pragma mark -
#pragma mark - Rewrite Super Methods

/**
 *  解析SRT字幕数据方法
 *
 *  @param string     字符串类型字幕数据
 *  @param completion 解析完成Block
 */
- (void)parseSubtitleRaw:(NSString *)srt completion:(void (^)(NSMutableArray* segments, NSMutableArray* invalidSegments))completion
{
    NSMutableArray* segments = [NSMutableArray array];
    NSMutableArray* invalidSegments = [NSMutableArray array];
    
    NSScanner *scanner = [NSScanner scannerWithString:srt];
    
    while (![scanner isAtEnd])
    {
        NSString *indexString;
        NSString *startString;
        NSString *endString;
        
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&indexString];
        [scanner scanUpToString:@" --> " intoString:&startString];
        [scanner scanString:@"-->" intoString:NULL];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&endString];
    
        NSString *textString;
        [scanner scanUpToString:@"\r\n\r\n" intoString:&textString];
        textString = [textString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>"];
        textString = [textString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        // Addresses trailing space added if CRLF is on a line by itself at the end of the SRT file
        textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSNumber *start = [NSNumber numberWithInteger:[self millisecondsFromTimecodeString:startString]];
        NSNumber *end = [NSNumber numberWithInteger:[self millisecondsFromTimecodeString:endString]];
        
        //判断开始时间和结束时间是否是无效的
        BOOL isNegativeTime = [start integerValue] > [self millisecondsFromTimecodeString:@"20:00:00,000"] ||
                              [end integerValue] > [self millisecondsFromTimecodeString:@"20:00:00,000"];
        
        //是否是重叠覆盖的片段
        BOOL isOverlappingSegment = segments.count > 0 &&
                                    [segments.lastObject[@"end_time"] integerValue] > [start integerValue];
        
        //是否是下一个字幕片段
        BOOL isNextSegment = segments.count == 0 ||
                             [indexString integerValue] > [segments.lastObject[@"index"] integerValue];
        
        //是否是有效的字幕片段
        BOOL isValidSegment = [start compare:end] == NSOrderedAscending;
    
        //时间符合条件
        //有效
        //下一个
        //不重叠
        if (!isNegativeTime && isValidSegment && isNextSegment && !isOverlappingSegment)
        {
            NSMutableDictionary* segment = [NSMutableDictionary dictionary];
            
            //序号
            [segment setValue:[NSNumber numberWithInteger:[indexString integerValue]] forKey:@"index"];
            //开始时间
            [segment setValue:start forKey:@"start_time"];
            //结束时间
            [segment setValue:end forKey:@"end_time"];
            //文本内容
            [segment setValue:textString forKey:@"content"];
            
            [segments addObject:segment];
        }
        else
        {
            [invalidSegments addObject:textString];
        }
    }
  
    completion(segments, invalidSegments);
}

#pragma mark -
#pragma mark - Private Methods

/**
 *  将时间格式01：00：00,000 转换为以毫秒为单位的时间长度 3600000ms
 *
 *  @param timecodeString 字符串类型时间
 *
 *  @return 时间长度
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

@end
