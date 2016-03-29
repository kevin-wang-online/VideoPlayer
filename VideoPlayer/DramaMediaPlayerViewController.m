//
//  MediaPlayerViewController.m
//  SizeClass
//
//  Created by Kevin on 15/3/11.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "DramaMediaPlayerViewController.h"

static NSString * const ReuseIdentifier = @"MY_Cell";

@interface DramaMediaPlayerViewController ()
{
    //菜单触摸计时器
    NSTimer *menuDisplayTimer;
    
    //用户操作书签状态
    BOOL bookMarkContidion;
    
    //菜单栏是否显示状态
    BOOL bottomAndTopMenuHidden;
    
    //iOS7版本旋转屏幕至竖屏标记
    BOOL rotationToPortraintMark;
    
    //状态栏是否隐藏标记
    BOOL statusBarHiddenCondition;
    
    //播放器高度值记录
    CGFloat playerContainerViewHeight;
    
    //记录用户添加当前书签起始位置以及内容信息
    NSMutableDictionary *bookMarkDictionary;
}

@end

@implementation DramaMediaPlayerViewController

@synthesize languageType;
@synthesize dramaUrl;
@synthesize dramaPlayer;
@synthesize dramaPlayerLayer;

@synthesize progressSlider;
@synthesize progressBackView;

//背景
@synthesize backgroundView;
@synthesize backgroundViewTopConstraint;

//播放器
@synthesize playerContainerView;
@synthesize playerContainerViewHeightConstraint;

//字幕
@synthesize playerCaptionScrollBackView;

@synthesize playerCaptionScrollBackContentView;
@synthesize playerCaptionContentConstraint;

@synthesize playerCaptionView;

//播放器菜单
@synthesize topMenuContainerView;
@synthesize bottomMenuContainerView;

@synthesize captionBottomProtocol;
@synthesize bottomCaptionTimer;

//菜单按钮
@synthesize playOrPauseButton;
@synthesize bookMarkButton;
@synthesize playTimeLabel;
@synthesize zoomScreenButton;

//表视图
@synthesize dramaDetailTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    //初始化导航菜单
    [self initializeNavagationBarItems];
    
    //初始化播放影片对象AVPlayerItem
    [self initializeAVPlayer];
    
    //注册话剧表视图所用TableViewCell类
    [self registerDramaDetailTableViewCell];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //初始化播放器界面
    [self initializePlayerLayerView];
    
    //初始化播放器字幕
    [self initializeNetworkXMLCaptionToPlayerView];
    
    //播放
    [dramaPlayer play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //暂停播放
    [dramaPlayer pause];
    
    //移除监听
    [self removeNotification];
    
    //移除对影片的监听
    [self removeObserverFromPlayerItem:dramaPlayer.currentItem];
    
    [menuDisplayTimer invalidate];
    
    dramaPlayer = nil;
}

#pragma mark -
#pragma mark - Super Status Methods

- (BOOL)prefersStatusBarHidden
{
    return statusBarHiddenCondition;
}

#pragma mark -
#pragma mark - Super Rotate Methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark - Private RequestWebserviceData Methods

/**
 *  用话剧ID请求话剧XML字幕数据
 *
 *  @param dramaID 话剧ID
 */
- (void)requestXMLCaptionDataWithDramaID:(NSString *)dramaID
{
    //拿回数据,初始化字幕对象
}

/**
 *  用话剧ID请求用户的书签数据
 *
 *  @param dramaID 话剧ID
 */
- (void)requestDramaBookmarkDataWithDramaID:(NSString *)dramaID
{
    //拿回数据,初始化用户书签表视图
}

/**
 *  用话剧ID和语言类别请求话剧详情数据
 *
 *  @param dramaID 话剧ID
 *  @param type    语言类别
 */
- (void)requestDramaDetailDataWithDramaID:(NSString *)dramaID andLanguageType:(LanuguageType)type
{
    //拿回数据,初始化话剧详情表视图
}

