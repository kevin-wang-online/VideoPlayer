//
//  VKVideoPlayerCaptionXML.m
//  ASIA
//
//  Created by Kevin on 15/4/8.
//  Copyright (c) 2015年 FreeWave. All rights reserved.
//

#import "VKVideoPlayerCaptionXML.h"

@interface VKVideoPlayerCaptionXML ()
{
    //暂存字幕数组
    NSMutableArray *captionArrayBuffer;
    
    //暂存字幕信息字典
    NSMutableDictionary *captionDictionaryBuffer;
    
    //暂存各国字幕内容数组
    NSMutableArray *captionContentArrayBuffer;
    
    //是否找到开始时间标签
    BOOL isFoundStartTime;
    //是否找到结束时间标签
    BOOL isFoundEndTime;
    //是否找到名称标签
    BOOL isFoundName;
    //是否找到字幕内容标签
    BOOL isFoundSubtitles;
    //是否找到某国字幕标签
    BOOL isFoundSubtitleLanguage;
}

@end

@implementation VKVideoPlayerCaptionXML


#pragma mark -
#pragma mark - Rewrite Super Methods

/**
 *  解析XML字幕数据方法
 *
 *  @param string     数据类型字幕数据
 *  @param completion 解析完成Block
 */
- (void)parseSubtitleData:(NSData *)data completion:(void (^)(NSMutableArray *, NSMutableArray *))completion
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    parser.delegate = self;
    
    [parser parse];
}

#pragma mark -
#pragma mark - Private Methods

/**
 *  将整数秒时间转换为整数毫秒
 *
 *  @param timeSecondString 字符串秒
 *
 *  @return 整形毫秒时间
 */
- (NSInteger)millisecondsFromTimeSecondsString:(NSString *)timeSecondString
{
    NSInteger totalMilloSeconds = [timeSecondString integerValue] * 1000;
    
    return totalMilloSeconds;
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
#pragma mark - NSXMLParser Delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"开始解析文档");
}

/**
 *  解析到一个元素开头的时候调用
 *
 *  @param parser        解析器
 *  @param elementName   元素名称
 *  @param namespaceURI  命名空间URI
 *  @param qName         校验码
 *  @param attributeDict 元素字典
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"解析到一个元素的开头---%@",elementName);
    if ([kCaptionCuepointsString isEqualToString:elementName])
    {
        //所有字幕根节点           开始标签
        if (!captionArrayBuffer)
        {
            captionArrayBuffer = [[NSMutableArray alloc] init];
        }
    }
    else if ([kCaptionCuepointString isEqualToString:elementName])
    {
        //一段字幕片段开始节点      开始标签
        if (!captionDictionaryBuffer)
        {
            captionDictionaryBuffer = [[NSMutableDictionary alloc] init];
        }
    }
    else if ([kCaptionStartString isEqualToString:elementName])
    {
        //一段字幕开始时间节点      开始标签
        isFoundStartTime = YES;
    }
    else if ([kCaptionEndString isEqualToString:elementName])
    {
        //一段字幕结束时间节点      开始标签
        isFoundEndTime = YES;
    }
    else if ([kCaptionNameString isEqualToString:elementName])
    {
        //一段字幕名称节点          开始标签
        isFoundName = YES;
    }
    else if ([kCaptionSubtitlesString isEqualToString:elementName])
    {
        //一段字幕内容节点          开始标签
        isFoundSubtitles = YES;
        
        if (!captionContentArrayBuffer)
        {
            captionContentArrayBuffer = [[NSMutableArray alloc] init];
        }
        
        [captionDictionaryBuffer setObject:captionContentArrayBuffer forKey:kCaptionSubtitlesKey];
    }
    else if ([kCaptionSubtitleString isEqualToString:elementName])
    {
        //某国语言字幕节点 CDATA类型数据    开始标签
        isFoundSubtitleLanguage = YES;
    }
}

/**
 *  解析到Characters数据
 *
 *  @param parser 解析器
 *  @param string 数据
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (isFoundStartTime)
    {
        //找到开始时间标签的内容
        NSNumber *startNumber = [NSNumber numberWithInteger:[self millisecondsFromTimeSecondsString:string]];
        
        [captionDictionaryBuffer setObject:startNumber forKey:kCaptionStartTimeKey];
    }
    else if (isFoundEndTime)
    {
        //找到结束时间标签的内容
        NSNumber *endNumber = [NSNumber numberWithInteger:[self millisecondsFromTimeSecondsString:string]];
        
        [captionDictionaryBuffer setObject:endNumber forKey:kCaptionEndTimeKey];
    }
    else if (isFoundName)
    {
        //找到名称标签的内容
        [captionDictionaryBuffer setObject:string forKey:kCaptionNameKey];
    }
}

/**
 *  解析到CDATA类型的数据
 *
 *  @param parser     解析器
 *  @param CDATABlock 数据
 */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    if (isFoundSubtitleLanguage)
    {
        //找到了格式为CDATA类型的字幕内容
        NSString *captionContentString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        
        //添加该国字幕内容到字幕内容数组
        [captionContentArrayBuffer addObject:captionContentString];
    }
}

/**
 *  解析到一个元素结尾的时候调用
 *
 *  @param parser       解析器
 *  @param elementName  元素名称
 *  @param namespaceURI 命名空间URI
 *  @param qName        校验码
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"解析到一个元素的结尾---%@",elementName);
    if ([kCaptionCuepointsString isEqualToString:elementName])
    {
        //所有字幕根节点    结束标签
    }
    else if ([kCaptionCuepointString isEqualToString:elementName])
    {
        //一段字幕片段开始节点   结束标签
        [captionArrayBuffer addObject:captionDictionaryBuffer];
        
        if (captionDictionaryBuffer)
        {
            captionDictionaryBuffer = nil;
        }
    }
    else if ([kCaptionStartString isEqualToString:elementName])
    {
        //一段字幕开始时间节点   结束标签
        isFoundStartTime = NO;
    }
    else if ([kCaptionEndString isEqualToString:elementName])
    {
        //一段字幕结束时间节点   结束标签
        isFoundEndTime = NO;
    }
    else if ([kCaptionNameString isEqualToString:elementName])
    {
        //一段字幕名称节点      结束标签
        isFoundName = NO;
    }
    else if ([kCaptionSubtitlesString isEqualToString:elementName])
    {
        //一段字幕内容节点      结束标签
        isFoundSubtitles = NO;
        
        if (captionContentArrayBuffer)
        {
            captionContentArrayBuffer = nil;
        }
    }
    else if ([kCaptionSubtitleString isEqualToString:elementName])
    {
        //某国语言字幕节点 CDATA类型数据        结束标签
        isFoundSubtitleLanguage = NO;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"结束解析文档");
    
    self.segments = captionArrayBuffer;
    
    [self processSegmentsForXML:self.segments];
}

@end
