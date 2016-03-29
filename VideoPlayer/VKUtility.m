//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKUtility.h"
#import "Reachability.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <DTCSSStylesheet.h>
#import "DTCoreTextConstants.h"
#import "NSAttributedString+HTML.h"

@interface VKUtility ()

@property (nonatomic, strong) UIColor *cachedBackgroundColor;

@end

@implementation VKUtility

@synthesize cachedBackgroundColor;
@synthesize wifiReach = _wifiReach;
@synthesize internetReach = _internetReach;

/**
 *  单例方法,返回唯一类对象
 *
 *  @return 类对象
 */
+ (instancetype)sharedInstance
{
   static id sharedInstance = nil;

   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
   });

   return sharedInstance;
}

/**
 *  初始化方法,不需要手动调用,调用单例方法便会进行自动初始化
 *
 *  @return 返回类对象
 */
- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.internetReach = [Reachability reachabilityForInternetConnection];
        self.wifiReach = [Reachability reachabilityForLocalWiFi];
        [self.wifiReach startNotifier];
    }
    
    return self;
}

/**
 *  释放方法
 */
- (void)dealloc
{
    [self.wifiReach stopNotifier];
}

/**
 *  返回设备Window
 *
 *  @return 设备Window
 */
- (UIWindow *)deviceWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow* window = app.keyWindow;
    
    if (!window)
        window = [app.windows objectAtIndex:0];
    
    return window;
}

/**
 *  返回设备类型
 *
 *  @return iPhone or iPad or iPod
 */
- (NSString *)shortDeviceModel
{
    NSArray *deviceModelStrTokens = [[[UIDevice currentDevice] model] componentsSeparatedByString:@" "];
    
    return (deviceModelStrTokens.count > 0) ? [deviceModelStrTokens objectAtIndex:0] : nil;
}

/**
 *  获取当前应用的版本信息
 *
 *  @return 版本信息
 */
- (NSString *)appVersion
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* CFBundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString* CFBundleShortVersionString = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    if ([CFBundleVersion isEqualToString:CFBundleShortVersionString])
    {
        return [NSString stringWithFormat:@"%@", CFBundleShortVersionString];
    }
    else
    {
        return [NSString stringWithFormat:@"%@.%@", CFBundleShortVersionString, CFBundleVersion];
    }
}

/**
 *  系统样式的提示信息
 *
 *  @param title   标题
 *  @param message 内容
 */
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    [self showAlertViewWithTitle:title message:message tag:0 delegate:nil];
}

/**
 *  系统样式提示信息
 *
 *  @param title    标题
 *  @param message  内容
 *  @param tag      标志
 *  @param delegate 委托
 */
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag delegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil
                                                cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    alertView.tag = tag;
    alertView.delegate = delegate;
    
    [alertView show];
}

/**
 *  如字符串过长,大于250,则返回250字符串长度加上省略号...
 *
 *  @param str 字符串
 *
 *  @return 处理过的字符串
 */
- (NSString *)shorten:(NSString *)str
{
    int n = 250;
    
    if (str.length > n)
      return [[str substringToIndex:n] stringByAppendingString:@"..."];
  
    return str;
}

/**
 @method 获取指定宽度width,字体大小fontSize,字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float)heightForString:(NSString *)value andWidth:(float)width
{
    //获取当前文本的属性
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:value];
    
    NSRange range = NSMakeRange(0, attrStr.length);
    
    // 获取该段attributedString的属性字典
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
    // 计算文本的大小
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(width - 16.0, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:dic
                                           context:nil].size;
    
    return sizeToFit.height + 16.0;
}

/**
 *  返回NSUserDefault指定键对应的对象
 *
 *  @param key 键
 *
 *  @return 值对象
 */
- (id)setting:(NSString *)key
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    return setting;
}

/**
 *  设定NSUserDefault中指定键所对应的值
 *
 *  @param setting  值对象
 *  @param key      键
 */
- (void)setSetting:(id)setting forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (setting == nil)
    {
        [defaults removeObjectForKey:key];
    }

    [defaults setValue:setting forKey:key];
    [defaults synchronize];
}