#pragma mark -
#pragma mark - Private UserInterface Methods

/**
 *  初始化导航栏菜单
 */
- (void)initializeNavagationBarItems
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickBackNavigationBarButton:)];
    
    backBarButtonItem.tintColor = UIColorWithRGB(107.0, 107.0, 103.0);
    
    UIBarButtonItem *changeLanguageBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"changeLanguage"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickChangeLanguageNavigationBarButton:)];
    
    changeLanguageBarButtonItem.tintColor = UIColorWithRGB(107.0, 107.0, 103.0);
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    self.navigationItem.rightBarButtonItem = changeLanguageBarButtonItem;
}

/**
 *  初始化播放器
 */
- (void)initializeAVPlayer
{
    //获取本地播放视频路径
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"MYSBD" ofType:@"mp4"];
    
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url=[[NSURL alloc] initFileURLWithPath:urlStr];
    
    //网络视频
    //NSURL *webUrl = [NSURL URLWithString:@"http://devimages.apple.com/samplecode/adDemo/ad.m3u8"];
    
    //利用路径初始化一个播放对象
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    
    //初始化视频播放器
    dramaPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    
    //加载对播放对象的监听
    [self addNotification];
    
    //播放器进度更新
    [self addProgressObserver];
    
    //给AVPlayerItem添加监听
    [self addObserverToPlayerItem:playerItem];
}

/**
 *  初始化播放器界面
 */
- (void)initializePlayerLayerView
{
    bottomMenuContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kTopAndBottomMenuAlphaValue];
    topMenuContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kTopAndBottomMenuAlphaValue];

    //加载进度条拉动响应事件
    [progressSlider addTarget:self action:@selector(seekToSpecifiedTimeAndUpdateTimeLabels) forControlEvents:UIControlEventValueChanged];
    
    //菜单栏自动隐藏时间控制器
    menuDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoHiddenPlayerMenuTime target:self selector:@selector(menuDisplayTimerActionMethod:) userInfo:nil repeats:YES];
    
    //加载视频播放界面点击事件
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickPlayerContainerView:)];
    
    [singleTap setDelegate:self];
    
    [playerContainerView addGestureRecognizer:singleTap];
    
    //初始化AVPlayerLayer底层播放器视图
    dramaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:dramaPlayer];
    
    playerContainerViewHeight = playerContainerView.frame.size.height;
    dramaPlayerLayer.frame = playerContainerView.frame;
    dramaPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [playerContainerView.layer addSublayer:dramaPlayerLayer];
    
    [playerContainerView bringSubviewToFront:playerCaptionScrollBackView];
    [playerContainerView bringSubviewToFront:topMenuContainerView];
    [playerContainerView bringSubviewToFront:bottomMenuContainerView];
}

/**
 *  初始化话剧详情表视图
 */
- (void)registerDramaDetailTableViewCell
{
    [dramaDetailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ReuseIdentifier];
}

/**
 *  初始化播放器字幕
 */
- (void)initializeNetworkXMLCaptionToPlayerView
{
    //1.调用网络接口获取XML字幕数据
    //2.对XML字幕数据进行解析
    //3.初始化字幕对象
    //4.显示字幕内容到播放器
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CaptionLong" ofType:@"xml"];
    
    NSData *testData = [NSData dataWithContentsOfFile:filePath];

    VKVideoPlayerCaption *xmlCaption = [[VKVideoPlayerCaptionXML alloc] initWithXMLData:testData];
    
    [self setCaptionToBottom:xmlCaption];
}

#pragma mark -
#pragma mark - Private Function Methods

