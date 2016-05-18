//
//  IntroViewController.m
//  renrenfenqi
//
//  Created by coco on 15-3-17.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "IntroViewController.h"
#import "AppUtils.h"

#define NUMBER_OF_PAGES 3
#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))

#define makeImageHeight(width) (width * 35.0) / 32.0
#define makeWordHeight(width) (width * 57.0) / 320.0

@interface IntroViewController ()
{
    float _viewWidth;
    float _viewHeight;
    
    UIPageControl *_pageControl;
}

//@property (strong, nonatomic) UIImageView *page1img;
@property (strong, nonatomic) UIImageView *page2img;
@property (strong, nonatomic) UIImageView *page3img;
@property (strong, nonatomic) UIImageView *page4img;
//@property (strong, nonatomic) UIImageView *page1word;
@property (strong, nonatomic) UIImageView *page2word;
@property (strong, nonatomic) UIImageView *page3word;
@property (strong, nonatomic) UIImageView *page4word;
@property (strong, nonatomic) UIButton *page4btn;

@end

@implementation IntroViewController

- (id)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO; //阻止scrollView纵向滚动
    
    self.scrollView.contentSize = CGSizeMake(NUMBER_OF_PAGES * CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame));
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.accessibilityLabel = @"RRJazzHands";
    self.scrollView.accessibilityIdentifier = @"RRJazzHands";
    self.scrollView.delegate = self;
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    [self placeViews];
    [self configureAnimation];
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (void)placeViews
{
    // put a unicorn in the middle of page two, hidden
//    self.page1img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage1_img.png"]];
//    self.page1img.frame = CGRectMake(0.0, 0.0, _viewWidth, makeImageHeight(_viewWidth));
//    self.page1img.center = self.view.center;
//    self.page1img.frame = CGRectOffset(
//                                       self.page1img.frame,
//                                       timeForPage(1),
//                                       -50.0
//                                       );
//    self.page1img.alpha = 1.0f;
//    [self.scrollView addSubview:self.page1img];
    
    self.page2img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage2_img.png"]];
    self.page2img.frame = CGRectMake(0.0, 0.0, _viewWidth, makeImageHeight(_viewWidth));
    self.page2img.center = self.view.center;
    self.page2img.frame = CGRectOffset(
                                       self.page2img.frame,
                                       timeForPage(1),
                                       -50.0
                                       );
    self.page2img.alpha = 1.0f;
    [self.scrollView addSubview:self.page2img];
    
    self.page3img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage3_img.png"]];
    self.page3img.frame = CGRectMake(0.0, 0.0, _viewWidth, makeImageHeight(_viewWidth));
    self.page3img.center = self.view.center;
    self.page3img.frame = CGRectOffset(
                                       self.page3img.frame,
                                       timeForPage(2),
                                       -50.0
                                       );
    self.page3img.alpha = 1.0f;
    [self.scrollView addSubview:self.page3img];
    
    self.page4img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage4_img.png"]];
    self.page4img.frame = CGRectMake(0.0, 0.0, _viewWidth, makeImageHeight(_viewWidth));
    self.page4img.center = self.view.center;
    self.page4img.frame = CGRectOffset(
                                       self.page4img.frame,
                                       timeForPage(3),
                                       -50.0
                                       );
    self.page4img.alpha = 1.0f;
    [self.scrollView addSubview:self.page4img];
    
    
//    self.page1word = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage1_word.png"]];
//    self.page1word.frame = CGRectMake(0.0, 0.0, _viewWidth, makeWordHeight(_viewWidth));
//    self.page1word.center = self.view.center;
//    self.page1word.frame = CGRectOffset(
//                                        self.page1word.frame,
//                                        timeForPage(1),
//                                        _viewHeight * 0.3
//                                        );
//    self.page1word.alpha = 1.0f;
//    [self.scrollView addSubview:self.page1word];
    
    self.page2word = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage2_word.png"]];
    self.page2word.frame = CGRectMake(0.0, 0.0, _viewWidth, makeWordHeight(_viewWidth));
    self.page2word.center = self.view.center;
    self.page2word.frame = CGRectOffset(
                                        self.page2word.frame,
                                        timeForPage(1),
                                        _viewHeight * 0.3
                                        );
        self.page2word.alpha = 1.0f;
    [self.scrollView addSubview:self.page2word];
    
    self.page3word = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage3_word.png"]];
    self.page3word.frame = CGRectMake(0.0, 0.0, _viewWidth, makeWordHeight(_viewWidth));
    self.page3word.center = self.view.center;
    self.page3word.frame = CGRectOffset(
                                        self.page3word.frame,
                                        timeForPage(2),
                                        _viewHeight * 0.3
                                        );
    self.page3word.alpha = 1.0f;
    [self.scrollView addSubview:self.page3word];
    
    self.page4word = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intropage4_word.png"]];
    self.page4word.frame = CGRectMake(0.0, 0.0, _viewWidth, makeWordHeight(_viewWidth));
    self.page4word.center = self.view.center;
    self.page4word.frame = CGRectOffset(
                                        self.page4word.frame,
                                        timeForPage(3),
                                        _viewHeight * 0.3
                                        );
    self.page4word.alpha = 1.0f;
    [self.scrollView addSubview:self.page4word];
    
    self.page4btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.page4btn.frame = CGRectMake(0.0, 0.0, 187.5, 40.0);
    [self.page4btn setImage:[UIImage imageNamed:@"intropage4_btn.png"] forState:UIControlStateNormal];
    self.page4btn.center = self.view.center;
    self.page4btn.frame = CGRectOffset(
                                        self.page4btn.frame,
                                        timeForPage(3),
                                        _viewHeight * 0.18
                                        );
    self.page4btn.alpha = 1.0f;
    [self.scrollView addSubview:self.page4btn];
    
    [self.page4btn addTarget:self action:@selector(doStart:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.frame = CGRectMake(0, 0, 150, 50);
    _pageControl.center = self.view.center;
    _pageControl.frame = CGRectOffset(
                                       _pageControl.frame,
                                       0.0,
                                       _viewHeight * 0.45
                                       );
    _pageControl.numberOfPages = NUMBER_OF_PAGES; // 一共显示多少个圆点（多少页）
    // 设置非选中页的圆点颜色
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    // 设置选中页的圆点颜色
    _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    
    // 禁止默认的点击功能
    _pageControl.enabled = NO;
    
    [self.view addSubview:_pageControl];
}

- (void)doStart:(id)sender
{
    self.scrollView.delegate = nil;
    [AppUtils goBack:self];
}

- (void)configureAnimation
{
    // Rotate a full circle from page 1 to 2
//    IFTTTFrameAnimation *word1MovesAnimation = [IFTTTFrameAnimation animationWithView:self.page1word];
//    [self.animator addAnimation:word1MovesAnimation];
//    [word1MovesAnimation addKeyFrames:@[
//                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:self.page1word.frame],
//                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:    CGRectOffset(self.page1word.frame, -400, 0.0)],
//                                        ]];
    
    IFTTTFrameAnimation *word2MovesAnimation = [IFTTTFrameAnimation animationWithView:self.page2word];
    [self.animator addAnimation:word2MovesAnimation];
    [word2MovesAnimation addKeyFrames:@[
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:self.page2word.frame],
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:    CGRectOffset(self.page2word.frame, -400, 0.0)],
                                        ]];
    
    IFTTTFrameAnimation *word3MovesAnimation = [IFTTTFrameAnimation animationWithView:self.page3word];
    [self.animator addAnimation:word3MovesAnimation];
    [word3MovesAnimation addKeyFrames:@[
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:    CGRectOffset(self.page3word.frame, 400, 0.0)],
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:self.page3word.frame],
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:    CGRectOffset(self.page2word.frame, -400, 0.0)],
                                        ]];
    
    IFTTTFrameAnimation *word4MovesAnimation = [IFTTTFrameAnimation animationWithView:self.page4word];
    [self.animator addAnimation:word4MovesAnimation];
    [word4MovesAnimation addKeyFrames:@[
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:    CGRectOffset(self.page4word.frame, 400, 0.0)],
                                        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:self.page4word.frame],
                                        ]];
    
    
    // Rotate a full circle from page 3 to 4
    IFTTTAngleAnimation *btnRotationAnimation = [IFTTTAngleAnimation animationWithView:self.page4btn];
    [self.animator addAnimation:btnRotationAnimation];
    [btnRotationAnimation addKeyFrames:@[
                                              [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAngle:0.0f],
                                              [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAngle:(CGFloat)(2 * M_PI)],
                                              ]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if ( aScrollView.contentOffset.x >= timeForPage(4) ) {
        _pageControl.currentPage = 3;
    }
    else if ( aScrollView.contentOffset.x >= timeForPage(3) ) {
        _pageControl.currentPage = 2;
    }
    else if ( aScrollView.contentOffset.x >= timeForPage(2) ) {
        _pageControl.currentPage = 1;
    }
    else if ( aScrollView.contentOffset.x >= timeForPage(1) ) {
        _pageControl.currentPage = 0;
    }
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
