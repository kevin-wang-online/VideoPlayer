//
//  MediaPlayerViewController.h
//  SizeClass
//
//  Created by Kevin on 15/3/11.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VKAndDTFileConstants.h"

@interface DramaMediaPlayerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,VKScrubberDelegate>

//==============================播放器属性参数=========================//

//选择的语言类型,默认为英文
@property (assign, nonatomic) CaptionLanuguageType languageType;

//视频的网络路径
@property (strong, nonatomic) NSString *dramaUrl;

//播放器Layer
@property (strong, nonatomic) AVPlayer *dramaPlayer;

//播放器Layer容器底层
@property (strong, nonatomic) AVPlayerLayer *dramaPlayerLayer;


//==============================播放器界面元素输出口=========================//

//播放器Layer的UIView容器
@property (strong, nonatomic) IBOutlet UIView *playerContainerView;

//播放器菜单的UIView容器
@property (strong, nonatomic) IBOutlet UIView *bottomMenuContainerView;

//播放器顶部菜单UIview容器
@property (strong, nonatomic) IBOutlet UIView *topMenuContainerView;

//播放器字幕ScrolView
@property (strong, nonatomic) IBOutlet UIScrollView *playerCaptionScrollBackView;

//播放器字幕ScrollView的ContentView
@property (strong, nonatomic) IBOutlet UIView *playerCaptionScrollBackContentView;

//播放器字幕ScrollView的ContentView的字幕视图
@property (strong, nonatomic) IBOutlet DTAttributedLabel *playerCaptionView;

//播放/暂停按钮
@property (strong, nonatomic) IBOutlet UIButton *playOrPauseButton;

//书签按钮
@property (strong, nonatomic) IBOutlet UIButton *bookMarkButton;

//播放时间标签
@property (strong, nonatomic) IBOutlet UILabel *playTimeLabel;

//进度条背景视图
@property (strong, nonatomic) IBOutlet UIView *progressBackView;

//进度调节指示条
@property (strong, nonatomic) IBOutlet VKScrubber *progressSlider;

//全屏播放按钮
@property (strong, nonatomic) IBOutlet UIButton *zoomScreenButton;

//话剧详情表视图
@property (strong, nonatomic) IBOutlet UITableView *dramaDetailTableView;

//背景视图
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

//==============================视图约束输出口变量=========================//

//视图控制器背景视图的顶部约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewTopConstraint;

//播放器视图的高度约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerContainerViewHeightConstraint;

//竖屏播放器字幕ScrollView的ContentView的高度约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerCaptionContentConstraint;

//==============================字幕成员变量=========================//

//字幕协议对象
@property (nonatomic, strong) id<VKVideoPlayerCaptionProtocol> captionBottomProtocol;

//字幕时间计时对象
@property (nonatomic, strong) id bottomCaptionTimer;

//==============================播放器按钮响应事件=========================//

//播放暂停按钮点击
- (IBAction)playOrPauseButtonTapped:(id)sender;

//书签按钮点击
- (IBAction)bookMarkButtonTapped:(id)sender;

//全屏按钮点击
- (IBAction)zoomPlusButtonTapped:(id)sender;

//缩屏按钮点击
- (IBAction)zoomAbstructButtonTapped:(id)sender;

//后退按钮点击
- (IBAction)playerBackButtonTapped:(id)sender;

//切换语言按钮点击
- (IBAction)changeLanguageButtonTapped:(id)sender;

@end