/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver
{
    AVPlayerItem *playerItem = dramaPlayer.currentItem;
    
    __block VKScrubber *scrubber = progressSlider;
    
    __weak __typeof(self) weakSelf = self;
    
    //这里设置每秒执行一次
    [dramaPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current = CMTimeGetSeconds(time);

        CGFloat totalSecond = CMTimeGetSeconds([playerItem duration]);
        
        if ([[NSString stringWithFormat:@"%f",totalSecond] isEqualToString:@"nan"])
        {
            totalSecond = 1.0;
        }
        
        weakSelf.playTimeLabel.text = [weakSelf timeFormatted:current];
        
        if (scrubber.maximumValue == 1.0)
        {
            //如果是默认值则设置相应的最大值
            [scrubber setMaximumValue:totalSecond];
        }
        
        if (current)
        {
            [scrubber setValue:current];
        }
    }];
}

/**
 *  重置菜单栏的时间计时
 */
- (void)resetMenuDisplayTimer
{
    [menuDisplayTimer invalidate];
    
    menuDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoHiddenPlayerMenuTime target:self selector:@selector(menuDisplayTimerActionMethod:) userInfo:nil repeats:YES];
}

/**
 *  将秒转换为时分秒格式
 *
 *  @param totalSeconds 总秒数
 *
 *  @return 时间
 */
- (NSString *)timeFormatted:(CGFloat)totalSeconds
{
    NSInteger seconds = (NSInteger)totalSeconds % 60;
    NSInteger minutes = (NSInteger)(totalSeconds / 60) % 60;
    NSInteger hours = (NSInteger)totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 *  通过字符串计算字幕高度
 *
 *  @param string 字符串
 *
 *  @return 高度系数
 */
- (CGFloat)calculateMultiplierOfContentHeightByString:(NSString *)string
{
    VKUtility *utility = [VKUtility sharedInstance];
    
    CGFloat captionHeight = [utility heightForString:string andWidth:playerCaptionView.width];
    
    return captionHeight / playerCaptionScrollBackView.height;
}

/**
 *  初始化用户录入书签内容视图
 */
- (void)initializeBookMarkContentView
{
    if (iOS8orLater)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入书签内容" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"请输入书签内容";
        }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"保存");
            
            UITextField *bookMarkContentTextField = alertController.textFields.firstObject;
            
            NSString *bookmarkContentString = bookMarkContentTextField.text;
            
            [bookMarkDictionary setObject:bookmarkContentString forKey:kBookMarkUserContent];
            
            NSLog(@"%@",bookMarkDictionary);
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"取消");
        }];
        
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入书签内容" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消",nil];
        
        [alertView setTag:kBookMarkAlertViewTag];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        [alertView show];
    }
}

#pragma mark -
#pragma mark - Private Caption Methods

/**
 *  重写BottomCaptionTimer的初始化方法
 *
 *  @param captionTimer 初始化参数
 */
- (void)setBottomCaptionTimer:(id)captionTimer
{
    if (bottomCaptionTimer)
    {
        [dramaPlayer removeTimeObserver:bottomCaptionTimer];
    }
    
    bottomCaptionTimer = captionTimer;
}

/**
 *  清空字幕视图内容
 *
 *  @param captionView 字幕视图
 */
- (void)clearCaptionView:(DTAttributedLabel *)captionView
{
    [captionView setAttributedString:[[NSAttributedString alloc] initWithHTMLData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:nil
                                                                 documentAttributes:NULL]];
}

/**
 *  加载字幕到播放器下方
 *
 *  @param caption 字幕
 */
- (void)setCaptionToBottom:(id<VKVideoPlayerCaptionProtocol>)caption
{
    [self setCaptionToBottom:caption playerView:playerContainerView];
}

/**
 *  加载字幕到播放器下方
 *
 *  @param caption             字幕
 *  @param playerContainerView 播放器视图
 */
- (void)setCaptionToBottom:(id<VKVideoPlayerCaptionProtocol>)caption playerView:(UIView *)playerContainerBackView
{
    if (!playerCaptionView)
    {
        playerCaptionView = [[DTAttributedLabel alloc] init];
        
        [playerCaptionScrollBackContentView addSubview:playerCaptionView];
    }
    
    [self setCaption:caption toCaptionView:playerCaptionView playerView:playerContainerBackView];
}

