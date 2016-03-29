//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

//#ifndef VKVideoPlayer_VKVideoPlayerConfig_h
//#define VKVideoPlayer_VKVideoPlayerConfig_h

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+VKFoundation.h"
#import <AVFoundation/AVFoundation.h>
#import "VKUtility.h"

#define kVKVideoPlayerDurationDidLoadNotification @"VKVideoPlayerDurationDidLoadNotification"
#define kVKVideoPlayerItemReadyToPlay @"VKVideoPlayerItemReadyToPlay"
#define kVKVideoPlayerScrubberValueUpdatedNotification @"VKVideoPlayerScrubberValueUpdatedNotification"
#define kVKVideoPlayerShowVideoInfoNotification @"VKVideoPlayerShowVideoInfoNotification"
#define kVKVideoPlayerOrientationDidChange @"VKVideoPlayerOrientationDidChange"
#define kVKVideoPlayerUpdateVideoTrack @"VKVideoPlayerUpdateVideoTrack"

#define kVKVideoPlayerPlaybackBufferEmpty @"VKVideoPlayerPlaybackBufferEmpty"
#define kVKVideoPlayerPlaybackLikelyToKeepUp @"VKVideoPlayerPlaybackLikelyToKeepUp"

#define kVKVideoPlayerStateChanged @"VKVideoPlayerStateChanged"
#define kVKVideoPlayerDismiss @"VKVideoPlayerDismiss"
#define kVKVideoPlayerShare @"VKVideoPlayerShare"

//======================VKFoundationFramework=======================//

#define NILIFNULL(foo) ((foo == [NSNull null]) ? nil : foo)
#define NULLIFNIL(foo) ((foo == nil) ? [NSNull null] : foo)
#define EMPTYIFNIL(foo) ((foo == nil) ? @"" : foo)

#define CGRectSetOrigin( r, origin ) CGRectMake( origin.x, origin.y, r.size.width, r.size.height )

typedef void (^VoidBlock)();



