//
//  Created by Kevin.
//  Copyright (c) 2015 Kevin Inc. All rights reserved.
//

#define VKSharedUtility [VKUtility sharedInstance]

@class Reachability;

@interface VKUtility : NSObject

@property (nonatomic, strong) Reachability* wifiReach;
@property (nonatomic, strong) Reachability* internetReach;


//单例方法,返回唯一示例对象
+ (instancetype)sharedInstance;

//返回设备Window
- (UIWindow *)deviceWindow;

//返回设备类型iPhone or iPod or iPad
- (NSString *)shortDeviceModel;

//UIAlertView返回系统样式的提示信息
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag delegate:(id<UIAlertViewDelegate>)delegate;

//如果字符串长度大于250则返回字符串250的字符串外加省略号...
- (NSString *)shorten:(NSString *)str;

//计算字符串的高度
- (float)heightForString:(NSString *)value andWidth:(float)width;

//返回NSUserDefaults当中的键值对象
- (id)setting:(NSString *)key;

//设置NSUserDefaults当中的键值对象
- (void)setSetting:(id)setting forKey:(NSString *)key;

//返回NSUserDefaults中的自定义对象
- (id)settingCustomObject:(NSString *)key;

//设置自定义对象到NSUserDefaults中
- (void)setSettingCustomObject:(id)setting forKey:(NSString *)key;

//设置默认的NSUserDefaults中的键值对数组
- (void)setDefaultSettings:(NSDictionary *)dictionary;

//返回系统主线程
- (NSRunLoop *)mainRunLoop;

//判断网络是否连接
- (BOOL)isConnected;

//判断是否连接到WIFI
- (BOOL)isConnectedViaWiFi;

//判断是否是iPad
- (BOOL)isPad;

//判断当前平台
- (NSString *)platform;

//获取当前应用的CFBoudnleVersion版本信息
- (NSString *)appVersion;

//Float类型转换为字符串类型NSString
- (NSString *)floatToIntString:(CGFloat)num;

//Double类型转换类整形的字符串类型NSString
- (NSString *)doubleToIntString:(double)num;

//字节大小转换为单位大小KB MB GB TB PB
- (NSString *)readableValueWithBytes:(id)bytes;

//字符串类型的HTTL数据,转换为带格式的NSAttributeString数据
- (NSAttributedString*)attributedStringWithHTML:(NSString*)html styleBlock:(NSString*)styleBlock;

//返回当前设备以及应用相关信息 
- (NSString *)defaultUserAgentString;

//将URL当中的参数转换为字典类型数据
- (NSDictionary*)parseURLParams:(NSString *)query;

//将秒转化为时长数据
- (NSString *)timeStringFromSecondsValue:(NSInteger)seconds;

//获取状态栏的Rect
- (CGRect)statusBarFrameViewRect:(UIView*)view;

//获取状态栏高度
- (CGFloat)statusBarHeight:(UIView*)view;

@end