/**
 *  加载字幕内容到DTAttributedLaebl上
 *
 *  @param caption                 字幕对象
 *  @param captionView             字幕视图 DTAttributeLabel
 *  @param playerContainerBackView 播放器视图
 */
- (void)setCaption:(id<VKVideoPlayerCaptionProtocol>)caption toCaptionView:(DTAttributedLabel *)captionView playerView:(UIView *)playerContainerBackView
{
    if (!caption.boundryTimes.count)
    {
        captionBottomProtocol = nil;
        bottomCaptionTimer = nil;
        
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    //AVPlayer的addBoundaryTimeObservereForTimes方法调用之后,以下方法会在播放器播放过程中每秒调用一次
    id captionTimer = [dramaPlayer addBoundaryTimeObserverForTimes:caption.boundryTimes queue:NULL usingBlock:^{
        [weakSelf updateCaptionView:captionView caption:caption playerView:playerContainerBackView];
    }];
    
    captionBottomProtocol = caption;
    bottomCaptionTimer = captionTimer;
    
    [self updateCaptionView:captionView caption:caption playerView:playerContainerBackView];
}

/**
 *  更新字幕视图
 *
 *  @param captionView         字幕视图
 *  @param caption             字幕
 *  @param playerContainerView 播放器视图
 */
- (void)updateCaptionView:(DTAttributedLabel *)captionView caption:(id<VKVideoPlayerCaptionProtocol>)caption playerView:(UIView *)playerContainerView
{
    //获取当前播放器的播放时间
    CGFloat timeInSeconds = CMTimeGetSeconds([dramaPlayer currentTime]);
    
    //转换时间格式
    CGFloat timeInMilliseconds = (timeInSeconds * 1000) > 0 ? (timeInSeconds * 1000):0;
    
    //由当前时间获取字幕对象中的当前时间字幕内容
    NSString *captionContent = [caption contentAtTime:timeInMilliseconds withLanguageType:languageType];
    
    //由字符串高度计算当前方向下字幕高度系数
    CGFloat multiplier = [self calculateMultiplierOfContentHeightByString:captionContent];
    
    //移除现有高度约束
    [playerCaptionContentConstraint autoRemove];
    
    //增加新的约束
    playerCaptionContentConstraint = [playerCaptionScrollBackContentView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:playerCaptionScrollBackView withMultiplier:multiplier];
    
    //设置当前字幕
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[self captionStyleSheet:@"#FFF"] forKey:DTDefaultStyleSheet];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:[captionContent dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:NULL];
    
    captionView.attributedString = string;
    captionView.isAccessibilityElement = YES;
    captionView.layoutFrameHeightIsConstrainedByBounds = NO;
    captionView.accessibilityLabel = [captionContent stripHtml];
}

/**
 *  获取字幕样式
 *
 *  @param color 颜色值
 *
 *  @return 样式
 */
- (DTCSSStylesheet *)captionStyleSheet:(NSString*)color
{
    float fontSize = 1.0f;
    float shadowSize = 1.0f;
    
    DTCSSStylesheet* stylesheet = [[DTCSSStylesheet alloc] initWithStyleBlock:[NSString stringWithFormat:@"body{\
                                                                               text-align: center;\
                                                                               font-size: %fem;\
                                                                               font-family: Helvetica Neue;\
                                                                               font-weight: bold;\
                                                                               color: %@;\
                                                                               text-shadow: -%fpx -%fpx %fpx #000, %fpx -%fpx %fpx #000, -%fpx %fpx %fpx #000, %fpx %fpx %fpx #000;\
                                                                               vertical-align: bottom;\
                                                                               }", fontSize, color, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize, shadowSize]];
    
    return stylesheet;
}

#pragma mark -
#pragma mark - IBAction Methods

/**
 *  播放暂停按钮点击响应
 *
 *  @param sender 触发
 */