/**
 *  获取NSUserDefaults中的自定义对象(需要解码)
 *
 *  @param key 键
 *
 *  @return 自定义对象
 */
- (id)settingCustomObject:(NSString *)key
{
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    id setting = encodedObject ? [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] : nil;
    
    return setting;
}

/**
 *  设置自定义对象到NSUserDefaults当中
 *
 *  @param setting 自定义对象
 *  @param key     键
 */
- (void)setSettingCustomObject:(id)setting forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:setting];
    
    [defaults setValue:encodedObject forKey:key];
    [defaults synchronize];
}

/**
 *  设置NSUserDefaults中的默认设置的键值数组
 *
 *  @param dictionary 键值数组
 */
- (void)setDefaultSettings:(NSDictionary *)dictionary
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

/**
 *  返回主线程
 *
 *  @return 线程
 */
- (NSRunLoop *)mainRunLoop
{
    return [NSRunLoop mainRunLoop];
}

/**
 *  返回AppDelegate
 *
 *  @return 系统委托对象
 */
- (id)appDelegate
{
    return (id)[UIApplication sharedApplication].delegate;
}

/**
 *  判断当前是否有网络连接
 *
 *  @return YES or NO
 */
- (BOOL)isConnected
{
    return [self.internetReach currentReachabilityStatus] != NotReachable;
}

/**
 *  判断当前是否连接到WIFI
 *
 *  @return YES or NO
 */
- (BOOL)isConnectedViaWiFi
{
    return [self.wifiReach isReachableViaWiFi];
}

/**
 *  判断当前设备是否是iPad
 *
 *  @return YES or NO
 */
- (BOOL)isPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

/**
 *  判断平台
 *
 *  @return 平台信息
 */
- (NSString *)platform
{
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

/**
 *  返回当前设备以及应用相关信息
 *
 *  @return 信息
 */
- (NSString *)defaultUserAgentString
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    // Attempt to find a name for this application
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!appName)
    {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }

    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];

    // If we couldn't find one, we'll give up (and ASIHTTPRequest will use the standard CFNetwork user agent)
    if (!appName)
    {
        return nil;
    }

    NSString *appVersion = [self appVersion];
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];

    #if TARGET_OS_IPHONE
    UIDevice *device = [UIDevice currentDevice];
    
    deviceName = [device model];
    OSName = [device systemName];
    OSVersion = [device systemVersion];

    #else
    deviceName = @"Macintosh";
    OSName = @"Mac OS X";

    // From http://www.cocoadev.com/index.pl?DeterminingOSVersion
    // We won't bother to check for systems prior to 10.4, since ASIHTTPRequest only works on 10.5+
    OSErr err;
    
    SInt32 versionMajor, versionMinor, versionBugFix;
    
    err = Gestalt(gestaltSystemVersionMajor, &versionMajor);
    
    if (err != noErr)
        return nil;
    
    err = Gestalt(gestaltSystemVersionMinor, &versionMinor);
    
    if (err != noErr)
        return nil;
    
    err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
    
    if (err != noErr)
        return nil;
    
    OSVersion = [NSString stringWithFormat:@"%u.%u.%u", versionMajor, versionMinor, versionBugFix];
    #endif

    // Takes the form "My Application 1.0 (Macintosh; Mac OS X 10.5.7; en_GB)"
    NSString *bundleIdentifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    
    return [NSString stringWithFormat:@"ViKiMobile %@ %@ %@ (%@; %@ %@; %@)", bundleIdentifier, appName, appVersion, deviceName, OSName, OSVersion, locale];
}

/**
 *  CGFloat类型转换为字符串类型
 *
 *  @param num 长整形
 *
 *  @return 字符串
 */
- (NSString *)floatToIntString:(CGFloat)num
{
    return [NSString stringWithFormat:@"%ld", (long)[[NSNumber numberWithFloat:num] integerValue]];
}

/**
 *  Double类型转换为字符串类型
 *
 *  @param num 超长整形
 *
 *  @return 字符串
 */
