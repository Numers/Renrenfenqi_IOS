//
//  ShareManage.m
//  renrenfenqi
//
//  Created by DY on 15/1/12.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "ShareManage.h"
#import "WXApi.h"
#import "CommonTools.h"

@implementation ShareManage

+ (ShareManage *) GetInstance {
    
    static ShareManage *instance = nil;
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+ (void)shareVideoToWeixinPlatform:(int)scene themeUrl:(NSString*)themeUrl thumbnail:(UIImage*)thumbnail title:(NSString*)title descript:(NSString*)descrip {
    
    NSData *thumbData = UIImageJPEGRepresentation(thumbnail,1);
    if ( [thumbData length]>=32*1024) {
        NSLog(@"分享缩略图大于32k");
        thumbnail = [CommonTools scaleToSize:thumbnail size:CGSizeMake(150, 150)];
    }
    
    if (![WXApi isWXAppInstalled]) {
        [AppUtils showAlertViewWithTitle:@"提示" message:@"你的iPhone 上还没有安装微信，无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。"];
        return;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        [AppUtils showAlertViewWithTitle:@"提示" message:@"你当前的微信版本过低，无法支持此功能，请更新微信至最新版本"];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    [message setThumbImage:thumbnail];
    message.description = descrip;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = themeUrl;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

@end