- (IBAction)playOrPauseButtonTapped:(id)sender
{
    if (dramaPlayer.rate == 0)
    {
        //此时处于暂停状态
        [sender setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        
        [dramaPlayer play];
    }
    else
    {
        //此时处于播放状态
        [sender setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        
        [dramaPlayer pause];
    }
    
    //重置计时
    [self resetMenuDisplayTimer];
}

/**
 *  书签按钮点击响应
 *
 *  @param sender 触发
 */
- (IBAction)bookMarkButtonTapped:(id)sender
{
    NSLog(@"书签");

    if (!bookMarkContidion)
    {
        //暂停播放器播放
        
        //进入添加书签状态
        bookMarkContidion = YES;
        
        if (!bookMarkDictionary)
        {
            bookMarkDictionary = [[NSMutableDictionary alloc] init];
        }
        
        //添加开始时间
        NSString *beginningTimeString = playTimeLabel.text;
        
        [bookMarkDictionary setObject:beginningTimeString forKey:kBookMarkBeginningTime];
    }
    else
    {
        //添加结束时间
        NSString *endingTimeString = playTimeLabel.text;
        
        [bookMarkDictionary setObject:endingTimeString forKey:kBookMarkEndingTime];
        
        //初始化添加书签提示框
        [self initializeBookMarkContentView];
        
        bookMarkContidion = NO;
    }
    
    //重置计时
    [self resetMenuDisplayTimer];
}

/**
 *  全屏按钮点击响应
 *
 *  @param sender 触发
 */
- (IBAction)zoomPlusButtonTapped:(id)sender
{
    NSLog(@"全屏");
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    
    //重置计时
    [self resetMenuDisplayTimer];
}

/**
 *  缩屏按钮点击响应
 *
 *  @param sender 触发
 */
- (IBAction)zoomAbstructButtonTapped:(id)sender
{
    NSLog(@"缩屏");
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    //重置计时
    [self resetMenuDisplayTimer];
}

/**
 *  后退按钮点击响应
 *
 *  @param sender 触发
 */
- (IBAction)playerBackButtonTapped:(id)sender
{
    NSLog(@"后退");
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    //重置计时
    [self resetMenuDisplayTimer];
}

/**
 *  切换语言按钮点击响应
 *
 *  @param sender 触发
 */
- (IBAction)changeLanguageButtonTapped:(id)sender
{
    NSLog(@"切换语言");
    
}

#pragma mark -
#pragma mark - Private Action Methods

/**
 *  点击后退导航菜单按钮
 *
 *  @param sender 触发
 */
- (void)didClickBackNavigationBarButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  点击切换语言导航菜单按钮
 *
 *  @param sender 触发
 */
- (void)didClickChangeLanguageNavigationBarButton:(id)sender
{
    
}

/**
 *  点击视频视图
 *
 *  @param sender
 */
- (void)didClickPlayerContainerView:(id)sender
{
    if (bottomAndTopMenuHidden)
    {
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:0.7f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        bottomMenuContainerView.frame = CGRectMake(0, playerCaptionScrollBackView.bottom - bottomMenuContainerView.height,  bottomMenuContainerView.width,  bottomMenuContainerView.height);
        
        topMenuContainerView.frame = CGRectMake(0, 0, topMenuContainerView.width, topMenuContainerView.height);
        
        //菜单显示
        bottomAndTopMenuHidden = NO;
        
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:0.7f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        bottomMenuContainerView.frame = CGRectMake(0, playerCaptionScrollBackView.bottom, bottomMenuContainerView.width,  bottomMenuContainerView.height);
        
        topMenuContainerView.frame = CGRectMake(0, - topMenuContainerView.height, topMenuContainerView.width, topMenuContainerView.height);
        
        //菜单隐藏
        bottomAndTopMenuHidden = YES;
        
        [UIView commitAnimations];
    }
    
    //重置计时
    [self resetMenuDisplayTimer];
}

/**
 *  菜单时间相应函数
 *
 *  @param sender
 */
- (void)menuDisplayTimerActionMethod:(id)sender
{
    if (!bottomAndTopMenuHidden)
    {
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        bottomMenuContainerView.frame = CGRectMake(0, bottomMenuContainerView.bottom, bottomMenuContainerView.width,  bottomMenuContainerView.height);
        
        topMenuContainerView.frame = CGRectMake(0, - topMenuContainerView.height, topMenuContainerView.width, topMenuContainerView.height);
        
        bottomAndTopMenuHidden = YES;
        
        [UIView commitAnimations];
    }
}

/**
 *  跳到指定的事件播放&更新播放时间标签
 */
- (void)seekToSpecifiedTimeAndUpdateTimeLabels
{
    NSLog(@"拉动到了多少：%f",progressSlider.value);
    
    [dramaPlayer pause];
    
    __weak __typeof(self) weakSelf = self;
    
    [dramaPlayer seekToTime:CMTimeMake(progressSlider.value, 1) completionHandler:^(BOOL finished) {
        
        [weakSelf updateCaptionView:playerCaptionView caption:captionBottomProtocol playerView:playerCaptionView];
        
        playTimeLabel.text = [weakSelf timeFormatted:progressSlider.value];
        
        [dramaPlayer play];
    }];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification
{
    NSLog(@"视频播放完成.");
    
    //播放完成,需要重新设置当前视频播放器状态
    [playOrPauseButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    
    [dramaPlayer seekToTime:CMTimeMake(0.0f, 1) completionHandler:^(BOOL finished) {
        [progressSlider setValue:0.0f];
    }];
}

#pragma mark -
#pragma mark - Private Notification Methods

/**
 *  添加播放器监听
 */
-(void)addNotification
{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:dramaPlayer.currentItem];
}

/**
 *  移除播放器监听
 */
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  给AVPlayerItem添加监听
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem
{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

/**
 *  给AVPlayerItem移除监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

#pragma mark -
#pragma mark - NSNotification Delegate

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = object;
    
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        
        if(status == AVPlayerStatusReadyToPlay)
        {
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *array = playerItem.loadedTimeRanges;
        
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

#pragma mark -
#pragma mark - UIViewController Rotation Notification

/**
 *  旋转首先调用
 *
 *  @param toInterfaceOrientation 旋转到的方向
 *  @param duration               旋转时间
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //屏幕旋转开始
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (iOS8orLater)
    {
        //iOS8以后的版本
        switch (toInterfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
            {
                //显示导航栏
                self.navigationController.navigationBar.hidden = NO;
                
                //显示状态栏
                statusBarHiddenCondition = NO;
                [self setNeedsStatusBarAppearanceUpdate];
                
                //隐藏顶部菜单
                self.topMenuContainerView.hidden = YES;
                
                //播放器Layer的位置以及尺寸调整
                dramaPlayerLayer.frame = CGRectMake(0, 0, ScreenHeight, playerContainerViewHeight);
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            {
                //隐藏导航栏
                self.navigationController.navigationBar.hidden = YES;
                
                //隐藏状态栏
                statusBarHiddenCondition = YES;
                [self setNeedsStatusBarAppearanceUpdate];
                
                //显示顶部菜单
                self.topMenuContainerView.hidden = NO;
                
                //播放器Layer的位置以及尺寸调整
                dramaPlayerLayer.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
            {
                //隐藏导航栏
                self.navigationController.navigationBar.hidden = YES;
                
                //隐藏状态栏
                statusBarHiddenCondition = YES;
                [self setNeedsStatusBarAppearanceUpdate];
                
                //显示顶部菜单
                self.topMenuContainerView.hidden = NO;
                
                //播放器Layer的位置以及尺寸调整
                dramaPlayerLayer.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
            }
                break;
            default:
                break;
        }
    }
    else
    {
        //iOS8以前的版本
        switch (toInterfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
            {
                //垂直
                self.navigationController.navigationBar.hidden = NO;
                self.topMenuContainerView.hidden = YES;
                
                //显示状态栏
                statusBarHiddenCondition = NO;
                [self setNeedsStatusBarAppearanceUpdate];
                
                //设置屏幕旋转标记
                rotationToPortraintMark = YES;
                
                //修改视图控制器背景视图的顶部约束
                [backgroundViewTopConstraint autoRemove];
                
                backgroundViewTopConstraint = [backgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:66];
                
                //修改播放器视图高度约束
                [playerContainerViewHeightConstraint autoRemove];
                
                playerContainerViewHeightConstraint = [playerContainerView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:backgroundView withMultiplier:0.4];
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            {
                //左横屏
                self.navigationController.navigationBar.hidden = YES;
                self.topMenuContainerView.hidden = NO;
                
                //隐藏状态栏
                statusBarHiddenCondition = YES;
                [self setNeedsStatusBarAppearanceUpdate];
                
                //播放器Layer的位置以及尺寸调整
                dramaPlayerLayer.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
                
                //修改视图控制器背景视图的顶部约束
                [backgroundViewTopConstraint autoRemove];
                
                backgroundViewTopConstraint = [backgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
                
                //修改播放器视图高度约束
                [playerContainerViewHeightConstraint autoRemove];
                
                playerContainerViewHeightConstraint = [playerContainerView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:backgroundView withMultiplier:1.0];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
            {
                //右横屏
                self.navigationController.navigationBar.hidden = YES;
                self.topMenuContainerView.hidden = NO;
                
                //隐藏状态栏
                statusBarHiddenCondition = YES;
                [self setNeedsStatusBarAppearanceUpdate];
                
                //播放器Layer的位置以及尺寸调整
                dramaPlayerLayer.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
                
                //修改视图控制器背景视图的顶部约束
                [backgroundViewTopConstraint autoRemove];
                
                backgroundViewTopConstraint = [backgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
                
                //修改播放器视图高度约束
                [playerContainerViewHeightConstraint autoRemove];
                
                playerContainerViewHeightConstraint = [playerContainerView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:backgroundView withMultiplier:1.0];
            }
                break;
            default:
                break;
        }
    }
}

/**
 *  开始旋转之后调用
 *
 *  @param toInterfaceOrientation 旋转到的方向
 *  @param duration               旋转时间
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //屏幕旋转进行中
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

/**
 *  完成旋转之后调用
 *
 *  @param fromInterfaceOrientation 之前的方向
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (rotationToPortraintMark)
    {
        //只针对iOS7版本屏幕旋转对播放器视图进行变换
        dramaPlayerLayer.frame = playerContainerView.frame;
        
        rotationToPortraintMark = NO;
    }
    
    //屏幕旋转完成,重新更新字幕视图
    [playerCaptionView relayoutText];
}

#pragma mark -
#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Infomation";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"DramaDetail";
    
    return cell;
}

#pragma mark -
#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了第%ld行",(long)indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kBookMarkAlertViewTag)
    {
        if (buttonIndex == 0)
        {
            //保存
            NSString *bookMarkContentString = [alertView textFieldAtIndex:0].text;
            
            [bookMarkDictionary setObject:bookMarkContentString forKey:kBookMarkUserContent];
            
            NSLog(@"%@",bookMarkDictionary);
        }
    }
}

#pragma mark -
#pragma mark - UIGestureRecognizer Delegate

/**
 *  筛选是否收到点击事件
 *
 *  @param gestureRecognizer
 *  @param touch
 *
 *  @return 是否
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[VKScrubber class]] || [touch.view isKindOfClass:[UIButton class]] || touch.view.tag == kTopPlayerMenuViewTag || touch.view.tag == kBottomPlayerMenuViewTag)
    {
        //防止触摸到slider而将菜单栏消失
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark - VKScrubber Delegate

/**
 *  进度指示器开始
 */
- (void)scrubbingBegin
{
    NSLog(@"进度开始");
}

/**
 *  进度指示器结束
 */
- (void)scrubbingEnd
{
    NSLog(@"进度结束");
}

@end