- (NSString *)doubleToIntString:(double)num
{
    return [NSString stringWithFormat:@"%ld", (long)[[NSNumber numberWithDouble:num] integerValue]];
}

/**
 *  字节类型转换为KB or MB or GB or TB or PB
 *
 *  @param bytes 字节数
 *
 *  @return 大小字符串
 */
- (NSString *)readableValueWithBytes:(id)bytes
{
    NSString *readable = @"";
    //round bytes to one kilobyte, if less than 1024 bytes
    
    if (([bytes longLongValue] < 1024))
    {
        readable = [NSString stringWithFormat:@"1 KB"];
    }
    //KB单位
    if (([bytes longLongValue]/1024) >= 1)
    {
        readable = [NSString stringWithFormat:@"%lld KB", ([bytes longLongValue]/1024)];
    }
    //MB单位
    if (([bytes longLongValue]/1024/1024) >= 1)
    {
        readable = [NSString stringWithFormat:@"%lld MB", ([bytes longLongValue]/1024/1024)];
    }
    //GB单位
    if (([bytes longLongValue]/1024/1024/1024) >= 1)
    {
        readable = [NSString stringWithFormat:@"%lld GB", ([bytes longLongValue]/1024/1024/1024)];
    }
    //TB单位
    if (([bytes longLongValue]/1024/1024/1024/1024) >= 1)
    {
        readable = [NSString stringWithFormat:@"%lld TB", ([bytes longLongValue]/1024/1024/1024/1024)];
    }
    //PB单位
    if (([bytes longLongValue]/1024/1024/1024/1024/1024) >= 1)
    {
        readable = [NSString stringWithFormat:@"%lld PB", ([bytes longLongValue]/1024/1024/1024/1024/1024)];
    }
    
    return readable;
}

/**
 *  字符串类型的HTTL数据,转换为带格式的NSAttributeString数据
 *
 *  @param html       HTML字符串数据
 *  @param styleBlock <#styleBlock description#>
 *
 *  @return     格式化后的字符串数据
 */
- (NSAttributedString*)attributedStringWithHTML:(NSString*)html styleBlock:(NSString*)styleBlock
{
    NSDictionary *styleOptionDic = [NSDictionary dictionaryWithObject:[[DTCSSStylesheet alloc] initWithStyleBlock:styleBlock] forKey:DTDefaultStyleSheet];
    
    return [[NSAttributedString alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                options:styleOptionDic
                                     documentAttributes:NULL];
}

/**
 *  将URL当中的参数转换为字典类型数据
 *
 *  @param query URL参数字段
 *
 *  @return 字典
 */
- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = @"";
      
        if (kv.count > 1)
        {
            val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if (kv.count > 0)
        {
            [params setObject:val forKey:kv[0]];
        }
    }
    
    return params;
}

/**
 *  秒时间转换为时长
 *
 *  @param seconds 秒数
 *
 *  @return 时长字符串
 */
- (NSString *)timeStringFromSecondsValue:(NSInteger)seconds
{
    NSString *retVal;
    
    NSInteger hours = seconds / 3600;
    NSInteger minutes = (seconds / 60) % 60;
    NSInteger secs = seconds % 60;
    
    if (hours > 0)
    {
        retVal = [NSString stringWithFormat:@"%01ld:%02ld:%02ld", (long)hours, (long)minutes, (long)secs];
    }
    else
    {
        retVal = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)secs];
    }
    
    return retVal;
}


- (CGRect)statusBarFrameViewRect:(UIView*)view
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect statusBarWindowRect = [view.window convertRect:statusBarFrame fromWindow: nil];
    CGRect statusBarViewRect = [view convertRect:statusBarWindowRect fromView: nil];
    
    return statusBarViewRect;
}

- (CGFloat)statusBarHeight:(UIView*)view
{
    CGRect statusBarFrame = [self statusBarFrameViewRect:view];
    CGFloat statusBarHeight = MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));
    
    if (statusBarHeight < 1.0f)
    {
        statusBarHeight = 20.0f;
    }
    
    return statusBarHeight;
}

@end
