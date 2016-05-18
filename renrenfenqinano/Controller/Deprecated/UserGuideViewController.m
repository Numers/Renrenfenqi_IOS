//
//  UserGuideViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-12.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "UserGuideViewController.h"
#import "AppUtils.h"
#import "HMSegmentedControl.h"

@interface UserGuideViewController ()
{
    NSArray *_bgColorArr;
    NSArray *_imgNameArr;
    
    UIImageView *_imgTitle;
    
    SGFocusImageFrame *_imageFrame;
}

@end

@implementation UserGuideViewController

- (void)showGuide
{
    NSMutableArray *imagesArr = [NSMutableArray array];
    int i = 0;
    for (id item in _imgNameArr) {
        SGFocusImageItem *item1 = [[SGFocusImageItem alloc] initWithTitle:@"title1" image:[UIImage imageNamed:item] tag:i];
        [imagesArr addObject:item1];
        i++;
    }
    
    _imageFrame = [[SGFocusImageFrame alloc] initWithFrame:self.imgGuide.frame
                                                                    delegate:self
                                                       focusImageItemsArrray:imagesArr];
    _imageFrame.autoScrolling = NO;
    [self.view addSubview:_imageFrame];
    
    float theWidth = self.view.bounds.size.width;
    float theHeight = self.view.bounds.size.height;
    _imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake((theWidth - 242) * 0.5, theHeight - 70.0, 242, 56)];
    [_imgTitle setImage:[UIImage imageNamed:@"aimage.png"]];
    [self.view addSubview:_imgTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _bgColorArr = @[USER_GUIDE_COLOR1, USER_GUIDE_COLOR2, USER_GUIDE_COLOR3, USER_GUIDE_COLOR4];
    _bgColorArr = @[[UIColor whiteColor], [UIColor whiteColor], [UIColor whiteColor], [UIColor whiteColor]];
    _imgNameArr = @[@"bootpage_body_no1_n", @"bootpage_body_no2_n", @"bootpage_body_no3_n", @"bootpage_body_no4_n"];//TODO
    [self.bgView setBackgroundColor:[UIColor whiteColor]];
    self.btnStart.hidden = YES;
    
    [self performSelector:@selector(showGuide) withObject:nil afterDelay:0.3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - delegate
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    if (item.tag == 1004) {
        [imageFrame removeFromSuperview];
    }
}

- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectPage:(int)curPage
{
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.bgView setBackgroundColor:[_bgColorArr objectAtIndex:curPage]];
                         if (curPage == 3) {
                             self.btnStart.hidden = NO;
                         }
                         else
                         {
                             self.btnStart.hidden = YES;
                         }
                     }
                     completion:^(BOOL finished){
                         // do whatever post processing you want (such as resetting what is "current" and what is "next")
                     }];
}

- (IBAction)doStartAction:(id)sender {
    [AppUtils goBack:self];
}
@end
